-----------------------------------
-- xi.effect.ENDRAIN
-- Applied by Heavenward Howl (Fenrir Blood Pact: Ward).
-- Sets the ENSPELL mod to ENSPELL_ENDRAIN (23) so the C++ attack handler
-- deals dark additional damage equal to (power %) of melee damage and drains
-- that amount as HP back to the attacker.
-- Power stored here is the moon-phase percentage value (e.g. 15 at Full Moon).
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    effect:addMod(xi.mod.ENSPELL, 23)          -- ENSPELL_ENDRAIN
    effect:addMod(xi.mod.ENSPELL_DMG, effect:getPower())
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
end

return effectObject
