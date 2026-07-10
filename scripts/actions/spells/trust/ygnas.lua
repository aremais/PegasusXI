-----------------------------------
-- Trust: Ygnas
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

    -- Retail notes:
    -- WHM/PLD healer. Keeps distance, does not auto-attack/enfeeble.
    -- Casts Cure I-VI, Erase/-na, Protect/Shell and Protectra/Shellra up to V, and Haste.
    -- Special traits: HP+10%, MP+10%, Cure Potency +50%, Fast Cast +50%,
    -- Regain 30 TP/tick, Beast Killer, and MP sustain behavior.
    mob:addMod(xi.mod.HPP, 10)
    mob:addMod(xi.mod.MPP, 10)
    mob:addMod(xi.mod.CURE_POTENCY, 50)
    mob:addMod(xi.mod.FASTCAST, 50)
    mob:addMod(xi.mod.REFRESH, 3)
    mob:addMod(xi.mod.REGAIN, 30)
    mob:addMod(xi.mod.BEAST_KILLER, 10)

    -- Ygnas prefers efficient curing. At 99, retail behavior heavily favors Cure III
    -- unless allies are low enough to justify Cure VI/highest cure.
    -- Keep this level-safe so lower-level spell gates are respected.
    local mainLevel = mob:getMainLvl()
    local efficientCure = xi.magic.spell.CURE or 1

    if mainLevel >= 21 then
        efficientCure = xi.magic.spell.CURE_III or 3
    elseif mainLevel >= 11 then
        efficientCure = xi.magic.spell.CURE_II or 2
    end

    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 45 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 75 }, { ai.r.MA, ai.s.SPECIFIC, efficientCure })

    -- Defensive buffs.
    -- Avoid broad PARTY targeting because passive aura Trusts such as Star Sibyl/Cornelia
    -- may not receive Protect/Shell and can cause infinite Protectra/Shellra loops.
    local protectShellTargets = { ai.t.MASTER, ai.t.SELF, ai.t.TANK, ai.t.MELEE, ai.t.RANGED }
    for _, targetType in ipairs(protectShellTargets) do
        mob:addGambit(targetType, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECTRA })
        mob:addGambit(targetType, { ai.c.NOT_STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SHELLRA })
        mob:addGambit(targetType, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECT })
        mob:addGambit(targetType, { ai.c.NOT_STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SHELL })
    end

    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.HASTE }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.HASTE })

    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.POISON }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.POISONA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.PARALYSIS }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PARALYNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.BLINDNESS }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.BLINDNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.SILENCE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SILENA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.PETRIFICATION }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STONA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.DISEASE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.VIRUNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.CURSE_I }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURSNA })

    -- Some LSB builds do not expose STATUS_FLAG/effectFlag. Guard it so Ygnas cannot crash on spawn.
    if
        ai.c.STATUS_FLAG ~= nil and
        xi.effectFlag ~= nil and
        xi.effectFlag.ERASABLE ~= nil
    then
        mob:addGambit(ai.t.SELF, { ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE })
        mob:addGambit(ai.t.PARTY, { ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE })
    end

    mob:setAutoAttackEnabled(false)
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.LONG_RANGE)

    -- Do not force ASAP/random TP use here. Retail Ygnas is delayed/conservative with TP,
    -- and some LSB builds do not expose setTrustTPSkillSettings or ai.s.RANDOM.
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
