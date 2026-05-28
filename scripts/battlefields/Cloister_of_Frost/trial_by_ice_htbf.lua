-----------------------------------
-- Area: Cloister of Frost
-- HTBF: ★Trial by Ice (Shiva Prime)
-- Entry KI: Avatar Phantom Gem (10 merits)
-- Direct drop: Rem's Tale Ch.10 per player
-- Title: Penitentes Blaster
-----------------------------------
require('scripts/globals/htbf_rewards')
-----------------------------------

local content = HTBFBattlefield:new({
    zoneId           = xi.zone.CLOISTER_OF_FROST,
    battlefieldId    = xi.battlefield.id.TRIAL_BY_ICE_HTBF,
    canLoseExp       = false,
    maxPlayers       = 6,
    timeLimit        = utils.minutes(30),
    index            = 5,
    entryNpc         = 'IP_Entrance',
    exitNpc          = 'Ice_Protocrystal',
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
        { itemId = xi.item.CALVED_CLAWS,       weight = 5000 },
        { itemId = xi.item.FRAZIL_STAFF,       weight = 5000 },
    },

    -- Unique armor
    {
        { itemId = xi.item.RIMEICE_EARRING,    weight = 3334 },
        { itemId = xi.item.NILAS_GLOVES,       weight = 3333 },
        { itemId = xi.item.FLOESTONE,          weight = 3333 },
    },
}

content.groups =
{
    {
        mobs = { 'Shiva_Prime_HTBF' },
        allDeath = function(battlefield, mob)
            local players = battlefield:getPlayers()

            for _, player in ipairs(players) do
                player:addTitle(xi.title.PENITENTES_BLASTER)
            end

            xi.htbf.onWin(battlefield, {
                battlefieldId = xi.battlefield.id.TRIAL_BY_ICE_HTBF,
                chapterItemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_10,
                mob           = mob,
                lootTable     = lootTable,
            })
        end,
    },
}

return content:register()
