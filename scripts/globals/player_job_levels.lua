-----------------------------------
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
--- Tries setJobLevel if available, else setMainJob+setLevel, else only current job.
---@param player userdata Player entity
---@param level number Level to set (1-99)
---@return boolean success True if all jobs were set
---@return string|nil message Optional message (e.g. if only current job could be set)
function xi.player_job_levels.setAllJobLevels(player, level)
    level = level or 99
    if level < 1 or level > 99 then
        return false, "Level must be between 1 and 99."
    end

    -- Prefer setJobLevel if the server exposes it
    if player.setJobLevel then
        for jobId = xi.job.WAR, xi.job.MON do
            player:setJobLevel(jobId, level)
        end
        return true
    end

    -- Fallback: set main job then level for each job (if setMainJob exists)
    if player.setMainJob then
        for jobId = xi.job.WAR, xi.job.MON do
            player:setMainJob(jobId)
            player:setLevel(level)
        end
        return true
    end

    -- Last resort: only current main job
    player:setLevel(level)
    return false, "Only current job set to " .. level .. "; server Lua API does not expose setJobLevel or setMainJob."
end

return xi.player_job_levels
