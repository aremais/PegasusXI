-----------------------------------
-- Trust: Lhu Mhakaracca
-----------------------------------
require('scripts/globals/trust')
-----------------------------------
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Source target: BST/WAR axe Trust.
    mob:addMod(xi.mod.DOUBLE_ATTACK, 10)

    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 75 }, { ai.c.HPP_LT, 20 } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.FERAL_HOWL }, 60)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 50 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 68 }, 15) -- Spinning Axe

    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.SPECIFIC, 68, 1000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
