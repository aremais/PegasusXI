-----------------------------------
-- Area: Nashmau
--  NPC: Tsutsuroon
-- Type: Tenshodo Merchant
-- !pos -15.193 0.000 31.356 53
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    if not player:hasKeyItem(xi.ki.TENSHODO_MEMBERS_CARD) then
        return
    end

    player:showText(npc, 10506)
    player:sendGuild(60431, 1, 23, 7)
end

return entity
