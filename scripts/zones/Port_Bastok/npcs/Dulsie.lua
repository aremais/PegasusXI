-----------------------------------
-- Area: Port Bastok
--  NPC: Dulsie
-- Adventurer's Assistant (custom starter pack)
-----------------------------------

local ID = zones[xi.zone.PORT_BASTOK]

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

    -- KEY ITEMS 389 to 447 -Maps
    for z = 389, 447 do
        player:addKeyItem(z)
    end

    -- KEY ITEMS 1856 to 1893
    for z = 1856, 1893 do
        player:addKeyItem(z)
    end

    -- Grants all Trust spells
    for spellId = xi.magic.spell.SHANTOTTO, xi.magic.spell.SHANTOTTO_II do
        player:addSpell(spellId, { silentLog = true })
    end

    -- Trust permits (safe to include)
    player:addKeyItem(xi.ki.BASTOK_TRUST_PERMIT)
    player:addKeyItem(xi.ki.WINDURST_TRUST_PERMIT)
    player:addKeyItem(xi.ki.SAN_DORIA_TRUST_PERMIT)

    -- Adds nation items for starting nation
    player:addItem(xi.item.REPUBLIC_AKETON)
    player:addItem(xi.item.REPUBLIC_SIGNET_STAFF)

    -- Grants gil and gives the appropriate message
    player:addGil(10000000)
    if ID and ID.text and ID.text.GIL_OBTAINED then
        player:messageSpecial(ID.text.GIL_OBTAINED, 10000000)
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
            player:printToPlayer('Starter pack granted.')
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
