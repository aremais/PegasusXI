-----------------------------------
-- func: kickip
-- desc: Force-disconnect every character session from the given client IPv4 (matches accounts_sessions.client_addr).
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 's'
}

commandObj.onTrigger = function(player, ip)
    if ip == nil or ip == '' then
        player:printToPlayer('Usage: !kickip <ipv4 address>')
        return
    end

    local n = KickSessionsByClientIP(ip)
    if n == 0 then
        player:printToPlayer(string.format('No active session found for IP %s.', ip))
    else
        player:printToPlayer(string.format('Sent disconnect for %d session(s) from %s.', n, ip))
        printf('%s used !kickip %s (%d session(s))', player:getName(), ip, n)
    end
end

return commandObj
