-----------------------------------
-- SKCNM Reward Handler
-----------------------------------
-- Sacred Kindred Crest NM (Macrocosmic Orb) reward system.
-- Mirrors the HTBF two-layer reward system but for orb-based entry.
--
-- DIRECT DROPS (personal, every player):
--   2x Rem's Tale chapter given directly to each player on win.
--
-- TREASURE POOL DROPS (shared):
--   2x Rem's Tale chapter (from lootTable) plus Gil, crafting materials,
--   scrolls, and rocks enter the treasure pool.
--
-- FLOW:
--   Trade orb → fight-selection CS (event 32000) → pick fight
--   → warp into arena → battle begins.
-----------------------------------

xi       = xi or {}
xi.skcnm = xi.skcnm or {}

-----------------------------------
-- Internal helpers
-----------------------------------

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
-- SKCNMBattlefield class
-----------------------------------
-- Extends Battlefield directly (orb-based entry, not quest/KI gated).
-- All SKCNM fight scripts use SKCNMBattlefield:new() instead of
-- Battlefield:new().

SKCNMBattlefield         = setmetatable({}, { __index = Battlefield })
SKCNMBattlefield.__index = SKCNMBattlefield

function SKCNMBattlefield:new(data)
    local obj = Battlefield:new(data)
    setmetatable(obj, self)
    return obj
end

-----------------------------------
-- Trade handler (registered via Battlefield.register)
-----------------------------------
-- Validates the orb trade then starts the fight-selection cutscene
-- (event 32000) directly.  No difficulty menu is shown.

function SKCNMBattlefield.onEntryTrade(player, npc, trade, onUpdate)
    -- ---- shared validation (mirrors Battlefield.onEntryTrade) ---------------

    if xi.battlefield.rejectLevelSyncedParty(player, npc) then
        return
    end

    if not trade then
        return
    end

    if player:hasStatusEffect(xi.effect.BATTLEFIELD) and not onUpdate then
        player:messageBasic(xi.msg.basic.WAIT_LONGER, 0, 0)
        return
    end

    local alliance = player:getAlliance()
    for _, member in pairs(alliance) do
        if member:hasStatusEffect(xi.effect.BATTLEFIELD) then
            player:messageBasic(xi.msg.basic.WAIT_LONGER, 0, 0)
            return
        end
    end

    local zoneId   = player:getZoneID()
    local contents = xi.battlefield.contentsByZone[zoneId]

    for _, content in ipairs(contents) do
        if
            #content.requiredItems > 0 and
            content.requiredItems.wornMessage and
            npcUtil.tradeHas(trade, content.tradeItems)
        then
            local itemId    = content.requiredItems[1]
            local totalUses = xi.battlefield.itemUses[itemId] or 1

            if player:getWornUses(itemId) >= totalUses then
                if type(content.requiredItems.wornMessage) == 'table' then
                    player:messageSpecial(unpack(content.requiredItems.wornMessage))
                elseif totalUses > 1 then
                    player:messageSpecial(content.requiredItems.wornMessage, itemId)
                else
                    player:messageSpecial(content.requiredItems.wornMessage, 0, 0, 0, itemId)
                end

                return
            end
        end
    end

    -- If called from onEntryEventUpdate (onUpdate=true) let base class handle.
    if onUpdate then
        return Battlefield.onEntryTrade(player, npc, trade, onUpdate)
    end

    -- ---- Start the fight-selection cutscene directly -------------------------

    local options = xi.battlefield.getBattlefieldOptions(player, npc, trade)

    if options == 0 then
        local noEntryMsg = zones[zoneId].text.NO_BATTLEFIELD_ENTRY
        if noEntryMsg then
            player:messageSpecial(noEntryMsg)
        end

        return
    end

    player:startEvent(32000, 0, 0, 0, options, 0, 0, 0, 0)
end
