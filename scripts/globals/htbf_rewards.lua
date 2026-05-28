-----------------------------------
-- HTBF Reward Handler
-----------------------------------
-- Manages the two-layer reward system for High-Tier Mission Battlefields.
--
-- DIRECT DROPS (personal, every player):
--   2x Rem's Tale chapter given directly to each player's inventory on win.
--
-- TREASURE POOL DROPS (shared):
--   2x Rem's Tale chapter plus unique weapons, armor, and rare materials
--   enter the battlefield's treasure pool.
--
-- UNLOCK (charvar per player per fight):
--   'HTBF_Win_<battlefieldId>'  >=1 means player has completed the fight.
-----------------------------------

xi      = xi or {}
xi.htbf = xi.htbf or {}

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
    local players = battlefield:getPlayers()

    for _, player in ipairs(players) do
        npcUtil.giveItem(player, chapterItemId)
        npcUtil.giveItem(player, chapterItemId)
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
--   chapterItemId : xi.item.COPY_OF_REMS_TALE_CHAPTER_X for this fight
--   mob           : the mob reference passed into allDeath (loot anchor)
--   lootTable     : content.loot table (may be nil for fights with no
--                   treasure pool drops such as Alexander/Odin/Cait Sith)
-- }
function xi.htbf.onWin(battlefield, params)
    recordWin(battlefield, params.battlefieldId)
    giveDirectDrops(battlefield, params.chapterItemId)

    -- 2 guaranteed Rem's Tale copies in the treasure pool
    if params.mob then
        local players = battlefield:getPlayers()
        if players and #players > 0 then
            players[1]:addTreasure(params.chapterItemId, params.mob)
            players[1]:addTreasure(params.chapterItemId, params.mob)
        end
    end

    rollTreasurePool(battlefield, params.lootTable, params.mob)
    battlefield:setStatus(xi.battlefield.status.WON)
end

-- Returns true if the player holds the required phantom gem (may register).
function xi.htbf.canRegister(player, phantomGemKi)
    return player:hasKeyItem(phantomGemKi)
end

-----------------------------------
-- HTBFBattlefield class
-----------------------------------
-- Extends Battlefield (NOT BattlefieldQuest).
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
