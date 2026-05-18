-----------------------------------
-- Area: Cloister of Tides
-- HTBF: ★Trial by Water (Leviathan Prime)
-- Entry KI: Avatar Phantom Gem (10 merits)
-- Direct drop: Rem's Tale Ch.9 per player
-- Title (Very Difficult): Bore Repulsor
-----------------------------------
require('scripts/globals/htbf_rewards')
-----------------------------------

local content = HTBFBattlefield:new({
    zoneId           = xi.zone.CLOISTER_OF_TIDES,
    battlefieldId    = xi.battlefield.id.TRIAL_BY_WATER_HTBF,
    canLoseExp       = false,
    maxPlayers       = 6,
    timeLimit        = utils.minutes(30),
    index            = 4,
    entryNpc         = 'WP_Entrance',
    exitNpc          = 'Water_Protocrystal',
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
        { itemId = xi.item.PELAGOS_LANCE,      weight = 3334 },
        { itemId = xi.item.VADOSE_ROD,         weight = 3333 },
        { itemId = xi.item.PHREATIC_AXE,       weight = 3333 },
    },

    -- Unique armor
    {
        { itemId = xi.item.BENTHOS_GRIP,       weight = 5000 },
        { itemId = xi.item.NERITIC_EARRING,    weight = 5000 },
    },
}

content.groups =
{
    {
        mobs = { 'Leviathan_Prime_HTBF' },
        allDeath = function(battlefield, mob)
            local diff = battlefield:getLocalVar('HTBF_Difficulty')

            if diff == xi.htbf.difficulty.VERY_DIFFICULT then
                local players = battlefield:getPlayers()

                for _, player in ipairs(players) do
                    player:addTitle(xi.title.BORE_REPULSOR)
                end
            end

            xi.htbf.onWin(battlefield, {
                battlefieldId = xi.battlefield.id.TRIAL_BY_WATER_HTBF,
                chapterItemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_9,
                mob           = mob,
                lootTable     = lootTable,
            })
        end,
    },
}

return content:register()
