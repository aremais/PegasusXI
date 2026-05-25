-----------------------------------
-- func: nuke (player)
-- desc: Instant 0 HP on cursor target or named player (GM); same behavior as !kill.
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
    player:printToPlayer('!nuke (player name — optional, else cursor target)')
end

commandObj.onTrigger = function(player, targetName)
    local targ

    if targetName and targetName ~= '' then
        targ = GetPlayerByName(targetName)
        if not targ then
            error(player, string.format('Player named "%s" not found.', targetName))
            return
        end
    else
        targ = player:getCursorTarget()
        if not targ then
            error(player, 'Select a target with the cursor, or pass a player name.')
            return
        end
    end

    if not targ:isPC() and not targ:isMob() then
        error(player, 'Target must be a player or a mob.')
        return
    end

    if targ:isAlive() then
        targ:setHP(0)
        if targ:getID() ~= player:getID() then
            player:printToPlayer(string.format('Nuked %s.', targ:getName()))
        end
    else
        player:printToPlayer(string.format('%s is already dead.', targ:getName()))
    end
end

return commandObj
