-----------------------------------
-- func: grats (player)
-- desc: Sends a short congrats message to you and the named player.
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 0,
    parameters = 's'
}

local function error(player, msg)
    player:printToPlayer(msg)
    player:printToPlayer('!grats <player name>')
end

commandObj.onTrigger = function(player, targetName)
    if not targetName or targetName == '' then
        error(player, 'Say who you are congratulating.')
        return
    end

    local targ = GetPlayerByName(targetName)
    if not targ then
        error(player, string.format('Player named "%s" is not online.', targetName))
        return
    end

    local msg = string.format('Grats, %s!', targ:getName())
    player:printToPlayer(msg)
    if targ:getID() ~= player:getID() then
        targ:printToPlayer(string.format('%s: %s', player:getName(), msg))
    end
end

return commandObj
