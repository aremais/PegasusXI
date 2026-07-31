-----------------------------------
-- Area: Windurst Walls
-- Door: House of the Hero
-- Involved In Quest: I Can Hear a Rainbow, Know One's Onions, Onion Rings, The Puppet Master, Class Reunion
-- !pos -26 -13 260 239
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local thePuppetMaster  = player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.THE_PUPPET_MASTER)
    local classReunion     = player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.CLASS_REUNION)
    local carbuncleDebacle = player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.CARBUNCLE_DEBACLE)
    local hearRainbow      = player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.I_CAN_HEAR_A_RAINBOW)

    -- I CAN HEAR A RAINBOW (SMN unlock; any main job with Carbuncle's ruby)
    -- Fallback when interaction framework does not fire; mirrors scripts/quests/windurst/SMN_I_Can_Hear_a_Rainbow.lua
    if
        hearRainbow == xi.questStatus.QUEST_AVAILABLE and
        player:getMainLvl() >= xi.settings.main.ADVANCED_JOB_LEVEL and
        player:hasItem(xi.item.CARBUNCLES_RUBY, xi.inventoryLocation.INVENTORY)
    then
        player:startEvent(384, 0, xi.item.CARBUNCLES_RUBY)

    -- CLASS REUNION
    elseif
        thePuppetMaster == xi.questStatus.QUEST_COMPLETED and
        classReunion == xi.questStatus.QUEST_AVAILABLE and
        player:getMainLvl() >= xi.settings.main.AF2_QUEST_LEVEL and
        player:getMainJob() == xi.job.SMN and
        not player:needToZone()
    then
        player:startEvent(413)

    -- CARBUNCLE DEBACLE
    elseif
        thePuppetMaster == xi.questStatus.QUEST_COMPLETED and
        classReunion == xi.questStatus.QUEST_COMPLETED and
        carbuncleDebacle == xi.questStatus.QUEST_AVAILABLE and
        player:getMainLvl() >= xi.settings.main.AF3_QUEST_LEVEL and
        player:getMainJob() == xi.job.SMN and
        not player:needToZone()
    then
        player:startEvent(415)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    -- I CAN HEAR A RAINBOW (only if interaction quest handler did not already begin the quest)
    if
        csid == 384 and
        player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.I_CAN_HEAR_A_RAINBOW) == xi.questStatus.QUEST_AVAILABLE
    then
        player:addQuest(xi.questLog.WINDURST, xi.quest.id.windurst.I_CAN_HEAR_A_RAINBOW)

    -- CLASS REUNION
    elseif csid == 413 then
        player:addQuest(xi.questLog.WINDURST, xi.quest.id.windurst.CLASS_REUNION)
        npcUtil.giveKeyItem(player, xi.ki.CARBUNCLES_TEAR)
        player:setCharVar('ClassReunionProgress', 1)

    -- CARBUNCLE DEBACLE
    elseif csid == 415 then
        player:addQuest(xi.questLog.WINDURST, xi.quest.id.windurst.CARBUNCLE_DEBACLE)
        player:setCharVar('CarbuncleDebacleProgress', 1)
    end
end

return entity
