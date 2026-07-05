-----------------------------------
-- Trust: Pieuje (UC)
-----------------------------------
---@type TSpellTrust
local spellObject = {}

local function trustMessage(mob, offset)
    local messageOffset = xi.trust.messageOffset or xi.trust.message_offset
    xi.trust.message(mob, messageOffset[offset])
end

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.PIEUJE_UC)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

local function hasValidConditions(conditions)
    if conditions == nil then
        return false
    end

    if type(conditions[1]) == "table" then
        for _, condition in ipairs(conditions) do
            if condition[1] == nil or condition[2] == nil then
                return false
            end
        end

        return true
    end

    return conditions[1] ~= nil and conditions[2] ~= nil
end

local function addGambitIf(mob, targetType, conditions, reaction)
    if
        targetType ~= nil and
        hasValidConditions(conditions) and
        reaction ~= nil and
        reaction[1] ~= nil and
        reaction[2] ~= nil and
        reaction[3] ~= nil
    then
        mob:addGambit(targetType, conditions, reaction)
    end
end

local function addProtectShellGambits(mob, targetType)
    addGambitIf(mob, targetType, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECTRA })
    addGambitIf(mob, targetType, { ai.c.NOT_STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SHELLRA })
end

local function addHasteGambit(mob, targetType)
    addGambitIf(mob, targetType, { ai.c.NOT_STATUS, xi.effect.HASTE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.HASTE })
end

local function addStatusRemovalGambits(mob, targetType)
    addGambitIf(mob, targetType, { ai.c.STATUS, xi.effect.POISON }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.POISONA })
    addGambitIf(mob, targetType, { ai.c.STATUS, xi.effect.PARALYSIS }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PARALYNA })
    addGambitIf(mob, targetType, { ai.c.STATUS, xi.effect.BLINDNESS }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.BLINDNA })
    addGambitIf(mob, targetType, { ai.c.STATUS, xi.effect.SILENCE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SILENA })
    addGambitIf(mob, targetType, { ai.c.STATUS, xi.effect.PETRIFICATION }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STONA })
    addGambitIf(mob, targetType, { ai.c.STATUS, xi.effect.DISEASE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.VIRUNA })
    addGambitIf(mob, targetType, { ai.c.STATUS, xi.effect.PLAGUE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.VIRUNA })
    addGambitIf(mob, targetType, { ai.c.STATUS, xi.effect.CURSE_I }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURSNA })
    addGambitIf(mob, targetType, { ai.c.STATUS, xi.effect.CURSE_II }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURSNA })
end

local function addEsunaGambits(mob)
    -- Retail behavior: in Afflatus Misery, Esuna is self-centered and removes
    -- matching debuffs from party members in range.
    addGambitIf(mob, ai.t.SELF, { { ai.c.STATUS, xi.effect.POISON }, { ai.c.STATUS, xi.effect.AFFLATUS_MISERY }, { ai.c.LVL_GTE, 61 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ESUNA })
    addGambitIf(mob, ai.t.SELF, { { ai.c.STATUS, xi.effect.PARALYSIS }, { ai.c.STATUS, xi.effect.AFFLATUS_MISERY }, { ai.c.LVL_GTE, 61 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ESUNA })
    addGambitIf(mob, ai.t.SELF, { { ai.c.STATUS, xi.effect.BLINDNESS }, { ai.c.STATUS, xi.effect.AFFLATUS_MISERY }, { ai.c.LVL_GTE, 61 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ESUNA })
    addGambitIf(mob, ai.t.SELF, { { ai.c.STATUS, xi.effect.SILENCE }, { ai.c.STATUS, xi.effect.AFFLATUS_MISERY }, { ai.c.LVL_GTE, 61 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ESUNA })
    addGambitIf(mob, ai.t.SELF, { { ai.c.STATUS, xi.effect.DISEASE }, { ai.c.STATUS, xi.effect.AFFLATUS_MISERY }, { ai.c.LVL_GTE, 61 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ESUNA })
    addGambitIf(mob, ai.t.SELF, { { ai.c.STATUS, xi.effect.PLAGUE }, { ai.c.STATUS, xi.effect.AFFLATUS_MISERY }, { ai.c.LVL_GTE, 61 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ESUNA })
    addGambitIf(mob, ai.t.SELF, { { ai.c.STATUS, xi.effect.PETRIFICATION }, { ai.c.STATUS, xi.effect.AFFLATUS_MISERY }, { ai.c.LVL_GTE, 61 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ESUNA })
    addGambitIf(mob, ai.t.SELF, { { ai.c.STATUS, xi.effect.CURSE_I }, { ai.c.STATUS, xi.effect.AFFLATUS_MISERY }, { ai.c.LVL_GTE, 61 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ESUNA })

    if ai.c.STATUS_FLAG ~= nil and xi.effectFlag ~= nil and xi.effectFlag.ERASABLE ~= nil then
        addGambitIf(mob, ai.t.SELF, { { ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE }, { ai.c.STATUS, xi.effect.AFFLATUS_MISERY }, { ai.c.LVL_GTE, 61 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ESUNA })
    end
end

spellObject.onMobSpawn = function(mob)
    trustMessage(mob, "SPAWN")

    -- Retail notes:
    -- WHM/PLD. Cure I-VI, -na, Erase, Esuna, Protect/ra, Shell/ra, Auspice, Haste.
    -- Afflatus Misery, Sacrosanctity. Starlight, Moonlight, Nott.
    -- Regain 34 TP/tick. Stays in place but can club enemies that are already nearby.
    -- Trion-specific Regen priority is not hardcoded because this branch has no safe Trion target selector.

    mob:addMod(xi.mod.REGAIN, 34)

    if xi.mod.REFRESH ~= nil then
        mob:addMod(xi.mod.REFRESH, 1)
    end

    if xi.mod.SLEEPRES ~= nil then
        mob:addMod(xi.mod.SLEEPRES, 15)
    end

    mob:setAutoAttackEnabled(true)
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.NO_MOVE)

    addGambitIf(mob, ai.t.SELF, { { ai.c.NOT_STATUS, xi.effect.AFFLATUS_MISERY }, { ai.c.LVL_GTE, 40 } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.AFFLATUS_MISERY })
    addGambitIf(mob, ai.t.SELF, { { ai.c.NOT_STATUS, xi.effect.AUSPICE }, { ai.c.LVL_GTE, 55 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.AUSPICE })

    if xi.effect.SACROSANCTITY ~= nil and xi.ja.SACROSANCTITY ~= nil then
        addGambitIf(mob, ai.t.SELF, { { ai.c.NOT_STATUS, xi.effect.SACROSANCTITY }, { ai.c.LVL_GTE, 95 } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SACROSANCTITY })
    end

    addGambitIf(mob, ai.t.SELF, { { ai.c.MPP_LT, 90 }, { ai.c.LVL_GTE, 50 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, xi.mobSkill.NOTT })
    addGambitIf(mob, ai.t.SELF, { { ai.c.MPP_LT, 75 }, { ai.c.LVL_GTE, 25 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, xi.mobSkill.MOONLIGHT })
    addGambitIf(mob, ai.t.SELF, { { ai.c.MPP_LT, 60 }, { ai.c.LVL_GTE, 5 }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, xi.mobSkill.STARLIGHT })

    addGambitIf(mob, ai.t.PARTY, { ai.c.STATUS, xi.effect.SLEEP_I }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE })
    addGambitIf(mob, ai.t.PARTY, { ai.c.STATUS, xi.effect.SLEEP_II }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE })

    addGambitIf(mob, ai.t.PARTY, { ai.c.HPP_LT, 25 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })

    addEsunaGambits(mob)

    addStatusRemovalGambits(mob, ai.t.MASTER)
    addStatusRemovalGambits(mob, ai.t.SELF)
    addStatusRemovalGambits(mob, ai.t.PARTY)

    if ai.c.STATUS_FLAG ~= nil and xi.effectFlag ~= nil and xi.effectFlag.ERASABLE ~= nil then
        addGambitIf(mob, ai.t.MASTER, { ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE })
        addGambitIf(mob, ai.t.SELF, { ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE })
        addGambitIf(mob, ai.t.PARTY, { ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE })
    end

    addHasteGambit(mob, ai.t.MASTER)
    addHasteGambit(mob, ai.t.TANK)
    addHasteGambit(mob, ai.t.MELEE)
    addHasteGambit(mob, ai.t.RANGED)
    addHasteGambit(mob, ai.t.CASTER)

    addProtectShellGambits(mob, ai.t.MASTER)
    addProtectShellGambits(mob, ai.t.SELF)
    addProtectShellGambits(mob, ai.t.TANK)
    addProtectShellGambits(mob, ai.t.MELEE)
    addProtectShellGambits(mob, ai.t.RANGED)
    addProtectShellGambits(mob, ai.t.CASTER)

    addGambitIf(mob, ai.t.PARTY, { ai.c.HPP_LT, 75 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })

    if xi.magic.spell.FLASH ~= nil then
        if xi.effect.FLASH ~= nil then
            addGambitIf(mob, ai.t.TARGET, { { ai.c.NOT_STATUS, xi.effect.FLASH }, { ai.c.LVL_GTE, 45 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.FLASH })
        else
            addGambitIf(mob, ai.t.TARGET, { { ai.c.ALWAYS, 0 }, { ai.c.LVL_GTE, 45 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.FLASH })
        end
    end
end

spellObject.onMobDespawn = function(mob)
    trustMessage(mob, "DESPAWN")
end

spellObject.onMobDeath = function(mob)
    trustMessage(mob, "DEATH")
end

return spellObject