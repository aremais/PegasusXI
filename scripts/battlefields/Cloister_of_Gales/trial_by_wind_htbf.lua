-----------------------------------
-- Area: Cloister of Gales
-- HTBF: ★Trial by Wind (Garuda Prime)
-- Entry KI: Avatar Phantom Gem (10 merits)
-- Direct drop: Rem's Tale Ch.6 per player
-- Title (Very Difficult): Sirocco Tamer
-----------------------------------
require('scripts/globals/htbf_rewards')
-----------------------------------

local content = HTBFBattlefield:new({
    zoneId           = xi.zone.CLOISTER_OF_GALES,
    battlefieldId    = xi.battlefield.id.TRIAL_BY_WIND_HTBF,
    canLoseExp       = false,
    maxPlayers       = 6,
    timeLimit        = utils.minutes(30),
    index            = 5,
    entryNpc         = 'WP_Entrance',
    exitNpc          = 'Wind_Protocrystal',
    requiredKeyItems = { xi.ki.AVATAR_PHANTOM_GEM },
})

local lootTable =
{
    -- Unique materials
    {
        { itemId = xi.item.MALIYAKALEYA_CORAL, weight = 5000 },
        { itemId = xi.item.HEPATIZON_ORE,      weight = 5000 },
        { itemId = xi.item.BERYLLIUM_ORE,      weight = 5000 },
        { itemId = xi.item.EXALTED_LOG,        weight = 5000 },
        { itemId = xi.item.SIFS_LOCK,          weight = 5000 },
    },

    -- Unique weapons
    {
        { itemId = xi.item.LEVANTE_DAGGER,     weight = 5000 },
        { itemId = xi.item.TRAMONTANE_AXE,     weight = 5000 },
    },

    -- Unique armor
    {
        { itemId = xi.item.LEBECHE_RING,       weight = 3334 },
        { itemId = xi.item.PONENTE_SASH,       weight = 3333 },
        { itemId = xi.item.OSTRO_GREAVES,      weight = 3333 },
    },
}

content.groups =
{
    {
        mobs = { 'Garuda_Prime_HTBF' },
        allDeath = function(battlefield, mob)
            local diff = battlefield:getLocalVar('HTBF_Difficulty')

            if diff == xi.htbf.difficulty.VERY_DIFFICULT then
                local players = battlefield:getPlayers()

                for _, player in ipairs(players) do
                    player:addTitle(xi.title.SIROCCO_TAMER)
                end
            end

            xi.htbf.onWin(battlefield, {
                battlefieldId = xi.battlefield.id.TRIAL_BY_WIND_HTBF,
                chapterItemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_6,
                mob           = mob,
                lootTable     = lootTable,
            })
        end,
    },
}

return content:register()
