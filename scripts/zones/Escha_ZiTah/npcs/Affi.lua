-----------------------------------
-- Area: Escha - Zi'Tah
--  NPC: Affi
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

    xi.domainInvasion.spawnMobIfMissing(17957397)

    player:printToPlayer('Affi grants you passage to the Domain Invasion battlefield.')
    player:setPos(-12.000, -0.425, 24.500, 192)
end

return entity
