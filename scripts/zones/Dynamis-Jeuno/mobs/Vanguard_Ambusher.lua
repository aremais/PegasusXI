-----------------------------------
-- Area: Dynamis - Jeuno
--  Mob: Vanguard Ambusher
-----------------------------------
mixins =
{
    require('scripts/mixins/dynamis_beastmen'),
    require('scripts/mixins/job_special')
}
local ID = zones[xi.zone.DYNAMIS_JEUNO]
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
end

entity.onMobDespawn = function(mob)
    xi.mob.phOnDespawn(mob, ID.mob.PROWLOX_BARRELBELLY, xi.dynamis.jeunoTimedGoblinLottery.chancePercentScaled, xi.dynamis.jeunoTimedGoblinLottery.cooldownSeconds) -- timed Goblin NM (Roving Bijou); see xi.dynamis.jeunoTimedGoblinLottery / BG-Wiki Dynamis - Jeuno
end

return entity
