-----------------------------------
-- Dismemberment Brigade II
-- Horlais Peak SKCNM, Macrocosmic Orb
-- !additem 4063
-----------------------------------
require('scripts/globals/skcnm')
local horlaisPeakID = zones[xi.zone.HORLAIS_PEAK]
-----------------------------------

local content = SKCNMBattlefield:new({
    zoneId        = xi.zone.HORLAIS_PEAK,
    battlefieldId = xi.battlefield.id.DISMEMBERMENT_BRIGADE_II,
    maxPlayers    = 6,
    timeLimit     = utils.minutes(30),
    index         = 3,
    entryNpc      = 'BC_Entrance',
    exitNpc       = 'Burning_Circle',
    requiredItems = { xi.item.MACROCOSMIC_ORB, wearMessage = horlaisPeakID.text.A_CRACK_HAS_FORMED, wornMessage = horlaisPeakID.text.ORB_IS_CRACKED },
})

content.groups =
{
    {
        mobIds =
        {
            {
                horlaisPeakID.mob.ARMSMASTER_DEKBUK,      -- Armsmaster Dekbuk (WAR)
                horlaisPeakID.mob.ARMSMASTER_DEKBUK + 1,  -- Invulnerable Mazzgozz (PLD)
                horlaisPeakID.mob.ARMSMASTER_DEKBUK + 2,  -- Keeneyed Aufwuf (BLM)
                horlaisPeakID.mob.ARMSMASTER_DEKBUK + 3,  -- Longarmed Gottditt (MNK)
                horlaisPeakID.mob.ARMSMASTER_DEKBUK + 4,  -- Mind's-eyed Klugwug (RNG)
                horlaisPeakID.mob.ARMSMASTER_DEKBUK + 5,  -- Undefeatable Sappdapp (DRK)
            },

            {
                horlaisPeakID.mob.ARMSMASTER_DEKBUK + 7,
                horlaisPeakID.mob.ARMSMASTER_DEKBUK + 8,
                horlaisPeakID.mob.ARMSMASTER_DEKBUK + 9,
                horlaisPeakID.mob.ARMSMASTER_DEKBUK + 10,
                horlaisPeakID.mob.ARMSMASTER_DEKBUK + 11,
                horlaisPeakID.mob.ARMSMASTER_DEKBUK + 12,
            },

            {
                horlaisPeakID.mob.ARMSMASTER_DEKBUK + 14,
                horlaisPeakID.mob.ARMSMASTER_DEKBUK + 15,
                horlaisPeakID.mob.ARMSMASTER_DEKBUK + 16,
                horlaisPeakID.mob.ARMSMASTER_DEKBUK + 17,
                horlaisPeakID.mob.ARMSMASTER_DEKBUK + 18,
                horlaisPeakID.mob.ARMSMASTER_DEKBUK + 19,
            },
        },

        superlink = true,
        allDeath  = function(battlefield, mob)
            xi.skcnm.onWin(battlefield, {
                chapterItemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_5,
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
        { itemId = xi.item.SCROLL_OF_REGEN_IV,               weight = 1250 },
        { itemId = xi.item.SCROLL_OF_GAIN_STR,               weight = 1250 },
        { itemId = xi.item.SCROLL_OF_GAIN_DEX,               weight = 1250 },
        { itemId = xi.item.SCROLL_OF_GAIN_VIT,               weight = 1250 },
        { itemId = xi.item.SCROLL_OF_GAIN_AGI,               weight = 1250 },
        { itemId = xi.item.SCROLL_OF_GAIN_INT,               weight = 1250 },
        { itemId = xi.item.SCROLL_OF_GAIN_MND,               weight = 1250 },
        { itemId = xi.item.SCROLL_OF_GAIN_CHR,               weight = 1250 },
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
