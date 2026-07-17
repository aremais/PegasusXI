-----------------------------------
-- func: setalljoblevels
-- desc: Sets all job levels (WAR through MON) to 99 for the target player.
--       If no target, applies to the GM. Requires server to expose setJobLevel
--       or setMainJob in Lua (see scripts/globals/player_job_levels.lua).
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 's'
}

local function errorMsg(player, msg)
    player:printToPlayer(msg)
    player:printToPlayer('!setalljoblevels (player)')
end

commandObj.onTrigger = function(player, target)
    local targ
    if target and target ~= '' then
        targ = GetPlayerByName(target)
        if targ == nil then
            errorMsg(player, string.format('Player named "%s" not found!', target))
            return
        end
    else
        targ = player
    end

    require('scripts/globals/player_job_levels')
    local success, msg = xi.player_job_levels.setAllJobLevels(targ, 99)

    if success then
        if targ:getID() ~= player:getID() then
            player:printToPlayer(string.format('Set all job levels to 99 for %s.', targ:getName()))
        else
            player:printToPlayer('All job levels set to 99.')
        end
    else
        player:printToPlayer(msg or 'Could not set all job levels.')
    end
end

return commandObj
