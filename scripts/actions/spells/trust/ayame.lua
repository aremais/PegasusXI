-----------------------------------
-- Trust: Ayame
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
    xi.trust.teamworkMessage(mob, {
        [xi.magic.spell.NAJI] = xi.trust.messageOffset.TEAMWORK_1,
        [xi.magic.spell.GILGAMESH] = xi.trust.messageOffset.TEAMWORK_2,
    })

    local lvl = mob:getMainLvl()

    if lvl >= 15 then
        mob:addGambit(ai.t.SELF, { ai.c.HAS_TOP_ENMITY, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.THIRD_EYE })
    end

    if lvl >= 25 then
        mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.HASSO }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.HASSO })
    end

    if lvl >= 30 then
        mob:addGambit(ai.t.SELF, { ai.c.TP_LT, 1000 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.MEDITATE })
    end

    mob:setTrustTPSkillSettings(ai.tp.OPENER, ai.s.SPECIAL_AYAME)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
