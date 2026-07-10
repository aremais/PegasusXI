-----------------------------------
-- Trust: Chacharoon
-----------------------------------
---@type TSpellTrust
local spellObject = {}

-- Retail/wiki-confirmed notes:
-- Chacharoon is a Qiqirn THF/RNG-style melee Trust.
-- He has no spells, has Triple Attack, low delay/low base damage, occasionally uses ranged attacks, and uses:
-- Pocket Sand, Tripe Gripe, and Sharp Eye.
--
-- Source-limited notes:
-- - Exact ranged attack rate and exact TP move formulas, powers, and durations are conservative here.
-- - Branch-safe Trust gambits are used for TP move selection.

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- BG notes HP-10%, MP-10%.
    mob:addMod(xi.mod.HPP, -10)
    mob:addMod(xi.mod.MPP, -10)

    -- Source-noted Triple Attack.
    mob:addMod(xi.mod.TRIPLE_ATTACK, 10)

    -- Chacharoon uses TP at 1000 and is not documented as a deliberate skillchain partner.
    -- These are Trust-specific mobskill rows assigned to TRUST_Chacharoon skill list 1078.
    -- Use branch-safe WS gambits for Chacharoon's Trust-specific TP moves.
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 3440 }, 60) -- Pocket Sand
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 3441 }, 60) -- Tripe Gripe
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 3442 }, 60) -- Sharp Eye
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
