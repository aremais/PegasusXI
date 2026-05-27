-----------------------------------
-- Area: Bastok Mines
--  NPC: Rashid
-- Type: Mission Giver
-- !pos -8.444 -2 -123.575 234
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    if player:getNation() ~= xi.nation.BASTOK then
        player:startEvent(1003) -- For non-Bastokian
    elseif xi.mission.bastokGateGuardOnTrigger(player, npc) then
        return
    else
        local flagMission, repeatMission = xi.mission.getMissionMask(player)
        player:startEvent(1001, flagMission, 0, 0, 0, 0, repeatMission) -- Mission List
    end
end

return entity
