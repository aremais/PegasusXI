-----------------------------------
-- Area: Konschtat Highlands
--  NPC: qm2 (???)
-- Involved in Quest: Forge Your Destiny
-- !pos -709 2 102 108
-----------------------------------
local ID = zones[xi.zone.KONSCHTAT_HIGHLANDS]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    if player:getQuestStatus(xi.questLog.OUTLANDS, xi.quest.id.outlands.FORGE_YOUR_DESTINY) ~= xi.questStatus.QUEST_ACCEPTED then
        return
    end

    if not npcUtil.tradeHasExactly(trade, xi.item.LUMP_OF_ORIENTAL_STEEL) then
        return
    end

    local forger = GetMobByID(ID.mob.FORGER)
    if not forger then
        return
    end

    if player:checkDistance(npc) > 1.6 then
        player:messageSpecial(ID.text.BLACKENED_MUST_BE_CLOSER)
        return
    end

    if
        forger:isSpawned() or
        npc:getLocalVar('forgerNextPopAllowedTime') > GetSystemTime()
    then
        player:messageSpecial(ID.text.BLACKENED_NOTHING_HAPPENS, xi.item.LUMP_OF_ORIENTAL_STEEL)
        return
    end

    local forgerMob = SpawnMob(ID.mob.FORGER)
    if not forgerMob then
        return
    end

    forgerMob:updateClaim(player)
    player:tradeComplete()

    -- QM is visible, but cannot be used to spawn Forger again until two minutes have elapsed
    -- since the NM despawns.
    forgerMob:setLocalVar('QMID', npc:getID())
    forgerMob:addListener('DESPAWN', 'DESPAWN_' .. ID.mob.FORGER, function(mobArg)
        local qmID = mobArg:getLocalVar('QMID')

        mobArg:removeListener('DESPAWN_' .. ID.mob.FORGER)
        GetNPCByID(qmID):setLocalVar('forgerNextPopAllowedTime', GetSystemTime() + 120)
    end)

    player:messageSpecial(ID.text.PLACE_BLACKENED_SPOT, xi.item.LUMP_OF_ORIENTAL_STEEL)
end

entity.onTrigger = function(player, npc)
    if player:getQuestStatus(xi.questLog.OUTLANDS, xi.quest.id.outlands.FORGE_YOUR_DESTINY) ~= xi.questStatus.QUEST_ACCEPTED then
        player:messageSpecial(ID.text.BLACKENED_SPOT_ON_GROUND)
        return
    end

    local forger = GetMobByID(ID.mob.FORGER)
    if forger and forger:isSpawned() then
        player:messageSpecial(ID.text.NOT_THE_TIME_FOR_THAT)
    elseif npc:getLocalVar('forgerNextPopAllowedTime') <= GetSystemTime() then
        -- This message persists even after kill, while the QM is active and quest is accepted.
        player:messageSpecial(ID.text.BLACKENED_SHOULD_PLACE, xi.item.LUMP_OF_ORIENTAL_STEEL)
    end
end

return entity
