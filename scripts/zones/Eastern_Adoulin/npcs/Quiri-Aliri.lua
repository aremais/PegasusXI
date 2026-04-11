-----------------------------------
-- Area: Eastern Adoulin
--  NPC: Quiri-Aliri
-- Same service as Fleuricette (Western Adoulin): Ionis for 10 bayld.
-- !pos -53.000 -0.150 85.000 257
--
-- customMenu avoids startEvent CSID mismatch (7514 guess soft-locked clients).
-----------------------------------
require('scripts/globals/ionis')

local ID = zones[xi.zone.EASTERN_ADOULIN]

---@type TNpcEntity
local entity = {}

local ionisCost     = 10
local ionisDuration = 10800

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
