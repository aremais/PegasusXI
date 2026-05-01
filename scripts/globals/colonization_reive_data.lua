-----------------------------------
-- Colonization Reive Data
-----------------------------------
xi = xi or {}
xi.reives = xi.reives or {}

local ceizakBattlegroundsID = zones[xi.zone.CEIZAK_BATTLEGROUNDS]
local cirdasCavernsID       = zones[xi.zone.CIRDAS_CAVERNS]
local dhoGatesID            = zones[xi.zone.DHO_GATES]
local foretDeHennetielID    = zones[xi.zone.FORET_DE_HENNETIEL]
local kamihrDriftsID        = zones[xi.zone.KAMIHR_DRIFTS]
local marjamiRavineID       = zones[xi.zone.MARJAMI_RAVINE]
local mohGatesID            = zones[xi.zone.MOH_GATES]
local morimarBasaltFieldsID = zones[xi.zone.MORIMAR_BASALT_FIELDS]
local outerRakaznarID       = zones[xi.zone.OUTER_RAKAZNAR]
local rakaznarInnerCourtID  = zones[xi.zone.RAKAZNAR_INNER_COURT]
local sihGatesID            = zones[xi.zone.SIH_GATES]
local wohGatesID            = zones[xi.zone.WOH_GATES]
local yahseHuntingGroundsID = zones[xi.zone.YAHSE_HUNTING_GROUNDS]
local yorciaWealdID         = zones[xi.zone.YORCIA_WEALD]

-- nil-safe: GetFirstID is nil if mob_spawn_points / npc_list rows are missing.
local function reiveMobBase(z)
    return (z and z.mob and z.mob.REIVE_MOB_OFFSET) or 0
end
local function reiveNpcCol(z)
    return (z and z.npc and z.npc.REIVE_COLLISION_OFFSET) or 0
end

--Zone Data
xi.reives.zoneData =
{
    [xi.zone.CEIZAK_BATTLEGROUNDS] =
    {
        reiveObjRespawnTime = 3600, -- 60 minutes
        reiveMobRespawnTime = 300,  -- 5 minutes
        reive =
        {
            -- !pos 120 0.184 -54 261
            [1] =
            {
                mob =
                {
                    reiveMobBase(ceizakBattlegroundsID) + 3,
                    reiveMobBase(ceizakBattlegroundsID) + 4,
                    reiveMobBase(ceizakBattlegroundsID) + 5,
                    reiveMobBase(ceizakBattlegroundsID) + 6,
                },
                obstacles =
                {
                    reiveMobBase(ceizakBattlegroundsID),
                    reiveMobBase(ceizakBattlegroundsID) + 1,
                    reiveMobBase(ceizakBattlegroundsID) + 2,
                },
                collision =
                {
                    reiveNpcCol(ceizakBattlegroundsID),
                    reiveNpcCol(ceizakBattlegroundsID) + 1,
                },
            },

            -- !pos -134 0.184 39 261
            [2] =
            {
                mob =
                {
                    reiveMobBase(ceizakBattlegroundsID) + 19,
                    reiveMobBase(ceizakBattlegroundsID) + 20,
                    reiveMobBase(ceizakBattlegroundsID) + 21,
                    reiveMobBase(ceizakBattlegroundsID) + 22,
                    reiveMobBase(ceizakBattlegroundsID) + 23,
                    reiveMobBase(ceizakBattlegroundsID) + 24,
                },
                obstacles =
                {
                    reiveMobBase(ceizakBattlegroundsID) + 16,
                    reiveMobBase(ceizakBattlegroundsID) + 17,
                    reiveMobBase(ceizakBattlegroundsID) + 18,
                },
                collision =
                {
                    reiveNpcCol(ceizakBattlegroundsID) + 2,
                    reiveNpcCol(ceizakBattlegroundsID) + 3,
                },
            },

            -- !pos -239 0.184 174 261
            [3] =
            {
                mob =
                {
                    reiveMobBase(ceizakBattlegroundsID) + 10,
                    reiveMobBase(ceizakBattlegroundsID) + 11,
                    reiveMobBase(ceizakBattlegroundsID) + 12,
                    reiveMobBase(ceizakBattlegroundsID) + 13,
                    reiveMobBase(ceizakBattlegroundsID) + 14,
                    reiveMobBase(ceizakBattlegroundsID) + 15,
                },
                obstacles =
                {
                    reiveMobBase(ceizakBattlegroundsID) + 7,
                    reiveMobBase(ceizakBattlegroundsID) + 8,
                    reiveMobBase(ceizakBattlegroundsID) + 9,
                },
                collision =
                {
                    reiveNpcCol(ceizakBattlegroundsID) + 4,
                    reiveNpcCol(ceizakBattlegroundsID) + 5,
                },
            },

            -- !pos -280.499 0.409 182 261
            [4] =
            {
                mob =
                {
                    reiveMobBase(ceizakBattlegroundsID) + 28,
                    reiveMobBase(ceizakBattlegroundsID) + 29,
                    reiveMobBase(ceizakBattlegroundsID) + 30,
                    reiveMobBase(ceizakBattlegroundsID) + 31,
                    reiveMobBase(ceizakBattlegroundsID) + 32,
                    reiveMobBase(ceizakBattlegroundsID) + 33,
                },
                obstacles =
                {
                    reiveMobBase(ceizakBattlegroundsID) + 25,
                    reiveMobBase(ceizakBattlegroundsID) + 26,
                    reiveMobBase(ceizakBattlegroundsID) + 27,
                },
                collision =
                {
                    reiveNpcCol(ceizakBattlegroundsID) + 6,
                    reiveNpcCol(ceizakBattlegroundsID) + 7,
                },
            },
        },
    },

    [xi.zone.CIRDAS_CAVERNS] =
    {
        reiveObjRespawnTime = 3600, -- 60 minutes
        reiveMobRespawnTime = 300,  -- 5 minutes
        reive =
        {

            -- !pos -120 19.972 22 270
            [1] =
            {
                mob =
                {
                    reiveMobBase(cirdasCavernsID) + 2,
                    reiveMobBase(cirdasCavernsID) + 3,
                    reiveMobBase(cirdasCavernsID) + 4,
                    reiveMobBase(cirdasCavernsID) + 5,
                },
                obstacles =
                {
                    reiveMobBase(cirdasCavernsID),
                    reiveMobBase(cirdasCavernsID) + 1,
                },
                collision =
                {
                    reiveNpcCol(cirdasCavernsID) + 12,
                    reiveNpcCol(cirdasCavernsID) + 13,
                },
            },

            -- !pos 439 19.972 142 270
            [2] =
            {
                mob =
                {
                    reiveMobBase(cirdasCavernsID) + 8,
                    reiveMobBase(cirdasCavernsID) + 9,
                    reiveMobBase(cirdasCavernsID) + 10,
                    reiveMobBase(cirdasCavernsID) + 11,
                },
                obstacles =
                {
                    reiveMobBase(cirdasCavernsID) + 6,
                    reiveMobBase(cirdasCavernsID) + 7,
                },
                collision =
                {
                    reiveNpcCol(cirdasCavernsID),
                    reiveNpcCol(cirdasCavernsID) + 1,
                },
            },

            -- !pos 98 19.972 -40 270
            [3] =
            {
                mob =
                {
                    reiveMobBase(cirdasCavernsID) + 14,
                    reiveMobBase(cirdasCavernsID) + 15,
                    reiveMobBase(cirdasCavernsID) + 16,
                    reiveMobBase(cirdasCavernsID) + 17,
                },
                obstacles =
                {
                    reiveMobBase(cirdasCavernsID) + 12,
                    reiveMobBase(cirdasCavernsID) + 13,
                },
                collision =
                {
                    reiveNpcCol(cirdasCavernsID) + 8,
                    reiveNpcCol(cirdasCavernsID) + 9,
                },
            },

            -- !pos -62 19.972 160 270
            [4] =
            {
                mob =
                {
                    reiveMobBase(cirdasCavernsID) + 20,
                    reiveMobBase(cirdasCavernsID) + 21,
                    reiveMobBase(cirdasCavernsID) + 22,
                    reiveMobBase(cirdasCavernsID) + 23,
                },
                obstacles =
                {
                    reiveMobBase(cirdasCavernsID) + 18,
                    reiveMobBase(cirdasCavernsID) + 19,
                },
                collision =
                {
                    reiveNpcCol(cirdasCavernsID) + 10,
                    reiveNpcCol(cirdasCavernsID) + 11,
                },
            },

            -- !pos 160 19.972 301 270
            [5] =
            {
                mob =
                {
                    reiveMobBase(cirdasCavernsID) + 26,
                    reiveMobBase(cirdasCavernsID) + 27,
                    reiveMobBase(cirdasCavernsID) + 28,
                    reiveMobBase(cirdasCavernsID) + 29,
                },
                obstacles =
                {
                    reiveMobBase(cirdasCavernsID) + 24,
                    reiveMobBase(cirdasCavernsID) + 25,
                },
                collision =
                {
                    reiveNpcCol(cirdasCavernsID) + 4,
                    reiveNpcCol(cirdasCavernsID) + 5,
                },
            },

            -- !pos 220.215 20 40.89 270
            [6] =
            {
                mob =
                {
                    reiveMobBase(cirdasCavernsID) + 32,
                    reiveMobBase(cirdasCavernsID) + 33,
                    reiveMobBase(cirdasCavernsID) + 34,
                    reiveMobBase(cirdasCavernsID) + 35,
                },
                obstacles =
                {
                    reiveMobBase(cirdasCavernsID) + 30,
                    reiveMobBase(cirdasCavernsID) + 31,
                },
                collision =
                {
                    reiveNpcCol(cirdasCavernsID) + 2,
                    reiveNpcCol(cirdasCavernsID) + 3,
                },
            },
        },
    },

    [xi.zone.DHO_GATES] =
    {
        reiveObjRespawnTime = 3600, -- 60 minutes
        reiveMobRespawnTime = 300,  -- 5 minutes
        reive =
        {
            -- !pos -60 -9.9 73.8 272
            [1] =
            {
                mob =
                {
                    reiveMobBase(dhoGatesID) + 2,
                    reiveMobBase(dhoGatesID) + 3,
                    reiveMobBase(dhoGatesID) + 4,
                    reiveMobBase(dhoGatesID) + 5,
                },
                obstacles =
                {
                    reiveMobBase(dhoGatesID),
                    reiveMobBase(dhoGatesID) + 1,
                },
                collision =
                {
                    reiveNpcCol(dhoGatesID),
                    reiveNpcCol(dhoGatesID) + 1,
                },
            },

            -- !pos -154 -20 300.9 272
            [2] =
            {
                mob =
                {
                    reiveMobBase(dhoGatesID) + 8,
                    reiveMobBase(dhoGatesID) + 9,
                    reiveMobBase(dhoGatesID) + 10,
                    reiveMobBase(dhoGatesID) + 11,
                },
                obstacles =
                {
                    reiveMobBase(dhoGatesID) + 6,
                    reiveMobBase(dhoGatesID) + 7,
                },
                collision =
                {
                    reiveNpcCol(dhoGatesID) + 2,
                    reiveNpcCol(dhoGatesID) + 3,
                },
            },
        },
    },

    [xi.zone.FORET_DE_HENNETIEL] =
    {
        reiveObjRespawnTime = 3600, -- 60 minutes
        reiveMobRespawnTime = 300,  -- 5 minutes
        reive =
        {
            -- !pos 183.4 -1.9 220 262
            [1] =
            {
                mob =
                {
                    reiveMobBase(foretDeHennetielID) + 1,
                    reiveMobBase(foretDeHennetielID) + 2,
                    reiveMobBase(foretDeHennetielID) + 3,
                },
                obstacles =
                {
                    reiveMobBase(foretDeHennetielID),
                },
                collision =
                {
                    reiveNpcCol(foretDeHennetielID) + 10,
                    reiveNpcCol(foretDeHennetielID) + 11,
                },
            },
            -- !pos 136.5 -2.1 258 262
            [2] =
            {
                mob =
                {
                    reiveMobBase(foretDeHennetielID) + 5,
                    reiveMobBase(foretDeHennetielID) + 6,
                    reiveMobBase(foretDeHennetielID) + 7,
                },
                obstacles =
                {
                    reiveMobBase(foretDeHennetielID) + 4,
                },
                collision =
                {
                    reiveNpcCol(foretDeHennetielID) + 8,
                    reiveNpcCol(foretDeHennetielID) + 9,
                },
            },

            -- !pos -16.6 -1.8 380 262
            [3] =
            {
                mob =
                {
                    reiveMobBase(foretDeHennetielID) + 9,
                    reiveMobBase(foretDeHennetielID) + 10,
                    reiveMobBase(foretDeHennetielID) + 11,
                },
                obstacles =
                {
                    reiveMobBase(foretDeHennetielID) + 8,
                },
                collision =
                {
                    reiveNpcCol(foretDeHennetielID) + 6,
                    reiveNpcCol(foretDeHennetielID) + 7,
                },
            },

            -- !pos -63 -2.1 418 262
            [4] =
            {
                mob =
                {
                    reiveMobBase(foretDeHennetielID) + 13,
                    reiveMobBase(foretDeHennetielID) + 14,
                    reiveMobBase(foretDeHennetielID) + 15,
                },
                obstacles =
                {
                    reiveMobBase(foretDeHennetielID) + 12,
                },
                collision =
                {
                    reiveNpcCol(foretDeHennetielID) + 4,
                    reiveNpcCol(foretDeHennetielID) + 5,
                },
            },

            -- !pos 343 -1.8 -299.4 262
            [5] =
            {
                mob =
                {
                    reiveMobBase(foretDeHennetielID) + 17,
                    reiveMobBase(foretDeHennetielID) + 18,
                    reiveMobBase(foretDeHennetielID) + 19,
                },
                obstacles =
                {
                    reiveMobBase(foretDeHennetielID) + 16,
                },
                collision =
                {
                    reiveNpcCol(foretDeHennetielID) + 18,
                    reiveNpcCol(foretDeHennetielID) + 19,
                },
            },

            -- !pos 296 -2.0 -261 262
            [6] =
            {
                mob =
                {
                    reiveMobBase(foretDeHennetielID) + 21,
                    reiveMobBase(foretDeHennetielID) + 22,
                    reiveMobBase(foretDeHennetielID) + 23,
                },
                obstacles =
                {
                    reiveMobBase(foretDeHennetielID) + 20,
                },
                collision =
                {
                    reiveNpcCol(foretDeHennetielID) + 16,
                    reiveNpcCol(foretDeHennetielID) + 17,
                },
            },

            -- !pos -16.5 -1.93 -219 262
            [7] =
            {
                mob =
                {
                    reiveMobBase(foretDeHennetielID) + 25,
                    reiveMobBase(foretDeHennetielID) + 26,
                    reiveMobBase(foretDeHennetielID) + 27,
                },
                obstacles =
                {
                    reiveMobBase(foretDeHennetielID) + 24,
                },
                collision =
                {
                    reiveNpcCol(foretDeHennetielID) + 14,
                    reiveNpcCol(foretDeHennetielID) + 15,
                },
            },

            -- !pos -63.4 -2.1 -181 262
            [8] =
            {
                mob =
                {
                    reiveMobBase(foretDeHennetielID) + 29,
                    reiveMobBase(foretDeHennetielID) + 30,
                    reiveMobBase(foretDeHennetielID) + 31,
                },
                obstacles =
                {
                    reiveMobBase(foretDeHennetielID) + 28,
                },
                collision =
                {
                    reiveNpcCol(foretDeHennetielID) + 12,
                    reiveNpcCol(foretDeHennetielID) + 13,
                },
            },

            -- !pos -380.9 -1.9 23 262
            [9] =
            {
                mob =
                {
                    reiveMobBase(foretDeHennetielID) + 33,
                    reiveMobBase(foretDeHennetielID) + 34,
                    reiveMobBase(foretDeHennetielID) + 35,
                },
                obstacles =
                {
                    reiveMobBase(foretDeHennetielID) + 32,
                },
                collision =
                {
                    reiveNpcCol(foretDeHennetielID) + 2,
                    reiveNpcCol(foretDeHennetielID) + 3,
                },
            },

            -- !pos -418.8 -2 -23.3 262
            [10] =
            {
                mob =
                {
                    reiveMobBase(foretDeHennetielID) + 37,
                    reiveMobBase(foretDeHennetielID) + 38,
                    reiveMobBase(foretDeHennetielID) + 39,
                },
                obstacles =
                {
                    reiveMobBase(foretDeHennetielID) + 36,
                },
                collision =
                {
                    reiveNpcCol(foretDeHennetielID),
                    reiveNpcCol(foretDeHennetielID) + 1,
                },
            },
        },
    },

    [xi.zone.KAMIHR_DRIFTS] =
    {
        reiveObjRespawnTime = 3600, -- 60 minutes
        reiveMobRespawnTime = 300,  -- 5 minutes
        reive =
        {
            -- !pos 114.7 40 -269.3 267
            [1] =
            {
                mob =
                {
                    reiveMobBase(kamihrDriftsID) + 2,
                    reiveMobBase(kamihrDriftsID) + 3,
                    reiveMobBase(kamihrDriftsID) + 4,
                    reiveMobBase(kamihrDriftsID) + 5,
                },
                obstacles =
                {
                    reiveMobBase(kamihrDriftsID),
                    reiveMobBase(kamihrDriftsID) + 1,
                },
                collision =
                {
                    reiveNpcCol(kamihrDriftsID),
                },
            },

            -- !pos 246 40 -110 267
            [2] =
            {
                mob =
                {
                    reiveMobBase(kamihrDriftsID) + 8,
                    reiveMobBase(kamihrDriftsID) + 9,
                    reiveMobBase(kamihrDriftsID) + 10,
                    reiveMobBase(kamihrDriftsID) + 11,
                },
                obstacles =
                {
                    reiveMobBase(kamihrDriftsID) + 6,
                    reiveMobBase(kamihrDriftsID) + 7,
                },
                collision =
                {
                    reiveNpcCol(kamihrDriftsID) + 1,
                },
            },

            -- !pos -34 20 11 267
            [3] =
            {
                mob =
                {
                    reiveMobBase(kamihrDriftsID) + 14,
                    reiveMobBase(kamihrDriftsID) + 15,
                    reiveMobBase(kamihrDriftsID) + 16,
                    reiveMobBase(kamihrDriftsID) + 17,
                },
                obstacles =
                {
                    reiveMobBase(kamihrDriftsID) + 12,
                    reiveMobBase(kamihrDriftsID) + 13,
                },
                collision =
                {
                    reiveNpcCol(kamihrDriftsID) + 2,
                },
            },

            -- !pos -354 0.2 269.4 267
            [4] =
            {
                mob =
                {
                    reiveMobBase(kamihrDriftsID) + 20,
                    reiveMobBase(kamihrDriftsID) + 21,
                    reiveMobBase(kamihrDriftsID) + 22,
                    reiveMobBase(kamihrDriftsID) + 23,
                },
                obstacles =
                {
                    reiveMobBase(kamihrDriftsID) + 18,
                    reiveMobBase(kamihrDriftsID) + 19,
                },
                collision =
                {
                    reiveNpcCol(kamihrDriftsID) + 3,
                },
            },
        },
    },

    [xi.zone.MARJAMI_RAVINE] =
    {
        reiveObjRespawnTime = 3600, -- 60 minutes
        reiveMobRespawnTime = 300,  -- 5 minutes
        reive =
        {

            -- !pos 339 -41.6 -18 266
            [1] =
            {
                mob =
                {
                    reiveMobBase(marjamiRavineID) + 2,
                    reiveMobBase(marjamiRavineID) + 3,
                    reiveMobBase(marjamiRavineID) + 4,
                    reiveMobBase(marjamiRavineID) + 5,
                },
                obstacles =
                {
                    reiveMobBase(marjamiRavineID),
                    reiveMobBase(marjamiRavineID) + 1,
                },
                collision =
                {
                    reiveNpcCol(marjamiRavineID),
                },
            },

            -- !pos 218 -21.6 60 266
            [2] =
            {
                mob =
                {
                    reiveMobBase(marjamiRavineID) + 8,
                    reiveMobBase(marjamiRavineID) + 9,
                    reiveMobBase(marjamiRavineID) + 10,
                    reiveMobBase(marjamiRavineID) + 11,
                },
                obstacles =
                {
                    reiveMobBase(marjamiRavineID) + 6,
                    reiveMobBase(marjamiRavineID) + 7,
                },
                collision =
                {
                    reiveNpcCol(marjamiRavineID) + 1,
                },
            },

            -- !pos 180 -1.6 -138 266
            [3] =
            {
                mob =
                {
                    reiveMobBase(marjamiRavineID) + 14,
                    reiveMobBase(marjamiRavineID) + 15,
                    reiveMobBase(marjamiRavineID) + 16,
                    reiveMobBase(marjamiRavineID) + 17,
                },
                obstacles =
                {
                    reiveMobBase(marjamiRavineID) + 12,
                    reiveMobBase(marjamiRavineID) + 13,
                },
                collision =
                {
                    reiveNpcCol(marjamiRavineID) + 2,
                },
            },

            -- !pos 102 38 -180 266
            [4] =
            {
                mob =
                {
                    reiveMobBase(marjamiRavineID) + 20,
                    reiveMobBase(marjamiRavineID) + 21,
                    reiveMobBase(marjamiRavineID) + 22,
                    reiveMobBase(marjamiRavineID) + 23,
                },
                obstacles =
                {
                    reiveMobBase(marjamiRavineID) + 18,
                    reiveMobBase(marjamiRavineID) + 19,
                },
                collision =
                {
                    reiveNpcCol(marjamiRavineID) + 3,
                },
            },

            -- !pos -98 38 -140 266
            [5] =
            {
                mob =
                {
                    reiveMobBase(marjamiRavineID) + 26,
                    reiveMobBase(marjamiRavineID) + 27,
                    reiveMobBase(marjamiRavineID) + 28,
                    reiveMobBase(marjamiRavineID) + 29,
                },
                obstacles =
                {
                    reiveMobBase(marjamiRavineID) + 24,
                    reiveMobBase(marjamiRavineID) + 25,
                },
                collision =
                {
                    reiveNpcCol(marjamiRavineID) + 4,
                },
            },

            -- !pos -178 -2.4 -60 266
            [6] =
            {
                mob =
                {
                    reiveMobBase(marjamiRavineID) + 32,
                    reiveMobBase(marjamiRavineID) + 33,
                    reiveMobBase(marjamiRavineID) + 34,
                    reiveMobBase(marjamiRavineID) + 35,
                },
                obstacles =
                {
                    reiveMobBase(marjamiRavineID) + 30,
                    reiveMobBase(marjamiRavineID) + 31,
                },
                collision =
                {
                    reiveNpcCol(marjamiRavineID) + 5,
                },
            },

            -- !pos -298 -22.4 100 266
            [7] =
            {
                mob =
                {
                    reiveMobBase(marjamiRavineID) + 38,
                    reiveMobBase(marjamiRavineID) + 39,
                    reiveMobBase(marjamiRavineID) + 40,
                    reiveMobBase(marjamiRavineID) + 41,
                },
                obstacles =
                {
                    reiveMobBase(marjamiRavineID) + 36,
                    reiveMobBase(marjamiRavineID) + 37,
                },
                collision =
                {
                    reiveNpcCol(marjamiRavineID) + 6,
                },
            },
        },
    },

    [xi.zone.MOH_GATES] =
    {
        reiveObjRespawnTime = 3600, -- 60 minutes
        reiveMobRespawnTime = 300,  -- 5 minutes
        reive =
        {
            -- !pos 240 19 -57.5 269
            [1] =
            {
                mob =
                {
                    reiveMobBase(mohGatesID) + 3,
                    reiveMobBase(mohGatesID) + 4,
                    reiveMobBase(mohGatesID) + 5,
                    reiveMobBase(mohGatesID) + 6,
                    reiveMobBase(mohGatesID) + 7,
                    reiveMobBase(mohGatesID) + 8,
                },
                obstacles =
                {
                    reiveMobBase(mohGatesID),
                    reiveMobBase(mohGatesID) + 1,
                    reiveMobBase(mohGatesID) + 2,
                },
                collision =
                {
                    reiveNpcCol(mohGatesID) + 2,
                    reiveNpcCol(mohGatesID) + 3,
                },
            },

            -- !pos 102 29.8 -160 269
            [2] =
            {
                mob =
                {
                    reiveMobBase(mohGatesID) + 12,
                    reiveMobBase(mohGatesID) + 13,
                    reiveMobBase(mohGatesID) + 14,
                    reiveMobBase(mohGatesID) + 15,
                    reiveMobBase(mohGatesID) + 16,
                    reiveMobBase(mohGatesID) + 17,
                },
                obstacles =
                {
                    reiveMobBase(mohGatesID) + 9,
                    reiveMobBase(mohGatesID) + 10,
                    reiveMobBase(mohGatesID) + 11,
                },
                collision =
                {
                    reiveNpcCol(mohGatesID),
                    reiveNpcCol(mohGatesID) + 1,
                },
            },
        },
    },

    [xi.zone.MORIMAR_BASALT_FIELDS] =
    {
        reiveObjRespawnTime = 3600, -- 60 minutes
        reiveMobRespawnTime = 300,  -- 5 minutes
        reive =
        {

            -- !pos 119.7 -0.08 -54.9 265
            [1] =
            {
                mob =
                {
                    reiveMobBase(morimarBasaltFieldsID) + 3,
                    reiveMobBase(morimarBasaltFieldsID) + 4,
                    reiveMobBase(morimarBasaltFieldsID) + 5,
                    reiveMobBase(morimarBasaltFieldsID) + 6,
                    reiveMobBase(morimarBasaltFieldsID) + 7,
                    reiveMobBase(morimarBasaltFieldsID) + 8,
                },
                obstacles =
                {
                    reiveMobBase(morimarBasaltFieldsID) + 0,
                    reiveMobBase(morimarBasaltFieldsID) + 1,
                    reiveMobBase(morimarBasaltFieldsID) + 2,
                },
                collision =
                {
                    reiveNpcCol(morimarBasaltFieldsID) + 4,
                    reiveNpcCol(morimarBasaltFieldsID) + 5,
                },
            },

            -- !pos -3.5 0.106 60 265
            [2] =
            {
                mob =
                {
                    reiveMobBase(morimarBasaltFieldsID) + 12,
                    reiveMobBase(morimarBasaltFieldsID) + 13,
                    reiveMobBase(morimarBasaltFieldsID) + 14,
                    reiveMobBase(morimarBasaltFieldsID) + 15,
                    reiveMobBase(morimarBasaltFieldsID) + 16,
                    reiveMobBase(morimarBasaltFieldsID) + 17,
                },
                obstacles =
                {
                    reiveMobBase(morimarBasaltFieldsID) + 9,
                    reiveMobBase(morimarBasaltFieldsID) + 10,
                    reiveMobBase(morimarBasaltFieldsID) + 11,
                },
                collision =
                {
                    reiveNpcCol(morimarBasaltFieldsID) + 2,
                    reiveNpcCol(morimarBasaltFieldsID) + 3,
                },
            },

            -- !pos -60 -15.89 -276.5 265
            [3] =
            {
                mob =
                {
                    reiveMobBase(morimarBasaltFieldsID) + 21,
                    reiveMobBase(morimarBasaltFieldsID) + 22,
                    reiveMobBase(morimarBasaltFieldsID) + 23,
                    reiveMobBase(morimarBasaltFieldsID) + 24,
                    reiveMobBase(morimarBasaltFieldsID) + 25,
                    reiveMobBase(morimarBasaltFieldsID) + 26,
                },
                obstacles =
                {
                    reiveMobBase(morimarBasaltFieldsID) + 18,
                    reiveMobBase(morimarBasaltFieldsID) + 19,
                    reiveMobBase(morimarBasaltFieldsID) + 20,
                },
                collision =
                {
                    reiveNpcCol(morimarBasaltFieldsID) + 10,
                    reiveNpcCol(morimarBasaltFieldsID) + 11,
                },
            },

            -- !pos -123 -15.89 -419.9 265
            [4] =
            {
                mob =
                {
                    reiveMobBase(morimarBasaltFieldsID) + 30,
                    reiveMobBase(morimarBasaltFieldsID) + 31,
                    reiveMobBase(morimarBasaltFieldsID) + 32,
                    reiveMobBase(morimarBasaltFieldsID) + 33,
                    reiveMobBase(morimarBasaltFieldsID) + 34,
                    reiveMobBase(morimarBasaltFieldsID) + 35,
                },
                obstacles =
                {
                    reiveMobBase(morimarBasaltFieldsID) + 27,
                    reiveMobBase(morimarBasaltFieldsID) + 28,
                    reiveMobBase(morimarBasaltFieldsID) + 29,
                },
                collision =
                {
                    reiveNpcCol(morimarBasaltFieldsID) + 12,
                    reiveNpcCol(morimarBasaltFieldsID) + 13,
                },
            },

            -- !pos -363 -31.89 -140 265
            [5] =
            {
                mob =
                {
                    reiveMobBase(morimarBasaltFieldsID) + 48,
                    reiveMobBase(morimarBasaltFieldsID) + 49,
                    reiveMobBase(morimarBasaltFieldsID) + 50,
                    reiveMobBase(morimarBasaltFieldsID) + 51,
                    reiveMobBase(morimarBasaltFieldsID) + 52,
                    reiveMobBase(morimarBasaltFieldsID) + 53,
                },
                obstacles =
                {
                    reiveMobBase(morimarBasaltFieldsID) + 45,
                    reiveMobBase(morimarBasaltFieldsID) + 46,
                    reiveMobBase(morimarBasaltFieldsID) + 47,
                },
                collision =
                {
                    reiveNpcCol(morimarBasaltFieldsID) + 6,
                    reiveNpcCol(morimarBasaltFieldsID) + 7,
                },
            },

            -- !pos -243 -47.89 399.9 265
            [6] =
            {
                mob =
                {
                    reiveMobBase(morimarBasaltFieldsID) + 57,
                    reiveMobBase(morimarBasaltFieldsID) + 58,
                    reiveMobBase(morimarBasaltFieldsID) + 59,
                    reiveMobBase(morimarBasaltFieldsID) + 60,
                    reiveMobBase(morimarBasaltFieldsID) + 61,
                    reiveMobBase(morimarBasaltFieldsID) + 62,
                },
                obstacles =
                {
                    reiveMobBase(morimarBasaltFieldsID) + 54,
                    reiveMobBase(morimarBasaltFieldsID) + 55,
                    reiveMobBase(morimarBasaltFieldsID) + 56,
                },
                collision =
                {
                    reiveNpcCol(morimarBasaltFieldsID),
                    reiveNpcCol(morimarBasaltFieldsID) + 1,
                },
            },

            -- !pos -240.7 -32.45 -219.4 265
            [7] =
            {
                mob =
                {
                    reiveMobBase(morimarBasaltFieldsID) + 39,
                    reiveMobBase(morimarBasaltFieldsID) + 40,
                    reiveMobBase(morimarBasaltFieldsID) + 41,
                    reiveMobBase(morimarBasaltFieldsID) + 42,
                    reiveMobBase(morimarBasaltFieldsID) + 43,
                    reiveMobBase(morimarBasaltFieldsID) + 44,
                },
                obstacles =
                {
                    reiveMobBase(morimarBasaltFieldsID) + 36,
                    reiveMobBase(morimarBasaltFieldsID) + 37,
                    reiveMobBase(morimarBasaltFieldsID) + 38,
                },
                collision =
                {
                    reiveNpcCol(morimarBasaltFieldsID) + 8,
                    reiveNpcCol(morimarBasaltFieldsID) + 9,
                },
            },
        },
    },

    [xi.zone.OUTER_RAKAZNAR] =
    {
        reiveObjRespawnTime = 900, -- 15 minutes
        reiveMobRespawnTime = 60,  -- 1 minute
        reive =
        {

            -- !pos 743.4 100 120.1 274
            [1] =
            {
                mob =
                {
                    reiveMobBase(outerRakaznarID) + 3,
                    reiveMobBase(outerRakaznarID) + 4,
                    reiveMobBase(outerRakaznarID) + 5,
                    reiveMobBase(outerRakaznarID) + 6,
                },
                obstacles =
                {
                    reiveMobBase(outerRakaznarID),
                    reiveMobBase(outerRakaznarID) + 1,
                    reiveMobBase(outerRakaznarID) + 2,
                },
                collision =
                {
                    reiveNpcCol(outerRakaznarID),
                },
            },

            -- !pos 720 100 -175.4 274
            [2] =
            {
                mob =
                {
                    reiveMobBase(outerRakaznarID) + 10,
                    reiveMobBase(outerRakaznarID) + 11,
                    reiveMobBase(outerRakaznarID) + 12,
                    reiveMobBase(outerRakaznarID) + 13,
                },
                obstacles =
                {
                    reiveMobBase(outerRakaznarID) + 7,
                    reiveMobBase(outerRakaznarID) + 8,
                    reiveMobBase(outerRakaznarID) + 9,
                },
                collision =
                {
                    reiveNpcCol(outerRakaznarID) + 1,
                },
            },

            -- !pos 424 100 -159.9 274
            [3] =
            {
                mob =
                {
                    reiveMobBase(outerRakaznarID) + 17,
                    reiveMobBase(outerRakaznarID) + 18,
                    reiveMobBase(outerRakaznarID) + 19,
                    reiveMobBase(outerRakaznarID) + 20,
                },
                obstacles =
                {
                    reiveMobBase(outerRakaznarID) + 14,
                    reiveMobBase(outerRakaznarID) + 15,
                    reiveMobBase(outerRakaznarID) + 16,
                },
                collision =
                {
                    reiveNpcCol(outerRakaznarID) + 3,
                },
            },

            -- !pos 440 100 135.2 274
            [4] =
            {
                mob =
                {
                    reiveMobBase(outerRakaznarID) + 24,
                    reiveMobBase(outerRakaznarID) + 25,
                    reiveMobBase(outerRakaznarID) + 26,
                    reiveMobBase(outerRakaznarID) + 27,
                },
                obstacles =
                {
                    reiveMobBase(outerRakaznarID) + 21,
                    reiveMobBase(outerRakaznarID) + 22,
                    reiveMobBase(outerRakaznarID) + 23,
                },
                collision =
                {
                    reiveNpcCol(outerRakaznarID) + 2,
                },
            },
        },
    },

    [xi.zone.RAKAZNAR_INNER_COURT] =
    {
        reiveObjRespawnTime = 900, -- 15 minutes
        reiveMobRespawnTime = 60,  -- 1 minute
        reive =
        {
            -- !pos 894.2 100 199.8 276
            [1] =
            {
                mob =
                {
                    reiveMobBase(rakaznarInnerCourtID) + 3,
                    reiveMobBase(rakaznarInnerCourtID) + 4,
                    reiveMobBase(rakaznarInnerCourtID) + 5,
                    reiveMobBase(rakaznarInnerCourtID) + 6,
                },
                obstacles =
                {
                    reiveMobBase(rakaznarInnerCourtID),
                    reiveMobBase(rakaznarInnerCourtID) + 1,
                    reiveMobBase(rakaznarInnerCourtID) + 2,
                },
                collision =
                {
                    reiveNpcCol(rakaznarInnerCourtID),
                },
            },

            -- !pos 519.9 100 228.6 276
            [2] =
            {
                mob =
                {
                    reiveMobBase(rakaznarInnerCourtID) + 10,
                    reiveMobBase(rakaznarInnerCourtID) + 11,
                    reiveMobBase(rakaznarInnerCourtID) + 12,
                    reiveMobBase(rakaznarInnerCourtID) + 13,
                },
                obstacles =
                {
                    reiveMobBase(rakaznarInnerCourtID) + 7,
                    reiveMobBase(rakaznarInnerCourtID) + 8,
                    reiveMobBase(rakaznarInnerCourtID) + 9,
                },
                collision =
                {
                    reiveNpcCol(rakaznarInnerCourtID) + 1,
                },
            },

            -- !pos 506 90 -160 276
            [3] =
            {
                mob =
                {
                    reiveMobBase(rakaznarInnerCourtID) + 17,
                    reiveMobBase(rakaznarInnerCourtID) + 18,
                    reiveMobBase(rakaznarInnerCourtID) + 19,
                    reiveMobBase(rakaznarInnerCourtID) + 20,
                },
                obstacles =
                {
                    reiveMobBase(rakaznarInnerCourtID) + 14,
                    reiveMobBase(rakaznarInnerCourtID) + 15,
                    reiveMobBase(rakaznarInnerCourtID) + 16,
                },
                collision =
                {
                    reiveNpcCol(rakaznarInnerCourtID) + 2,
                },
            },

            -- !pos 879.9 90 -173.8 276
            [4] =
            {
                mob =
                {
                    reiveMobBase(rakaznarInnerCourtID) + 24,
                    reiveMobBase(rakaznarInnerCourtID) + 25,
                    reiveMobBase(rakaznarInnerCourtID) + 26,
                    reiveMobBase(rakaznarInnerCourtID) + 27,
                },
                obstacles =
                {
                    reiveMobBase(rakaznarInnerCourtID) + 21,
                    reiveMobBase(rakaznarInnerCourtID) + 22,
                    reiveMobBase(rakaznarInnerCourtID) + 23,
                },
                collision =
                {
                    reiveNpcCol(rakaznarInnerCourtID) + 3,
                },
            },
        },
    },

    [xi.zone.SIH_GATES] =
    {
        reiveObjRespawnTime = 3600, -- 60 minutes
        reiveMobRespawnTime = 300,  -- 5 minutes
        reive =
        {

            -- !pos -118.8 -10 -99 268
            [1] =
            {
                mob =
                {
                    reiveMobBase(sihGatesID) + 3,
                    reiveMobBase(sihGatesID) + 4,
                    reiveMobBase(sihGatesID) + 5,
                    reiveMobBase(sihGatesID) + 6,
                    reiveMobBase(sihGatesID) + 7,
                    reiveMobBase(sihGatesID) + 8,
                },
                obstacles =
                {
                    reiveMobBase(sihGatesID),
                    reiveMobBase(sihGatesID) + 1,
                    reiveMobBase(sihGatesID) + 2,
                },
                collision =
                {
                    reiveNpcCol(sihGatesID),
                    reiveNpcCol(sihGatesID) + 1,
                },
            },

            -- !pos -77.9 -9.8 -259.9 268
            [2] =
            {
                mob =
                {
                    reiveMobBase(sihGatesID) + 12,
                    reiveMobBase(sihGatesID) + 13,
                    reiveMobBase(sihGatesID) + 14,
                    reiveMobBase(sihGatesID) + 15,
                    reiveMobBase(sihGatesID) + 16,
                    reiveMobBase(sihGatesID) + 17,
                },
                obstacles =
                {
                    reiveMobBase(sihGatesID) + 9,
                    reiveMobBase(sihGatesID) + 10,
                    reiveMobBase(sihGatesID) + 11,
                },
                collision =
                {
                    reiveNpcCol(sihGatesID) + 2,
                    reiveNpcCol(sihGatesID) + 3,
                },
            },
        },
    },

    [xi.zone.WOH_GATES] =
    {
        reiveObjRespawnTime = 3600, -- 60 minutes
        reiveMobRespawnTime = 300,  -- 5 minutes
        reive =
        {

            -- !pos 276 30 99.5 273
            [1] =
            {
                mob =
                {
                    reiveMobBase(wohGatesID) + 2,
                    reiveMobBase(wohGatesID) + 3,
                    reiveMobBase(wohGatesID) + 4,
                    reiveMobBase(wohGatesID) + 5,
                },
                obstacles =
                {
                    reiveMobBase(wohGatesID),
                    reiveMobBase(wohGatesID) + 1,
                },
                collision =
                {
                    reiveNpcCol(wohGatesID),
                    reiveNpcCol(wohGatesID) + 1,
                },
            },

            -- !pos 284 30.6 259.7 273
            [2] =
            {
                mob =
                {
                    reiveMobBase(wohGatesID) + 8,
                    reiveMobBase(wohGatesID) + 9,
                    reiveMobBase(wohGatesID) + 10,
                    reiveMobBase(wohGatesID) + 11,
                },
                obstacles =
                {
                    reiveMobBase(wohGatesID) + 6,
                    reiveMobBase(wohGatesID) + 7,
                },
                collision =
                {
                    reiveNpcCol(wohGatesID) + 2,
                    reiveNpcCol(wohGatesID) + 3,
                },
            },
        },
    },

    [xi.zone.YAHSE_HUNTING_GROUNDS] =
    {
        reiveObjRespawnTime = 3600, -- 60 minutes
        reiveMobRespawnTime = 300,  -- 5 minutes
        reive =
        {
            -- !pos -155.5 0.3 141.9 260
            [1] =
            {
                mob =
                {
                    reiveMobBase(yahseHuntingGroundsID) + 17,
                    reiveMobBase(yahseHuntingGroundsID) + 18,
                    reiveMobBase(yahseHuntingGroundsID) + 19,
                    reiveMobBase(yahseHuntingGroundsID) + 20,
                    reiveMobBase(yahseHuntingGroundsID) + 21,
                    reiveMobBase(yahseHuntingGroundsID) + 22,
                },
                obstacles =
                {
                    reiveMobBase(yahseHuntingGroundsID) + 14,
                    reiveMobBase(yahseHuntingGroundsID) + 15,
                    reiveMobBase(yahseHuntingGroundsID) + 16,
                },
                collision =
                {
                    reiveNpcCol(yahseHuntingGroundsID) + 8,
                    reiveNpcCol(yahseHuntingGroundsID) + 9,
                },
            },

            -- !pos 116 0.3 -177.9 260
            [2] =
            {
                mob =
                {
                    reiveMobBase(yahseHuntingGroundsID) + 26,
                    reiveMobBase(yahseHuntingGroundsID) + 27,
                    reiveMobBase(yahseHuntingGroundsID) + 28,
                    reiveMobBase(yahseHuntingGroundsID) + 29,
                    reiveMobBase(yahseHuntingGroundsID) + 30,
                    reiveMobBase(yahseHuntingGroundsID) + 31,
                },
                obstacles =
                {
                    reiveMobBase(yahseHuntingGroundsID) + 23,
                    reiveMobBase(yahseHuntingGroundsID) + 24,
                    reiveMobBase(yahseHuntingGroundsID) + 25,
                },
                collision =
                {
                    reiveNpcCol(yahseHuntingGroundsID) + 4,
                    reiveNpcCol(yahseHuntingGroundsID) + 5,
                },
            },

            -- !pos 153 0.49 -19.7 260
            [3] =
            {
                mob =
                {
                    reiveMobBase(yahseHuntingGroundsID) + 10,
                    reiveMobBase(yahseHuntingGroundsID) + 11,
                    reiveMobBase(yahseHuntingGroundsID) + 12,
                    reiveMobBase(yahseHuntingGroundsID) + 13,
                },
                obstacles =
                {
                    reiveMobBase(yahseHuntingGroundsID) + 7,
                    reiveMobBase(yahseHuntingGroundsID) + 8,
                    reiveMobBase(yahseHuntingGroundsID) + 9,
                },
                collision =
                {
                    reiveNpcCol(yahseHuntingGroundsID) + 0,
                    reiveNpcCol(yahseHuntingGroundsID) + 1,
                },
            },

            -- !pos -315.7 0.41 -221 260
            [4] =
            {
                mob =
                {
                    reiveMobBase(yahseHuntingGroundsID) + 35,
                    reiveMobBase(yahseHuntingGroundsID) + 36,
                    reiveMobBase(yahseHuntingGroundsID) + 37,
                    reiveMobBase(yahseHuntingGroundsID) + 38,
                    reiveMobBase(yahseHuntingGroundsID) + 39,
                    reiveMobBase(yahseHuntingGroundsID) + 40,
                },
                obstacles =
                {
                    reiveMobBase(yahseHuntingGroundsID) + 32,
                    reiveMobBase(yahseHuntingGroundsID) + 33,
                    reiveMobBase(yahseHuntingGroundsID) + 34,
                },
                collision =
                {
                    reiveNpcCol(yahseHuntingGroundsID) + 6,
                    reiveNpcCol(yahseHuntingGroundsID) + 7,
                },
            },

            -- !pos 115 0.27 -176 260
            [5] =
            {
                mob =
                {
                    reiveMobBase(yahseHuntingGroundsID) + 3,
                    reiveMobBase(yahseHuntingGroundsID) + 4,
                    reiveMobBase(yahseHuntingGroundsID) + 5,
                    reiveMobBase(yahseHuntingGroundsID) + 6,
                },
                obstacles =
                {
                    reiveMobBase(yahseHuntingGroundsID) + 0,
                    reiveMobBase(yahseHuntingGroundsID) + 1,
                    reiveMobBase(yahseHuntingGroundsID) + 2,
                },
                collision =
                {
                    reiveNpcCol(yahseHuntingGroundsID) + 2,
                    reiveNpcCol(yahseHuntingGroundsID) + 3,
                },
            },
        },
    },

    [xi.zone.YORCIA_WEALD] =
    {
        reiveObjRespawnTime = 3600, -- 60 minutes
        reiveMobRespawnTime = 300,  -- 5 minutes
        reive =
        {

            -- !pos 100 1.6 342 263
            [1] =
            {
                mob =
                {
                    reiveMobBase(yorciaWealdID) + 2,
                    reiveMobBase(yorciaWealdID) + 3,
                    reiveMobBase(yorciaWealdID) + 4,
                    reiveMobBase(yorciaWealdID) + 5,
                },
                obstacles =
                {
                    reiveMobBase(yorciaWealdID) + 0,
                    reiveMobBase(yorciaWealdID) + 1,
                },
                collision =
                {
                    reiveNpcCol(yorciaWealdID) + 0,
                },
            },

            -- !pos -102 1.57 180 263
            [2] =
            {
                mob =
                {
                    reiveMobBase(yorciaWealdID) + 8,
                    reiveMobBase(yorciaWealdID) + 9,
                    reiveMobBase(yorciaWealdID) + 10,
                    reiveMobBase(yorciaWealdID) + 11,
                },
                obstacles =
                {
                    reiveMobBase(yorciaWealdID) + 6,
                    reiveMobBase(yorciaWealdID) + 7,
                },
                collision =
                {
                    reiveNpcCol(yorciaWealdID) + 3,
                },
            },

            -- !pos 258 1.57 -140 263
            [3] =
            {
                mob =
                {
                    reiveMobBase(yorciaWealdID) + 14,
                    reiveMobBase(yorciaWealdID) + 15,
                    reiveMobBase(yorciaWealdID) + 16,
                    reiveMobBase(yorciaWealdID) + 17,
                },
                obstacles =
                {
                    reiveMobBase(yorciaWealdID) + 12,
                    reiveMobBase(yorciaWealdID) + 13,
                },
                collision =
                {
                    reiveNpcCol(yorciaWealdID) + 1,
                },
            },

            -- !pos 60 1.63 -178 263
            [4] =
            {
                mob =
                {
                    reiveMobBase(yorciaWealdID) + 20,
                    reiveMobBase(yorciaWealdID) + 21,
                    reiveMobBase(yorciaWealdID) + 22,
                    reiveMobBase(yorciaWealdID) + 23,
                },
                obstacles =
                {
                    reiveMobBase(yorciaWealdID) + 18,
                    reiveMobBase(yorciaWealdID) + 19,
                },
                collision =
                {
                    reiveNpcCol(yorciaWealdID) + 2,
                },
            },
        },
    },
}
