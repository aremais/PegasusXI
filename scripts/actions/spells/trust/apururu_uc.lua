-----------------------------------
-- Trust: Apururu UC
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

local isWearingApururuShirt = function(player)
    local wearingBody = player:getEquipID(xi.slot.BODY) == xi.item.APURURU_UNITY_SHIRT
    return wearingBody
end

spellObject.onMobSpawn = function(mob)
    local master = mob:getMaster()
    if isWearingApururuShirt(master) then
        xi.trust.message(mob, xi.trust.messageOffset.TEAMWORK_2)
    else
        xi.trust.message(mob, xi.trust.messageOffset.SPAWN)
    end

    -- Unity ranking high : xi.trust.message(mob, xi.trust.messageOffset.TEAMWORK_1)

    -- TODO: UC trusts are supposed to get bonuses depending on unity ranking. Needs research.
    -- TODO: Custom spawn messages if Unity ranking is higher.
    -- NOTE: Devotion/Martyr are intentionally not added as normal gambits yet.
    -- The current gambit JA executor retargets non-self abilities to the battle target,
    -- which makes party-targeted JAs unsafe until the engine supports matched JA targets.

    mob:addGambit(ai.t.SELF, { { ai.c.MPP_LT, 51 }, { ai.c.LVL_GTE, 50 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, xi.mobSkill.NOTT })

    -- Retail behavior: Convert is only used at very low MP.
    mob:addGambit(ai.t.SELF, { { ai.c.MPP_LT, 10 }, { ai.c.LVL_GTE, 40 } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.CONVERT })

    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 25 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })

    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.SLEEP_I }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURAGA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.SLEEP_II }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURAGA })

    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 75 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })

    -- Defensive buffs.
    -- Avoid broad PARTY targeting because passive aura Trusts such as Star Sibyl/Cornelia
    -- may not receive Protect/Shell and can cause infinite Protectra/Shellra loops.
    local protectShellTargets = { ai.t.MASTER, ai.t.SELF, ai.t.TANK, ai.t.MELEE, ai.t.RANGED }
    for _, targetType in ipairs(protectShellTargets) do
        mob:addGambit(targetType, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECTRA })
        mob:addGambit(targetType, { ai.c.NOT_STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SHELLRA })
    end

    mob:addGambit(ai.t.MELEE, { ai.c.NOT_STATUS, xi.effect.HASTE }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.HASTE })

    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.POISON }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.POISONA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.PARALYSIS }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PARALYNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.BLINDNESS }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.BLINDNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.SILENCE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SILENA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.PETRIFICATION }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STONA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.DISEASE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.VIRUNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.CURSE_I }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURSNA })

    mob:addGambit(ai.t.SELF, { ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE })

    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.STONESKIN }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STONESKIN })

    -- BGwiki states 75/tick regain.  Only used for Nott WS.
    mob:addMod(xi.mod.REGAIN, 75)

    -- Trust synergy: when Ajido-Marujido is present, Apururu gains Cure Potency +25%.
    -- This is dynamic so the modifier is removed if the party composition changes.
    local lastAjidoCurePotencyBonus = 0
    mob:addListener('COMBAT_TICK', 'APURURU_UC_AJIDO_SYNERGY_CTICK', function(mobArg)
        local targetBonus = 0
        local master = mobArg:getMaster()

        if master ~= nil then
            local party = master:getPartyWithTrusts()
            for _, member in pairs(party) do
                if
                    member:getObjType() == xi.objType.TRUST and
                    member:getTrustID() == xi.magic.spell.AJIDO_MARUJIDO
                then
                    targetBonus = 25
                    break
                end
            end
        end

        if targetBonus ~= lastAjidoCurePotencyBonus then
            mobArg:delMod(xi.mod.CURE_POTENCY, lastAjidoCurePotencyBonus)
            mobArg:addMod(xi.mod.CURE_POTENCY, targetBonus)
            lastAjidoCurePotencyBonus = targetBonus
        end
    end)

    mob:setAutoAttackEnabled(false)

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MID_RANGE)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
