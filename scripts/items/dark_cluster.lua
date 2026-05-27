-----------------------------------
-- ID: 4111
-- Dark Cluster
-- Turn into a stack of dark crystals
-----------------------------------
---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target, user)
    npcUtil.giveItem(user, { { xi.item.DARK_CRYSTAL, 12 } })
end

return itemObject
