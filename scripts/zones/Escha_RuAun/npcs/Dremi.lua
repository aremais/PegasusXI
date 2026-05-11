-----------------------------------
-- Area: Escha - Ru'Aun
--  NPC: Dremi
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

    xi.domainInvasion.spawnMobIfMissing(17961638)

    player:printToPlayer('Dremi grants you passage to the Domain Invasion battlefield.')
    player:setPos(-10.000, -44.099, -220.000, 64)
end

return entity
