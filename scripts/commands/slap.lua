-----------------------------------
-- func: slap (player)
-- desc: Harmless bump + message; target is cursor PC or named player (GM).
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
    player:printToPlayer('!slap (player name — optional, else cursor target on a player)')
end

commandObj.onTrigger = function(player, victimName)
    local targ

    if victimName and victimName ~= '' then
        targ = GetPlayerByName(victimName)
        if not targ then
            error(player, string.format('Player named "%s" not found.', victimName))
            return
        end
    else
        targ = player:getCursorTarget()
        if not targ or targ:isNPC() then
            error(player, 'Select a player with the cursor, or pass a player name.')
            return
        end
    end

    local pos = targ:getPos()
    targ:setPos(pos.x, pos.y + 0.35, pos.z, pos.rot)

    player:printToPlayer(string.format('You slap %s.', targ:getName()))
    if targ:getID() ~= player:getID() then
        targ:printToPlayer(string.format('%s slaps you!', player:getName()))
    end
end

return commandObj
