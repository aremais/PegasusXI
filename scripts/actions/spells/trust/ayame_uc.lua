-----------------------------------
-- Trust: Ayame UC
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.AYAME_UC)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Ayame UC is a SAM melee Trust. Unlike normal Ayame's dedicated
    -- SPECIAL_AYAME opener behavior, UC is treated as a more direct
    -- skillchain-capable Samurai until Shikikoyo/Mudo support is completed.
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 25 }, { ai.c.NOT_STATUS, xi.effect.HASSO } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.HASSO })
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 35 }, { ai.c.HAS_TOP_ENMITY, 0 }, { ai.c.NOT_STATUS, xi.effect.SEIGAN } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SEIGAN })
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 15 }, { ai.c.HAS_TOP_ENMITY, 0 } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.THIRD_EYE })
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 30 }, { ai.c.TP_LT, 1000 } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.MEDITATE })
    mob:addGambit(ai.t.SELF, { ai.c.LVL_GTE, 77 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SENGIKORI })

    -- Source behavior notes Shikikoyo after the caller uses a WS at 2000+ TP,
    -- and Tachi: Mudo as a special WS. Those are held until proper targeting
    -- and mobskill Lua support are implemented.
    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.HIGHEST, 2000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
