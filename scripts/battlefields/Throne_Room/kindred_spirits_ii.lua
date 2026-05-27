-----------------------------------
-- Kindred Spirits II
-- Throne Room SKCNM, Macrocosmic Orb
-- !additem 4063
-----------------------------------
require('scripts/globals/skcnm')
local throneRoomID = zones[xi.zone.THRONE_ROOM]
-----------------------------------

local content = SKCNMBattlefield:new({
    zoneId        = xi.zone.THRONE_ROOM,
    battlefieldId = xi.battlefield.id.KINDRED_SPIRITS_II,
    maxPlayers    = 6,
    timeLimit     = utils.minutes(30),
    index         = 5,
    entryNpc      = '_4l1',
    exitNpcs      = { '_4l2', '_4l3', '_4l4' },
    requiredItems = { xi.item.MACROCOSMIC_ORB }, -- wear/worn messages handled centrally in skcnm.lua
})

content.groups =
{
    {
        mobIds =
        {
            {
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL_II,      -- Grand Marquis Chomiel
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL_II + 1,  -- Count Andromalius
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL_II + 2,  -- Duke Amduscias
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL_II + 3,  -- Duke Dantalian
            },

            {
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL_II + 7,
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL_II + 8,
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL_II + 9,
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL_II + 10,
            },

            {
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL_II + 14,
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL_II + 15,
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL_II + 16,
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL_II + 17,
            },
        },

        superlink = true,
        allDeath  = function(battlefield, mob)
            xi.skcnm.onWin(battlefield, {
                chapterItemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_2,
                mob           = mob,
                lootTable     = content.loot,
            })
        end,
    },

    {
        mobIds =
        {
            { throneRoomID.mob.GRAND_MARQUIS_CHOMIEL_II + 5  }, -- Demon's Elemental
            { throneRoomID.mob.GRAND_MARQUIS_CHOMIEL_II + 12 },
            { throneRoomID.mob.GRAND_MARQUIS_CHOMIEL_II + 19 },
        },
    },

    {
        mobIds =
        {
            { throneRoomID.mob.GRAND_MARQUIS_CHOMIEL_II + 6  }, -- Demon's Avatar
            { throneRoomID.mob.GRAND_MARQUIS_CHOMIEL_II + 13 },
            { throneRoomID.mob.GRAND_MARQUIS_CHOMIEL_II + 20 },
        },

        spawned = false,
    },
}

content.loot =
{
    {
        { itemId = xi.item.GIL,                              weight = 10000, amount = 30000 },
    },

    {
        { itemId = xi.item.SQUARE_OF_DAMASCENE_CLOTH,        weight = 2000 },
        { itemId = xi.item.MYTHRIL_INGOT,                    weight = 2000 },
        { itemId = xi.item.SPOOL_OF_MALBORO_FIBER,           weight = 2000 },
        { itemId = xi.item.VIAL_OF_BLACK_BEETLE_BLOOD,       weight = 2000 },
        { itemId = xi.item.PIECE_OF_OXBLOOD,                 weight = 2000 },
    },

    {
        { itemId = xi.item.SCROLL_OF_BLIZZARD_V,            weight = 2000 },
        { itemId = xi.item.SCROLL_OF_FIRE_V,                weight = 2000 },
        { itemId = xi.item.SCROLL_OF_STONEJA,               weight = 2000 },
        { itemId = xi.item.SCROLL_OF_WATER_CAROL_II,        weight = 2000 },
        { itemId = xi.item.SCROLL_OF_REFRESH_II,            weight = 2000 },
    },

    {
        quantity = 2,
        { itemId = xi.item.BLACK_ROCK,                       weight =  400 },
        { itemId = xi.item.BLUE_ROCK,                        weight =  400 },
        { itemId = xi.item.GREEN_ROCK,                       weight =  400 },
        { itemId = xi.item.PURPLE_ROCK,                      weight =  400 },
        { itemId = xi.item.RED_ROCK,                         weight =  400 },
        { itemId = xi.item.TRANSLUCENT_ROCK,                 weight =  400 },
        { itemId = xi.item.WHITE_ROCK,                       weight =  400 },
        { itemId = xi.item.YELLOW_ROCK,                      weight =  400 },
        { itemId = xi.item.AQUAMARINE,                       weight =  400 },
        { itemId = xi.item.CHRYSOBERYL,                      weight =  400 },
        { itemId = xi.item.FLUORITE,                         weight =  400 },
        { itemId = xi.item.JADEITE,                          weight =  400 },
        { itemId = xi.item.MOONSTONE,                        weight =  400 },
        { itemId = xi.item.PAINITE,                          weight =  400 },
        { itemId = xi.item.SUNSTONE,                         weight =  400 },
        { itemId = xi.item.ZIRCON,                           weight =  400 },
        { itemId = xi.item.HI_RERAISER,                      weight =  400 },
        { itemId = xi.item.VILE_ELIXIR_P1,                   weight =  400 },
    },

    -- Rem's Tale Chapter 2: 2x guaranteed in treasure pool
    {
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_2,      weight = 10000 },
    },

    {
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_2,      weight = 10000 },
    },
}

return content:register()
