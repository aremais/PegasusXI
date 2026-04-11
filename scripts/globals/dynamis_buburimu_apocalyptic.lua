-----------------------------------
-- Dynamis - Buburimu: Apocalyptic Beast / Arch Apocalyptic Beast (bg-wiki)
-- Shadescale Skull: locks breaths (flame, poison, wind)
-- Shadescale Femur: locks Body Slam, Heavy Stomp
-- Shadescale Talon: locks Chaos Blade, Petro Eyes
-- Shadescale Heart: locks Nullsong, Thornsong, Lodesong
-----------------------------------
xi = xi or {}
xi.dynamis = xi.dynamis or {}

local zoneId = xi.zone.DYNAMIS_BUBURIMU

-- Mob skill IDs (mob_skills.mob_skill_id) on Dragon family list + Nullsong
local skillPool =
{
    642,  -- flame_breath
    643,  -- poison_breath_dragon
    644,  -- wind_breath
    645,  -- body_slam
    646,  -- heavy_stomp
    647,  -- chaos_blade
    648,  -- petro_eyes
    649,  -- voidsong
    650,  -- thornsong
    651,  -- lodesong
    1792, -- nullsong
}

local mobNames =
{
    ['Apocalyptic_Beast']      = true,
    ['Arch_Apocalyptic_Beast'] = true,
}

local itemLocks =
{
    DynamisApocalypticShadescaleSkull  = { [642] = true, [643] = true, [644] = true },
    DynamisApocalypticShadescaleFemur  = { [645] = true, [646] = true },
    DynamisApocalypticShadescaleTalon  = { [647] = true, [648] = true },
    DynamisApocalypticShadescaleHeart  = { [1792] = true, [650] = true, [651] = true },
}

local function isApocalypticFamily(mob)
    return mob and not mob:isPC() and mobNames[mob:getName()] == true
end

local function buildBlocked(mob)
    local blocked = {}

    for varName, skills in pairs(itemLocks) do
        if mob:getLocalVar(varName) == 1 then
            for skillId, _ in pairs(skills) do
                blocked[skillId] = true
            end
        end
    end

    return blocked
end

local function pickUnblockedSkill(blocked)
    local pool = {}

    for _, skillId in ipairs(skillPool) do
        if not blocked[skillId] then
            table.insert(pool, skillId)
        end
    end

    if #pool == 0 then
        return 0
    end

    return pool[math.random(1, #pool)]
end

xi.dynamis.buburimuApocalypticItemCheck = function(target, varName)
    if
        not target or
        target:isPC() or
        target:getZoneID() ~= zoneId or
        not isApocalypticFamily(target)
    then
        return xi.msg.basic.ITEM_CANNOT_USE_ON
    end

    if target:getLocalVar(varName) == 1 then
        return xi.msg.basic.ITEM_UNABLE_TO_USE
    end

    return 0
end

xi.dynamis.buburimuApocalypticItemUse = function(target, user, varName)
    target:setLocalVar(varName, 1)
    target:weaknessTrigger(1)
end

xi.dynamis.buburimuApocalypticOnMobMobskillChoose = function(mob, target, skillId)
    if not isApocalypticFamily(mob) then
        return 0
    end

    local blocked = buildBlocked(mob)
    if not blocked[skillId] then
        return 0
    end

    return pickUnblockedSkill(blocked)
end
