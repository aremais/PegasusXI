-----------------------------------
-- Divine Punishers II
-- Balga's Dais SKCNM, Macrocosmic Orb
-- !additem 4063
-----------------------------------
require('scripts/globals/skcnm')
local balgasDaisID = zones[xi.zone.BALGAS_DAIS]
-----------------------------------

local content = SKCNMBattlefield:new({
    zoneId        = xi.zone.BALGAS_DAIS,
    battlefieldId = xi.battlefield.id.DIVINE_PUNISHERS_II,
    maxPlayers    = 6,
    timeLimit     = utils.minutes(30),
    index         = 22,
    entryNpc      = 'BC_Entrance',
    exitNpc       = 'Burning_Circle',
    requiredItems = { xi.item.MACROCOSMIC_ORB, wearMessage = balgasDaisID.text.A_CRACK_HAS_FORMED, wornMessage = balgasDaisID.text.ORB_IS_CRACKED },
})

content.groups =
{
    {
        mobIds =
        {
            {
                balgasDaisID.mob.VOO_TOLU_THE_GHOSTFIST_II,      -- Voo Tolu the Ghostfist (MNK)
                balgasDaisID.mob.VOO_TOLU_THE_GHOSTFIST_II + 1,  -- Aa Nawu the Thunderblade (SAM)
                balgasDaisID.mob.VOO_TOLU_THE_GHOSTFIST_II + 2,  -- Cuu Doko the Blizzard (WHM)
                balgasDaisID.mob.VOO_TOLU_THE_GHOSTFIST_II + 3,  -- Yoo Mihi the Haze (NIN)
                balgasDaisID.mob.VOO_TOLU_THE_GHOSTFIST_II + 4,  -- Gii Jaha the Raucous (BRD)
                balgasDaisID.mob.VOO_TOLU_THE_GHOSTFIST_II + 5,  -- Zuu Xowu the Darksmoke (BLM)
            },

            {
                balgasDaisID.mob.VOO_TOLU_THE_GHOSTFIST_II + 7,
                balgasDaisID.mob.VOO_TOLU_THE_GHOSTFIST_II + 8,
                balgasDaisID.mob.VOO_TOLU_THE_GHOSTFIST_II + 9,
                balgasDaisID.mob.VOO_TOLU_THE_GHOSTFIST_II + 10,
                balgasDaisID.mob.VOO_TOLU_THE_GHOSTFIST_II + 11,
                balgasDaisID.mob.VOO_TOLU_THE_GHOSTFIST_II + 12,
            },

            {
                balgasDaisID.mob.VOO_TOLU_THE_GHOSTFIST_II + 14,
                balgasDaisID.mob.VOO_TOLU_THE_GHOSTFIST_II + 15,
                balgasDaisID.mob.VOO_TOLU_THE_GHOSTFIST_II + 16,
                balgasDaisID.mob.VOO_TOLU_THE_GHOSTFIST_II + 17,
                balgasDaisID.mob.VOO_TOLU_THE_GHOSTFIST_II + 18,
                balgasDaisID.mob.VOO_TOLU_THE_GHOSTFIST_II + 19,
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
