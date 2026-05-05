-----------------------------------
-- xi.effect.ENASPIR
-- Applied by Heavenward Howl (Fenrir Blood Pact: Ward).
-- Sets the ENSPELL mod to ENSPELL_ENASPIR (24) so the C++ attack handler
-- deals dark additional damage equal to (power %) of melee damage and drains
-- that amount as MP from the defender to the attacker.
-- Power stored here is the moon-phase percentage value (e.g. 5 at New Moon).
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    effect:addMod(xi.mod.ENSPELL, 24)          -- ENSPELL_ENASPIR
    effect:addMod(xi.mod.ENSPELL_DMG, effect:getPower())
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
end

return effectObject
