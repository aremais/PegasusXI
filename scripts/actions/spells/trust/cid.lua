-----------------------------------
-- Trust: Cid
-----------------------------------
---@type TSpellTrust
local spellObject = {}

-- Retail/wiki-confirmed notes:
-- Cid is a WAR-style melee/ranged Trust.
-- Uses Berserk, Aggressor, Double Attack, melee attacks, and gun/ranged attacks.
-- Uses True Strike, Critical Mass, and Fiery Tailings.
-- Source notes he uses a gun roughly every 10 seconds.
-- Source notes he saves TP up to 2500 waiting to close a skillchain and saves Berserk until he is about to WS.
--
-- Source-limited notes:
-- - Exact skillchain-closing wait logic is approximated with local TP/WS settings.
-- - Exact ranged damage/rate mechanics are handled by the local RATTACK gambit.
-- - Exact special TP move formulas are handled in the mobskill scripts / DB where available.

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Source-noted Double Attack.
    if mob:getMainLvl() >= 25 then
        mob:addMod(xi.mod.DOUBLE_ATTACK, 10)
    end

    -- Source notes Cid uses a gun roughly every 10 seconds.
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.RATTACK, 0, 0 }, 10)

    -- Source-noted job abilities.
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 45 }, { ai.c.NOT_STATUS, xi.effect.AGGRESSOR } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.AGGRESSOR }, 60)

    -- Source notes Cid saves Berserk until he is about to use a weapon skill.
    -- Locally approximate this by using Berserk only when TP is already high enough.
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 15 }, { ai.c.TP_GTE, 1000 } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.BERSERK }, 60)

    -- Cid-specific Trust TP moves.
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, 3314 }, 30) -- True Strike
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 50 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 3322 }, 30) -- Critical Mass
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 75 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, 3323 }, 30) -- Fiery Tailings

    -- Retail/source notes Cid may save TP up to 2500 for skillchain closing.
    -- Use local closer-until-TP behavior and cap at 2500.
    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.RANDOM, 2500)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
