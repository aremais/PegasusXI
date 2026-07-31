-----------------------------------
-- Linkshell Concierge NPCs
-- Retail uses server packet 0x048 for the stock/browse UI; that protocol is not implemented here.
-----------------------------------

xi = xi or {}
xi.linkshellConcierge = xi.linkshellConcierge or {}

xi.linkshellConcierge.onTrigger = function(player, _npc)
    -- Channel 29 = xi.msg.channel.SYSTEM_3 (avoid relying on load order vs. scripts/globals/msg.lua)
    player:printToPlayer('The Linkshell Concierge listing system is not implemented on this server.', 29)
    player:printToPlayer('To recruit for your linkshell, use shout, yell, the Assist Channel (where available), linkshell chat, or trade linkpearls directly.', 29)
end

return xi.linkshellConcierge
