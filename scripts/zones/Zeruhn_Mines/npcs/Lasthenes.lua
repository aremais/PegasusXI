-----------------------------------
-- Area: Zeruhn Mines
--  NPC: Lasthenes
-- Notes: Opens Gate
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    player:setLocalVar('LasthenesKorroloka', 0)
    if player:getXPos() > -79.5 then
        player:startEvent(180)
    else
        player:startEvent(181)
    end
end

-- Option 1 in update = "Let me through"; the walking cutscene still runs before onEventFinish.
-- Server warp after CS avoids MAPRECT failing when DB zoneline from_pos is wrong upstream.
entity.onEventUpdate = function(player, csid, option, npc)
    if csid == 180 or csid == 181 then
        if option == 1 then
            player:setLocalVar('LasthenesKorroloka', 1)
        elseif option == 2 then
            player:setLocalVar('LasthenesKorroloka', 0)
        end
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid ~= 180 and csid ~= 181 then
        return
    end

    if player:getLocalVar('LasthenesKorroloka') == 1 then
        player:setLocalVar('LasthenesKorroloka', 0)
        player:setPos(0, 0, 0, 0, xi.zone.KORROLOKA_TUNNEL)
    else
        player:setLocalVar('LasthenesKorroloka', 0)
    end
end

return entity
