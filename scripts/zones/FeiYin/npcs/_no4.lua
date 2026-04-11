-----------------------------------
-- Area: Fei'Yin
--  NPC: Cermet Door (_no4)
-- !pos -184.500 -1.975 190.000
--
-- Windurst Mission 8-2 (The Jester Who'd be King): Rhinostery ring — CS 22 with Rukususu.
-- Retail DAT references npc targid 441 (npc_list 17613241); without that row the client spams
-- CHARREQ and the scene can soft-lock.
--
-- Quest "Curses, Foiled A-Golem!?" (CS 13/14) also uses this door.
-- Default zone event 15 is not registered (see DefaultActions.lua); this script is the only _no4 handler.
--
-- Door + cutscene: after startEvent, return a value other than -1 so the engine does not treat the
-- interaction as "open door only" (see CAIContainer::Trigger / luautils::OnTrigger). KI is granted in
-- onEventFinish when the client completes CS 22.
-----------------------------------

local golemQuest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.CURSES_FOILED_A_GOLEM)

local windurstMissionLog = xi.mission.log_id.WINDURST
local jesterMissionId    = xi.mission.id.windurst.THE_JESTER_WHOD_BE_KING

-- Windurst M8-2 Rhinostery ring (Rukususu at this door)
local csidRhinoRing = 22

-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    -- "Curses, Foiled A-Golem!?" — takes precedence when both could apply.
    if player:getQuestStatus(golemQuest.areaId, golemQuest.questId) == xi.questStatus.QUEST_ACCEPTED then
        if player:hasKeyItem(xi.ki.SHANTOTTOS_NEW_SPELL) then
            golemQuest:setVar(player, 'Prog', 2)
            player:delKeyItem(xi.ki.SHANTOTTOS_NEW_SPELL)
            return -1
        elseif player:hasKeyItem(xi.ki.SHANTOTTOS_EX_SPELL) then
            player:startEvent(13)
            return 1
        end
    end

    -- Windurst M8-2 — cutscene with Rukususu, then Rhinostery ring on event finish.
    if
        player:getCurrentMission(windurstMissionLog) == jesterMissionId and
        player:getMissionStatus(windurstMissionLog) == 1 and
        not player:hasKeyItem(xi.ki.RHINOSTERY_RING)
    then
        player:startEvent(csidRhinoRing, 0, xi.ki.RHINOSTERY_RING)
        return 1
    end

    if player:getCurrentMission(windurstMissionLog) == jesterMissionId then
        return -1
    end

    return -1
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == csidRhinoRing then
        npcUtil.giveKeyItem(player, xi.ki.RHINOSTERY_RING)

        if
            player:hasKeyItem(xi.ki.AURASTERY_RING) and
            player:hasKeyItem(xi.ki.OPTISTERY_RING)
        then
            player:setMissionStatus(windurstMissionLog, 2)
        end
    end
end

return entity
