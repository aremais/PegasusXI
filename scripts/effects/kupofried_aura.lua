-----------------------------------
-- xi.effect.KUPOFRIED_AURA
-- Applied by Trust: Kupofried proximity aura
-- Grants an EXP/CP bonus to nearby party members
-----------------------------------

---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    target:addMod(xi.mod.EXP_BONUS, effect:getPower())
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:delMod(xi.mod.EXP_BONUS, effect:getPower())
end

return effectObject
