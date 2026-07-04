-----------------------------------
-- Trust: Invincible Shield (UC)
-----------------------------------
require("scripts/globals/trust")
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

    -- Source target: WAR/MNK Great Axe Unity Trust.
    mob:addMod(xi.mod.DOUBLE_ATTACK, 10)

    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 5 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE }, 30)
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 15 }, { ai.c.NOT_STATUS, xi.effect.BERSERK } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.BERSERK }, 60)
    mob:addGambit(ai.t.SELF, { ai.c.LVL_GTE, 35 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.WARCRY }, 300)
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 60 }, { ai.c.NOT_STATUS, xi.effect.RETALIATION } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.RETALIATION }, 180)
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 77 }, { ai.c.NOT_STATUS, xi.effect.RESTRAINT } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.RESTRAINT }, 180)
    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 75 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.TOMAHAWK }, 180)
    mob:addGambit(ai.t.SELF, { ai.c.LVL_GTE, 87 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.BLOOD_RAGE }, 300)

    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 60 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 86 }) -- Raging Rush
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 65 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 88 }) -- Steel Cyclone
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 99 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 3499 }) -- Soturi's Fury

    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM, 1000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject