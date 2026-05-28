-----------------------------------
-- Area: The Shrouded Maw
-- HTBF: ★Waking Dreams (Diabolos Prime)
-- Entry KI: Waking Dreams Phantom Gem (10 merits)
-- Direct drop: Rem's Tale Ch.8 per player
-- Title: Devil's Demise
-----------------------------------
require('scripts/globals/htbf_rewards')
-----------------------------------

local content = HTBFBattlefield:new({
    zoneId           = xi.zone.THE_SHROUDED_MAW,
    battlefieldId    = xi.battlefield.id.WAKING_DREAMS_HTBF,
    canLoseExp       = false,
    maxPlayers       = 6,
    timeLimit        = utils.minutes(30),
    index            = 3,
    entryNpc         = 'MC_Entrance',
    exitNpc          = 'Memento_Circle',
    requiredKeyItems = { xi.ki.WAKING_DREAMS_PHANTOM_GEM },
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
        { itemId = xi.item.SHUHANSADAMUNE,     weight = 10000 },
    },

    -- Unique armor
    {
        { itemId = xi.item.DARKSIDE_EARRING,   weight = 2500 },
        { itemId = xi.item.PERNICIOUS_RING,    weight = 2500 },
        { itemId = xi.item.CHOZORON_COSELETE,  weight = 2500 },
        { itemId = xi.item.LOAGAETH_CUFFS,     weight = 2500 },
    },
}

content.groups =
{
    {
        mobs = { 'Diabolos_HTBF' },
        allDeath = function(battlefield, mob)
            local players = battlefield:getPlayers()

            for _, player in ipairs(players) do
                player:addTitle(xi.title.DEVILS_DEMISE)
            end

            xi.htbf.onWin(battlefield, {
                battlefieldId = xi.battlefield.id.WAKING_DREAMS_HTBF,
                chapterItemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_8,
                mob           = mob,
                lootTable     = lootTable,
            })
        end,
    },
}

return content:register()
