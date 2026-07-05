-----------------------------------
-- Trust: Balamor
-----------------------------------
---@type TSpellTrust
local spellObject = {}

-- Retail/wiki-confirmed notes:
-- Balamor is a DRK/BLM-style melee Trust with Absorb-stat magic and four unique TP moves:
-- Feast of Arrows, Regurgitated Swarm, Setting the Stage, and Last Laugh.
--
-- Held engine-level traits:
-- - Undead-style Cure/Waltz restriction.
-- - Drain immunity while still taking damage from drain-type effects.
-- - Dark-element magical auto-attacks.
--
-- These are not forced here because they require safe engine/system support rather
-- than simple Trust Lua gambits.

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Retail/wiki passive stat notes: HP+40%, MP+100%.
    -- These percent mods are used by other LSB content and are safer than directly
    -- changing current HP/MP values.
    mob:addMod(xi.mod.HPP, 40)
    mob:addMod(xi.mod.MPP, 100)

    -- Absorb-stat spell level gates mirror mob_spell_lists spellList 396:
    -- Absorb-MND 31, CHR 33, VIT 35, AGI 37, INT 39, DEX 41, STR 43.
    -- Excluded by source: Absorb-TP, Absorb-ACC, Absorb-Attri.
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 31 }, { ai.c.NOT_STATUS, xi.effect.MND_DOWN } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_MND }, 60)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 33 }, { ai.c.NOT_STATUS, xi.effect.CHR_DOWN } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_CHR }, 60)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 35 }, { ai.c.NOT_STATUS, xi.effect.VIT_DOWN } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_VIT }, 60)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 37 }, { ai.c.NOT_STATUS, xi.effect.AGI_DOWN } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_AGI }, 60)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 39 }, { ai.c.NOT_STATUS, xi.effect.INT_DOWN } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_INT }, 60)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 41 }, { ai.c.NOT_STATUS, xi.effect.DEX_DOWN } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_DEX }, 60)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 43 }, { ai.c.NOT_STATUS, xi.effect.STR_DOWN } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_STR }, 60)

    -- Balamor uses TP randomly and is not a deliberate skillchain partner.
    -- The wikis confirm these four TP moves, but do not provide confirmed individual Trust level gates.
    -- Exact Trust WS damage formulas are not fully documented on the wikis; scripts are conservative implementations.
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, 3617 }, 30) -- Feast of Arrows
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, 3618 }, 30) -- Regurgitated Swarm
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, 3619 }, 30) -- Setting the Stage
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, 3620 }, 30) -- Last Laugh

    -- Fallback TP behavior using the populated skill list.
    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM, 1000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
