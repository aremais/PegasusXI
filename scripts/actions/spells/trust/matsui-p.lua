-----------------------------------
-- Trust: Matsui-P
-----------------------------------
require('scripts/globals/trust')
-----------------------------------
local spellObject = {}

local matsuiPSpell = xi.magic.spell.MATSUI_P or 1003

local function addModIfKnown(mob, modId, value)
    if modId ~= nil and value ~= nil then
        mob:addMod(modId, value)
    end
end

local function addGambitIfKnown(mob, targetType, condition, action, cooldown)
    if
        targetType == nil or
        condition == nil or
        condition[1] == nil or
        condition[2] == nil or
        action == nil or
        action[1] == nil or
        action[2] == nil or
        action[3] == nil
    then
        return
    end

    if cooldown ~= nil then
        mob:addGambit(targetType, condition, action, cooldown)
    else
        mob:addGambit(targetType, condition, action)
    end
end

local function addStatusJA(mob, level, statusEffect, jobAbility, cooldown)
    if
        mob:getMainLvl() >= level and
        statusEffect ~= nil and
        jobAbility ~= nil
    then
        addGambitIfKnown(mob, ai.t.SELF, { ai.c.NOT_STATUS, statusEffect }, { ai.r.JA, ai.s.SPECIFIC, jobAbility }, cooldown)
    end
end

local function addAlwaysJA(mob, level, jobAbility, cooldown)
    if
        mob:getMainLvl() >= level and
        jobAbility ~= nil and
        ai.c.ALWAYS ~= nil
    then
        addGambitIfKnown(mob, ai.t.SELF, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, jobAbility }, cooldown)
    end
end

local function addStatusSpell(mob, targetType, level, statusEffect, spellId, cooldown)
    if
        mob:getMainLvl() >= level and
        statusEffect ~= nil and
        spellId ~= nil
    then
        addGambitIfKnown(mob, targetType, { ai.c.NOT_STATUS, statusEffect }, { ai.r.MA, ai.s.SPECIFIC, spellId }, cooldown)
    end
end

local function addAlwaysSpell(mob, targetType, level, spellId, cooldown)
    if
        mob:getMainLvl() >= level and
        spellId ~= nil and
        ai.c.ALWAYS ~= nil
    then
        addGambitIfKnown(mob, targetType, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.SPECIFIC, spellId }, cooldown)
    end
end

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, matsuiPSpell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Retail target:
    -- Matsui-P is a NIN/BLM damage Trust that opens skillchains and magic bursts
    -- with elemental ninjutsu and tier-I black magic.
    -- Enable actual mob offhand swings first; xi.mod.DUAL_WIELD only handles delay reduction.
    if xi.mobMod ~= nil and xi.mobMod.DUAL_WIELD ~= nil then
        mob:setMobMod(xi.mobMod.DUAL_WIELD, 1)
    end

    addModIfKnown(mob, xi.mod.DUAL_WIELD, 25)
    addModIfKnown(mob, xi.mod.DAKEN, 25)
    addModIfKnown(mob, xi.mod.MATT, 35)
    addModIfKnown(mob, xi.mod.MACC, 35)
    addModIfKnown(mob, xi.mod.FASTCAST, 20)
    addModIfKnown(mob, xi.mod.STORETP, 20)
    addModIfKnown(mob, xi.mod.SUBTLE_BLOW, 15)

    local lvl = mob:getMainLvl()

    -- Shadows and defensive NIN tools.
    if
        lvl >= 12 and
        xi.effect.COPY_IMAGE ~= nil and
        xi.magic.spellFamily.UTSUSEMI ~= nil
    then
        addGambitIfKnown(mob, ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.COPY_IMAGE }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.UTSUSEMI }, 20)
    end

    addStatusSpell(mob, ai.t.SELF, 88, xi.effect.MIGAWARI, xi.magic.spell.MIGAWARI_ICHI, 120)

    -- Self-buffs / job abilities.
    addAlwaysSpell(mob, ai.t.SELF, 78, xi.magic.spell.KAKKA_ICHI, 300)
    addAlwaysSpell(mob, ai.t.SELF, 85, xi.magic.spell.MYOSHU_ICHI, 300)

    addStatusJA(mob, 40, xi.effect.INNIN, xi.ja.INNIN, 180)
    addStatusJA(mob, 75, xi.effect.SANGE, xi.ja.SANGE, 180)
    addStatusJA(mob, 15, xi.effect.ELEMENTAL_SEAL, xi.ja.ELEMENTAL_SEAL, 600)
    addStatusJA(mob, 77, xi.effect.FUTAE, xi.ja.FUTAE, 180)
    addAlwaysJA(mob, 95, xi.ja.ISSEKIGAN, 300)

    -- Listed behavior includes Mana Wall, but it is guarded because Matsui-P is BLM subjob.
    addStatusJA(mob, 76, xi.effect.MANA_WALL, xi.ja.MANA_WALL, 600)

    -- Magic burst behavior.
    if
        ai.c.MB_AVAILABLE ~= nil and
        ai.s.MB_ELEMENT ~= nil and
        xi.magic.spellFamily.NONE ~= nil
    then
        addGambitIfKnown(mob, ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 }, { ai.r.MA, ai.s.MB_ELEMENT, xi.magic.spellFamily.NONE })
    end

    -- Debuffs and interrupt tools.
    addStatusSpell(mob, ai.t.TARGET, 83, xi.effect.MAGIC_DEF_DOWN, xi.magic.spell.AISHA_ICHI, 90)
    addStatusSpell(mob, ai.t.TARGET, 83, xi.effect.ACCURACY_DOWN, xi.magic.spell.YURIN_ICHI, 90)
    addStatusSpell(mob, ai.t.TARGET, 30, xi.effect.PARALYSIS, xi.magic.spell.JUBAKU_ICHI, 60)
    addStatusSpell(mob, ai.t.TARGET, 23, xi.effect.SLOW, xi.magic.spell.HOJO_ICHI, 60)
    addStatusSpell(mob, ai.t.TARGET, 19, xi.effect.BLINDNESS, xi.magic.spell.KURAYAMI_ICHI, 60)
    addStatusSpell(mob, ai.t.TARGET, 27, xi.effect.POISON, xi.magic.spell.DOKUMORI_ICHI, 60)
    addStatusSpell(mob, ai.t.TARGET, 24, xi.effect.BURN, xi.magic.spell.BURN, 90)
    addAlwaysSpell(mob, ai.t.TARGET, 12, xi.magic.spell.DRAIN, 180)

    if
        lvl >= 45 and
        ai.c.CASTING_MA ~= nil and
        xi.magic.spell.STUN ~= nil
    then
        addGambitIfKnown(mob, ai.t.TARGET, { ai.c.CASTING_MA, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN }, 20)
    end

    addAlwaysSpell(mob, ai.t.TARGET, 25, xi.magic.spell.ASPIR, 180)

    -- General magic fallback.
    -- Keep this as one HIGHEST/NONE gambit so Matsui-P does not juggle twelve
    -- separate elemental filler timers. MB_ELEMENT above handles actual magic bursts.
    if xi.magic.spellFamily.NONE ~= nil then
        if ai.c.NOT_SC_AVAILABLE ~= nil then
            addGambitIfKnown(mob, ai.t.TARGET, { ai.c.NOT_SC_AVAILABLE, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.NONE }, 45)
        else
            addGambitIfKnown(mob, ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.NONE }, 60)
        end
    end

    -- Matsui-P opens skillchains like Ayame.
    -- The DB skill list 1135 already supplies Blade: Rin/Retsu/Ei/Jin/Ten/Ku/Kamu/Hi/Shun.
    mob:setTrustTPSkillSettings(ai.tp.OPENER, ai.s.SPECIAL_AYAME)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
