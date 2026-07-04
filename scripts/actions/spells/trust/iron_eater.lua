-----------------------------------
-- Trust: Iron Eater
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

    -- Source target: WAR Great Axe melee Trust.
    mob:addMod(xi.mod.DOUBLE_ATTACK, 10)
    mob:addMod(xi.mod.STORETP, 10)

    mob:addGambit(ai.t.MASTER, { { ai.c.HPP_LT, 50 }, { ai.c.LVL_GTE, 5 } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE }, 30)
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 15 }, { ai.c.NOT_STATUS, xi.effect.BERSERK } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.BERSERK }, 60)
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 77 }, { ai.c.NOT_STATUS, xi.effect.RESTRAINT } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.RESTRAINT }, 180)

    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 1 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 80 }) -- Shield Break
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 10 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 83 }) -- Armor Break
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 65 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 88 }) -- Steel Cyclone

end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
