-----------------------------------
-- Trust: Teodor
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

    -- Retail notes:
    -- BLM/DRK. HP+35%, MP+50%.
    -- Uses elemental magic only to Magic Burst.
    -- Uses TP without attempting to skillchain.
    -- Uses Start from Scratch under 50% HP.
    -- After dark aura, builds TP toward Hemocladis; approximated safely by
    -- preferring Hemocladis at 2000 TP without adding custom AI infrastructure.
    mob:addMod(xi.mod.HPP, 35)
    mob:addMod(xi.mod.MPP, 50)
    mob:addMod(xi.mod.ARCANA_KILLER, 10)
    mob:addMod(xi.mod.FASTCAST, 20)

    -- MB-only elemental casting. Spell list 399 contains -ga and -ja spells.
    -- Do not add free-cast nuking.
    mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 }, { ai.r.MA, ai.s.MB_ELEMENT, xi.magic.spellFamily.NONE })

    -- Start from Scratch: branch-safe WS gambit.
    mob:addGambit(ai.t.SELF, { ai.c.HPP_LT, 50 }, { ai.r.WS, ai.s.SPECIFIC, 3380 }, 180)

    -- Hemocladis: HP-restoring move, preferred once Teodor reaches 2000 TP.
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 2000 }, { ai.r.WS, ai.s.SPECIFIC, 3385 }, 30)

    -- Non-SC TP usage approximation. Staggered cooldowns give varied TP usage
    -- without legacy TP helper usage or skillchain targeting.
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 3383 }, 90)  -- Open Coffin
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 3381 }, 120) -- Frenzied Thrust
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 3382 }, 150) -- Sinner's Cross
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 3384 }, 180) -- Ravenous Assault
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
