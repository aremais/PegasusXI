-----------------------------------
-- Area: Dynamis - Jeuno
--  Mob: Vanguard Enchanter
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

entity.onMobSpawn = function(mob)
    xi.dynamis.mobInfo(mob)
end

entity.onMobDeath = function(mob, player, optParams)
end

entity.onMobDespawn = function(mob)
    xi.mob.phOnDespawn(mob, ID.mob.HERMITRIX_TOOTHROT, xi.dynamis.jeunoTimedGoblinLottery.chancePercentScaled, xi.dynamis.jeunoTimedGoblinLottery.cooldownSeconds) -- timed Goblin NM (Roving Bijou); see xi.dynamis.jeunoTimedGoblinLottery / BG-Wiki Dynamis - Jeuno
    xi.mob.phOnDespawn(mob, ID.mob.WYRMWIX_SNAKESPECS, xi.dynamis.jeunoTimedGoblinLottery.chancePercentScaled, xi.dynamis.jeunoTimedGoblinLottery.cooldownSeconds) -- timed Goblin NM (Roving Bijou); see xi.dynamis.jeunoTimedGoblinLottery / BG-Wiki Dynamis - Jeuno
    xi.mob.phOnDespawn(mob, ID.mob.JABBROX_GRANNYGUISE, xi.dynamis.jeunoTimedGoblinLottery.chancePercentScaled, xi.dynamis.jeunoTimedGoblinLottery.cooldownSeconds) -- timed Goblin NM (Roving Bijou); see xi.dynamis.jeunoTimedGoblinLottery / BG-Wiki Dynamis - Jeuno
end

return entity
