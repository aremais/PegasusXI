-----------------------------------
-- Area: Port Bastok
--  NPC: Dulsie
-- Adventurer's Assistant (custom starter pack)
-----------------------------------

local ID = zones[xi.zone.PORT_BASTOK]
local npcUtil = require("scripts/globals/npc_util")

---@type TNpcEntity
local entity = {}

local function grantStarterPack(player)
    -- Adds all maps (Pre-SoA, no Dynamis)
    local baseMapKIs =
    {
        8, 9, 118, 138,
        352, 353, 354, 355, 356, 357,
        385, 386, 387, 388,
    }

    for _, ki in ipairs(baseMapKIs) do
        player:addKeyItem(ki)
    end

    -- KEY ITEMS 389 to 447
    for z = 389, 447 do
        player:addKeyItem(z)
    end

    -- KEY ITEMS 1856 to 1893
    for z = 1856, 1893 do
        player:addKeyItem(z)
    end

    -- KEY ITEMS 1738 to 1757
    for z = 1738, 1757 do
        player:addKeyItem(z)
    end

    -- Adds all 3 starting nation rings
    player:addItem(13497)
    player:addItem(17584)
    player:addItem(14429)

    -- Unlocks subjob
    player:unlockJob(0)

    -- Grants gil and gives the appropriate message
    player:addGil(10000000)
    if ID and ID.text and ID.text.GIL_OBTAINED then
        player:messageSpecial(ID.text.GIL_OBTAINED, 10000000)
    end

    -- Unlocks Advanced Jobs
    for jobId = 7, 22 do
        player:unlockJob(jobId)
    end

    -- Set main job to 99 and sub job to 49
    player:setLevel(99)
    if player.setSubJobLevel then
        player:setSubJobLevel(49)
    elseif player.setSubLevel then
        player:setSubLevel(49)
    end
end

entity.onTrade = function(player, npc, trade)
    if
        trade:getItemCount() == 1 and
        trade:hasItemQty(xi.item.ADVENTURER_COUPON, 1)
    then
        -- Grant immediately; no event so nothing can retrigger
        player:tradeComplete()
        grantStarterPack(player)

        -- Optional: simple feedback line
        if player.printToPlayer then
            player:printToPlayer("Starter pack granted.")
        end
    end
end

entity.onTrigger = function(player, npc)
    -- No event to avoid loop; just tell the player what to do
    if player.printToPlayer then
        player:printToPlayer("Trade an Adventurer's Coupon to receive the starter pack.")
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    -- Unused; reward is granted in onTrade
end

return entity