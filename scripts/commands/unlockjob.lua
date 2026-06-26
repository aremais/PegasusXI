-----------------------------------
-- func: unlockjob <job> (player)
-- desc: Fully unlocks an advanced job for the target player (or self):
--         1. Unlocks the job        (player:unlockJob)
--         2. Grants the job gesture (player:addKeyItem JOB_GESTURE_x)
--         3. Marks the unlock quest chain complete (player:completeQuest)
--       Replicates what the unlock quest reward grants, for clean restores.
--       Place in: scripts/commands/unlockjob.lua
--
--       DRG/GEO/RUN unlock via battlefield/Adoulin NPCs (no completed-quest
--       log entry), so they receive unlock + gesture only.
--       DRG/GEO/RUN remain unlock + gesture only (no completed-quest log entry).
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'ss'
}

-- Per-job: job enum, gesture key item, and the quest chain (in log order).
local jobData =
{
    PLD = { job = xi.job.PLD, ki = xi.ki.JOB_GESTURE_PALADIN,
            quests = {
                { xi.questLog.SANDORIA, xi.quest.id.sandoria.A_SQUIRES_TEST_II },
                { xi.questLog.SANDORIA, xi.quest.id.sandoria.A_KNIGHTS_TEST },
            } },
    DRK = { job = xi.job.DRK, ki = xi.ki.JOB_GESTURE_DARK_KNIGHT,
            quests = {
                { xi.questLog.BASTOK, xi.quest.id.bastok.BLADE_OF_DARKNESS },
            } },
    BST = { job = xi.job.BST, ki = xi.ki.JOB_GESTURE_BEASTMASTER,
            quests = {
                { xi.questLog.JEUNO, xi.quest.id.jeuno.CHOCOBOS_WOUNDS },
                { xi.questLog.JEUNO, xi.quest.id.jeuno.SAVE_MY_SON },
                { xi.questLog.JEUNO, xi.quest.id.jeuno.PATH_OF_THE_BEASTMASTER },
            } },
    BRD = { job = xi.job.BRD, ki = xi.ki.JOB_GESTURE_BARD,
            quests = {
                { xi.questLog.JEUNO, xi.quest.id.jeuno.A_MINSTREL_IN_DESPAIR },
                { xi.questLog.JEUNO, xi.quest.id.jeuno.PATH_OF_THE_BARD },
            } },
    RNG = { job = xi.job.RNG, ki = xi.ki.JOB_GESTURE_RANGER,
            quests = {
                { xi.questLog.WINDURST, xi.quest.id.windurst.THE_FANGED_ONE },
            } },
    SAM = { job = xi.job.SAM, ki = xi.ki.JOB_GESTURE_SAMURAI,
            quests = {
                { xi.questLog.OUTLANDS, xi.quest.id.outlands.FORGE_YOUR_DESTINY },
            } },
    NIN = { job = xi.job.NIN, ki = xi.ki.JOB_GESTURE_NINJA,
            quests = {
                { xi.questLog.BASTOK, xi.quest.id.bastok.AYAME_AND_KAEDE },
            } },
    DRG = { job = xi.job.DRG, ki = xi.ki.JOB_GESTURE_DRAGOON,      quests = {} },
    SMN = { job = xi.job.SMN, ki = xi.ki.JOB_GESTURE_SUMMONER,
            quests = {
                { xi.questLog.WINDURST, xi.quest.id.windurst.I_CAN_HEAR_A_RAINBOW },
            } },
    BLU = { job = xi.job.BLU, ki = xi.ki.JOB_GESTURE_BLUE_MAGE,
            quests = {
                { xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.AN_EMPTY_VESSEL },
            } },
    COR = { job = xi.job.COR, ki = xi.ki.JOB_GESTURE_CORSAIR,
            quests = {
                { xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.LUCK_OF_THE_DRAW },
            } },
    PUP = { job = xi.job.PUP, ki = xi.ki.JOB_GESTURE_PUPPETMASTER,
            quests = {
                { xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.NO_STRINGS_ATTACHED },
            } },
    DNC = { job = xi.job.DNC, ki = xi.ki.JOB_GESTURE_DANCER,
            quests = {
                { xi.questLog.JEUNO, xi.quest.id.jeuno.LAKESIDE_MINUET },
            } },
    SCH = { job = xi.job.SCH, ki = xi.ki.JOB_GESTURE_SCHOLAR,
            quests = {
                { xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.A_LITTLE_KNOWLEDGE },
            } },
    GEO = { job = xi.job.GEO, ki = xi.ki.JOB_GESTURE_GEOMANCER,    quests = {} },
    RUN = { job = xi.job.RUN, ki = xi.ki.JOB_GESTURE_RUNE_FENCER,  quests = {} },
}

local function error(player, msg)
    player:printToPlayer(msg)
    player:printToPlayer('!unlockjob <job> (player)   e.g. !unlockjob BST Miku')
end

commandObj.onTrigger = function(player, jobName, target)
    if jobName == nil then
        error(player, 'You must supply a job abbreviation (e.g. BST).')
        return
    end

    local data = jobData[string.upper(jobName)]
    if data == nil then
        error(player, string.format('"%s" is not an unlockable advanced job.', tostring(jobName)))
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

    -- 1. unlock the job (only if locked, so we never reset an existing level)
    if targ:getJobLevel(data.job) > 0 then
        player:printToPlayer(string.format('%s already had %s unlocked.',
            targ:getName(), string.upper(jobName)))
    else
        targ:unlockJob(data.job)
    end

    -- 2. grant the job gesture key item
    if data.ki ~= nil and not targ:hasKeyItem(data.ki) then
        targ:addKeyItem(data.ki)
    end

    -- 3. complete the unlock quest chain
    local nQuests = 0
    for _, q in ipairs(data.quests) do
        if q[1] ~= nil and q[2] ~= nil then
            targ:completeQuest(q[1], q[2])
            nQuests = nQuests + 1
        end
    end

    player:printToPlayer(string.format('Unlocked %s for %s (gesture + %d quest%s).',
        string.upper(jobName), targ:getName(), nQuests, nQuests == 1 and '' or 's'))
    if targ ~= player then
        targ:printToPlayer(string.format('%s has been unlocked for you.', string.upper(jobName)))
    end
end

return commandObj
