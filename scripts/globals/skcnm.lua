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
-- Difficulty scaling
-----------------------------------

-- hp   : percent modifier applied to base MaxHP  (e.g. -45 → 55 % of base)
-- att/def/eva : flat mod values added to the mob stat
local diffScaling =
{
    [0] = { hp = -45, att = -100, def = -100, eva =  -50 }, -- Very Easy
    [1] = { hp = -20, att =  -50, def =  -50, eva =  -25 }, -- Easy
    [2] = { hp =   0, att =    0, def =    0, eva =    0 }, -- Normal (base)
    [3] = { hp =  25, att =   50, def =   50, eva =   25 }, -- Difficult
    [4] = { hp =  55, att =  100, def =  100, eva =   50 }, -- Very Difficult
}

local function applyDiffScaling(battlefield, diffIndex)
    local scaling = diffScaling[diffIndex]

    if not scaling then
        return
    end

    local mobs = battlefield:getMobs(true, true)

    if not mobs then
        return
    end

    for _, mob in ipairs(mobs) do
        if mob and mob:isAlive() then
            -- HP scaling: adjust MaxHP by percentage from base
            if scaling.hp ~= 0 then
                local baseHP = mob:getMaxHP()
                local newHP  = math.max(1, math.floor(baseHP * (100 + scaling.hp) / 100))
                mob:setMaxHP(newHP)
                mob:setHP(newHP)
            end

            -- Stat mods: only apply if non-zero to avoid dirty Normal state
            if scaling.att ~= 0 then
                mob:addMod(xi.mod.ATT, scaling.att)
            end

            if scaling.def ~= 0 then
                mob:addMod(xi.mod.DEF, scaling.def)
            end

            if scaling.eva ~= 0 then
                mob:addMod(xi.mod.EVA, scaling.eva)
            end
        end
    end
end

-----------------------------------
-- Difficulty selection menu
-----------------------------------
-- The menu is shown in onEventFinishEnter, AFTER the player confirms the fight
-- name in event 32000 but BEFORE setEnteredBattlefield fires the warp.
-- At that point the battlefield exists, mobs are spawned, and the player is
-- NOT in any event — so MESSAGE_GMPROMPT renders immediately.
-- The selection callback calls player:setEnteredBattlefield(true) to complete
-- the warp once a difficulty is chosen (or the menu is dismissed).
-----------------------------------

local difficultyLabels =
{
    [0] = 'Very Easy',
    [1] = 'Easy',
    [2] = 'Normal',
    [3] = 'Difficult',
    [4] = 'Very Difficult',
}

local difficultyShortNames =
{
    [0] = 'Very Easy',
    [1] = 'Easy',
    [2] = 'Normal',
    [3] = 'Difficult',
    [4] = 'Very Difficult',
}

local function showPreEntryDiffMenu(player, battlefield)
    -- Pre-set Normal so dismiss/cancel has a safe default
    battlefield:setLocalVar('SKCNM_Difficulty', xi.skcnm.difficulty.NORMAL)

    local function onChosen(p, diffIndex)
        battlefield:setLocalVar('SKCNM_Difficulty', diffIndex)
        applyDiffScaling(battlefield, diffIndex)

        -- Fire the orb wear message that was deferred from onBattlefieldEnter
        local wearMsgId = battlefield:getLocalVar('SKCNM_WearMsg')
        local wearItem  = battlefield:getLocalVar('SKCNM_WearItem')

        if wearMsgId ~= 0 then
            p:messageSpecial(wearMsgId, 0, 0, 0, wearItem)
        end

        local chosen  = difficultyShortNames[diffIndex]
        local players = battlefield:getPlayers()

        for _, member in ipairs(players) do
            member:printToPlayer('Difficulty: ' .. chosen .. '.', xi.msg.channel.NS_SAY)
        end

        p:setEnteredBattlefield(true)
    end

    local menu =
    {
        title   = 'Select Battle Difficulty',
        options = {},
        onCancelled = function(p)
            onChosen(p, xi.skcnm.difficulty.NORMAL)
        end,
    }

    for value = 0, 4 do
        table.insert(menu.options, {
            difficultyLabels[value],
            function(p)
                onChosen(p, value)
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

-- Suppress the orb wear message (e.g. "A crack has formed...") that the base
-- class normally fires here.  Instead we call incrementItemWear ourselves and
-- store the message ID on the battlefield so it can be shown AFTER the player
-- picks a difficulty in onEventFinishEnter.  This keeps the message order:
--   Select Difficulty → "A crack has formed..." → warp into battle.
function SKCNMBattlefield:onBattlefieldEnter(player, battlefield)
    local initiatorId = select(1, battlefield:getInitiator())

    if player:getID() == initiatorId and self.requiredItems.wearMessage then
        local savedMsg = self.requiredItems.wearMessage
        local itemId   = self.requiredItems[1]

        -- Remove wearMessage so the base class skips the message block entirely
        self.requiredItems.wearMessage = nil
        Battlefield.onBattlefieldEnter(self, player, battlefield)
        self.requiredItems.wearMessage = savedMsg

        -- Wear the item manually (base class skipped it along with the message)
        player:incrementItemWear(itemId)

        -- Store for showPreEntryDiffMenu to use in the callback
        battlefield:setLocalVar('SKCNM_WearMsg',  savedMsg)
        battlefield:setLocalVar('SKCNM_WearItem', itemId)
    else
        Battlefield.onBattlefieldEnter(self, player, battlefield)
    end
end

-- Override the post-fight-selection hook so we can show the difficulty menu
-- before the player physically warps in.
-- Only the battlefield initiator (the player who traded the orb) sees the menu;
-- party members who enter separately warp in immediately using the already-set
-- difficulty.
function SKCNMBattlefield:onEventFinishEnter(player, csid, option)
    -- Mirror base-class bookkeeping (minus setEnteredBattlefield)
    player:setLocalVar('[battlefield]area', 0)
    self:setLocalVar(player, 'CS', 1)

    local battlefield = player:getBattlefield()
    local initiatorId = battlefield and select(1, battlefield:getInitiator()) or 0

    if battlefield and player:getID() == initiatorId then
        showPreEntryDiffMenu(player, battlefield)
    else
        -- Party member, or unexpected nil battlefield: warp straight in
        player:setEnteredBattlefield(true)
    end
end
