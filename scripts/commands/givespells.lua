-----------------------------------
-- func: givespells <player> <id,id,id,...>
-- desc: Adds a batch of spells (comma-separated spell IDs) to the target. Used
--       by GMAss's "Learn All Job Spells" button, which sends a job's whole
--       spellbook in a few batched calls. If only a CSV is given (no player),
--       it applies to the caller.
--
--       GSPL_DBG| lines are diagnostics only (in case addSpell isn't the right
--       method on this build) -- remove the diagnostic block once confirmed.
--
--       Place in: scripts/commands/givespells.lua   (NEW file -> full xi_map restart)
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'ss'
}

commandObj.onTrigger = function(player, arg1, arg2)
    -- Resolve target + csv. Two forms:
    --   !givespells <player> <csv>   -> arg1 = name, arg2 = csv
    --   !givespells <csv>            -> arg1 = csv,  arg2 = nil  (self)
    local target, csv
    if arg2 == nil or arg2 == '' then
        target = player
        csv = arg1
    else
        target = GetPlayerByName(arg1)
        csv = arg2
        if target == nil then
            player:printToPlayer(string.format('givespells: player "%s" not found.', tostring(arg1)))
            return
        end
    end

    if csv == nil or csv == '' then
        player:printToPlayer('Usage: !givespells <player> <id,id,id,...>')
        return
    end

    local count = 0
    local firstErr = nil
    for idStr in string.gmatch(csv, '([^,]+)') do
        local id = tonumber(idStr)
        if id ~= nil and id > 0 then
            local ok, err = pcall(function() target:addSpell(id) end)
            if ok then
                count = count + 1
            elseif firstErr == nil then
                firstErr = tostring(err)
            end
        end
    end

    if firstErr ~= nil then
        player:printToPlayer('GSPL_DBG|' .. firstErr)
    end
    player:printToPlayer(string.format('Gave %d spell(s) to %s.', count, target:getName()))
end

return commandObj
