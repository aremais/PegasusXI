-----------------------------------
-- Area: Tahrongi Canyon
--  NPC: Telepoint
-- !pos 100.000 35.150 340.000 117
-----------------------------------
local ID = zones[xi.zone.TAHRONGI_CANYON]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    -- Trade any normal crystal for a faded crystal.
    local item = trade:getItemId()
    if
        trade:getItemCount() == 1 and
        item >= xi.item.FIRE_CRYSTAL and
        item <= xi.item.DARK_CRYSTAL and
        npcUtil.giveItem(player, xi.item.FADED_CRYSTAL)
    then
        player:tradeComplete()
    end
end

entity.onTrigger = function(player, npc)
    if not player:hasKeyItem(xi.ki.MEA_GATE_CRYSTAL) then
        npcUtil.giveKeyItem(player, xi.ki.MEA_GATE_CRYSTAL)
    else
        player:messageSpecial(ID.text.ALREADY_OBTAINED_TELE)
    end
end

return entity
