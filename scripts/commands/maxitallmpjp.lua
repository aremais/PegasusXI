-----------------------------------
-- func: maxitallmpjp
-- desc: Alias of !maxjpmp — JOB_BREAKER + max JP + max merits.
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
    player:printToPlayer('!maxitallmpjp (player)')
end

commandObj.onTrigger = function(player, targetName)
    if xi.commands.maxjpmp and type(xi.commands.maxjpmp.onTrigger) == 'function' then
        xi.commands.maxjpmp.onTrigger(player, targetName)
        return
    end

    error(player, 'maxjpmp command is not loaded.')
end

return commandObj
