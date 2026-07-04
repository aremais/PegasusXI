-----------------------------------
-- Trust: Naja Salaheem
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

    -- Source notes: MNK/WAR club user with Focus, Dodge, Counterstance,
    -- Double Attack, True Strike, Hexa Strike, Black Halo, Peacebreaker, and Justicebreaker.
    mob:addMod(xi.mod.DOUBLE_ATTACK, 10)

    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.FOCUS }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.FOCUS })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.DODGE }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.DODGE })
    mob:addGambit(ai.t.SELF, { ai.c.HAS_TOP_ENMITY, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.COUNTERSTANCE })

    -- Source notes: gains high TP and uses WS at 1000 TP.
    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
