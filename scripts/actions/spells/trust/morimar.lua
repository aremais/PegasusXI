-----------------------------------
-- Trust: Morimar
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    mob:addListener('WEAPONSKILL_USE', 'MORIMAR_WEAPONSKILL_USE', function(mobArg, target, skill, tp, action, damage)
        if skill:getID() == 3680 then
            mobArg:setLocalVar('MorimarVehementResolution', 0)
        end
    end)

    -- Retail/source notes: possesses HP+10%.
    mob:addMod(xi.mod.HPP, 10)

    -- Approximation: saves TP to close skillchains; special glow/forced
    -- 12 Blades behavior is held until a safe implementation is confirmed.
    mob:setTrustTPSkillSettings(ai.tp.CLOSER, ai.s.RANDOM)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
