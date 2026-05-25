-----------------------------------
-- ID: 4110
-- Light Cluster
-- Turn into a stack of light crystals
-----------------------------------
---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.itemUtils.itemBoxOnItemCheck(caster)
end

itemObject.onItemUse = function(target, user)
    npcUtil.giveItem(user, { { xi.item.LIGHT_CRYSTAL, 12 } })
end

return itemObject
