-----------------------------------
-- Trust: Cid
-- WAR/RNG
-- Melees with club and uses Cid-specific WS from DB skill_list_id 1052.
-- Uses Aggressor and Berserk.
-- Holds up to 2500 TP to close skillchains.
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

    local lvl = mob:getMainLvl()

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MELEE)
    mob:setMobMod(xi.mobMod.SKILL_LIST, 1052)

    -- Retail Cid uses Aggressor.
    if lvl >= 45 then
        mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.AGGRESSOR }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.AGGRESSOR })
    end

    -- Retail notes say Cid saves Berserk until he is about to use a WS.
    -- PegasusXI-safe version: enabled with closer TP behavior so he holds TP instead of dumping immediately.
    if lvl >= 15 then
        mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.BERSERK }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.BERSERK })
    end

    -- Uses WS from mob_skill_lists 1052:
    -- true_strike, hexa_strike, critical_mass, fiery_tailings.
    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.HIGHEST, 2500)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
