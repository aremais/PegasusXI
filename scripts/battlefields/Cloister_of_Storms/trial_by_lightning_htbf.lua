-----------------------------------
-- Area: Cloister of Storms
-- HTBF: ★Trial by Lightning (Ramuh Prime)
-- Entry KI: Avatar Phantom Gem (10 merits)
-- Direct drop: Rem's Tale Ch.7 per player
-- Title (Very Difficult): Fulmination Disruptor
-----------------------------------
require('scripts/globals/htbf_rewards')
-----------------------------------

local content = HTBFBattlefield:new({
    zoneId           = xi.zone.CLOISTER_OF_STORMS,
    battlefieldId    = xi.battlefield.id.TRIAL_BY_LIGHTNING_HTBF,
    canLoseExp       = false,
    maxPlayers       = 6,
    timeLimit        = utils.minutes(30),
    index            = 5,
    entryNpc         = 'LP_Entrance',
    exitNpc          = 'Lightning_Protocrystal',
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
        { itemId = xi.item.STACCATO_STAFF,     weight = 5000 },
        { itemId = xi.item.DONAR_GUN,          weight = 5000 },
    },

    -- Unique armor
    {
        { itemId = xi.item.VOLTSURGE_TORQUE,   weight = 3334 },
        { itemId = xi.item.UKKO_SASH,          weight = 3333 },
        { itemId = xi.item.BRONTES_CUISSES,    weight = 3333 },
    },
}

content.groups =
{
    {
        mobs = { 'Ramuh_Prime_HTBF' },
        allDeath = function(battlefield, mob)
            local diff = battlefield:getLocalVar('HTBF_Difficulty')

            if diff == xi.htbf.difficulty.VERY_DIFFICULT then
                local players = battlefield:getPlayers()

                for _, player in ipairs(players) do
                    player:addTitle(xi.title.FULMINATION_DISRUPTOR)
                end
            end

            xi.htbf.onWin(battlefield, {
                battlefieldId = xi.battlefield.id.TRIAL_BY_LIGHTNING_HTBF,
                chapterItemId = xi.item.REMS_TALE_CH_7,
                mob           = mob,
                lootTable     = lootTable,
            })
        end,
    },
}

return content:register()
