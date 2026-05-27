-----------------------------------
-- Area: Full Moon Fountain
-- HTBF: ★The Moonlit Path (Fenrir Prime)
-- Entry KI: Moonlit Path Phantom Gem (10 merits)
-- Direct drop: Rem's Tale Ch.6 per player
-- Title (Very Difficult): Lupine Liquidator
-----------------------------------
require('scripts/globals/htbf_rewards')
-----------------------------------

local content = HTBFBattlefield:new({
    zoneId           = xi.zone.FULL_MOON_FOUNTAIN,
    battlefieldId    = xi.battlefield.id.MOONLIT_PATH_HTBF,
    canLoseExp       = false,
    maxPlayers       = 6,
    timeLimit        = utils.minutes(30),
    index            = 3,
    entryNpc         = 'MS_Entrance',
    exitNpc          = 'Moon_Spiral',
    requiredKeyItems = { xi.ki.MOONLIT_PATH_PHANTOM_GEM },
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
        { itemId = xi.item.MEDEINA_KILIJ,      weight = 10000 },
    },

    -- Unique armor
    {
        { itemId = xi.item.CAPITOLINE_STRAP,   weight = 2500 },
        { itemId = xi.item.VRIKODARA_JUPON,    weight = 2500 },
        { itemId = xi.item.MAIITSOH_HAUBE,     weight = 2500 },
        { itemId = xi.item.LUPINE_CAPE,        weight = 2500 },
    },
}

content.groups =
{
    {
        mobs = { 'Fenrir_Prime_HTBF' },
        allDeath = function(battlefield, mob)
            local diff = battlefield:getLocalVar('HTBF_Difficulty')

            if diff == xi.htbf.difficulty.VERY_DIFFICULT then
                local players = battlefield:getPlayers()

                for _, player in ipairs(players) do
                    player:addTitle(xi.title.LUPINE_LIQUIDATOR)
                end
            end

            xi.htbf.onWin(battlefield, {
                battlefieldId = xi.battlefield.id.MOONLIT_PATH_HTBF,
                chapterItemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_6,
                mob           = mob,
                lootTable     = lootTable,
            })
        end,
    },
}

return content:register()
