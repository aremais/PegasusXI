-----------------------------------
-- Jungle Boogymen II
-- Sacrificial Chamber SKCNM, Macrocosmic Orb
-- !additem 4063
-----------------------------------
require('scripts/globals/skcnm')
local sacrificialChamberID = zones[xi.zone.SACRIFICIAL_CHAMBER]
-----------------------------------

local content = SKCNMBattlefield:new({
    zoneId        = xi.zone.SACRIFICIAL_CHAMBER,
    battlefieldId = xi.battlefield.id.JUNGLE_BOOGYMEN_II,
    maxPlayers    = 6,
    timeLimit     = utils.minutes(30),
    index         = 5,
    entryNpc      = '_4j0',
    exitNpcs      = { '_4j2', '_4j3', '_4j4' },
    requiredItems = { xi.item.MACROCOSMIC_ORB }, -- wear/worn messages handled centrally in skcnm.lua
})

content.groups =
{
    {
        mobIds =
        {
            {
                sacrificialChamberID.mob.SABLE_TONGUED_GONBERRY_II,      -- Sable-tongued Gonberry
                sacrificialChamberID.mob.SABLE_TONGUED_GONBERRY_II + 1,  -- Virid-faced Shanberry
                sacrificialChamberID.mob.SABLE_TONGUED_GONBERRY_II + 2,  -- Cyaneous-toed Yallberry
                sacrificialChamberID.mob.SABLE_TONGUED_GONBERRY_II + 3,  -- Vermilion-eared Nobberry
            },

            {
                sacrificialChamberID.mob.SABLE_TONGUED_GONBERRY_II + 7,
                sacrificialChamberID.mob.SABLE_TONGUED_GONBERRY_II + 8,
                sacrificialChamberID.mob.SABLE_TONGUED_GONBERRY_II + 9,
                sacrificialChamberID.mob.SABLE_TONGUED_GONBERRY_II + 10,
            },

            {
                sacrificialChamberID.mob.SABLE_TONGUED_GONBERRY_II + 14,
                sacrificialChamberID.mob.SABLE_TONGUED_GONBERRY_II + 15,
                sacrificialChamberID.mob.SABLE_TONGUED_GONBERRY_II + 16,
                sacrificialChamberID.mob.SABLE_TONGUED_GONBERRY_II + 17,
            },
        },

        superlink = true,
        allDeath  = function(battlefield, mob)
            xi.skcnm.onWin(battlefield, {
                chapterItemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_1,
                mob           = mob,
                lootTable     = content.loot,
            })
        end,
    },

    {
        mobIds =
        {
            { sacrificialChamberID.mob.SABLE_TONGUED_GONBERRY_II + 5  }, -- Tonberry's Elemental
            { sacrificialChamberID.mob.SABLE_TONGUED_GONBERRY_II + 12 },
            { sacrificialChamberID.mob.SABLE_TONGUED_GONBERRY_II + 19 },
        },
    },

    {
        mobIds =
        {
            { sacrificialChamberID.mob.SABLE_TONGUED_GONBERRY_II + 6  }, -- Tonberry's Avatar
            { sacrificialChamberID.mob.SABLE_TONGUED_GONBERRY_II + 13 },
            { sacrificialChamberID.mob.SABLE_TONGUED_GONBERRY_II + 20 },
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
        { itemId = xi.item.SCROLL_OF_FOE_LULLABY_II,        weight = 2500 },
        { itemId = xi.item.SCROLL_OF_MAGES_BALLAD_III,      weight = 2500 },
        { itemId = xi.item.SCROLL_OF_FIRE_CAROL_II,         weight = 2500 },
        { itemId = xi.item.SCROLL_OF_WATER_CAROL_II,        weight = 2500 },
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

    -- Rem's Tale Chapter 1: 1x guaranteed + up to 3 more at 50% each (1–4x total)
    {
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_1,      weight = 10000 },
    },

    {
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_1,      weight =  5000 },
        { itemId = xi.item.NONE,                              weight =  5000 },
    },

    {
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_1,      weight =  5000 },
        { itemId = xi.item.NONE,                              weight =  5000 },
    },

    {
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_1,      weight =  5000 },
        { itemId = xi.item.NONE,                              weight =  5000 },
    },
}

return content:register()
