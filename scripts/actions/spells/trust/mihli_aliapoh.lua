-----------------------------------
-- Trust: Mihli Aliapoh
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    -- Records of Eminence: Alter Ego: Mihli Aliapoh
    if caster:getEminenceProgress(934) then
        xi.roe.onRecordTrigger(caster, 934)
    end

    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.teamworkMessage(mob, {
        [xi.magic.spell.RUGHADJEEN] = xi.trust.messageOffset.TEAMWORK_1,
        [xi.magic.spell.GADALAR] = xi.trust.messageOffset.TEAMWORK_2,
        [xi.magic.spell.NAJELITH] = xi.trust.messageOffset.TEAMWORK_3,
        [xi.magic.spell.ZAZARG] = xi.trust.messageOffset.TEAMWORK_4,
    })

    -- Retail notes: Cure Potency Bonus +5% and unusually high Healing Magic skill.
    mob:addMod(xi.mod.CURE_POTENCY, 5)

    if xi.mod.HEALING then
        mob:addMod(xi.mod.HEALING, 500)
    elseif xi.mod.HEALING_MAGIC then
        mob:addMod(xi.mod.HEALING_MAGIC, 500)
    end

    -- Rughadjeen serpent-general synergy:
    -- Mihli Aliapoh gains +25% Cure Potency while Rughadjeen is present.
    local lastRughadjeenBonus = 0
    mob:addListener('COMBAT_TICK', 'MIHLI_ALIAPOH_CTICK', function(mobArg)
        local targetBonus = 0
        local master = mobArg:getMaster()

        if master ~= nil then
            local party = master:getPartyWithTrusts()

            for _, member in pairs(party) do
                if
                    member:getObjType() == xi.objType.TRUST and
                    member:getTrustID() == xi.magic.spell.RUGHADJEEN
                then
                    targetBonus = 25
                    break
                end
            end
        end

        if targetBonus ~= lastRughadjeenBonus then
            mobArg:delMod(xi.mod.CURE_POTENCY, lastRughadjeenBonus)
            mobArg:addMod(xi.mod.CURE_POTENCY, targetBonus)
            lastRughadjeenBonus = targetBonus
        end
    end)

    -- Afflatus Solace.
    mob:addGambit(ai.t.SELF, { { ai.c.NOT_STATUS, xi.effect.AFFLATUS_SOLACE }, { ai.c.LVL_GTE, 40 } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.AFFLATUS_SOLACE })

    -- Status removal: Mihli prioritizes herself first.
    mob:addGambit(ai.t.SELF, { ai.c.STATUS, xi.effect.POISON }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.POISONA })
    mob:addGambit(ai.t.SELF, { ai.c.STATUS, xi.effect.PARALYSIS }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PARALYNA })
    mob:addGambit(ai.t.SELF, { ai.c.STATUS, xi.effect.BLINDNESS }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.BLINDNA })
    mob:addGambit(ai.t.SELF, { ai.c.STATUS, xi.effect.SILENCE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SILENA })
    mob:addGambit(ai.t.SELF, { ai.c.STATUS, xi.effect.PETRIFICATION }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STONA })
    mob:addGambit(ai.t.SELF, { ai.c.STATUS, xi.effect.DISEASE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.VIRUNA })
    mob:addGambit(ai.t.SELF, { ai.c.STATUS, xi.effect.CURSE_I }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURSNA })
    mob:addGambit(ai.t.SELF, { ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE })

    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.POISON }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.POISONA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.PARALYSIS }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PARALYNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.BLINDNESS }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.BLINDNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.SILENCE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SILENA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.PETRIFICATION }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STONA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.DISEASE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.VIRUNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.CURSE_I }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURSNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE })

    -- Wake sleeping party members with Cure.
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.SLEEP_I }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.SLEEP_II }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE })

    -- Retail-style healing thresholds:
    -- tank/current top-enmity target under 75%, everyone else under 50%.
    mob:addGambit(ai.t.TOP_ENMITY, { ai.c.HPP_LT, 75 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 50 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })

    -- Single-target recovery buffs after dispel/loss.
    -- Defensive buffs.
    -- Avoid broad PARTY targeting because passive aura Trusts such as Star Sibyl/Cornelia
    -- may not receive Protect/Shell and can cause infinite Protect/Shell loops.
    local protectShellTargets = { ai.t.MASTER, ai.t.SELF, ai.t.TANK, ai.t.MELEE, ai.t.RANGED }
    for _, targetType in ipairs(protectShellTargets) do
        mob:addGambit(targetType, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECTRA })
        mob:addGambit(targetType, { ai.c.NOT_STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SHELLRA })
        mob:addGambit(targetType, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECT })
        mob:addGambit(targetType, { ai.c.NOT_STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SHELL })
    end

    -- Lowest-priority enfeebling: Slow first, then Paralyze.
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.SLOW }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SLOW }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.PARALYSIS }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PARALYZE }, 60)

    -- Mihli prefers Scouring Bubbles and does not intentionally skillchain.
    mob:addGambit(ai.t.SELF, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 3203 })
    mob:addGambit(ai.t.SELF, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.HIGHEST, 0 })

    mob:addListener('WEAPONSKILL_USE', 'MIHLI_ALIAPOH_WEAPONSKILL_USE', function(mobArg, target, skill, tp, action, damage)
        if skill:getID() == 3203 then -- Scouring Bubbles
            -- Bah! Guess I'll pull out another one of my trrricks!
            if math.random(1, 100) <= 33 then
                xi.trust.message(mobArg, xi.trust.messageOffset.SPECIAL_MOVE_1)
            end
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
