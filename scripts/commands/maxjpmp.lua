-----------------------------------
-- func: maxjpmp
-- desc: GM override - max all Job Point abilities and all merit abilities.
--       Same as running !maxjobpoints then !maxmerits.
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
    player:printToPlayer('!maxjpmp (player)')
end

commandObj.onTrigger = function(player, targetName)
    if xi.commands.maxjobpoints and type(xi.commands.maxjobpoints.onTrigger) == 'function' then
        xi.commands.maxjobpoints.onTrigger(player, targetName)
    end

    if xi.commands.maxmerits and type(xi.commands.maxmerits.onTrigger) == 'function' then
        xi.commands.maxmerits.onTrigger(player, targetName)
    end
end

return commandObj
