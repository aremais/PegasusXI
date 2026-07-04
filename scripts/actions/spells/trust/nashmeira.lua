-----------------------------------
-- Trust: Nashmeira
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.NASHMEIRA_II)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Retail/source behavior:
    -- PUP/WHM support Trust. No job abilities.
    -- Uses Imperial Authority at 1000 TP.
    -- Casts Cure I-IV only in emergencies, around <33% HP.
    -- Local DB spellList 335 provides Cure I-IV, -na spells, and Erase.
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 33 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })

    mob:addGambit(ai.t.PARTY, { ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE })

    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.POISON }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.POISONA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.PARALYSIS }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PARALYNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.BLINDNESS }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.BLINDNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.SILENCE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SILENA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.DISEASE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.VIRUNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.PETRIFICATION }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STONA })

    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.CURSE_I }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURSNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.CURSE_II }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURSNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.BANE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURSNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.DOOM }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURSNA })

    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 3243 })
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
