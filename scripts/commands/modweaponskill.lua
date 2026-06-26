-----------------------------------
-- func: modweaponskill <add|del> <unlockId> (player)
-- desc: Adds or removes a SINGLE learned weaponskill (by unlock_id) for the
--       target player (or self). Mirrors addallweaponskills, but for one WS.
--       Place in: scripts/commands/modweaponskill.lua
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'sis'
}

local function error(player, msg)
    player:printToPlayer(msg)
    player:printToPlayer('!modweaponskill <add|del> <unlockId> (player)')
end

commandObj.onTrigger = function(player, action, unlockId, target)
    if action == nil or (action ~= 'add' and action ~= 'del') then
        error(player, 'Action must be "add" or "del".')
        return
    end
    if unlockId == nil or unlockId < 1 then
        error(player, 'You must specify a valid weaponskill unlock id.')
        return
    end

    local targ
    if target == nil then
        targ = player
    else
        targ = GetPlayerByName(target)
        if targ == nil then
            error(player, string.format('Player named "%s" not found!', target))
            return
        end
    end

    if action == 'add' then
        targ:addLearnedWeaponskill(unlockId)
        player:printToPlayer(string.format('%s learned weaponskill (unlock #%d).', targ:getName(), unlockId))
        if targ ~= player then
            targ:printToPlayer('A weaponskill has been added to you.')
        end
    else
        targ:delLearnedWeaponskill(unlockId)
        player:printToPlayer(string.format('%s unlearned weaponskill (unlock #%d).', targ:getName(), unlockId))
        if targ ~= player then
            targ:printToPlayer('A weaponskill has been removed from you.')
        end
    end
end

return commandObj
