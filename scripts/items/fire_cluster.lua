-----------------------------------
-- ID: 4104
-- Fire Cluster
-- Turn into a stack of fire crystals
-----------------------------------
---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.itemUtils.itemBoxOnItemCheck(caster)
end

itemObject.onItemUse = function(target, user)
    npcUtil.giveItem(user, { { xi.item.FIRE_CRYSTAL, 12 } })
end

return itemObject
