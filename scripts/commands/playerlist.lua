-----------------------------------
-- func: playerlist (zoneid)
-- desc: Prints the roster of currently-online characters so GMAss can build a
--       searchable Target-Player picker (mirrors /sea all and /sea area).
--       No argument = whole server (iterates zone ids); a zoneid argument =
--       only that zone. Uses GetZone():getPlayers() -- no SQL.
--
--       Output (captured by GMAss; "PLST" has no "GMAss" substring so it isn't
--       self-filtered by the addon's text scanner):
--           PLST_BEGIN
--           PLST|<name>|<jobAbbrev>|<level>|<zone>
--           ...
--           PLST_END|<count>
--
--       Place in: scripts/commands/playerlist.lua   (NEW file -> full xi_map restart)
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'i'
}

local JOB = {
    [1]='WAR',[2]='MNK',[3]='WHM',[4]='BLM',[5]='RDM',[6]='THF',[7]='PLD',
    [8]='DRK',[9]='BST',[10]='BRD',[11]='RNG',[12]='SAM',[13]='NIN',[14]='DRG',
    [15]='SMN',[16]='BLU',[17]='COR',[18]='PUP',[19]='DNC',[20]='SCH',[21]='GEO',
    [22]='RUN',
}

commandObj.onTrigger = function(player, zoneid)
    player:printToPlayer('PLST_BEGIN')

    local count = 0

    local function dumpZone(z)
        local zone = GetZone(z)
        if zone == nil then return end

        local okP, players = pcall(function() return zone:getPlayers() end)
        if not okP or players == nil then return end

        local zname = tostring(z)
        pcall(function() local n = zone:getName(); if n and n ~= '' then zname = n end end)

        for _, p in pairs(players) do
            pcall(function()
                local name = p:getName()
                local mjob = p:getMainJob()
                local mlvl = p:getMainLvl()
                local jobAbbr = JOB[mjob] or '---'
                local lvl = (mlvl and mlvl > 0) and tostring(mlvl) or '?'
                player:printToPlayer(string.format('PLST|%s|%s|%s|%s', name, jobAbbr, lvl, zname))
                count = count + 1
            end)
        end
    end

    if zoneid ~= nil and zoneid > 0 then
        pcall(function() dumpZone(zoneid) end)
    else
        -- Whole server: iterate the FFXI zone-id space. Zones not handled by
        -- this process (or invalid ids) return nil and are skipped.
        for z = 0, 399 do
            pcall(function() dumpZone(z) end)
        end
    end

    player:printToPlayer(string.format('PLST_END|%u', count))
end

return commandObj
