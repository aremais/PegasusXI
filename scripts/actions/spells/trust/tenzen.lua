-----------------------------------
-- Trust: Tenzen
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.TENZEN_II)
end

spellObject.onSpellCast = function(caster, target, spell)
    -- Records of Eminence: Alter Ego: Tenzen
    if caster:getEminenceProgress(935) then
        xi.roe.onRecordTrigger(caster, 935)
    end

    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.teamworkMessage(mob, {
        [xi.magic.spell.IROHA] = xi.trust.messageOffset.TEAMWORK_1,
    })

    -- Retail behavior: Tenzen retains 400 TP after weapon skills.
    mob:addMod(xi.mod.SAVETP, 400)

    -- Maintain Hasso while engaged.
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.HASSO }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.HASSO })

    -- Build TP toward Tenzen's 1500 TP skillchain-closing threshold.
    mob:addGambit(ai.t.SELF, { ai.c.TP_LT, 1500 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.MEDITATE })

    -- Use Hagakure before weapon skills once Tenzen is ready to close.
    mob:addGambit(ai.t.SELF, { ai.c.TP_GTE, 1500 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.HAGAKURE })

    -- Defensive SAM behavior when Tenzen has hate.
    mob:addGambit(ai.t.SELF, { ai.c.HAS_TOP_ENMITY, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.THIRD_EYE })

    -- Tenzen holds TP until 1500 and then uses the best available Amatsu WS from TRUST_Tenzen skill list 1023.
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1500 }, { ai.r.WS, ai.s.HIGHEST })
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
