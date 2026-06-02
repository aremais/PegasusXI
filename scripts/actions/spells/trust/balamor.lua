-----------------------------------
-- Trust: Balamor
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

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MELEE)
    mob:setMobMod(xi.mobMod.SKILL_LIST, 1098)
    mob:addMod(xi.mod.HPP, 40)
    mob:addMod(xi.mod.MPP, 100)

    -- Dark magic: Balamor spell list 396 contains Absorb spells.
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.STR_DOWN }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_STR }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.DEX_DOWN }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_DEX }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.VIT_DOWN }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_VIT }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.AGI_DOWN }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_AGI }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.INT_DOWN }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_INT }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.MND_DOWN }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_MND }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.CHR_DOWN }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_CHR }, 60)

    -- Balamor uses TP moves randomly and does not attempt to skillchain.
    -- Trust-specific single-target versions:
    -- 3617 Feast of Arrows
    -- 3618 Regurgitated Swarm
    -- 3619 Setting the Stage
    -- 3620 Last Laugh
    mob:addListener('COMBAT_TICK', 'BALAMOR_RANDOM_TP_MOVE', function(mobArg)
        local target = mobArg:getTarget()

        if target ~= nil and mobArg:getTP() >= 1000 and mobArg:getLocalVar('BalamorRandomTPCooldown') <= os.time() then
            local moves =
            {
                3617,
                3618,
                3619,
                3620,
            }

            mobArg:useMobAbility(moves[math.random(1, #moves)])
            mobArg:setLocalVar('BalamorRandomTPCooldown', os.time() + 10)
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
