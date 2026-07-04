-----------------------------------
-- Repairer Moogle
-- Restores items with corrupted data (retail: trade applicable item).
-----------------------------------
xi.repairerMoogle = xi.repairerMoogle or {}

-- Items eligible for data restoration via Repairer Moogle.
local repairableItems =
{
    [xi.item.TRISKA_SCYTHE_P1] = true,
}

xi.repairerMoogle.onTrade = function(player, npc, trade)
    for slot = 0, trade:getSlotCount() - 1 do
        local itemId = trade:getItemId(slot)

        if repairableItems[itemId] then
            if player:getFreeSlotsCount() == 0 then
                player:messageSpecial(zones[player:getZoneID()].text.FULL_INVENTORY_AFTER_TRADE)
                return
            end

            player:confirmTrade()
            npcUtil.giveItem(player, itemId)
            return
        end
    end
end

xi.repairerMoogle.onTrigger = function(player, npc)
    player:showText(npc, zones[player:getZoneID()].text.NOKKHI_BAD_ITEM)
end
