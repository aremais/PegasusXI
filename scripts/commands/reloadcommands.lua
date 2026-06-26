-----------------------------------
-- func: reloadcommands
-- desc: Reload all scripts/commands/*.lua into xi.commands (no map restart).
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 4,
    parameters = ''
}

commandObj.onTrigger = function(player)
    if type(ReloadCommandScripts) ~= 'function' then
        player:printToPlayer('ReloadCommandScripts is unavailable. Rebuild xi_map from the latest server source.')
        return
    end

    ReloadCommandScripts()
    player:printToPlayer('Reloaded GM commands from scripts/commands/. Check map log for the reload summary.')
end

return commandObj
