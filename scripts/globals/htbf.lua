-----------------------------------
-- HTBF Phantom Gem Vendor
-----------------------------------
-- Shared module used by all three phantom gem vendor NPCs.
-- Players purchase Phantom Gems here using merit points.
-- Each gem grants entry to one or more High-Tier Mission Battlefields.
--
-- Entry requirement: player main job level >= 95.
-- Gems are unique key items; duplicate purchases are rejected.
--
-- Pagination: 5 gems per page with Prev/Next navigation.
-- The 50ms timer between page transitions prevents double-menu conflicts.
-----------------------------------

xi      = xi or {}
xi.htbf = xi.htbf or {}

local itemsPerPage = 5
local minLevel     = 95

local gemList =
{
    -- ── Rise of the Zilart ────────────────────────────────────────────────────
    { ki = xi.ki.SHADOW_LORD_PHANTOM_GEM,      name = 'Shadow Lord Phantom Gem',      cost = 10 },
    { ki = xi.ki.STELLAR_FULCRUM_PHANTOM_GEM,  name = 'Stellar Fulcrum Phantom Gem',  cost = 10 },

    -- ── Chains of Promathia ───────────────────────────────────────────────────
    { ki = xi.ki.CELESTIAL_NEXUS_PHANTOM_GEM,  name = 'Celestial Nexus Phantom Gem',  cost = 10 },
    { ki = xi.ki.PHANTOM_GEM_OF_APATHY,        name = 'Phantom Gem of Apathy',        cost = 15 },
    { ki = xi.ki.PHANTOM_GEM_OF_COWARDICE,     name = 'Phantom Gem of Cowardice',     cost = 15 },
    { ki = xi.ki.PHANTOM_GEM_OF_ENVY,          name = 'Phantom Gem of Envy',          cost = 15 },
    { ki = xi.ki.PHANTOM_GEM_OF_ARROGANCE,     name = 'Phantom Gem of Arrogance',     cost = 15 },
    { ki = xi.ki.PHANTOM_GEM_OF_RAGE,          name = 'Phantom Gem of Rage',          cost = 15 },
    { ki = xi.ki.P_PERPETRATOR_PHANTOM_GEM,    name = 'P. Perpetrator Phantom Gem',   cost = 20 },

    -- ── Treasures of Aht Urhgan ───────────────────────────────────────────────
    { ki = xi.ki.SAVAGES_PHANTOM_GEM,          name = 'Savages Phantom Gem',          cost = 10 },
    { ki = xi.ki.WARRIORS_PATH_PHANTOM_GEM,    name = 'Warrior\'s Path Phantom Gem',  cost = 10 },
    { ki = xi.ki.PUPPET_IN_PERIL_PHANTOM_GEM,  name = 'Puppet in Peril Phantom Gem',  cost = 10 },
    { ki = xi.ki.LEGACY_PHANTOM_GEM,           name = 'Legacy Phantom Gem',           cost = 10 },
    { ki = xi.ki.HEAD_WIND_PHANTOM_GEM,        name = 'Head Wind Phantom Gem',        cost = 10 },

    -- ── Wings of the Goddess ──────────────────────────────────────────────────
    { ki = xi.ki.FEARED_ONE_PHANTOM_GEM,       name = 'Feared One Phantom Gem',       cost = 10 },

    -- ── Avatar Primes ─────────────────────────────────────────────────────────
    { ki = xi.ki.AVATAR_PHANTOM_GEM,           name = 'Avatar Phantom Gem',           cost = 10 },
    { ki = xi.ki.MOONLIT_PATH_PHANTOM_GEM,     name = 'Moonlit Path Phantom Gem',     cost = 10 },
    { ki = xi.ki.WAKING_THE_BEAST_PHANTOM_GEM, name = 'Waking the Beast Phantom Gem', cost = 10 },
    { ki = xi.ki.WAKING_DREAMS_PHANTOM_GEM,    name = 'Waking Dreams Phantom Gem',    cost = 10 },

    -- ── Rhapsodies of Vana'diel ───────────────────────────────────────────────
    -- TODO: Alexander/Odin/Cait Sith zones not yet implemented — gems disabled until fights are ready.
    -- { ki = xi.ki.DIVINE_PHANTOM_GEM,        name = 'Divine Phantom Gem',           cost = 10 },
    -- { ki = xi.ki.STYGIAN_PACT_PHANTOM_GEM,  name = 'Stygian Pact Phantom Gem',     cost = 10 },
    -- { ki = xi.ki.CHAMPION_PHANTOM_GEM,      name = 'Champion Phantom Gem',         cost = 10 },
    { ki = xi.ki.MAIDEN_PHANTOM_GEM,           name = 'Maiden Phantom Gem',           cost = 30 },
    { ki = xi.ki.WYRM_GOD_PHANTOM_GEM,         name = 'Wyrm God Phantom Gem',         cost = 30 },
    { ki = xi.ki.ORB_OF_RADIANCE_PHANTOM_GEM,  name = 'Orb of Radiance Phantom Gem',  cost = 30 },
}

local function tryPurchase(player, gem)
    if player:hasKeyItem(gem.ki) then
        player:printToPlayer('You already possess that phantom gem.', xi.msg.channel.NS_SAY)
        return
    end

    if player:getMeritCount() < gem.cost then
        player:printToPlayer(
            string.format('You need %d merit points to receive that phantom gem.', gem.cost),
            xi.msg.channel.NS_SAY
        )
        return
    end

    player:setMerits(player:getMeritCount() - gem.cost)
    npcUtil.giveKeyItem(player, gem.ki)
end

local function showPage(player, title, page)
    local totalPages = math.ceil(#gemList / itemsPerPage)
    local startIdx   = (page - 1) * itemsPerPage + 1
    local endIdx     = math.min(page * itemsPerPage, #gemList)

    local menu =
    {
        title   = title .. ' [' .. page .. '/' .. totalPages .. ']',
        options = {},
    }

    for i = startIdx, endIdx do
        local gem = gemList[i]

        table.insert(menu.options, {
            gem.name .. ' (' .. gem.cost .. ')',
            function(p)
                tryPurchase(p, gem)
            end,
        })
    end

    if page > 1 then
        local prevPage = page - 1

        table.insert(menu.options, {
            '<< Previous',
            function(p)
                p:timer(50, function(pp)
                    showPage(pp, title, prevPage)
                end)
            end,
        })
    end

    if page < totalPages then
        local nextPage = page + 1

        table.insert(menu.options, {
            'Next >>',
            function(p)
                p:timer(50, function(pp)
                    showPage(pp, title, nextPage)
                end)
            end,
        })
    end

    table.insert(menu.options, {
        'Nothing.',
        function(_) end,
    })

    player:customMenu(menu)
end

function xi.htbf.onTrigger(player, npc, menuTitle, lowLvlMsg)
    if player:getMainLvl() < minLevel then
        player:printToPlayer(lowLvlMsg, xi.msg.channel.NS_SAY)
        return
    end

    showPage(player, menuTitle, 1)
end
