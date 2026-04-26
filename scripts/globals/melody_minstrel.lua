-----------------------------------
-- Melody Minstrels (cutscene replay NPCs in towns)
-- Client expects cost + current gil as event params (see Past Event Watchers
-- e.g. Lamepaue, Dalba). Without them, dialogue shows "0 gil" but the client
-- still rejects the transaction ("You do not have enough gil.").
-----------------------------------
xi = xi or {}
xi.melodyMinstrel = xi.melodyMinstrel or {}

xi.melodyMinstrel.GIL_COST = 10

---@param player CBaseEntity
---@param eventId integer Zone-local event id for this NPC's replay menu
function xi.melodyMinstrel.onTrigger(player, eventId)
    local gil = player:getGil()
    player:startEvent(eventId, xi.melodyMinstrel.GIL_COST, gil)
end

---@param player CBaseEntity
---@param csid integer
---@param option integer
---@param npc CBaseEntity
---@param eventId integer
function xi.melodyMinstrel.onEventUpdate(player, csid, option, npc, eventId)
    if csid ~= eventId then
        return
    end

    local cost = xi.melodyMinstrel.GIL_COST
    if not player:delGil(cost) then
        player:updateEvent(0)
    end
end
