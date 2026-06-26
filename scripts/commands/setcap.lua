-----------------------------------
-- func: setcap <level> (player) (job)
-- desc: Sets the level cap (limit break) for the target player (or self) AND
--       marks every Genkai/Limit-Break quest up to that cap complete, for a
--       clean quest log -- the way the quest rewards would.
--         LB1=55  LB2=60  LB3=65  LB4=70  LB5=75
--         LB6=80  LB7=85  LB8=90  LB9=95  LB10=99
--       The optional <job> selects the correct LB5 quest (Shattering Stars for
--       the original 15; The Beast Within for BLU, etc.). Without a job, LB5
--       defaults to Shattering Stars.
--       Place in: scripts/commands/setcap.lua
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'iss'
}

-- Universal Genkai chain (same for every job). cap -> { questLog, questId }.
-- Cap 75 (LB5) is handled separately because it varies by job.
local genkaiChain =
{
    [55] = { xi.questLog.JEUNO, xi.quest.id.jeuno.IN_DEFIANT_CHALLENGE },
    [60] = { xi.questLog.JEUNO, xi.quest.id.jeuno.ATOP_THE_HIGHEST_MOUNTAINS },
    [65] = { xi.questLog.JEUNO, xi.quest.id.jeuno.WHENCE_BLOWS_THE_WIND },
    [70] = { xi.questLog.JEUNO, xi.quest.id.jeuno.RIDING_ON_THE_CLOUDS },
    [80] = { xi.questLog.JEUNO, xi.quest.id.jeuno.NEW_WORLDS_AWAIT },
    [85] = { xi.questLog.JEUNO, xi.quest.id.jeuno.EXPANDING_HORIZONS },
    [90] = { xi.questLog.JEUNO, xi.quest.id.jeuno.BEYOND_THE_STARS },
    [95] = { xi.questLog.JEUNO, xi.quest.id.jeuno.DORMANT_POWERS_DISLODGED },
    [99] = { xi.questLog.JEUNO, xi.quest.id.jeuno.BEYOND_INFINITY },
}

-- LB5 (cap 75) quest by job. Original-15 jobs use the default (Shattering
-- Stars). BLU/COR/PUP confirmed; DNC/SCH/GEO/RUN pending (cap still raises,
-- their LB5 quest is skipped until mapped).
local lb5Default = { xi.questLog.JEUNO, xi.quest.id.jeuno.SHATTERING_STARS }
local lb5ByJob =
{
    BLU = { xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.THE_BEAST_WITHIN },
    COR = { xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.BREAKING_THE_BONDS_OF_FATE },
    PUP = { xi.questLog.BASTOK,     xi.quest.id.bastok.ACHIEVING_TRUE_POWER },
}
-- Expansion jobs whose LB5 is NOT Shattering Stars. If not in lb5ByJob yet,
-- their LB5 quest is skipped (so we never flag the wrong quest).
local lb5Expansion = { BLU = true, COR = true, PUP = true, DNC = true, SCH = true, GEO = true, RUN = true }

local capOrder = { 55, 60, 65, 70, 75, 80, 85, 90, 95, 99 }

local function error(player, msg)
    player:printToPlayer(msg)
    player:printToPlayer('!setcap <level 1-99> (player) (job)   e.g. !setcap 75 Miku BLU')
end

commandObj.onTrigger = function(player, cap, target, jobName)
    if cap == nil or cap < 1 or cap > 99 then
        error(player, 'Level cap must be between 1 and 99.')
        return
    end

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

    -- 1. raise the cap
    targ:setLevelCap(cap)

    -- 2. complete every Genkai quest up to and including the chosen cap
    local jobU = jobName and string.upper(jobName) or nil
    local nQuests = 0
    for _, c in ipairs(capOrder) do
        if c <= cap then
            if c == 75 then
                -- LB5: pick the job-correct quest
                local q
                if jobU and lb5ByJob[jobU] then
                    q = lb5ByJob[jobU]
                elseif jobU and lb5Expansion[jobU] then
                    q = nil   -- expansion LB5 not yet mapped; skip (cap still raised)
                else
                    q = lb5Default   -- original 15 or unspecified
                end
                if q then targ:completeQuest(q[1], q[2]); nQuests = nQuests + 1 end
            else
                local q = genkaiChain[c]
                if q then targ:completeQuest(q[1], q[2]); nQuests = nQuests + 1 end
                if c == 99 then
                    -- LB10 is a two-quest step: Prelude then Beyond Infinity
                    targ:completeQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.PRELUDE_TO_PUISSANCE)
                    nQuests = nQuests + 1
                end
            end
        end
    end

    player:printToPlayer(string.format('Set cap of %s to %d (%d LB quest%s marked complete).',
        targ:getName(), cap, nQuests, nQuests == 1 and '' or 's'))
    if targ ~= player then
        targ:printToPlayer(string.format('Your level cap has been set to %d.', cap))
    end
end

return commandObj
