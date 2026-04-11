-----------------------------------
-- Dynamis - Valkurm: Cirrate & Arch Christelle (retail-style)
-- Timed / Lost NM deaths unlock weak breath tiers on the mega boss.
-- Odorless Fungus, Absorbent Moss, Redolent Root lock abilities (bg-wiki).
-----------------------------------
xi = xi or {}
xi.dynamis = xi.dynamis or {}

-- 1 = corresponding timed (or Lost) family NM defeated this run → boss uses weak breath for that line
local svWeakMiasmic  = '[DynaValk]ChristelleWeakMiasmic'
local svWeakFragrant = '[DynaValk]ChristelleWeakFragrant'
local svWeakPutrid   = '[DynaValk]ChristelleWeakPutrid'

local mobNameCirrate = 'Cirrate_Christelle'

local charmSkillId = 1337

-- After moss: % chance to redirect standalone Charm into another allowed TP move (retail: fewer charms)
local charmMitigationChance = 65

local cirrateConfig =
{
    miasmic  = { weak = 1604, strong = 1605 },
    fragrant = { weak = 1606, strong = 1607 },
    putrid   = { weak = 1608, strong = 1609 },
    extra    = { 1610, 1611, charmSkillId }, -- EBB, Vampiric, Charm
    itemLocks =
    {
        DynamisChristelleFungus = { [1604] = true, [1605] = true },
        DynamisChristelleMoss   = { [1606] = true, [1607] = true },
        DynamisChristelleRoot   = { [1608] = true, [1609] = true, [1611] = true },
    },
}

xi.dynamis.valkurmResetChristelleTiers = function()
    SetServerVariable(svWeakMiasmic, 0)
    SetServerVariable(svWeakFragrant, 0)
    SetServerVariable(svWeakPutrid, 0)
end

---@param line 'miasmic'|'fragrant'|'putrid'
xi.dynamis.valkurmMarkChristelleWeakTier = function(line)
    if line == 'miasmic' then
        SetServerVariable(svWeakMiasmic, 1)
    elseif line == 'fragrant' then
        SetServerVariable(svWeakFragrant, 1)
    elseif line == 'putrid' then
        SetServerVariable(svWeakPutrid, 1)
    end
end

local function snapshotTierLocals(mob)
    mob:setLocalVar('ChristelleTierMiasmic', GetServerVariable(svWeakMiasmic) == 1 and 1 or 0)
    mob:setLocalVar('ChristelleTierFragrant', GetServerVariable(svWeakFragrant) == 1 and 1 or 0)
    mob:setLocalVar('ChristelleTierPutrid', GetServerVariable(svWeakPutrid) == 1 and 1 or 0)
end

local function buildAllowedCirrate(mob)
    local allowed = {}

    if mob:getLocalVar('ChristelleTierMiasmic') == 1 then
        allowed[cirrateConfig.miasmic.weak] = true
    else
        allowed[cirrateConfig.miasmic.strong] = true
    end

    if mob:getLocalVar('ChristelleTierFragrant') == 1 then
        allowed[cirrateConfig.fragrant.weak] = true
    else
        allowed[cirrateConfig.fragrant.strong] = true
    end

    if mob:getLocalVar('ChristelleTierPutrid') == 1 then
        allowed[cirrateConfig.putrid.weak] = true
    else
        allowed[cirrateConfig.putrid.strong] = true
    end

    for _, skillId in ipairs(cirrateConfig.extra) do
        allowed[skillId] = true
    end

    return allowed
end

local function buildItemBlocked(mob, itemLocks)
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

local function pickRandomSkill(allowed, blocked, preferExclude)
    local pool = {}
    for skillId, _ in pairs(allowed) do
        if
            not blocked[skillId] and
            (not preferExclude or skillId ~= preferExclude)
        then
            table.insert(pool, skillId)
        end
    end

    if #pool == 0 then
        for skillId, _ in pairs(allowed) do
            if not blocked[skillId] then
                table.insert(pool, skillId)
            end
        end
    end

    if #pool == 0 then
        return 0
    end

    return pool[math.random(1, #pool)]
end

xi.dynamis.valkurmChristelleOnSpawn = function(mob)
    snapshotTierLocals(mob)
    -- Retail: enhanced movement until Odorless Fungus; use elevated run multiplier when mod unset/low
    local mult = mob:getMobMod(xi.mobMod.RUN_SPEED_MULT)
    if mult <= 100 then
        mob:setMobMod(xi.mobMod.RUN_SPEED_MULT, 130)
    end
end

xi.dynamis.valkurmChristelleItemCheck = function(target, varName)
    if
        not target or
        target:isPC() or
        target:getZoneID() ~= xi.zone.DYNAMIS_VALKURM
    then
        return xi.msg.basic.ITEM_CANNOT_USE_ON
    end

    -- bg-wiki: items apply to Cirrate Christelle only (not Arch)
    if target:getName() ~= mobNameCirrate then
        return xi.msg.basic.ITEM_CANNOT_USE_ON
    end

    if target:getLocalVar(varName) == 1 then
        return xi.msg.basic.ITEM_UNABLE_TO_USE
    end

    return 0
end

xi.dynamis.valkurmChristelleItemUse = function(target, user, varName, onApply)
    target:setLocalVar(varName, 1)
    if onApply then
        onApply(target, user)
    end

    target:weaknessTrigger(1)
end

xi.dynamis.valkurmChristelleOnMobMobskillChoose = function(mob, target, skillId)
    if mob:getName() ~= mobNameCirrate then
        return 0
    end

    local allowed   = buildAllowedCirrate(mob)
    local itemLocks = cirrateConfig.itemLocks
    local blocked   = buildItemBlocked(mob, itemLocks)

    -- Absorbent Moss: fewer standalone Charm uses (Fragrant charm is already locked with the breath)
    if
        skillId == charmSkillId and
        mob:getLocalVar('DynamisChristelleMoss') == 1 and
        math.random(100) <= charmMitigationChance
    then
        local alt = pickRandomSkill(allowed, blocked, charmSkillId)
        if alt > 0 then
            return alt
        end
    end

    if allowed[skillId] and not blocked[skillId] then
        return 0
    end

    local picked = pickRandomSkill(allowed, blocked, nil)
    if picked > 0 then
        return picked
    end

    return 0
end
