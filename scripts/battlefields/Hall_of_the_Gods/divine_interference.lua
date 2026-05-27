-----------------------------------
-- Area: Hall of the Gods (PLACEHOLDER — DO NOT ENABLE)
-- HTBF: ★Divine Interference (Alexander Prime)
-- Entry KI: Divine Phantom Gem (10 merits)
-- Direct drop: Rem's Tale Ch.6-10 per player (all chapters)
-- Title (Very Difficult): Alexander Annihilator
-- Note: "New" HTBF — unique/rare drops are NOT guaranteed on D/VD.
--
-- TODO: Entry NPC is the Verdical Conflux in Selbina (zone 248).
--       The NPC script needs to be created at:
--         scripts/zones/Selbina/npcs/Verdical_Conflux.lua
--       The correct battlefield zone for Alexander Prime HTBF also needs to be
--       confirmed before uncommenting — zoneId is currently wrong (HALL_OF_THE_GODS).
--       The Divine Phantom Gem is also disabled in the vendor (htbf.lua).
--       Do not uncomment content:register() until the zone and NPC are set up.
-----------------------------------
-- require('scripts/globals/htbf_rewards')
-----------------------------------

--[[ DISABLED
local content = HTBFBattlefield:new({
    zoneId           = xi.zone.HALL_OF_THE_GODS,
    battlefieldId    = xi.battlefield.id.DIVINE_INTERFERENCE_HTBF,
    canLoseExp       = false,
    maxPlayers       = 6,
    timeLimit        = utils.minutes(30),
    index            = 0,
    entryNpc         = 'HG_Entrance',
    exitNpc          = 'Hall_Gate',
    requiredKeyItems = { xi.ki.DIVINE_PHANTOM_GEM },
})

-- Alexander has no unique material drops.
-- All five Rem's Tale chapters may appear in the treasure pool (any Ch.6-10).
local lootTable =
{
    -- Treasure-pool chapter (any of Ch.6-10 — separate from direct drops)
    {
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_6,     weight = 2000 },
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_7,     weight = 2000 },
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_8,     weight = 2000 },
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_9,     weight = 2000 },
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_10,    weight = 2000 },
    },

    -- Unique weapon
    {
        { itemId = xi.item.SACRO_BULWARK,      weight = 10000 },
    },

    -- Unique armor
    {
        { itemId = xi.item.SACRO_BREASTPLATE,  weight = 2500 },
        { itemId = xi.item.SACRO_GORGET,       weight = 2500 },
        { itemId = xi.item.SACRO_CORD,         weight = 2500 },
        { itemId = xi.item.SACRO_MANTLE,       weight = 2500 },
    },
}

-- Alexander gives all five chapters directly to each player on win.
-- We override chapterItemId with a custom delivery via a pre-win hook.
local function giveAllChapters(battlefield)
    local players = battlefield:getPlayers()

    for _, player in ipairs(players) do
        npcUtil.giveItem(player, xi.item.COPY_OF_REMS_TALE_CHAPTER_6)
        npcUtil.giveItem(player, xi.item.COPY_OF_REMS_TALE_CHAPTER_7)
        npcUtil.giveItem(player, xi.item.COPY_OF_REMS_TALE_CHAPTER_8)
        npcUtil.giveItem(player, xi.item.COPY_OF_REMS_TALE_CHAPTER_9)
        npcUtil.giveItem(player, xi.item.COPY_OF_REMS_TALE_CHAPTER_10)
    end
end

content.groups =
{
    {
        mobs = { 'Alexander_Prime_HTBF' },
        allDeath = function(battlefield, mob)
            local diff = battlefield:getLocalVar('HTBF_Difficulty')

            if diff == xi.htbf.difficulty.VERY_DIFFICULT then
                local players = battlefield:getPlayers()

                for _, player in ipairs(players) do
                    player:addTitle(xi.title.ALEXANDER_ANNIHILATOR)
                end
            end

            -- Record win for all players
            local players = battlefield:getPlayers()

            for _, player in ipairs(players) do
                player:setCharVar('HTBF_Win_' .. xi.battlefield.id.DIVINE_INTERFERENCE_HTBF, 1)
            end

            -- Give all five chapters directly
            giveAllChapters(battlefield)

            -- Roll treasure pool (weapons/armor only — no upgrade materials)
            local selected = utils.selectFromLootGroups(players[1], lootTable)

            for _, entry in ipairs(selected) do
                players[1]:addTreasure(entry.itemId, mob)
            end

            battlefield:setStatus(xi.battlefield.status.WON)
        end,
    },
}

return content:register()
--]] -- END DISABLED
