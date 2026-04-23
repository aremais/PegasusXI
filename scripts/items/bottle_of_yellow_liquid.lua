-----------------------------------
--  ID: 5264
--  Item: Yellow Liquid
--  Used on Mammets (CoP Ancient Vows, etc.): applies FOOD to prevent form changes; no stat mods.
-----------------------------------
---@type TItem
local itemObject = {}

-- Mammet family id in mob_family_system.sql ('Mammet')
local mammetFamily = 503

itemObject.onItemCheck = function(target, item, param, caster)
    local user = caster or target

    if target:getObjType() == xi.objType.MOB then
        if target:getFamily() ~= mammetFamily then
            return xi.msg.basic.ITEM_UNABLE_TO_USE
        end

        if target:hasStatusEffect(xi.effect.FOOD) then
            return xi.msg.basic.IS_FULL
        end

        if user:checkDistance(target) > 10 then
            return xi.msg.basic.TOO_FAR_AWAY
        end

        return 0
    end

    return xi.itemUtils.foodOnItemCheck(target, xi.foodType.BASIC)
end

itemObject.onItemUse = function(target, user, item, action)
    target:addStatusEffect(xi.effect.FOOD, {
        duration         = 30,
        origin           = user,
        subType          = item:getID(),
        sourceType       = xi.effectSourceType.FOOD,
        sourceTypeParam  = item:getID(),
    })
end

itemObject.onEffectGain = function(target, effect)
end

itemObject.onEffectLose = function(target, effect)
end

return itemObject
