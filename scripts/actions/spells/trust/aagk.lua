-----------------------------------
-- Trust: AAGK
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

    -- Ark Angel GK is a SAM/DRG melee Trust with HP+20%.
    mob:addMod(xi.mod.HPP, 20)

    -- SAM job abilities.
    mob:addGambit(ai.t.SELF,   { { ai.c.LVL_GTE, 25 }, { ai.c.NOT_STATUS, xi.effect.HASSO } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.HASSO })
    mob:addGambit(ai.t.SELF,   { { ai.c.LVL_GTE, 30 }, { ai.c.TP_LT, 1000 } },                 { ai.r.JA, ai.s.SPECIFIC, xi.ja.MEDITATE })
    mob:addGambit(ai.t.SELF,   { ai.c.LVL_GTE, 40 },                                           { ai.r.JA, ai.s.SPECIFIC, xi.ja.SEKKANOKI })
    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 65 },                                           { ai.r.JA, ai.s.SPECIFIC, xi.ja.KONZEN_ITTAI })
    mob:addGambit(ai.t.SELF,   { ai.c.LVL_GTE, 95 },                                           { ai.r.JA, ai.s.SPECIFIC, xi.ja.HAGAKURE })

    -- DRG subjob utility. Level gates use subjob-equivalent main levels.
    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 20 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.JUMP })
    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 70 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.HIGH_JUMP })

    -- AAGK is noted for closing skillchains and can act aggressively with TP.
    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.HIGHEST, 1000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
