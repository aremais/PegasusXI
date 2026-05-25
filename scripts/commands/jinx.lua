-----------------------------------
-- func: jinx (player)
-- desc: Puts a short Silence on cursor target or named player (GM, testing/social).
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
    player:printToPlayer('!jinx (player name — optional, else cursor target)')
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
        if not targ or targ:isNPC() then
            error(player, 'Select a player with the cursor, or pass a player name.')
            return
        end
    end

    targ:addStatusEffect(xi.effect.SILENCE, { power = 1, duration = 30, origin = player })
    player:printToPlayer(string.format('Jinx! %s is silenced briefly.', targ:getName()))
end

return commandObj
