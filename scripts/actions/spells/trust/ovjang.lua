-----------------------------------
-- Trust: Ovjang
-----------------------------------
require('scripts/globals/trust')
require('scripts/globals/gambits')

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

    -- Retail/source synergy:
    -- When Nashmeira is present, Ovjang receives reduced enmity (-10%)
    -- and increased magic damage (+10%). MATT is used as the closest
    -- branch-safe percentage-style magic damage approximation.
    local lastEnmityBonus = 0
    local lastMagicBonus  = 0

    mob:addListener('COMBAT_TICK', 'OVJANG_NASHMEIRA_CTICK', function(mobArg)
        local targetEnmityBonus = 0
        local targetMagicBonus  = 0
        local party = mobArg:getMaster():getPartyWithTrusts()

        for _, member in pairs(party) do
            if member:getObjType() == xi.objType.TRUST then
                if member:getTrustID() == xi.magic.spell.NASHMEIRA then
                    targetEnmityBonus = -10
                    targetMagicBonus  = 10
                end
            end
        end

        if targetEnmityBonus ~= lastEnmityBonus then
            mobArg:delMod(xi.mod.ENMITY, lastEnmityBonus)
            mobArg:addMod(xi.mod.ENMITY, targetEnmityBonus)

            lastEnmityBonus = targetEnmityBonus
        end

        if targetMagicBonus ~= lastMagicBonus then
            mobArg:delMod(xi.mod.MATT, lastMagicBonus)
            mobArg:addMod(xi.mod.MATT, targetMagicBonus)

            lastMagicBonus = targetMagicBonus
        end
    end)

    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 32 }, { ai.c.STATUS_FLAG, xi.effectFlag.DISPELABLE } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.DISPEL }, 15)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 18 }, { ai.c.NOT_STATUS, xi.effect.SILENCE } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SILENCE }, 60)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 13 }, { ai.c.NOT_STATUS, xi.effect.SLOW } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SLOW }, 60)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 6 }, { ai.c.NOT_STATUS, xi.effect.PARALYSIS } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PARALYZE }, 60)

    mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 }, { ai.r.MA, ai.s.MB_ELEMENT, xi.magic.spellFamily.NONE })
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_SC_AVAILABLE, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.NONE }, 60)

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.NO_MOVE)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
