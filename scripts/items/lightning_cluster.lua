-----------------------------------
-- ID: 4108
-- Lighting Cluster
-- Turn into a stack of lighting crystals
-----------------------------------
---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target, user)
    npcUtil.giveItem(user, { { xi.item.LIGHTNING_CRYSTAL, 12 } })
end

return itemObject
