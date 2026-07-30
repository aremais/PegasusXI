-----------------------------------
-- func: unlocksubjob (player)
-- desc: Unlocks the support (sub) job slot for the target player (or self).
--       Mirrors the Elder Memories / The Old Lady reward: unlockJob(0) is the
--       switch this server uses to grant sub-job access, then the quest is
--       marked complete. Place in: scripts/commands/unlocksubjob.lua
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
    player:printToPlayer('!unlocksubjob (player)')
end

commandObj.onTrigger = function(player, target)
    local targ
    if target == nil then
        targ = player
    else
        targ = GetPlayerByName(target)
        if targ == nil then
            error(player, string.format('Player named "%s" not found!', target))
            return
        end
    end

    -- unlockJob(0) is the flag that grants support-job access, exactly as
    -- Isacio/Vera do on quest completion (matches the server source literal).
    targ:unlockJob(0)
    targ:completeQuest(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.ELDER_MEMORIES)

    player:printToPlayer(string.format('%s can now designate a support job.', targ:getName()))
    if targ ~= player then
        targ:printToPlayer('You can now designate a support job!')
    end
end

return commandObj
