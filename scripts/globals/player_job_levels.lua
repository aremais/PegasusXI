--Updating to fix sanity issues with player_job_levels. This file is used by both the !setalljoblevels command and by NPCs, so it should be careful about input validation and error handling.
-- Shared logic: set all job levels on a player.
-- Used by both the !setalljoblevels command and by NPCs.
-- Returns: success (boolean), message (string)
--
-- NPC usage (e.g. in grantStarterPack or onTrigger):
--   require('scripts/globals/player_job_levels')
--   local ok, msg = xi.player_job_levels.setAllJobLevels(player, 99)
--   if not ok and msg then
--     player:printToPlayer(msg)  -- optional: tell player only current job was set
--   end
-----------------------------------

xi = xi or {}

xi.player_job_levels = xi.player_job_levels or {}

--- Set all jobs (WAR through MON) to the given level.
--- Uses changeJob + setLevel to persist per-job levels.
---@param player userdata Player entity
---@param level number Level to set (1-99)
---@return boolean success True if all jobs were set
---@return string|nil message Optional message
function xi.player_job_levels.setAllJobLevels(player, level)
    level = level or 99
    if level < 1 or level > 99 then
        return false, 'Level must be between 1 and 99.'
    end

    local originalJob = player:getMainJob()
    for jobId = xi.job.WAR, xi.job.MON do
        player:changeJob(jobId)
        player:setLevel(level)
    end

    player:changeJob(originalJob)
    return true
end

return xi.player_job_levels
