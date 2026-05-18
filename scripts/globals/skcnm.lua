-----------------------------------
-- SKCNM Reward Handler
-----------------------------------
-- Sacred Kindred Crest NM (Macrocosmic Orb) reward system.
-- Mirrors the HTBF two-layer reward system but for orb-based entry.
--
-- DIRECT DROPS (personal, every player):
--   Rem's Tale chapters and R/E/M upgrade materials scaled by difficulty.
--
-- TREASURE POOL DROPS (shared):
--   Gil, crafting materials, scrolls, and rocks enter the treasure pool.
--
-- DIFFICULTY (stored in battlefield localVar 'SKCNM_Difficulty'):
--   0 = Very Easy | 1 = Easy | 2 = Normal | 3 = Difficult | 4 = Very Difficult
--   Defaults to Normal (2) if unset.
-----------------------------------

xi       = xi or {}
xi.skcnm = xi.skcnm or {}

xi.skcnm.difficulty =
{
    VERY_EASY      = 0,
    EASY           = 1,
    NORMAL         = 2,
    DIFFICULT      = 3,
    VERY_DIFFICULT = 4,
}

-- [diffIndex + 1] = { chapters, upgrades }
local diffRewards =
{
    { chapters = 1, upgrades = 0 }, -- Very Easy
    { chapters = 1, upgrades = 1 }, -- Easy
    { chapters = 2, upgrades = 1 }, -- Normal
    { chapters = 3, upgrades = 2 }, -- Difficult
    { chapters = 4, upgrades = 2 }, -- Very Difficult
}

local upgradePool =
{
    xi.item.PLUTON,
    xi.item.RIFTBORN_BOULDER,
    xi.item.BEITETSU,
}

-----------------------------------
-- Internal helpers
-----------------------------------

local function giveDirectDrops(battlefield, chapterItemId)
    local diffIndex = battlefield:getLocalVar('SKCNM_Difficulty')
    local rewards   = diffRewards[diffIndex + 1] or diffRewards[3] -- default Normal
    local players   = battlefield:getPlayers()

    for _, player in ipairs(players) do
        for _ = 1, rewards.chapters do
            npcUtil.giveItem(player, chapterItemId)
        end

        for _ = 1, rewards.upgrades do
            npcUtil.giveItem(player, upgradePool[math.random(#upgradePool)])
        end
    end
end

local function rollTreasurePool(battlefield, lootTable, mob)
    if not lootTable or not mob then
        return
    end

    local players = battlefield:getPlayers()

    if not players or #players == 0 then
        return
    end

    local firstPlayer = players[1]
    local selected    = utils.selectFromLootGroups(firstPlayer, lootTable)

    for _, entry in ipairs(selected) do
        firstPlayer:addTreasure(entry.itemId, mob)
    end
end

-----------------------------------
-- Public API
-----------------------------------

-- Called from allDeath in each fight script.
--
-- params = {
--   chapterItemId : xi.item.COPY_OF_REMS_TALE_CHAPTER_X for this fight
--   mob           : the mob reference passed into allDeath (loot anchor)
--   lootTable     : content.loot table (treasure pool items)
-- }
function xi.skcnm.onWin(battlefield, params)
    giveDirectDrops(battlefield, params.chapterItemId)
    rollTreasurePool(battlefield, params.lootTable, params.mob)
    battlefield:setStatus(xi.battlefield.status.WON)
end

-----------------------------------
-- Difficulty selection menu
-----------------------------------

local difficultyLabels =
{
    [0] = '★     Very Easy',
    [1] = '★★    Easy',
    [2] = '★★★   Normal',
    [3] = '★★★★  Difficult',
    [4] = '★★★★★ Very Difficult',
}

local difficultyShortNames =
{
    [0] = 'Very Easy',
    [1] = 'Easy',
    [2] = 'Normal',
    [3] = 'Difficult',
    [4] = 'Very Difficult',
}

local function showDifficultyMenu(player, battlefield)
    -- Default to Normal in case the player dismisses without picking
    battlefield:setLocalVar('SKCNM_Difficulty', xi.skcnm.difficulty.NORMAL)

    local menu =
    {
        title   = 'Select Battle Difficulty',
        options = {},
    }

    for value = 0, 4 do
        local label = difficultyLabels[value]

        table.insert(menu.options, {
            label,
            function(_)
                battlefield:setLocalVar('SKCNM_Difficulty', value)

                local chosen  = difficultyShortNames[value]
                local players = battlefield:getPlayers()

                for _, member in ipairs(players) do
                    member:printToPlayer(
                        'Difficulty: ' .. chosen .. '.',
                        xi.msg.channel.NS_SAY
                    )
                end
            end,
        })
    end

    player:customMenu(menu)
end

-----------------------------------
-- SKCNMBattlefield class
-----------------------------------
-- Extends Battlefield directly (orb-based entry, not quest/KI gated).
-- All SKCNM fight scripts use SKCNMBattlefield:new() instead of
-- Battlefield:new() so the difficulty menu is shown automatically on entry.

SKCNMBattlefield         = setmetatable({}, { __index = Battlefield })
SKCNMBattlefield.__index = SKCNMBattlefield

function SKCNMBattlefield:new(data)
    local obj = Battlefield:new(data)
    setmetatable(obj, self)
    return obj
end

-- Only the initiator sees the menu; all members receive the announcement
-- once the initiator selects a difficulty.
function SKCNMBattlefield:battlefieldEntry(player, battlefield)
    local initiatorId = select(1, battlefield:getInitiator())

    if player:getID() == initiatorId then
        showDifficultyMenu(player, battlefield)
    end
end
