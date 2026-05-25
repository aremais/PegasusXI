-----------------------------------
-- HTBF Reward Handler
-----------------------------------
-- Manages the two-layer reward system for High-Tier Mission Battlefields.
--
-- DIRECT DROPS (personal, every player):
--   Rem's Tale chapters and R/E/M upgrade materials are given directly to
--   each participating player's inventory on win, scaled by difficulty.
--
-- TREASURE POOL DROPS (shared):
--   Unique weapons, armor, and rare materials enter the battlefield's
--   treasure pool. Any party member may claim these.
--
-- DIFFICULTY (stored in battlefield localVar 'HTBF_Difficulty'):
--   0 = Very Easy | 1 = Easy | 2 = Normal | 3 = Difficult | 4 = Very Difficult
--   Defaults to Normal (2) if unset.
--
-- UNLOCK (charvar per player per fight):
--   'HTBF_Win_<battlefieldId>'  >=1 means Difficult/Very Difficult available.
-----------------------------------

xi      = xi or {}
xi.htbf = xi.htbf or {}

xi.htbf.difficulty =
{
    VERY_EASY      = 0,
    EASY           = 1,
    NORMAL         = 2,
    DIFFICULT      = 3,
    VERY_DIFFICULT = 4,
}

-- [diffIndex + 1] = { chapters, upgrades }
-- Based on retail reward table (all fights except ★Divine Might)
local diffRewards =
{
    { chapters = 1, upgrades = 0 }, -- Very Easy
    { chapters = 1, upgrades = 1 }, -- Easy
    { chapters = 2, upgrades = 1 }, -- Normal
    { chapters = 3, upgrades = 2 }, -- Difficult
    { chapters = 4, upgrades = 2 }, -- Very Difficult
}

-- The three R/E/M upgrade materials awarded randomly to each player
local upgradePool =
{
    xi.item.PLUTON,
    xi.item.RIFTBORN_BOULDER,
    xi.item.BEITETSU,
}

-----------------------------------
-- Internal helpers
-----------------------------------

local function recordWin(battlefield, battlefieldId)
    local players = battlefield:getPlayers()

    for _, player in ipairs(players) do
        player:setCharVar('HTBF_Win_' .. battlefieldId, 1)
    end
end

local function giveDirectDrops(battlefield, chapterItemId)
    local diffIndex = battlefield:getLocalVar('HTBF_Difficulty')
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
--   battlefieldId : xi.battlefield.id constant for this fight
--   chapterItemId : xi.item.REMS_TALE_CH_X for this fight
--   mob           : the mob reference passed into allDeath (loot anchor)
--   lootTable     : content.loot table (may be nil for fights with no
--                   treasure pool drops such as Alexander/Odin/Cait Sith)
-- }
function xi.htbf.onWin(battlefield, params)
    recordWin(battlefield, params.battlefieldId)
    giveDirectDrops(battlefield, params.chapterItemId)
    rollTreasurePool(battlefield, params.lootTable, params.mob)
    battlefield:setStatus(xi.battlefield.status.WON)
end

-- Returns true if this player has ever won this fight (D/VD unlocked).
function xi.htbf.hardModeUnlocked(player, battlefieldId)
    return player:getCharVar('HTBF_Win_' .. battlefieldId) >= 1
end

-- Returns true if the player holds the required phantom gem (may register).
function xi.htbf.canRegister(player, phantomGemKi)
    return player:hasKeyItem(phantomGemKi)
end

-----------------------------------
-- Difficulty selection (shown to the initiator on battlefield entry)
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

-- Show the difficulty selection menu to the initiator immediately on
-- entering the battlefield.  The menu sets HTBF_Difficulty on the
-- battlefield object and broadcasts the choice to all players.
-- A default of Normal is applied before showing the menu so that
-- closing the dialog without picking still yields a valid difficulty.
local function showDifficultyMenu(player, battlefield)
    -- Default to Normal in case the player dismisses the menu
    battlefield:setLocalVar('HTBF_Difficulty', xi.htbf.difficulty.NORMAL)

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
                battlefield:setLocalVar('HTBF_Difficulty', value)

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
-- HTBFBattlefield class
-----------------------------------
-- Extends BattlefieldQuest.  All HTBF fight scripts should use
-- HTBFBattlefield:new() instead of BattlefieldQuest:new() so that
-- the difficulty selection menu is shown automatically on entry.

-- HTBFBattlefield extends Battlefield (NOT BattlefieldQuest).
-- BattlefieldQuest:checkRequirements adds a mandatory quest-status check that
-- always fails for HTBF because these fights have no associated quest — entry
-- is gated only by phantom gem key items, which Battlefield:checkRequirements
-- already handles via requiredKeyItems.
HTBFBattlefield         = setmetatable({}, { __index = Battlefield })
HTBFBattlefield.__index = HTBFBattlefield

function HTBFBattlefield:new(data)
    local obj = Battlefield:new(data)
    setmetatable(obj, self)
    return obj
end

-- Called for every player who enters the battlefield.
-- Only the initiator sees the difficulty menu; other members receive
-- the announcement once the initiator makes their selection.
function HTBFBattlefield:battlefieldEntry(player, battlefield)
    local initiatorId = select(1, battlefield:getInitiator())

    if player:getID() == initiatorId then
        showDifficultyMenu(player, battlefield)
    end
end
