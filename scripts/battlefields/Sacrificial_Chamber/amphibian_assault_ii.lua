-----------------------------------
-- Amphibian Assault II
-- Sacrificial Chamber SKCNM, Macrocosmic Orb
-- !additem 4063
-----------------------------------
require('scripts/globals/skcnm')
local sacrificialChamberID = zones[xi.zone.SACRIFICIAL_CHAMBER]
-----------------------------------

local content = SKCNMBattlefield:new({
    zoneId        = xi.zone.SACRIFICIAL_CHAMBER,
    battlefieldId = xi.battlefield.id.AMPHIBIAN_ASSAULT_II,
    maxPlayers    = 6,
    timeLimit     = utils.minutes(30),
    index         = 6,
    entryNpc      = '_4j0',
    exitNpcs      = { '_4j2', '_4j3', '_4j4' },
    requiredItems = { xi.item.MACROCOSMIC_ORB, wearMessage = sacrificialChamberID.text.A_CRACK_HAS_FORMED, wornMessage = sacrificialChamberID.text.ORB_IS_CRACKED },
})

-- Win only when all Sahagin AND the wyvern (if alive) are dead.
local function handleDeath(battlefield, mob)
    local baseMobId = sacrificialChamberID.mob.QULL_THE_FALLSTOPPER_II + (battlefield:getArea() - 1) * 6

    for _, mobOffset in ipairs({ 0, 1, 2, 3, 5 }) do
        local battlefieldMob = GetMobByID(baseMobId + mobOffset)
        if battlefieldMob and battlefieldMob:isAlive() then
            return
        end
    end

    xi.skcnm.onWin(battlefield, {
        chapterItemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_1,
        mob           = mob,
        lootTable     = content.loot,
    })
end

content.groups =
{
    {
        mobIds =
        {
            {
                sacrificialChamberID.mob.QULL_THE_FALLSTOPPER_II,      -- Qull the Fallstopper
                sacrificialChamberID.mob.QULL_THE_FALLSTOPPER_II + 1,  -- Rauu the Whaleswooner
                sacrificialChamberID.mob.QULL_THE_FALLSTOPPER_II + 2,  -- Hyohh the Conchblower
                sacrificialChamberID.mob.QULL_THE_FALLSTOPPER_II + 3,  -- Pevv the Riverleaper
            },

            {
                sacrificialChamberID.mob.QULL_THE_FALLSTOPPER_II + 6,
                sacrificialChamberID.mob.QULL_THE_FALLSTOPPER_II + 7,
                sacrificialChamberID.mob.QULL_THE_FALLSTOPPER_II + 8,
                sacrificialChamberID.mob.QULL_THE_FALLSTOPPER_II + 9,
            },

            {
                sacrificialChamberID.mob.QULL_THE_FALLSTOPPER_II + 12,
                sacrificialChamberID.mob.QULL_THE_FALLSTOPPER_II + 13,
                sacrificialChamberID.mob.QULL_THE_FALLSTOPPER_II + 14,
                sacrificialChamberID.mob.QULL_THE_FALLSTOPPER_II + 15,
            },
        },

        superlinkGroup = 1,
        allDeath = handleDeath,
    },

    {
        mobIds =
        {
            { sacrificialChamberID.mob.QULL_THE_FALLSTOPPER_II + 5  }, -- Sahagin's Wyvern
            { sacrificialChamberID.mob.QULL_THE_FALLSTOPPER_II + 11 },
            { sacrificialChamberID.mob.QULL_THE_FALLSTOPPER_II + 17 },
        },

        superlink = true,
        spawned   = false,
        allDeath  = handleDeath,
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
}

return content:register()
