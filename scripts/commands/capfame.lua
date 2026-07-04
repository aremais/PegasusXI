-----------------------------------
-- func: capfame
-- desc: Caps all fame/reputation across all regions for a target player.
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 3,
    parameters = 's'
}

local function error(player, msg)
    if msg == nil then
        msg = '!capfame <player>'
    end

    player:printToPlayer(msg)
end

commandObj.onTrigger = function(player, target)
    if target == nil then
        error(player, 'You must enter a target player name.')
        return
    end

    local targ = GetPlayerByName(target)
    if targ == nil then
        error(player, string.format('Player named "%s" not found or not a valid player!', target))
        return
    end

    local fameBaseValues = { 0, 50, 125, 225, 325, 425, 488, 550, 613 }
    local fameMultiplier = xi.settings.map.FAME_MULTIPLIER

    for fameZone = 0, 15 do
        local maxLevel = (fameZone >= 6 and fameZone <= 14) and 6 or 9
        targ:setFame(fameZone, fameBaseValues[maxLevel] / fameMultiplier)
    end

    player:printToPlayer(string.format('Capped all fame for %s across all regions.', targ:getName()))
end

return commandObj
