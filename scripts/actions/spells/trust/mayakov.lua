-----------------------------------
-- Trust: Mayakov
-----------------------------------
---@type TSpellTrust
local spellObject = {}

local healingJobs =
{
    xi.job.WHM,
    xi.job.RDM,
    xi.job.SCH,
    xi.job.PLD,
}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SABER_DANCE }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SABER_DANCE })
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.LETHARGIC_DAZE_5 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.FEATHER_STEP })

    -- Source-listed JA. Finishing-move-specific gambit conditions are not exposed cleanly here,
    -- so this is safely status-gated and cooldown-gated by the JA system.
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.CLIMACTIC_FLOURISH }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.CLIMACTIC_FLOURISH })

    for i = 1, #healingJobs do
        local master = mob:getMaster()
        if
            master and
            master:getMainJob() == healingJobs[i]
        then
            mob:addGambit(ai.t.SELF, { ai.c.NO_SAMBA, ai.r.JA }, { 0, ai.s.SPECIFIC, xi.ja.HASTE_SAMBA })
        end
    end

    mob:addGambit(ai.t.TARGET, { ai.c.IS_ECOSYSTEM, xi.ecosystem.UNDEAD }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.HASTE_SAMBA })
    mob:addGambit(ai.t.SELF, { ai.c.NO_SAMBA, 0 }, { ai.r.JA, ai.s.BEST_SAMBA, xi.ja.DRAIN_SAMBA })

    -- Approximation: source notes indicate Mayakov does not try to skillchain.
    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
