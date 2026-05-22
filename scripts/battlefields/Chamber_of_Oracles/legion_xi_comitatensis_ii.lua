-----------------------------------
-- Legion XI Comitatensis II
-- Chamber of Oracles SKCNM, Macrocosmic Orb
-- !additem 4063
-----------------------------------
require('scripts/globals/skcnm')
local chamberOfOraclesID = zones[xi.zone.CHAMBER_OF_ORACLES]
-----------------------------------

local content = SKCNMBattlefield:new({
    zoneId        = xi.zone.CHAMBER_OF_ORACLES,
    battlefieldId = xi.battlefield.id.LEGION_XI_COMITATENSIS_II,
    maxPlayers    = 6,
    timeLimit     = utils.minutes(30),
    index         = 10,
    entryNpc      = 'SC_Entrance',
    exitNpc       = 'Shimmering_Circle',
    requiredItems = { xi.item.MACROCOSMIC_ORB, wearMessage = chamberOfOraclesID.text.A_CRACK_HAS_FORMED, wornMessage = chamberOfOraclesID.text.ORB_IS_CRACKED },
})

content.groups =
{
    {
        mobIds =
        {
            {
                chamberOfOraclesID.mob.SECUTOR_XI_XXXII_II,      -- Secutor XI-XXXII (WAR)
                chamberOfOraclesID.mob.SECUTOR_XI_XXXII_II + 1,  -- Retiarius XI-XIX (BLM)
                chamberOfOraclesID.mob.SECUTOR_XI_XXXII_II + 2,  -- Hoplomachus XI-XXVI (PLD)
                chamberOfOraclesID.mob.SECUTOR_XI_XXXII_II + 3,  -- Centurio XI-I (RNG)
            },

            {
                chamberOfOraclesID.mob.SECUTOR_XI_XXXII_II + 5,
                chamberOfOraclesID.mob.SECUTOR_XI_XXXII_II + 6,
                chamberOfOraclesID.mob.SECUTOR_XI_XXXII_II + 7,
                chamberOfOraclesID.mob.SECUTOR_XI_XXXII_II + 8,
            },

            {
                chamberOfOraclesID.mob.SECUTOR_XI_XXXII_II + 10,
                chamberOfOraclesID.mob.SECUTOR_XI_XXXII_II + 11,
                chamberOfOraclesID.mob.SECUTOR_XI_XXXII_II + 12,
                chamberOfOraclesID.mob.SECUTOR_XI_XXXII_II + 13,
            },
        },

        superlink = true,
        allDeath  = function(battlefield, mob)
            xi.skcnm.onWin(battlefield, {
                chapterItemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_4,
                mob           = mob,
                lootTable     = content.loot,
            })
        end,
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
        { itemId = xi.item.SCROLL_OF_BLIZZARD_V,            weight = 1666 },
        { itemId = xi.item.SCROLL_OF_FIRE_V,                weight = 1666 },
        { itemId = xi.item.SCROLL_OF_WATER_CAROL_II,        weight = 1667 },
        { itemId = xi.item.SCROLL_OF_FIRE_CAROL_II,         weight = 1667 },
        { itemId = xi.item.SCROLL_OF_REFRESH_II,            weight = 1667 },
        { itemId = xi.item.SCROLL_OF_MAGES_BALLAD_III,      weight = 1667 },
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

    -- Rem's Tale Chapter 4: 1x guaranteed + up to 3 more at 50% each (1–4x total)
    {
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_4,      weight = 10000 },
    },

    {
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_4,      weight =  5000 },
        { itemId = xi.item.NONE,                              weight =  5000 },
    },

    {
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_4,      weight =  5000 },
        { itemId = xi.item.NONE,                              weight =  5000 },
    },

    {
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_4,      weight =  5000 },
        { itemId = xi.item.NONE,                              weight =  5000 },
    },
}

return content:register()
