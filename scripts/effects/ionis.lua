-----------------------------------
-- xi.effect.IONIS
-- Coalition bonuses from scripts/globals/ionis.lua (snapshot on effect).
-----------------------------------
require('scripts/globals/ionis')

---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    xi.ionis.applyBonuses(target, effect)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    xi.ionis.removeBonuses(target, effect)
end

return effectObject
