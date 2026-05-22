--[[
    addallopwarps.lua
    Grants all Outpost Warp unlocks (teleport flags) for all 3 nations.

    Author: Aremais
]]--

local commandObj = {}
commandObj.cmdprops =
{
    permission = 1,
    parameters = 's' -- optional: player name
}

commandObj.onTrigger = function(player, targetName)
    local targ = player

    if targetName ~= nil and targetName ~= '' then
        local found = GetPlayerByName(targetName)
        if found == nil then
            player:printToPlayer(string.format('addallopwarps: Player \'%s\' not found.', targetName))
            return
        end

        targ = found
    end

    local nations = { xi.nation.SANDORIA, xi.nation.BASTOK, xi.nation.WINDURST }

    -- Conquest outpost warp checks use region + 5 as the teleport index.
    for _, nation in ipairs(nations) do
        for region = xi.region.RONFAURE, xi.region.TAVNAZIANARCH do
            targ:addTeleport(nation, region + 5)
        end
    end

    player:printToPlayer(string.format('addallopwarps: Granted all outpost warp unlocks to %s.', targ:getName()))
end

return commandObj
