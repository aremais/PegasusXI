-----------------------------------
-- Area: Dynamis - Valkurm
--  Mob: Fairy Ring
-----------------------------------
require('scripts/globals/dynamis_valkurm_christelle')
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobSpawn = function(mob)
    mob:setBaseSpeed(70)
    mob:setMobSkillAttack(2008) -- use mephitic spare as its auto attack
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:setMobMod(xi.mobMod.WEAPON_BONUS, 165) -- Level 85 + 2 + 165 = 252 Base damage
end

entity.onMobDeath = function(mob, player, optParams)
    xi.dynamis.valkurmMarkChristelleWeakTier('miasmic')
end

return entity
