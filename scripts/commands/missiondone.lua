-----------------------------------
-- func: missiondone <logID> <missionID> <player>
-- desc: Marks the target as having completed EVERY mission in the line from the
--       start up to and including <missionID>, in order, so the Completed list
--       shows them all -- not just the chosen one. Walks the canonical mission
--       id list for the log (addMission to make each active, then completeMission).
--       Place in: scripts/commands/missiondone.lua
-----------------------------------
local logIdHelpers = require('scripts/globals/log_ids')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'sss'
}

local function error(player, msg)
    player:printToPlayer(msg)
    player:printToPlayer('!missiondone <logID> <missionID> (player)')
end

commandObj.onTrigger = function(player, logId, missionId, target)
    -- validate logId
    local logInfo = logIdHelpers.getMissionLogInfo(logId)
    if logInfo == nil then
        error(player, 'Invalid logID.')
        return
    end

    local logName = logInfo.full_name
    logId = logInfo.mission_log

    -- resolve the target mission id (accepts numeric or a name constant)
    local areaKey         = xi.mission.area[logId]
    local areaMissionIds  = xi.mission.id[areaKey]
    if missionId ~= nil then
        missionId = tonumber(missionId) or (areaMissionIds and areaMissionIds[string.upper(missionId)]) or _G[string.upper(missionId)]
    end

    if missionId == nil or missionId < 0 then
        error(player, 'Invalid missionID.')
        return
    end

    -- validate target
    local targ
    if target == nil then
        targ = player
    else
        targ = GetPlayerByName(target)
        if targ == nil then
            error(player, string.format('Player named "%s" not found!', target))
            return
        end
    end

    -- Chains of Promathia stores progress differently from every other log:
    -- there is NO per-mission "completed" bitmask. A CoP mission shows as
    -- completed when its id is LESS THAN the log's current mission (a high-water
    -- mark). completeMission() would reset current to 0 for CoP, which blanks
    -- the entire CoP log -- that's why the old add+complete loop wiped it.
    --
    -- So for CoP we just set current to the next mission id after the chosen
    -- one. That marks the chosen mission and everything before it as completed,
    -- and leaves the following mission active. If the chosen one is the last in
    -- the line, we push current just past it so the whole line reads complete.
    if logId == xi.mission.log_id.COP then
        local nextId
        if areaMissionIds ~= nil then
            for _, id in pairs(areaMissionIds) do
                if type(id) == 'number' and id > missionId and (nextId == nil or id < nextId) then
                    nextId = id
                end
            end
        end
        nextId = nextId or (missionId + 1)

        targ:addMission(logId, nextId)
        pcall(function() targ:sendPartialMissionLog(logId, false) end)
        player:printToPlayer(string.format('Completed %s through mission %u for %s.', logName, missionId, targ:getName()))
        return
    end

    -- Build the ordered list of every canonical mission id in this log that is
    -- <= the chosen one. xi.mission.id[area] is a name->id table; we collect the
    -- numeric ids, sort them, and walk in order. Mission ids are not contiguous
    -- (some lines skip numbers), so we drive off the real id set, not a range.
    local ids = {}
    if areaMissionIds ~= nil then
        for _, id in pairs(areaMissionIds) do
            if type(id) == 'number' and id >= 0 and id <= missionId then
                table.insert(ids, id)
            end
        end
    end

    -- Fallback: if the id table wasn't usable, at least do the chosen one.
    if #ids == 0 then
        table.insert(ids, missionId)
    end

    table.sort(ids)

    -- Walk the line: make each mission active, then complete it. Completing the
    -- active mission advances the pointer, so the next iteration's addMission
    -- lands cleanly. Duplicate ids are skipped.
    local seen = {}
    local count = 0
    for _, id in ipairs(ids) do
        if not seen[id] then
            seen[id] = true
            targ:addMission(logId, id)
            targ:completeMission(logId, id)
            count = count + 1
        end
    end

    -- Refresh the client's mission log display where supported.
    pcall(function() targ:sendPartialMissionLog(logId, true) end)

    player:printToPlayer(string.format('Completed %s missions up to ID %u (%u total) for %s.', logName, missionId, count, targ:getName()))
end

return commandObj
