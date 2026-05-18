-----------------------------------
-- Brothers D'Aurphe II
-- Qu'Bia Arena SKCNM, Macrocosmic Orb
-- !additem 4063
-----------------------------------
local quBiaArenaID = zones[xi.zone.QUBIA_ARENA]
-----------------------------------

local content = Battlefield:new({
    zoneId        = xi.zone.QUBIA_ARENA,
    battlefieldId = xi.battlefield.id.BROTHERS_D_AURPHE_II,
    maxPlayers    = 6,
    timeLimit     = utils.minutes(30),
    index         = 13,
    entryNpc      = 'BC_Entrance',
    exitNpc       = 'Burning_Circle',
    requiredItems = { xi.item.MACROCOSMIC_ORB, wearMessage = quBiaArenaID.text.A_CRACK_HAS_FORMED, wornMessage = quBiaArenaID.text.ORB_IS_CRACKED },
})

content.groups =
{
    {
        mobIds =
        {
            {
                quBiaArenaID.mob.VAICOLIAUX_B_DAURPHE,     -- Vaicoliaux B. D'Aurphe
                quBiaArenaID.mob.VAICOLIAUX_B_DAURPHE + 1, -- Maldaramet B. D'Aurphe
                quBiaArenaID.mob.VAICOLIAUX_B_DAURPHE + 2, -- Disfaurit B. D'Aurphe
                quBiaArenaID.mob.VAICOLIAUX_B_DAURPHE + 3, -- Jeumouque B. D'Aurphe
            },

            {
                quBiaArenaID.mob.VAICOLIAUX_B_DAURPHE + 5,
                quBiaArenaID.mob.VAICOLIAUX_B_DAURPHE + 6,
                quBiaArenaID.mob.VAICOLIAUX_B_DAURPHE + 7,
                quBiaArenaID.mob.VAICOLIAUX_B_DAURPHE + 8,
            },

            {
                quBiaArenaID.mob.VAICOLIAUX_B_DAURPHE + 10,
                quBiaArenaID.mob.VAICOLIAUX_B_DAURPHE + 11,
                quBiaArenaID.mob.VAICOLIAUX_B_DAURPHE + 12,
                quBiaArenaID.mob.VAICOLIAUX_B_DAURPHE + 13,
            },
        },

        superlink = true,
        allDeath  = utils.bind(content.handleAllMonstersDefeated, content),
    },
}

content.loot =
{
    {
        { itemId = xi.item.GIL,                              weight = 10000, amount = 30000 },
    },

    {
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_3,     weight = 10000, quantity = 2 },
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
        { itemId = xi.item.SCROLL_OF_ADDLE,                  weight = 3333 },
        { itemId = xi.item.SCROLL_OF_AERO_V,                 weight = 3333 },
        { itemId = xi.item.SCROLL_OF_ENDARK,                 weight = 3334 },
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
