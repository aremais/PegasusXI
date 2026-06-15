-----------------------------------
-- Area: Monarch Linn
-- Name: Ancient Vows
-----------------------------------

local content = BattlefieldMission:new({
    zoneId        = xi.zone.MONARCH_LINN,
    battlefieldId = xi.battlefield.id.ANCIENT_VOWS,
    canLoseExp    = false,
    isMission     = true,
    allowTrusts   = true,
    maxPlayers    = 6,
    levelCap      = 40,
    timeLimit     = utils.minutes(30),
    index         = 0,
    entryNpc      = 'SD_Entrance',
    exitNpcs      = { 'SD_BCNM_Exit_1', 'SD_BCNM_Exit_2', 'SD_BCNM_Exit_3' },
    missionArea   = xi.mission.log_id.COP,
    mission       = xi.mission.id.cop.ANCIENT_VOWS,
    requiredVar   = 'Mission[6][248]Status',
    requiredValue = 2,

    grantXP = 1000,
    title   = xi.title.TAVNAZIAN_TRAVELER,
})

function content:entryRequirement(player, npc, isRegistrant, trade)
    -- NOTE: In cases for testing or something may have happened to the player's
    -- prevZone value, ensure we entered the "correct" way by confirming that
    -- they did not enter from Site B01.

    return player:getPreviousZone() ~= xi.zone.RIVERNE_SITE_B01
end

content.groups =
{
    {
        -- Name-based lookup splits 9 Mammet spawns across the 3 Monarch Linn arenas.
        mobs = { 'Mammet-19_Epsilon' },

        allDeath = function(battlefield, mob)
            battlefield:setStatus(xi.battlefield.status.WON)
        end,
    },
}

return content:register()
