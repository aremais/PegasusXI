-----------------------------------
-- Area: Reisenjima
--  NPC: Shiftrix
-- Note: Simplified Domain Invasion entry
-----------------------------------
require('scripts/globals/domain_invasion')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    if player:getMainLvl() < 99 then
        player:printToPlayer('You must be level 99 to participate in Domain Invasion.')
        return
    end

    xi.domainInvasion.spawnMobIfMissing(17969868)

    player:printToPlayer('Shiftrix grants you passage to the Domain Invasion battlefield.')
    player:setPos(605.200, -372.000, -957.800, 225)
end

return entity
