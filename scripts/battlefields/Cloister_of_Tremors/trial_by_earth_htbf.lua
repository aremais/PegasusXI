-----------------------------------
-- Area: Cloister of Tremors
-- HTBF: ★Trial by Earth (Titan Prime)
-- Entry KI: Avatar Phantom Gem (10 merits)
-- Direct drop: Rem's Tale Ch.8 per player
-- Title: Lithosphere Annihilator
-----------------------------------
require('scripts/globals/htbf_rewards')
-----------------------------------

local content = HTBFBattlefield:new({
    zoneId           = xi.zone.CLOISTER_OF_TREMORS,
    battlefieldId    = xi.battlefield.id.TRIAL_BY_EARTH_HTBF,
    canLoseExp       = false,
    maxPlayers       = 6,
    timeLimit        = utils.minutes(30),
    index            = 5,
    entryNpc         = 'EP_Entrance',
    exitNpc          = 'Earth_Protocrystal',
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
        { itemId = xi.item.MAFIC_CUDGEL,       weight = 3334 },
        { itemId = xi.item.FORESHOCK_SWORD,    weight = 3333 },
        { itemId = xi.item.TOGAKUSHI_SHURIKEN, weight = 3333 },
    },

    -- Unique armor
    {
        { itemId = xi.item.SUPERSHEAR_RING,    weight = 5000 },
        { itemId = xi.item.PLUMOSE_SACHET,     weight = 5000 },
    },
}

content.groups =
{
    {
        mobs = { 'Titan_Prime_HTBF' },
        allDeath = function(battlefield, mob)
            local players = battlefield:getPlayers()

            for _, player in ipairs(players) do
                player:addTitle(xi.title.LITHOSPHERE_ANNIHILATOR)
            end

            xi.htbf.onWin(battlefield, {
                battlefieldId = xi.battlefield.id.TRIAL_BY_EARTH_HTBF,
                chapterItemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_8,
                mob           = mob,
                lootTable     = lootTable,
            })
        end,
    },
}

return content:register()
