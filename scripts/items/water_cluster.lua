-----------------------------------
-- ID: 4109
-- Water Cluster
-- Turn into a stack of water crystals
-----------------------------------
---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.itemUtils.itemBoxOnItemCheck(caster)
end

itemObject.onItemUse = function(target, user)
    npcUtil.giveItem(user, { { xi.item.WATER_CRYSTAL, 12 } })
end

return itemObject
