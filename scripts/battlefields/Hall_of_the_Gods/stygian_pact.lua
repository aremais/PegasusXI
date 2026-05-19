-----------------------------------
-- Area: Hall of the Gods (PLACEHOLDER — DO NOT ENABLE)
-- HTBF: ★A Stygian Pact (Odin Prime)
-- Entry KI: Stygian Pact Phantom Gem (10 merits)
-- Direct drop: Rem's Tale Ch.6-10 per player (all chapters)
-- Title (Very Difficult): Dread Purger
-- Note: "New" HTBF — unique/rare drops are NOT guaranteed on D/VD.
--
-- TODO: Entry NPC is the Verdical Conflux in Selbina (zone 248).
--       The NPC script needs to be created at:
--         scripts/zones/Selbina/npcs/Verdical_Conflux.lua
--       The correct battlefield zone for Odin Prime HTBF also needs to be
--       confirmed before uncommenting — zoneId is currently wrong (HALL_OF_THE_GODS).
--       The Stygian Pact Phantom Gem is also disabled in the vendor (htbf.lua).
--       Do not uncomment content:register() until the zone and NPC are set up.
-----------------------------------
-- require('scripts/globals/htbf_rewards')
-----------------------------------

--[[ DISABLED
local content = HTBFBattlefield:new({
    zoneId           = xi.zone.HALL_OF_THE_GODS,
    battlefieldId    = xi.battlefield.id.STYGIAN_PACT_HTBF,
    canLoseExp       = false,
    maxPlayers       = 6,
    timeLimit        = utils.minutes(30),
    index            = 1,
    entryNpc         = 'HG_Entrance',
    exitNpc          = 'Hall_Gate',
    requiredKeyItems = { xi.ki.STYGIAN_PACT_PHANTOM_GEM },
})

-- Odin has no unique material drops.
local lootTable =
{
    -- Treasure-pool chapter (any of Ch.6-10)
    {
        { itemId = xi.item.REMS_TALE_CH_6,        weight = 2000 },
        { itemId = xi.item.REMS_TALE_CH_7,        weight = 2000 },
        { itemId = xi.item.REMS_TALE_CH_8,        weight = 2000 },
        { itemId = xi.item.REMS_TALE_CH_9,        weight = 2000 },
        { itemId = xi.item.REMS_TALE_CH_10,       weight = 2000 },
    },

    -- Unique weapons
    {
        { itemId = xi.item.GEIRROTHR,             weight = 3334 },
        { itemId = xi.item.ZANTETSUKEN,           weight = 3333 },
        { itemId = xi.item.ZANTETSUKEN_X,         weight = 3333 },
    },

    -- Unique armor
    {
        { itemId = xi.item.HJARRANDI_HELM,        weight = 2500 },
        { itemId = xi.item.HJARRANDI_BREASTPLATE, weight = 2500 },
        { itemId = xi.item.FREKE_RING,            weight = 2500 },
        { itemId = xi.item.GERE_RING,             weight = 2500 },
    },
}

local function giveAllChapters(battlefield)
    local players = battlefield:getPlayers()

    for _, player in ipairs(players) do
        npcUtil.giveItem(player, xi.item.REMS_TALE_CH_6)
        npcUtil.giveItem(player, xi.item.REMS_TALE_CH_7)
        npcUtil.giveItem(player, xi.item.REMS_TALE_CH_8)
        npcUtil.giveItem(player, xi.item.REMS_TALE_CH_9)
        npcUtil.giveItem(player, xi.item.REMS_TALE_CH_10)
    end
end

content.groups =
{
    {
        mobs = { 'Odin_Prime_HTBF' },
        allDeath = function(battlefield, mob)
            local diff    = battlefield:getLocalVar('HTBF_Difficulty')
            local players = battlefield:getPlayers()

            if diff == xi.htbf.difficulty.VERY_DIFFICULT then
                for _, player in ipairs(players) do
                    player:addTitle(xi.title.DREAD_PURGER)
                end
            end

            for _, player in ipairs(players) do
                player:setCharVar('HTBF_Win_' .. xi.battlefield.id.STYGIAN_PACT_HTBF, 1)
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
