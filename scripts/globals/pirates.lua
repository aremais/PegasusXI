-----------------------------------
-- Ship bound for [Mhaura/Selbina] Pirates helpers
-- NOTE: Careful with queues as they don't resolve until a zone wakes from sleep, potentially having mismatched timing. Timers are fine.
-----------------------------------

xi = xi or {}
xi.pirates = xi.pirates or {}

-- chance for encounter to have a special middle NPC, which indicates a chance for NM to spawn
local vermCloakPirateChance = 10

-- At least this many Crossbones alive during the encounter; all zone Crossbones IDs may be up (e.g. 4) if available.
local CROSSBONES_MIN_ALIVE = 3

local actions =
{
    ARRIVING        = 0,
    ARRIVE          = 1,
    PIRATES_ARRIVE  = 2,
    MOBS_SPAWN      = 3,
    PIRATES_RETREAT = 4,
    DEPART          = 5,
    DEPARTING       = 6,
}

-- times are minutes after midnight for first cycle, cycle is 480 minutes
local piratesSchedule =
{
    { endTime = utils.timeStringToMinutes('01:10'), action = actions.ARRIVING },
    { endTime = utils.timeStringToMinutes('01:30'), action = actions.ARRIVE },
    { endTime = utils.timeStringToMinutes('01:32'), action = actions.PIRATES_ARRIVE },
    { endTime = utils.timeStringToMinutes('01:35'), action = actions.MOBS_SPAWN },
    { endTime = utils.timeStringToMinutes('04:20'), action = actions.PIRATES_RETREAT },
    { endTime = utils.timeStringToMinutes('04:27'), action = actions.DEPART },
    { endTime = utils.timeStringToMinutes('04:48'), action = actions.DEPARTING },
}

local piratesData =
{
    -- Pirate ship is on left side of boat
    [xi.zone.SHIP_BOUND_FOR_SELBINA_PIRATES] =
    {
        {
            startPos    = { x = -33.601, y = -7.16, z = 13.37, rotation = 0 },
            standingPos = { x =  -21.90, y = -7.16, z = 10.46, rotation = 0 },
        },
        {
            startPos    = { x = -29.728, y = -7.16, z = 1.30, rotation = 0 },
            standingPos = { x =  -21.90, y = -7.16, z = 6.59, rotation = 0 },
        },
        {
            startPos    = { x = -29.602, y = -7.16, z = -2.47, rotation = 0 },
            standingPos = { x =  -21.90, y = -7.16, z =  2.10, rotation = 0 },
        },
    },
    -- Pirate ship is on right side of boat
    [xi.zone.SHIP_BOUND_FOR_MHAURA_PIRATES] =
    {
        {
            startPos    = { x = 33.601, y = -7.16, z = 13.37, rotation = 128 },
            standingPos = { x =  21.90, y = -7.16, z = 10.46, rotation = 128 },
        },
        {
            startPos    = { x = 29.728, y = -7.16, z = 1.30, rotation = 128 },
            standingPos = { x =  21.90, y = -7.16, z = 6.59, rotation = 128 },
        },
        {
            startPos    = { x = 29.602, y = -7.16, z = -2.47, rotation = 128 },
            standingPos = { x =  21.90, y = -7.16, z =  2.10, rotation = 128 },
        },
    },
}

local function countAliveCrossbones(crossbonesIds)
    local n = 0
    for _, mobId in ipairs(crossbonesIds) do
        local mob = GetMobByID(mobId)
        if mob and mob:isSpawned() and mob:isAlive() then
            n = n + 1
        end
    end

    return n
end

-- While pirates loop summon animations after mobs have spawned, keep at least CROSSBONES_MIN_ALIVE Crossbones up
-- (spawn all listed IDs on pull; extra IDs mean more than the minimum can be alive).
local function maybeSummonCrossboneOnPirateCastComplete(zone)
    if zone:getLocalVar('currPiratesAction') ~= actions.MOBS_SPAWN then
        return
    end

    local zoneId = zone:getID()
    if
        zoneId ~= xi.zone.SHIP_BOUND_FOR_MHAURA_PIRATES and
        zoneId ~= xi.zone.SHIP_BOUND_FOR_SELBINA_PIRATES
    then
        return
    end

    local ID = zones[zoneId]
    if not ID or not ID.mob or not ID.mob.CROSSBONES then
        return
    end

    local crossbonesIds = ID.mob.CROSSBONES
    local poolSize        = #crossbonesIds
    if poolSize == 0 then
        return
    end

    local minNeeded       = math.min(CROSSBONES_MIN_ALIVE, poolSize)
    local deficit         = minNeeded - countAliveCrossbones(crossbonesIds)
    if deficit <= 0 then
        return
    end

    for i = 1, poolSize do
        if deficit <= 0 then
            break
        end

        local mobId = crossbonesIds[i]
        local mob   = GetMobByID(mobId)
        if mob and not mob:isSpawned() then
            SpawnMob(mobId)
            deficit = deficit - 1
        end
    end

    if deficit <= 0 then
        return
    end

    for i = 1, poolSize do
        local mobId = crossbonesIds[i]
        local mob   = GetMobByID(mobId)
        if mob and mob:isSpawned() and not mob:isAlive() then
            DespawnMob(mobId)
            mob:timer(500, function()
                if zone:getLocalVar('currPiratesAction') ~= actions.MOBS_SPAWN then
                    return
                end

                local m = GetMobByID(mobId)
                if m and not m:isSpawned() then
                    SpawnMob(mobId)
                end

                maybeSummonCrossboneOnPirateCastComplete(zone)
            end)
            return
        end
    end
end

-- True from MOBS_SPAWN until PIRATES_RETREAT (currPiratesAction is not advanced between those triggers).
xi.pirates.isPirateMobWaveActive = function(zone)
    if not zone then
        return false
    end

    return zone:getLocalVar('currPiratesAction') == actions.MOBS_SPAWN
end

xi.pirates.setupPirateNPCSchedule = function(npc)
    npc:initNpcAi()

    -- create triggers for every stage of the encounter on each Pirate NPC
    for _, eventData in ipairs(piratesSchedule) do
        npc:addPeriodicTrigger(eventData.action, 480, eventData.endTime)
    end
end

-- Re-arms a timer to loop summoner cast start/stop while pirates are alongside the ship.
-- Visibility ends on DEPART (or DISAPPEAR elsewhere); do not hide NPCs here between cycles.
local function summonAnimations(npc, rotation, offset)
    if npc:getStatus() == xi.status.DISAPPEAR then
        return
    end

    if not npc:isFollowingPath() then
        local pos = npc:getPos()
        if npc:getLocalVar('initialNpcState') == 1 then
            npc:setLocalVar('initialNpcState', 0)
            -- rotate to face the player boat
            npc:setPos(pos.x, pos.y, pos.z, rotation)
            -- first summoning rotation happens in order of NPC ID
            npc:setLocalVar('summonStartTime', GetSystemTime() + (offset - 1) * 2)
        end

        local summonStartTime = npc:getLocalVar('summonStartTime')
        if summonStartTime ~= 0 and summonStartTime <= GetSystemTime() then
            npc:setLocalVar('summonStartTime', 0)
            npc:setLocalVar('summonEndTime', GetSystemTime() + math.random(1, 2))

            npc:entityAnimationPacket(xi.animationString.CAST_SUMMONER_START)
        end

        local summonEndTime = npc:getLocalVar('summonEndTime')
        if summonEndTime ~= 0 and summonEndTime <= GetSystemTime() then
            npc:setLocalVar('summonEndTime', 0)
            -- npcs seem to wait anywhere from 5 to 10s to do another summoning animation
            npc:setLocalVar('summonStartTime', GetSystemTime() + math.random(4 + offset, 10))

            npc:entityAnimationPacket(xi.animationString.CAST_SUMMONER_STOP)

            -- One NPC handles respawn checks so three pirates do not race the same mob IDs
            if offset == 1 then
                local pirateZone = npc:getZone()
                if pirateZone then
                    maybeSummonCrossboneOnPirateCastComplete(pirateZone)
                end
            end
        end
    end

    if npc:getStatus() == xi.status.DISAPPEAR then
        return
    end

    -- check again in 1.2s (pirates summon animation can last from 1s to 2s)
    npc:timer(1200, function(npcArg)
        summonAnimations(npcArg, rotation, offset)
    end)
end

-- called on every NPC periodic trigger, which is mapped 1-1 to the schedule table, with triggerId == action
xi.pirates.pirateNPCTimeTrigger = function(npc, triggerId, zoneKey)
    local pirateZone = npc:getZone()
    if not pirateZone then
        return
    end

    local pirateNPCs = zones[pirateZone:getID()].npc.PIRATES
    local pirateIdx = 0
    for i, npcId in ipairs(pirateNPCs) do
        if npcId == npc:getID() then
            pirateIdx = i
            break
        end
    end

    local pirateData = piratesData[zoneKey][pirateIdx]
    if not pirateData then
        return
    end

    if triggerId == actions.PIRATES_ARRIVE then
        -- Pirates appear and run to position
        if pirateIdx == 2 then
            -- middle pirate has chance to wear a verm cloak, which then means the pirate encounter _might_ have the NM spawn
            local bodyModel = 8195
            local nmCanSpawn = 0
            if math.random(1, 100) <= vermCloakPirateChance then
                bodyModel = 47
                nmCanSpawn = 1
            end

            npc:setModelId(bodyModel, xi.slot.BODY)
            pirateZone:setLocalVar('nmCanSpawn', nmCanSpawn)
        end

        npc:setPos(pirateData.startPos)
        npc:setStatus(xi.status.NORMAL)
        npc:clearPath()
        npc:pathTo(pirateData.standingPos.x, pirateData.standingPos.y, pirateData.standingPos.z, xi.path.flag.RUN + xi.path.flag.WALLHACK)

        -- Indicates we need to rotate NPC after pathing completes
        npc:setLocalVar('initialNpcState', 1)
        summonAnimations(npc, pirateData.standingPos.rotation, pirateIdx)
    elseif triggerId == actions.PIRATES_RETREAT then
        -- retreat; summoning stops (timers cleared) while pirates run back to their ship
        local summonEndTime = npc:getLocalVar('summonEndTime')
        npc:setLocalVar('summonStartTime', 0)
        npc:setLocalVar('summonEndTime', 0)
        if summonEndTime > 0 then
            npc:entityAnimationPacket(xi.animationString.CAST_SUMMONER_STOP)
        end

        npc:pathTo(pirateData.startPos.x, pirateData.startPos.y, pirateData.startPos.z, xi.path.flag.RUN + xi.path.flag.WALLHACK)
    elseif triggerId == actions.DEPART then
        -- Just in case summonAnimations didn't set status
        npc:clearPath()
        npc:setStatus(xi.status.DISAPPEAR)
    end

    xi.pirates.zoneStateChange(pirateZone, triggerId)
end

local function spawnPirateWave(zone)
    local zoneId = zone:getID()
    local ID = zones[zoneId]
    if not ID or not ID.mob then
        return
    end

    local spawnList = {}

    if ID.mob.CROSSBONES then
        for _, mobId in ipairs(ID.mob.CROSSBONES) do
            spawnList[#spawnList + 1] = mobId
        end
    end

    if zoneId == xi.zone.SHIP_BOUND_FOR_SELBINA_PIRATES then
        spawnList[#spawnList + 1] = ID.mob.SHIP_WIGHT
        spawnList[#spawnList + 1] = ID.mob.BLACKBEARD
        -- Enagakure uses night / key item logic in Zone.lua; not spawned by the pirate wave
    elseif zoneId == xi.zone.SHIP_BOUND_FOR_MHAURA_PIRATES then
        spawnList[#spawnList + 1] = ID.mob.WIGHT
        spawnList[#spawnList + 1] = ID.mob.SILVERHOOK
    else
        return
    end

    for _, mobId in ipairs(spawnList) do
        if mobId and mobId > 0 then
            -- Use silent lookup: missing mob rows (e.g. DB not migrated to 177152xx IDs) should not spam GetMobByID warnings.
            local mob = GetEntityByID(mobId, nil, true)
            if mob and not mob:isSpawned() then
                SpawnMob(mobId)
            end
        end
    end
end

-- Despawn non-Crossbones wave mobs on retreat (players finish off skeletons).
local function despawnPirateWave(zone)
    local zoneId = zone:getID()
    local ID = zones[zoneId]
    if not ID or not ID.mob then
        return
    end

    local despawnList = {}

    if zoneId == xi.zone.SHIP_BOUND_FOR_SELBINA_PIRATES then
        despawnList[#despawnList + 1] = ID.mob.SHIP_WIGHT
        despawnList[#despawnList + 1] = ID.mob.BLACKBEARD
    elseif zoneId == xi.zone.SHIP_BOUND_FOR_MHAURA_PIRATES then
        despawnList[#despawnList + 1] = ID.mob.WIGHT
        despawnList[#despawnList + 1] = ID.mob.SILVERHOOK
    else
        return
    end

    for _, mobId in ipairs(despawnList) do
        if mobId and mobId > 0 then
            local mob = GetEntityByID(mobId, nil, true)
            if mob and mob:isSpawned() and not mob:isEngaged() then
                DespawnMob(mobId)
            end
        end
    end
end

xi.pirates.zoneStateChange = function(zone, action)
    -- change the zone's state once per action cycle (this function is called by each NPC)
    if zone:getLocalVar('currPiratesAction') ~= action then
        zone:setLocalVar('currPiratesAction', action)

        if action == actions.MOBS_SPAWN then
            spawnPirateWave(zone)
        elseif action == actions.PIRATES_RETREAT then
            despawnPirateWave(zone)
        end
    end
end
