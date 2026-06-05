-----------------------------------
-- Area: Hall of the Gods (PLACEHOLDER — DO NOT ENABLE)
-- HTBF: ★Champion of the Dawn (Cait Sith Prime)
-- Entry KI: Champion Phantom Gem (10 merits)
-- Direct drop: Rem's Tale Ch.6-10 per player (all chapters)
-- Title (Very Difficult): Sidhe Smasher
-- Note: "New" HTBF — unique/rare drops are NOT guaranteed on D/VD.
--
-- TODO: Entry NPC is the Verdical Conflux in Selbina (zone 248).
--       The NPC script needs to be created at:
--         scripts/zones/Selbina/npcs/Verdical_Conflux.lua
--       The correct battlefield zone for Cait Sith Prime HTBF also needs to be
--       confirmed before uncommenting — zoneId is currently wrong (HALL_OF_THE_GODS).
--       The Champion Phantom Gem is also disabled in the vendor (htbf.lua).
--       Do not uncomment content:register() until the zone and NPC are set up.
-----------------------------------
-- require('scripts/globals/htbf_rewards')
-----------------------------------

--[[ DISABLED
local content = HTBFBattlefield:new({
    zoneId           = xi.zone.HALL_OF_THE_GODS,
    battlefieldId    = xi.battlefield.id.CHAMPION_OF_THE_DAWN_HTBF,
    canLoseExp       = false,
    maxPlayers       = 6,
    timeLimit        = utils.minutes(30),
    index            = 2,
    entryNpc         = 'HG_Entrance',
    exitNpc          = 'Hall_Gate',
    requiredKeyItems = { xi.ki.CHAMPION_PHANTOM_GEM },
})

-- Cait Sith has no unique material drops.
local lootTable =
{
    -- Treasure-pool chapter (any of Ch.6-10)
    {
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_6,      weight = 2000 },
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_7,      weight = 2000 },
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_8,      weight = 2000 },
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_9,      weight = 2000 },
        { itemId = xi.item.COPY_OF_REMS_TALE_CHAPTER_10,     weight = 2000 },
    },

    -- Unique weapons
    {
        { itemId = xi.item.CATH_PALUG_HAMMER,   weight = 5000 },
        { itemId = xi.item.CATH_PALUG_STONE,    weight = 5000 },
    },

    -- Unique armor
    {
        { itemId = xi.item.CATH_PALUG_CROWN,    weight = 3334 },
        { itemId = xi.item.CATH_PALUG_RING,     weight = 3333 },
        { itemId = xi.item.CATH_PALUG_EARRING,  weight = 3333 },
    },
}

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
        mobs = { 'Cait_Sith_Prime_HTBF' },
        allDeath = function(battlefield, mob)
            local diff    = battlefield:getLocalVar('HTBF_Difficulty')
            local players = battlefield:getPlayers()

            if diff == xi.htbf.difficulty.VERY_DIFFICULT then
                for _, player in ipairs(players) do
                    player:addTitle(xi.title.SIDHE_SMASHER)
                end
            end

            for _, player in ipairs(players) do
                player:setCharVar('HTBF_Win_' .. xi.battlefield.id.CHAMPION_OF_THE_DAWN_HTBF, 1)
            end

            giveAllChapters(battlefield)

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

-- Draft only: lives under scripts/battlefields/_drafts/ so the server does not auto-load it.
-- Move back to scripts/battlefields/Hall_of_the_Gods/ after zone/NPC setup is complete.
