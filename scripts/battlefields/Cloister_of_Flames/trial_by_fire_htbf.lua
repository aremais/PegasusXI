-----------------------------------
-- Area: Cloister of Flames
-- HTBF: ★Trial by Fire (Ifrit Prime)
-- Entry KI: Avatar Phantom Gem (10 merits)
-- Direct drop: Rem's Tale Ch.9 per player
-- Title (Very Difficult): Blaze Marshaller
-----------------------------------
require('scripts/globals/htbf_rewards')
-----------------------------------

local content = HTBFBattlefield:new({
    zoneId           = xi.zone.CLOISTER_OF_FLAMES,
    battlefieldId    = xi.battlefield.id.TRIAL_BY_FIRE_HTBF,
    canLoseExp       = false,
    maxPlayers       = 6,
    timeLimit        = utils.minutes(30),
    index            = 4,
    entryNpc         = 'FP_Entrance',
    exitNpc          = 'Fire_Protocrystal',
    requiredKeyItems = { xi.ki.AVATAR_PHANTOM_GEM },
})

local lootTable =
{
    -- Unique materials (shared across all avatar prime HTBFs)
    {
        { itemId = xi.item.MALIYAKALEYA_CORAL, weight = 5000 },
        { itemId = xi.item.HEPATIZON_ORE,      weight = 5000 },
        { itemId = xi.item.BERYLLIUM_ORE,      weight = 5000 },
        { itemId = xi.item.EXALTED_LOG,        weight = 5000 },
        { itemId = xi.item.SIFS_LOCK,          weight = 5000 },
    },

    -- Unique weapons
    {
        { itemId = xi.item.PERFERVID_SWORD,    weight = 5000 },
        { itemId = xi.item.ATAKIGIRI,          weight = 5000 },
    },

    -- Unique armor
    {
        { itemId = xi.item.COALRAKE_SABOTS,    weight = 3334 },
        { itemId = xi.item.ANNEALED_MANTLE,    weight = 3333 },
        { itemId = xi.item.IMMOLATION_GRIP,    weight = 3333 },
    },
}

content.groups =
{
    {
        mobs = { 'Ifrit_Prime_HTBF' },
        allDeath = function(battlefield, mob)
            local diff = battlefield:getLocalVar('HTBF_Difficulty')

            if diff == xi.htbf.difficulty.VERY_DIFFICULT then
                local players = battlefield:getPlayers()

                for _, player in ipairs(players) do
                    player:addTitle(xi.title.BLAZE_MARSHALLER)
                end
            end

            xi.htbf.onWin(battlefield, {
                battlefieldId = xi.battlefield.id.TRIAL_BY_FIRE_HTBF,
                chapterItemId = xi.item.REMS_TALE_CH_9,
                mob           = mob,
                lootTable     = lootTable,
            })
        end,
    },
}

return content:register()
