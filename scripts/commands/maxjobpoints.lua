-----------------------------------
-- func: maxjobpoints
-- desc: GM override - max all 10 Job Point abilities on every job (rank 20 / Su5).
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 's'
}

local function error(player, msg)
    player:printToPlayer(msg)
    player:printToPlayer('!maxjobpoints (player)')
end

commandObj.onTrigger = function(player, targetName)
    local targ = player

    if targetName and targetName ~= '' then
        targ = GetPlayerByName(targetName)
        if not targ then
            error(player, string.format('Player named "%s" not found!', targetName))
            return
        end
    end

    local origMjob = targ:getMainJob()
    local origSjob = targ:getSubJob()

    for jobId = 1, xi.MAX_JOB_TYPE - 1 do
        if jobId ~= xi.job.NONE and jobId ~= xi.job.MON then
            targ:unlockJob(jobId)
            targ:changeJob(jobId)
            targ:setLevel(99)
            targ:masterJob()
        end
    end

    targ:changeJob(origMjob)
    if origSjob and origSjob > 0 then
        targ:changesJob(origSjob)
    end

    player:printToPlayer(string.format('%s now has all Job Point abilities maxed on every job.', targ:getName()))
end

return commandObj
