-----------------------------------
-- Trust: Qultada
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

    -- Qultada: COR support/DD Trust. Retail behavior uses a mix of melee/ranged
    -- attacks, COR rolls, ranged attacks, and TP moves from skill list 1082.
    -- Local DB already supplies Burning Blade, Savage Blade, Sniper Shot, and Detonator.

    -- Enhanced Magic Accuracy was added in the Dec. 10, 2015 version update.
    local power = mob:getMainLvl() / 5
    mob:addMod(xi.mod.MACC, power)

    -- Triple Shot support for his ranged identity.
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.TRIPLE_SHOT }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.TRIPLE_SHOT }, 180)

    -- EXP/capacity-point roll behavior: use Corsair's Roll when Dedication or
    -- Commitment is active. This keeps the EXP-roll behavior conditional instead
    -- of always occupying a roll slot.
    mob:addGambit(ai.t.PARTY, {
        { ai.c.STATUS, xi.effect.DEDICATION },
        { ai.c.NOT_STATUS, xi.effect.CORSAIRS_ROLL },
    }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.CORSAIRS_ROLL }, 60)

    mob:addGambit(ai.t.PARTY, {
        { ai.c.STATUS, xi.effect.COMMITMENT },
        { ai.c.NOT_STATUS, xi.effect.CORSAIRS_ROLL },
    }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.CORSAIRS_ROLL }, 60)

    -- Default combat rolls: Chaos Roll plus Fighter's Roll when Corsair's Roll
    -- is not occupying the EXP/CP slot.
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.CHAOS_ROLL }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.CHAOS_ROLL }, 60)

    mob:addGambit(ai.t.PARTY, {
        { ai.c.NOT_STATUS, xi.effect.CORSAIRS_ROLL },
        { ai.c.NOT_STATUS, xi.effect.FIGHTERS_ROLL },
    }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.FIGHTERS_ROLL }, 60)

    -- Ranged attack cadence.
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.RATTACK, 0, 0 }, 10)

    -- Uses confirmed Qultada WS list 1082. ASAP better matches WS-at-TP behavior
    -- than opener-only while still respecting the existing DB skill list.
    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
