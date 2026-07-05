-----------------------------------
-- Trust: Gessho
-- Will only use the highest tier debuff available, but will use both Utsusemi spells.
-- Will maintain Yonin full time.
-- Holds TP until 1500 to try to close skillchains.
-----------------------------------
---@type TSpellTrust
local spellObject = {}

local gesshoSkills =
{
    HANE_FUBUKI     = 3256,
    SHIBARAKU       = 3257,
    SHIKO_NO_MITATE = 3258,
    HAPPOBARAI      = 3259,
    RINPYOTOSHA     = 3260,
}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.teamworkMessage(mob, {
        [xi.magic.spell.NAJA_SALAHEEM] = xi.trust.messageOffset.TEAMWORK_1,
        [xi.magic.spell.ABQUHBAH]      = xi.trust.messageOffset.TEAMWORK_2,
    })

    mob:addMobMod(xi.mobMod.CAN_PARRY, 1)

    mob:addMod(xi.mod.MAIN_DMG_RATING, xi.trust.modGrowthValMax(mob, 35))
    mob:addMod(xi.mod.DOUBLE_ATTACK, xi.trust.modGrowthValMax(mob, 15))
    mob:addMod(xi.mod.ACC, xi.trust.modGrowthValMax(mob, 200))
    mob:addMod(xi.mod.EVA, xi.trust.modGrowthValMax(mob, 125))
    mob:addMod(xi.mod.FASTCAST, 30)
    mob:addMod(xi.mod.ENMITY, 10)

    local lvl = mob:getMainLvl()

    if lvl >= 5 then
        mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE })
    end

    if lvl >= 40 then
        mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.YONIN }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.YONIN })
    end

    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS, xi.effect.COPY_IMAGE }, { ai.r.MA, ai.s.HIGHEST,  xi.magic.spellFamily.UTSUSEMI })
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.BLINDNESS  }, { ai.r.MA, ai.s.HIGHEST,  xi.magic.spellFamily.KURAYAMI }, 30)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.SLOW       }, { ai.r.MA, ai.s.HIGHEST,  xi.magic.spellFamily.HOJO     }, 30)

    -- Retail note: exact unique Trust move level gates are not exposed in mob_skill_lists,
    -- so these are conservative explicit gates to prevent low-level access.
    if lvl >= 25 then
        mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1500 }, { ai.r.WS, ai.s.SPECIFIC, gesshoSkills.HANE_FUBUKI })
    end

    if lvl >= 40 then
        mob:addGambit(ai.t.SELF, {
            { ai.c.TP_GTE,     1500 },
            { ai.c.NOT_STATUS, xi.effect.DEFENSE_BOOST },
        }, { ai.r.WS, ai.s.SPECIFIC, gesshoSkills.SHIKO_NO_MITATE }, 300)
    end

    if lvl >= 50 then
        mob:addGambit(ai.t.TARGET, {
            { ai.c.TP_GTE,  1500 },
            { ai.c.HPP_LT, 75 },
        }, { ai.r.WS, ai.s.SPECIFIC, gesshoSkills.HAPPOBARAI })
    end

    if lvl >= 60 then
        mob:addGambit(ai.t.SELF, {
            { ai.c.TP_GTE,     1500 },
            { ai.c.NOT_STATUS, xi.effect.WARCRY },
        }, { ai.r.WS, ai.s.SPECIFIC, gesshoSkills.RINPYOTOSHA }, 300)
    end

    if lvl >= 70 then
        mob:addGambit(ai.t.TARGET, {
            { ai.c.TP_GTE,  1500 },
            { ai.c.HPP_LT, 50 },
        }, { ai.r.WS, ai.s.SPECIFIC, gesshoSkills.SHIBARAKU })
    end

    mob:addListener('WEAPONSKILL_USE', 'GESSHO_WEAPONSKILL_USE', function(mobArg, target, skill, tp, action, damage)
        if skill:getID() == gesshoSkills.SHIBARAKU then
            xi.trust.message(mobArg, xi.trust.messageOffset.SPECIAL_MOVE_1)
        end
    end)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
