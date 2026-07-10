-----------------------------------
-- Trust: King of Hearts
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
    xi.trust.teamworkMessage(mob, {
        [xi.magic.spell.SHANTOTTO] = xi.trust.messageOffset.TEAMWORK_1,
    })

    mob:addGambit(ai.t.MASTER, { ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE })
    mob:addGambit(ai.t.SELF,   { ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE })
    mob:addGambit(ai.t.PARTY,  { ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE })

    local statusRemoval =
    {
        { xi.effect.POISON,        xi.magic.spell.POISONA  },
        { xi.effect.PARALYSIS,     xi.magic.spell.PARALYNA },
        { xi.effect.BLINDNESS,     xi.magic.spell.BLINDNA  },
        { xi.effect.SILENCE,       xi.magic.spell.SILENA   },
        { xi.effect.PETRIFICATION, xi.magic.spell.STONA    },
        { xi.effect.DISEASE,       xi.magic.spell.VIRUNA   },
        { xi.effect.CURSE_I,       xi.magic.spell.CURSNA   },
    }

    for _, removal in ipairs(statusRemoval) do
        mob:addGambit(ai.t.MASTER, { ai.c.STATUS, removal[1] }, { ai.r.MA, ai.s.SPECIFIC, removal[2] })
        mob:addGambit(ai.t.SELF,   { ai.c.STATUS, removal[1] }, { ai.r.MA, ai.s.SPECIFIC, removal[2] })
        mob:addGambit(ai.t.PARTY,  { ai.c.STATUS, removal[1] }, { ai.r.MA, ai.s.SPECIFIC, removal[2] })
    end

    mob:addGambit(ai.t.MASTER, { ai.c.STATUS, xi.effect.SLEEP_I  }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE })
    mob:addGambit(ai.t.MASTER, { ai.c.STATUS, xi.effect.SLEEP_II }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE })
    mob:addGambit(ai.t.SELF,   { ai.c.STATUS, xi.effect.SLEEP_I  }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE })
    mob:addGambit(ai.t.SELF,   { ai.c.STATUS, xi.effect.SLEEP_II }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE })
    mob:addGambit(ai.t.PARTY,  { ai.c.STATUS, xi.effect.SLEEP_I  }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE })
    mob:addGambit(ai.t.PARTY,  { ai.c.STATUS, xi.effect.SLEEP_II }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE })

    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 50 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })

    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.DIA }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.DIA }, 15)

    mob:addGambit(ai.t.TARGET, { ai.c.STATUS_FLAG, xi.effectFlag.DISPELABLE }, { ai.r.WS, ai.s.SPECIFIC, 330 })

    mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 }, { ai.r.MA, ai.s.MB_ELEMENT, xi.magic.spellFamily.NONE })

    mob:addGambit(ai.t.MASTER, { ai.c.NOT_STATUS, xi.effect.HASTE   }, { ai.r.MA, ai.s.HIGHEST,  xi.magic.spellFamily.HASTE })
    mob:addGambit(ai.t.MASTER, { ai.c.NOT_STATUS, xi.effect.REFRESH }, { ai.r.MA, ai.s.HIGHEST,  xi.magic.spellFamily.REFRESH })
    mob:addGambit(ai.t.MASTER, { ai.c.NOT_STATUS, xi.effect.PHALANX }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PHALANX_II })

    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.HASTE   }, { ai.r.MA, ai.s.HIGHEST,  xi.magic.spellFamily.HASTE })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.REFRESH }, { ai.r.MA, ai.s.HIGHEST,  xi.magic.spellFamily.REFRESH })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.PHALANX }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PHALANX_II })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.TEMPER  }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.TEMPER })

    mob:addGambit(ai.t.TOP_ENMITY, { ai.c.NOT_STATUS, xi.effect.PHALANX }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PHALANX_II })

    local wsSelector = ai.s.RANDOM or ai.s.HIGHEST
    mob:addGambit(ai.t.SELF, { ai.c.TP_GTE, 1000 }, { ai.r.WS, wsSelector, 0 })
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
