-----------------------------------
-- Kindred Spirits II
-- Throne Room SKCNM, Macrocosmic Orb
-- !additem 4063
-----------------------------------
local throneRoomID = zones[xi.zone.THRONE_ROOM]
-----------------------------------

local content = Battlefield:new({
    zoneId        = xi.zone.THRONE_ROOM,
    battlefieldId = xi.battlefield.id.KINDRED_SPIRITS_II,
    maxPlayers    = 6,
    timeLimit     = utils.minutes(30),
    index         = 3,
    entryNpc      = '_4l1',
    exitNpcs      = { '_4l2', '_4l3', '_4l4' },
    requiredItems = { xi.item.MACROCOSMIC_ORB, wearMessage = throneRoomID.text.A_CRACK_HAS_FORMED, wornMessage = throneRoomID.text.ORB_IS_CRACKED },
    armouryCrates =
    {
        throneRoomID.mob.GRAND_MARQUIS_CHOMIEL + 4,
        throneRoomID.mob.GRAND_MARQUIS_CHOMIEL + 11,
        throneRoomID.mob.GRAND_MARQUIS_CHOMIEL + 18,
    },
})

content.groups =
{
    {
        mobIds =
        {
            {
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL,      -- Grand Marquis Chomiel
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL + 1,  -- Count Andromalius
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL + 2,  -- Duke Amduscias
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL + 3,  -- Duke Dantalian
            },

            {
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL + 7,
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL + 8,
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL + 9,
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL + 10,
            },

            {
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL + 14,
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL + 15,
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL + 16,
                throneRoomID.mob.GRAND_MARQUIS_CHOMIEL + 17,
            },
        },

        superlink = true,
        allDeath  = utils.bind(content.handleAllMonstersDefeated, content),
    },

    {
        mobIds =
        {
            { throneRoomID.mob.GRAND_MARQUIS_CHOMIEL + 5  }, -- Demon's Elemental
            { throneRoomID.mob.GRAND_MARQUIS_CHOMIEL + 12 },
            { throneRoomID.mob.GRAND_MARQUIS_CHOMIEL + 19 },
        },
    },

    {
        mobIds =
        {
            { throneRoomID.mob.GRAND_MARQUIS_CHOMIEL + 6  }, -- Demon's Avatar
            { throneRoomID.mob.GRAND_MARQUIS_CHOMIEL + 13 },
            { throneRoomID.mob.GRAND_MARQUIS_CHOMIEL + 20 },
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
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_2,     weight = 10000, quantity = 2 },
    },

    {
        { itemId = xi.item.PLUTON,                           weight = 1500 },
        { itemId = xi.item.PLUTON_CASE,                      weight =  500 },
        { itemId = xi.item.RIFTBORN_BOULDER,                 weight = 1500 },
        { itemId = xi.item.BOULDER_CASE,                     weight =  500 },
        { itemId = xi.item.BEITETSU,                         weight = 1500 },
        { itemId = xi.item.BEITETSU_PARCEL,                  weight =  500 },
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
}

return content:register()
