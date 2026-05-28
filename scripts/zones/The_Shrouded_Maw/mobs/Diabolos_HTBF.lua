-----------------------------------
-- Area: The Shrouded Maw
--  Mob: Diabolos Prime
-- Involved in: Waking Dreams HTBF
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:setMobMod(xi.mobMod.ALWAYS_AGGRO, 1)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.PETRIFY)
    mob:addImmunity(xi.immunity.SILENCE)
    mob:addImmunity(xi.immunity.SLOW)
    mob:addImmunity(xi.immunity.TERROR)
end

entity.onMobSpawn = function(mob)
    mob:setLocalVar('nightmarePercent', math.random(50, 75))
    mob:setLocalVar('ruinousOmenPercent', math.random(35, 49))
    mob:setMagicCastingEnabled(false)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 150)
    mob:setMobMod(xi.mobMod.NO_STANDBACK, 1)
    mob:setMobMod(xi.mobMod.MAGIC_COOL, 20)
    mob:setMod(xi.mod.REGAIN, 55)
    mob:setMobMod(xi.mobMod.DETECTION, xi.detects.SIGHT)
end

entity.onMobEngage = function(mob, target)
    -- Enable magic casting after 20 seconds
    mob:timer(20000, function(mobArg)
        mobArg:setMagicCastingEnabled(true)
    end)
end

entity.onMobFight = function(mob, target)
    local currentHP = mob:getHPP()

    if
        currentHP <= mob:getLocalVar('nightmarePercent') and
        mob:getLocalVar('nightmareUsed') == 0
    then
        mob:setLocalVar('nightmareUsed', 1)
        mob:useMobAbility(xi.mobSkill.NIGHTMARE_1)
    end

    if
        currentHP <= mob:getLocalVar('ruinousOmenPercent') and
        mob:getLocalVar('ruinousOmenUsed') == 0
    then
        mob:setLocalVar('ruinousOmenUsed', 1)
        mob:useMobAbility(xi.mobSkill.RUINOUS_OMEN_1)
    end
end

entity.onMobMobskillChoose = function(mob, target, skillId)
    local skills =
    {
        { skill = xi.mobSkill.NETHER_BLAST_1,    weight = 25 },
        { skill = xi.mobSkill.NOCTOSHIELD_1,     weight = 10 },
        { skill = xi.mobSkill.ULTIMATE_TERROR_1, weight = 10 },
        { skill = xi.mobSkill.SOMNOLENCE_1,      weight = 10 },
        { skill = xi.mobSkill.CACODEMONIA_1,     weight = 10 },
        { skill = xi.mobSkill.CAMISADO_2,        weight = 10 },
        { skill = xi.mobSkill.DREAM_SHROUD_1,    weight = 10 },
        { skill = xi.mobSkill.NIGHTMARE_1,       weight = 5  },
    }

    local roll = math.random(1, 100)
    local cumulative = 0

    for _, entry in ipairs(skills) do
        cumulative = cumulative + entry.weight
        if roll <= cumulative then
            return entry.skill
        end
    end

    return xi.mobSkill.NOCTOSHIELD_1
end

entity.onMobWeaponSkill = function(mob, target, skill, action)
    local skillId = skill:getID()

    if
        skillId == xi.mobSkill.ULTIMATE_TERROR_1 or
        skillId == xi.mobSkill.CACODEMONIA_1 or
        skillId == xi.mobSkill.NIGHTMARE_1
    then
        local camisado = math.random(1, 2) == 1 and xi.mobSkill.CAMISADO_1 or xi.mobSkill.CAMISADO_2
        mob:queue(0, function(mobArg)
            mobArg:useMobAbility(camisado)
        end)
    end
end

entity.onMobSpellChoose = function(mob, target, spellId)
    local spellList =
    {
        [1] = { xi.magic.spell.DISPELGA, target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [2] = { xi.magic.spell.DISPEL,   target, false, xi.action.type.DAMAGE_TARGET,     nil,                 0, 100 },
        [3] = { xi.magic.spell.DRAIN,    target, false, xi.action.type.DRAIN_HP,          nil,                 0, 100 },
        [4] = { xi.magic.spell.ASPIR,    target, false, xi.action.type.DRAIN_MP,          nil,                 0, 100 },
        [5] = { xi.magic.spell.BIO_III,  target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.BIO,       6, 100 },
        [6] = { xi.magic.spell.BLIND,    target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.BLINDNESS, 1, 100 },
        [7] = { xi.magic.spell.SLEEP_II, target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.SLEEP_I,   2, 100 },
        [8] = { xi.magic.spell.SLEEPGA,  target, false, xi.action.type.ENFEEBLING_TARGET, xi.effect.SLEEP_I,   1, 100 },
    }

    return xi.combat.behavior.chooseAction(mob, target, nil, spellList)
end

return entity
