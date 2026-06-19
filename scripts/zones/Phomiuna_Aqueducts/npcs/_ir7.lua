-----------------------------------
-- Area: Phomiuna_Aqueducts
--  NPC: _ir7 (Iron Gate)
-- !pos -70.800 -1.500 60.000 27
-----------------------------------
local ID = zones[xi.zone.PHOMIUNA_AQUEDUCTS]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    local gateX = npc:getXPos()

    if player:getXPos() > gateX and npc:getAnimation() == xi.anim.CLOSE_DOOR then
        if npcUtil.tradeHasExactly(trade, xi.item.BRONZE_KEY) then
            player:confirmTrade()
            player:messageSpecial(ID.text.ITEM_BREAKS, xi.item.BRONZE_KEY) -- TextID 7235
            npc:openDoor(15)
        elseif
            player:getMainJob() == xi.job.THF and
            (npcUtil.tradeHasExactly(trade, xi.item.SKELETON_KEY) or
            npcUtil.tradeHasExactly(trade, xi.item.SET_OF_THIEFS_TOOLS) or
            npcUtil.tradeHasExactly(trade, xi.item.LIVING_KEY))
        then
            -- Thief pick: open silently (no messageSpecial)
            player:confirmTrade()
            npc:openDoor(15)
        end
    end
end

entity.onTrigger = function(player, npc)
    local gateX = npc:getXPos()

    if player:getXPos() <= gateX then
        -- Inside side: open silently (no messageSpecial)
        npc:openDoor(15)
    elseif npc:getAnimation() == xi.anim.CLOSE_DOOR then
        player:messageSpecial(ID.text.DOOR_LOCKED, xi.item.BRONZE_KEY)
    end
end

return entity
