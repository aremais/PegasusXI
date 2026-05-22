-----------------------------------
-- Area: Full Moon Fountain
-- HTBF: ★Waking the Beast (Carbuncle Prime)
-- Entry KI: Waking the Beast Phantom Gem (10 merits)
-- Direct drop: Rem's Tale Ch.7 per player
-- Title (Very Difficult): Ruby Repulser
-----------------------------------
require('scripts/globals/htbf_rewards')
-----------------------------------

local content = HTBFBattlefield:new({
    zoneId           = xi.zone.FULL_MOON_FOUNTAIN,
    battlefieldId    = xi.battlefield.id.WAKING_THE_BEAST_HTBF,
    canLoseExp       = false,
    maxPlayers       = 6,
    timeLimit        = utils.minutes(30),
    index            = 4,
    entryNpc         = 'MS_Entrance',
    exitNpc          = 'Moon_Spiral',
    requiredKeyItems = { xi.ki.WAKING_THE_BEAST_PHANTOM_GEM },
})

local lootTable =
{
    -- Unique materials
    {
        { itemId = xi.item.MALIYAKALEYA_CORAL,     weight = 5000 },
        { itemId = xi.item.HEPATIZON_ORE,          weight = 5000 },
        { itemId = xi.item.BERYLLIUM_ORE,          weight = 5000 },
        { itemId = xi.item.EXALTED_LOG,            weight = 5000 },
        { itemId = xi.item.SIFS_LOCK,              weight = 5000 },
    },

    -- Unique weapons
    {
        { itemId = xi.item.MARQUETRY_STAFF,        weight = 10000 },
    },

    -- Unique armor
    {
        { itemId = xi.item.ENGRAVED_BELT,          weight = 2500 },
        { itemId = xi.item.LAPIDARY_TUNIC,         weight = 2500 },
        { itemId = xi.item.SATLADA_NECKLACE,       weight = 2500 },
        { itemId = xi.item.DIAMANTAIRE_SOLLERETS,  weight = 2500 },
    },
}

content.groups =
{
    {
        mobs = { 'Carbuncle_Prime_HTBF' },
        allDeath = function(battlefield, mob)
            local diff = battlefield:getLocalVar('HTBF_Difficulty')

            if diff == xi.htbf.difficulty.VERY_DIFFICULT then
                local players = battlefield:getPlayers()

                for _, player in ipairs(players) do
                    player:addTitle(xi.title.RUBY_REPULSER)
                end
            end

            xi.htbf.onWin(battlefield, {
                battlefieldId = xi.battlefield.id.WAKING_THE_BEAST_HTBF,
                chapterItemId = xi.item.REMS_TALE_CH_7,
                mob           = mob,
                lootTable     = lootTable,
            })
        end,
    },
}

return content:register()
