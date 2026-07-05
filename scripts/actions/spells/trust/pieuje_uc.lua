-----------------------------------
-- Trust: Pieuje (UC)
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
    xi.trust.message(mob, xi.trust.message_offset.SPAWN)

    -- Retail notes: Afflatus Misery, Auto Refresh, Regain, Cure/Protectra/Shellra,
    -- Flash, Auspice, Haste, -na/Erase/Esuna, and Starlight/Moonlight/Nott.
    mob:addMod(xi.mod.REFRESH, 3)
    mob:addMod(xi.mod.REGAIN, 50)

    mob:addGambit(ai.t.SELF, { { ai.c.NOT_STATUS, xi.effect.AFFLATUS_MISERY }, { ai.c.LVL_GTE, 40 } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.AFFLATUS_MISERY })

    mob:addGambit(ai.t.SELF, { { ai.c.MPP_LT, 51 }, { ai.c.LVL_GTE, 50 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, xi.mobSkill.NOTT })

    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 25 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 75 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })

    -- Defensive buffs.
    -- Avoid broad PARTY targeting because passive aura Trusts such as Star Sibyl/Cornelia
    -- may not receive Protect/Shell and can cause infinite Protectra/Shellra loops.
    local protectShellTargets = { ai.t.MASTER, ai.t.SELF, ai.t.TANK, ai.t.MELEE, ai.t.RANGED }
    for _, targetType in ipairs(protectShellTargets) do
        mob:addGambit(targetType, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECTRA })
        mob:addGambit(targetType, { ai.c.NOT_STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SHELLRA })
    end

    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.HASTE }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.HASTE })
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.AUSPICE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.AUSPICE })

    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.POISON }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.POISONA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.PARALYSIS }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PARALYNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.BLINDNESS }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.BLINDNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.SILENCE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SILENA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.PETRIFICATION }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STONA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.DISEASE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.VIRUNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.CURSE_I }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURSNA })

    mob:addGambit(ai.t.SELF, { ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE })

    mob:addGambit(ai.t.PARTY, {
        ai.l.OR(
            { ai.c.STATUS, xi.effect.POISON },
            { ai.c.STATUS, xi.effect.PARALYSIS },
            { ai.c.STATUS, xi.effect.BLINDNESS },
            { ai.c.STATUS, xi.effect.SILENCE },
            { ai.c.STATUS, xi.effect.DISEASE },
            { ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE }
        ),
    }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ESUNA })

    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.FLASH }, 60)

    mob:setAutoAttackEnabled(false)
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MID_RANGE)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.message_offset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.message_offset.DEATH)
end

return spellObject
