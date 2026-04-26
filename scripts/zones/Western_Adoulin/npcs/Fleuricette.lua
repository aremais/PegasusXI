-----------------------------------
-- Area: Western Adoulin
--  NPC: Fleuricette
-- Ionis for 10 bayld (Ulbuka regional influence buff).
-- !pos -154.500 4.000 -17.000 256
--
-- Uses customMenu instead of startEvent: guessed zone CSIDs (e.g. 2524) mismatched
-- retail ROM data and soft-locked characters in event state. Revisit with a
-- captured CSID + options before switching back to cutscenes.
-----------------------------------
require('scripts/globals/ionis')

local ID = zones[xi.zone.WESTERN_ADOULIN]

---@type TNpcEntity
local entity = {}

local ionisCost     = 10
local ionisDuration = 10800 -- seconds (retail: 180 minutes per bg-wiki Ionis)

local function grantIonis(player)
    if player:getCurrency('bayld') < ionisCost then
        player:messageSpecial(ID.text.NOT_ENOUGH_BAYLD)
        return
    end

    player:delCurrency('bayld', ionisCost)
    player:delStatusEffectsByFlag(xi.effectFlag.INFLUENCE, true)
    local ionisParams = xi.ionis.encodeEffectParams(player)
    player:addStatusEffect(xi.effect.IONIS, {
        duration = ionisDuration,
        origin = player,
        power = ionisParams.power,
        subPower = ionisParams.subPower,
        subType = ionisParams.subType,
    })
end

entity.onTrigger = function(player, npc)
    player:customMenu({
        title = string.format('Ionis (%u bayld)', ionisCost),
        options =
        {
            {
                'Receive Ionis',
                function(p)
                    grantIonis(p)
                end,
            },
            {
                'Cancel',
                function(_) end,
            },
        },
    })
end

return entity
