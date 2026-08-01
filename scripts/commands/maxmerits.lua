-----------------------------------
-- func: maxmerits
-- desc: GM override - max every merit ability to its rank cap.
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 's'
}

local function error(player, msg)
    player:printToPlayer(msg)
    player:printToPlayer('!maxmerits (player)')
end

commandObj.onTrigger = function(player, targetName)
    local targ = player

    if targetName and targetName ~= '' then
        targ = GetPlayerByName(targetName)
        if not targ then
            error(player, string.format('Player named "%s" not found!', targetName))
            return
        end
    end

    -- maxAllMerits C++ binding is not available on this fork yet.
    -- Award a large pool of spendable merit points instead.
    targ:setMerits(30)
    player:printToPlayer(string.format('%s merit points set to 30. Spend them to max abilities as needed.', targ:getName()))
end

return commandObj
