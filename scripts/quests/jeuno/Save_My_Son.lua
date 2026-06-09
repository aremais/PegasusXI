-----------------------------------
-- Save My Son
-----------------------------------
-- Log ID: 3, Quest ID: 5
-- Door: Merchant's House (_6t2) : !pos -82.22 -7.65 -168.839 245
-- Nightflowers                  : !pos -264.775 -3.718 28.767 126
-----------------------------------

local lowerJeunoID = zones[xi.zone.LOWER_JEUNO]
local upperJeunoID = zones[xi.zone.UPPER_JEUNO]

local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.SAVE_MY_SON)

-- Event 163 embeds broken reward opcodes on Pegasus (item ID 13110 shown as gil,
-- gil amount 2100 issued as key item Vana'diel Tribune Vol.13). Strip those and
-- grant the real rewards from Lua when the cutscene finishes, as pre-IF _6t2 did.
local function captureCutsceneRewardState(player)
    player:setLocalVar('SaveMySon_GilBefore', player:getGil())
    player:setLocalVar('SaveMySon_HadTribune', player:hasKeyItem(xi.ki.VANADIEL_TRIBUNE_VOL13) and 1 or 0)
end

local function stripErroneousCutsceneRewards(player)
    local gilBefore  = player:getLocalVar('SaveMySon_GilBefore')
    local hadTribune = player:getLocalVar('SaveMySon_HadTribune') == 1

    if not hadTribune and player:hasKeyItem(xi.ki.VANADIEL_TRIBUNE_VOL13) then
        player:delKeyItem(xi.ki.VANADIEL_TRIBUNE_VOL13)
    end

    local gilDelta = player:getGil() - gilBefore
    if gilDelta == xi.item.BEAST_WHISTLE then
        player:delGil(gilDelta)
    end
end

local function clearCutsceneRewardState(player)
    player:setLocalVar('SaveMySon_GilBefore', 0)
    player:setLocalVar('SaveMySon_HadTribune', 0)
end

local function completeSaveMySon(player)
    if
        player:getFreeSlotsCount() == 0 and
        not player:hasItem(xi.item.BEAST_WHISTLE)
    then
        player:messageSpecial(lowerJeunoID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.BEAST_WHISTLE)
        return false
    end

    local reward =
    {
        fame     = quest.reward.fame,
        fameArea = quest.reward.fameArea,
        gil      = quest.reward.gil,
        title    = quest.reward.title,
    }

    if not player:hasItem(xi.item.BEAST_WHISTLE) then
        reward.item = quest.reward.item
    end

    if not npcUtil.completeQuest(player, xi.questLog.JEUNO, xi.quest.id.jeuno.SAVE_MY_SON, reward) then
        return false
    end

    quest:cleanup(player)
    return true
end

local function grantBeastmasterJob(player)
    if player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.PATH_OF_THE_BEASTMASTER) then
        return
    end

    if player:getQuestStatus(xi.questLog.JEUNO, xi.quest.id.jeuno.PATH_OF_THE_BEASTMASTER) == xi.questStatus.QUEST_AVAILABLE then
        player:addQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.PATH_OF_THE_BEASTMASTER)
    end

    player:unlockJob(xi.job.BST)
    player:messageSpecial(upperJeunoID.text.YOU_CAN_NOW_BECOME_A_BEASTMASTER)

    npcUtil.completeQuest(player, xi.questLog.JEUNO, xi.quest.id.jeuno.PATH_OF_THE_BEASTMASTER, {
        fame     = 30,
        fameArea = xi.fameArea.JEUNO,
        keyItem  = xi.ki.JOB_GESTURE_BEASTMASTER,
        title    = xi.title.ANIMAL_TRAINER,
    })
end

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.JEUNO,
    gil      = 2100,
    item     = xi.item.BEAST_WHISTLE,
    title    = xi.title.LIFE_SAVER,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.CHOCOBOS_WOUNDS) and
                player:getMainLvl() >= xi.settings.main.ADVANCED_JOB_LEVEL
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['_6t2'] = quest:progressEvent(164),

            onEventFinish =
            {
                [164] = function(player, csid, option, npc)
                    if option == 0 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['_6t2'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Prog') == 1 then
                        captureCutsceneRewardState(player)
                        return quest:progressEvent(163)
                    else
                        return quest:event(229)
                    end
                end,
            },

            onEventUpdate =
            {
                [163] = function(player, csid, option, npc)
                    stripErroneousCutsceneRewards(player)
                end,
            },

            onEventFinish =
            {
                [163] = function(player, csid, option, npc)
                    stripErroneousCutsceneRewards(player)
                    clearCutsceneRewardState(player)

                    if completeSaveMySon(player) then
                        grantBeastmasterJob(player)
                    end
                end,
            },
        },

        [xi.zone.UPPER_JEUNO] =
        {
            ['Shalott'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Prog') == 0 then
                        return quest:event(101)
                    else
                        return quest:event(44)
                    end
                end,
            },
        },

        [xi.zone.QUFIM_ISLAND] =
        {
            ['Nightflowers'] =
            {
                onTrigger = function(player, npc)
                    local vanadielClockTime = utils.vanadielClockTime()
                    local isNight           = vanadielClockTime > 2130 or vanadielClockTime <= 540

                    if quest:getVar(player, 'Prog') == 0 and isNight then
                        return quest:progressEvent(0)
                    end
                end,
            },

            onEventFinish =
            {
                [0] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 1)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['_6t2'] = quest:event(132):replaceDefault(),
        },

        [xi.zone.UPPER_JEUNO] =
        {
            ['Shalott'] = quest:event(44):replaceDefault(),
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED and
                not player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.PATH_OF_THE_BEASTMASTER)
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['Chocobo'] = quest:event(55),
            ['Osker']   = quest:event(55),
        },
    },
}

return quest
