-----------------------------------
-- Trust: Joachim
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    -- Records of Eminence: Alter Ego: Joachim
    if caster:getEminenceProgress(937) then
        xi.roe.onRecordTrigger(caster, 937)
    end

    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -----------------------------------
    -- STATUS REMOVAL (highest priority)
    -----------------------------------
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.POISON },        { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.POISONA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.PARALYSIS },     { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PARALYNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.BLINDNESS },     { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.BLINDNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.SILENCE },       { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SILENA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.PETRIFICATION }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STONA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.DISEASE },       { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.VIRUNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.CURSE_I },       { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURSNA })

    -----------------------------------
    -- HEALING (priority over songs)
    -----------------------------------

    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 33 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 66 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE_II })

    -----------------------------------
    -- SONG PRIORITY SYSTEM
    -----------------------------------

    -- Paeon x2 when Joachim HP < 90%
    mob:addGambit(ai.t.SELF,
        { ai.c.HPP_LT, 90 },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.ARMYS_PAEON }
    )

    -- Ballad when MP < 75%
    mob:addGambit(ai.t.SELF,
        { ai.c.MPP_LT, 75 },
        { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.MAGE_BALLAD }
    )

    -- March / madrigal: HIGHEST avoids two NOT_STATUS marches/madrigals where the second never fired.
    mob:addGambit(ai.t.PARTY,
        { ai.c.NOT_STATUS, xi.effect.MARCH },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.MARCH }
    )

    mob:addGambit(ai.t.PARTY,
        { ai.c.NOT_STATUS, xi.effect.MADRIGAL },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.MADRIGAL }
    )

    mob:addGambit(ai.t.PARTY,
        { ai.c.NOT_STATUS, xi.effect.MINUET },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.VALOR_MINUET }
    )

    mob:addGambit(ai.t.PARTY,
        { ai.c.NOT_STATUS, xi.effect.MINNE },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.KNIGHTS_MINNE }
    )

    -- Try and ranged attack every 60s
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.RATTACK, 0, 0 }, 60)

    mob:setAutoAttackEnabled(false)

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MID_RANGE)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
