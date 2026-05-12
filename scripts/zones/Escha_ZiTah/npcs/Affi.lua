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
    xi.domainInvasion.enterBattlefield(player, 1)
end

return entity
