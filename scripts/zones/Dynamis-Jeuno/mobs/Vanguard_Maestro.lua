-----------------------------------
-- Area: Dynamis - Jeuno
--  Mob: Vanguard Maestro
-----------------------------------
mixins =
{
    require('scripts/mixins/dynamis_beastmen'),
    require('scripts/mixins/job_special')
}
-----------------------------------
---@type TMobEntity
local entity = {}

-- Retail (BG-Wiki Dynamis - Jeuno): Odious Mask on this job via mob_groups drop table; not a PH for a timed Goblin NM.

entity.onMobDeath = function(mob, player, optParams)
end

return entity
