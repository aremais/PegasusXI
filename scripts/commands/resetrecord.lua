-----------------------------------
-- func: resetrecord <recordID> [player]
-- desc: Resets a Records of Eminence objective so it can be earned again.
--       Clears the completion flag AND removes the record from the active log.
--       No player name = yourself. Target must be ONLINE.
--
--       This is the inverse of the stock !completerecord command.
--
--       Implementation note: setEminenceCompleted(recordID, repeat, status)
--         arg2 repeat = false -> DelEminenceRecord (drops it from the 30-slot
--                                active log rather than just zeroing progress)
--         arg3 status = false -> SetEminenceRecordCompletion(..., false)
--       Both push updated RoE packets to the client and save immediately, so
--       the change shows up without relogging.
--
--       Place in: scripts/commands/resetrecord.lua  (NEW file -> full xi_map restart)
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'is'
}

local function usage(player, msg)
    player:printToPlayer(msg)
    player:printToPlayer('!resetrecord <recordID> (player)')
end

commandObj.onTrigger = function(player, recordID, target)
    if recordID == nil then
        usage(player, 'Invalid recordID.')
        return
    end

    local targ = player
    if target ~= nil and target ~= '' then
        targ = GetPlayerByName(target)
        if targ == nil then
            usage(player, string.format('Player named "%s" not found (must be online).', target))
            return
        end
    end

    targ:setEminenceCompleted(recordID, false, false)

    player:printToPlayer(string.format('Reset RoE Record %u for %s.', recordID, targ:getName()))
    if targ ~= player then
        targ:printToPlayer(string.format('A GM has reset your RoE record %u.', recordID))
    end
end

return commandObj
