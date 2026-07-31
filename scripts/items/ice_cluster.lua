-----------------------------------
-- ID: 4105
-- Ice Cluster
-- Turn into a stack of ice crystals
-----------------------------------
---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.itemUtils.itemBoxOnItemCheck(caster)
end

itemObject.onItemUse = function(target, user)
    npcUtil.giveItem(user, { { xi.item.ICE_CRYSTAL, 12 } })
end

return itemObject
