-----------------------------------
-- Area: The Eldieme Necropolis
--  NPC: Treasure Coffer
-- !zone 195
-----------------------------------
---@type TNpcEntity
local entity = {}

local borghertzNecropolisQuests =
{
    { questId = xi.quest.id.jeuno.BORGHERTZS_WARRING_HANDS,   jobId = xi.job.WAR },
    { questId = xi.quest.id.jeuno.BORGHERTZS_STALWART_HANDS,  jobId = xi.job.PLD },
    { questId = xi.quest.id.jeuno.BORGHERTZS_VERMILLION_HANDS, jobId = xi.job.RDM },
    { questId = xi.quest.id.jeuno.BORGHERTZS_SHADOWY_HANDS,   jobId = xi.job.DRK },
}

local function needsOldGauntlets(player)
    if player:hasKeyItem(xi.keyItem.OLD_GAUNTLETS) then
        return false
    end

    for _, questInfo in ipairs(borghertzNecropolisQuests) do
        if
            player:getQuestStatus(xi.questLog.JEUNO, questInfo.questId) == xi.questStatus.QUEST_ACCEPTED or
            player:getCharVar(string.format('Quest[3][%u]Option', questInfo.questId)) == questInfo.jobId
        then
            return true
        end
    end

    return false
end

entity.onTrade = function(player, npc, trade)
    if needsOldGauntlets(player) then
        return xi.treasure.onTrade(player, npc, trade, 2, xi.keyItem.OLD_GAUNTLETS)
    else
        return xi.treasure.onTrade(player, npc, trade, 0, 0)
    end
end

entity.onTrigger = function(player, npc)
    xi.treasure.onTrigger(player, npc)
end

return entity
