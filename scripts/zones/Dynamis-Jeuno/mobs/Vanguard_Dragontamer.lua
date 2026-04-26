-----------------------------------
-- Area: Dynamis - Jeuno
--  Mob: Vanguard Dragontamer
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

entity.onMobInitialize = function(mob)
    xi.pet.setMobPet(mob, 1, 'Vanguards_Wyvern')
end

entity.onMobSpawn = function(mob)
    xi.dynamis.mobInfo(mob)
end

entity.onMobDeath = function(mob, player, optParams)
end

entity.onMobDespawn = function(mob)
    xi.mob.phOnDespawn(mob, ID.mob.RUTRIX_HAMGAMS, xi.dynamis.jeunoTimedGoblinLottery.chancePercentScaled, xi.dynamis.jeunoTimedGoblinLottery.cooldownSeconds) -- timed Goblin NM (Roving Bijou); see xi.dynamis.jeunoTimedGoblinLottery / BG-Wiki Dynamis - Jeuno
end

return entity
