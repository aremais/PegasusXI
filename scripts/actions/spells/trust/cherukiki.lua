-----------------------------------
-- Trust: Cherukiki
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
        [xi.magic.spell.MAKKI_CHEBUKKI] = xi.trust.messageOffset.TEAMWORK_1,
        [xi.magic.spell.KUKKI_CHEBUKKI] = xi.trust.messageOffset.TEAMWORK_2,
        [xi.magic.spell.PRISHE] = xi.trust.messageOffset.TEAMWORK_3,
        [xi.magic.spell.TENZEN] = xi.trust.messageOffset.TEAMWORK_4,
    })

    -- Retail notes / held approximations:
    -- * Cherukiki does not engage.
    -- * She favors Regen over Cure.
    -- * She should stay back at roughly mid-range.
    -- * NIN exclusion for Haste is not implemented because this branch does not expose
    --   a branch-safe job-filter gambit condition.
    -- * Meteor teamwork with Kukki-Chebukki and Makki-Chebukki is held until a safe
    --   existing listener/cast pattern is confirmed.

    mob:addMod(xi.mod.REGEN, 5)

    mob:setAutoAttackEnabled(false)
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MID_RANGE)

    -- Wake sleeping party members with Cure I.
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.SLEEP_I }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.SLEEP_II }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE })

    -- Emergency Cure before Regen maintenance.
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 25 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })

    -- Cherukiki favors Regen over Cure.
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.REGEN }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.REGEN })

    -- General Cure threshold kept lower than standard healers so Regen remains favored.
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 50 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })

    -- Defensive buffs.
    -- Avoid broad PARTY targeting because passive aura Trusts such as Star Sibyl/Cornelia
    -- may not receive Protect/Shell and can cause infinite Protectra/Shellra loops.
    local protectShellTargets = { ai.t.MASTER, ai.t.SELF, ai.t.TANK, ai.t.MELEE, ai.t.RANGED }
    for _, targetType in ipairs(protectShellTargets) do
        mob:addGambit(targetType, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECTRA })
        mob:addGambit(targetType, { ai.c.NOT_STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SHELLRA })
    end

    -- Haste herself, the player, and melee damage dealers.
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.HASTE }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.HASTE })
    mob:addGambit(ai.t.MASTER, { ai.c.NOT_STATUS, xi.effect.HASTE }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.HASTE })
    mob:addGambit(ai.t.MELEE, { ai.c.NOT_STATUS, xi.effect.HASTE }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.HASTE })

    -- Enfeebles.
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.PARALYSIS }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PARALYZE }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.SLOW }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SLOW }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.SILENCE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SILENCE }, 60)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
