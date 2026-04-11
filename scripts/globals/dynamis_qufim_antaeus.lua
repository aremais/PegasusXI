-----------------------------------
-- Dynamis - Qufim: Antaeus / Arch Antaeus weakening items (bg-wiki)
-- Perforated Wing: removes damage boost (mob damage multiplier)
-- Sea Monk Venom: removes Regen
-- Undying Moiety: removes per-hit damage soft cap (RECEIVED_DAMAGE_CAP)
-----------------------------------
xi = xi or {}
xi.dynamis = xi.dynamis or {}

local zoneId = xi.zone.DYNAMIS_QUFIM

local mobNames =
{
    ['Antaeus']      = true,
    ['Arch_Antaeus'] = true,
}

local function isAntaeusFamily(mob)
    return mob and not mob:isPC() and mobNames[mob:getName()] == true
end

local function applySpawnBuffs(mob)
    if mob:getName() == 'Arch_Antaeus' then
        mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 170)
        mob:setLocalVar('DynamisAntaeusRegen', 90)
        mob:addMod(xi.mod.REGEN, 90)
        mob:setMod(xi.mod.RECEIVED_DAMAGE_CAP, 220)
        mob:setMod(xi.mod.RECEIVED_DAMAGE_VARIANT, 35)
    else
        mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 140)
        mob:setLocalVar('DynamisAntaeusRegen', 45)
        mob:addMod(xi.mod.REGEN, 45)
        mob:setMod(xi.mod.RECEIVED_DAMAGE_CAP, 280)
        mob:setMod(xi.mod.RECEIVED_DAMAGE_VARIANT, 40)
    end
end

xi.dynamis.qufimAntaeusOnSpawn = function(mob)
    if isAntaeusFamily(mob) then
        applySpawnBuffs(mob)
    end
end

xi.dynamis.qufimAntaeusItemCheck = function(target, varName)
    if
        not target or
        target:isPC() or
        target:getZoneID() ~= zoneId or
        not isAntaeusFamily(target)
    then
        return xi.msg.basic.ITEM_CANNOT_USE_ON
    end

    if target:getLocalVar(varName) == 1 then
        return xi.msg.basic.ITEM_UNABLE_TO_USE
    end

    return 0
end

xi.dynamis.qufimAntaeusItemUse = function(target, user, varName, onApply)
    target:setLocalVar(varName, 1)
    if onApply then
        onApply(target, user)
    end

    target:weaknessTrigger(1)
end
