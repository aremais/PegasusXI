-----------------------------------
-- Area: Dynamis - Buburimu
--  Mob: Arch Apocalyptic Beast
-- Note: Mega Boss (Fiendish Tome II); same Shadescale weakening as base beast (bg-wiki)
-----------------------------------
require('scripts/globals/dynamis_buburimu_apocalyptic')
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobSpawn = function(mob)
    mob:addImmunity(xi.immunity.GRAVITY)
end

entity.onMobMobskillChoose = xi.dynamis.buburimuApocalypticOnMobMobskillChoose

-- KI / title: awarded from normal Apocalyptic Beast (megaBossOnDeath), not Arch.

return entity
