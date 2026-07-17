-----------------------------------
-- func: nopants
-- desc: Silly flavor text only (no equipment changes).
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = ''
}

commandObj.onTrigger = function(player)
    player:printToPlayer('The winds of Vana\'diel rustle suspiciously, then think better of it.')
end

return commandObj
