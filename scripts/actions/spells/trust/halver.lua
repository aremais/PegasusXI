-----------------------------------
-- Trust: Halver
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

    -- Source target: PLD/WAR polearm melee fighter with Double Attack, Cure I-IV, Flash,
    -- Provoke, Berserk, Sentinel, Rampart, and Raiden/Penta/Impulse polearm weapon skills.
    if mob:getMainLvl() >= 15 then
        mob:addMod(xi.mod.DOUBLE_ATTACK, 10)
    end

    mob:addGambit(ai.t.TANK, { ai.c.HPP_LT, 75 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 50 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 37 }, { ai.c.NOT_STATUS, xi.effect.FLASH } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.FLASH })

    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 10 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE }, 30)
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 30 }, { ai.c.NOT_STATUS, xi.effect.BERSERK } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.BERSERK }, 60)
    mob:addGambit(ai.t.SELF, { ai.c.LVL_GTE, 30 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SENTINEL }, 180)
    mob:addGambit(ai.t.SELF, { ai.c.LVL_GTE, 62 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.RAMPART }, 180)

    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 24 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 114 }) -- Raiden Thrust
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 49 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 116 }) -- Penta Thrust
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 71 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 120 }) -- Impulse Drive

    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM, 1000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
