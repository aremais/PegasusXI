-----------------------------------
-- Global: htbf
-- High-Tier Mission Battlefield (HTBF) Phantom Gem exchange system.
-- Used by Trisvain (Northern San d'Oria), Raving Opossum (Port Bastok),
-- and Mimble-Pimble (Port Windurst).
--
-- Requirements to purchase a Phantom Gem:
--   - Main job level 95 or higher
--   - Sufficient free merit points (see cost per gem below)
--   - Must not already possess the key item
--
-- Merit costs per gem (sourced from BG Wiki):
--   10 merits — most fights (Shadow Lord, CoP, ToAU, Avatar primes, etc.)
--   15 merits — Ark Angels 1-5 (Apathy / Cowardice / Envy / Arrogance / Rage)
--   20 merits — Divine Might (Pentacide Perpetrator)
--   30 merits — Wyrm God (Shinryu), Orb of Radiance (Cloud of Darkness, TODO)
-----------------------------------
require('scripts/globals/npc_util')

xi      = xi or {}
xi.htbf = xi.htbf or {}

-- Number of gems shown per menu page (client renders 3 items + 1 nav button).
local itemsPerPage = 3

-- Minimum main-job level required to purchase any Phantom Gem.
local minLevel = 95

---@class PhantomGemEntry
---@field ki    xi.keyItem  Key item ID
---@field name  string      Display name shown in menu
---@field cost  integer     Merit point cost

---@type PhantomGemEntry[]
local gemList =
{
    -- ── Avatar Prime Fights ───────────────────────────────────────────────────
    -- ★Trial by Fire/Ice/Wind/Earth/Lightning/Water (all 6 elemental primes share one gem)
    { ki = xi.ki.AVATAR_PHANTOM_GEM,           name = 'Avatar Phantom Gem',                cost = 10 },
    -- ★The Moonlit Path         (Fenrir Prime)
    { ki = xi.ki.MOONLIT_PATH_PHANTOM_GEM,     name = 'Moonlit Path Phantom Gem',          cost = 10 },
    -- ★Waking the Beast         (Carbuncle Prime)
    { ki = xi.ki.WAKING_THE_BEAST_PHANTOM_GEM, name = 'Waking the Beast Phantom Gem',      cost = 10 },
    -- ★Waking Dreams            (Diabolos Prime)
    { ki = xi.ki.WAKING_DREAMS_PHANTOM_GEM,    name = 'Waking Dreams Phantom Gem',         cost = 10 },

    -- ── TODO: Add remaining HTBFs below as they are implemented ──────────────
    -- ── Rise of the Zilart ───────────────────────────────────────────────────
    -- { ki = xi.ki.SHADOW_LORD_PHANTOM_GEM,      name = 'Shadow Lord Phantom Gem',           cost = 10 },
    -- { ki = xi.ki.STELLAR_FULCRUM_PHANTOM_GEM,  name = 'Stellar Fulcrum Phantom Gem',       cost = 10 },
    -- { ki = xi.ki.PHANTOM_GEM_OF_APATHY,        name = 'Phantom Gem of Apathy',             cost = 15 },
    -- { ki = xi.ki.PHANTOM_GEM_OF_COWARDICE,     name = 'Phantom Gem of Cowardice',          cost = 15 },
    -- { ki = xi.ki.PHANTOM_GEM_OF_ENVY,          name = 'Phantom Gem of Envy',               cost = 15 },
    -- { ki = xi.ki.PHANTOM_GEM_OF_ARROGANCE,     name = 'Phantom Gem of Arrogance',          cost = 15 },
    -- { ki = xi.ki.PHANTOM_GEM_OF_RAGE,          name = 'Phantom Gem of Rage',               cost = 15 },
    -- { ki = xi.ki.P_PERPETRATOR_PHANTOM_GEM,    name = 'Pentacide Perpetrator Phantom Gem', cost = 20 },
    -- { ki = xi.ki.CELESTIAL_NEXUS_PHANTOM_GEM,  name = 'Celestial Nexus Phantom Gem',       cost = 10 },
    -- ── Chains of Promathia ──────────────────────────────────────────────────
    -- { ki = xi.ki.SAVAGES_PHANTOM_GEM,          name = "Savage's Phantom Gem",              cost = 10 },
    -- { ki = xi.ki.HEAD_WIND_PHANTOM_GEM,        name = 'Head Wind Phantom Gem',             cost = 10 },
    -- { ki = xi.ki.FEARED_ONE_PHANTOM_GEM,       name = 'Feared One Phantom Gem',            cost = 10 },
    -- { ki = xi.ki.WARRIORS_PATH_PHANTOM_GEM,    name = "Warrior's Path Phantom Gem",        cost = 10 },
    -- { ki = xi.ki.DAWN_PHANTOM_GEM,             name = 'Dawn Phantom Gem',                  cost = 10 },
    -- ── Treasures of Aht Urhgan ─────────────────────────────────────────────
    -- { ki = xi.ki.PUPPET_IN_PERIL_PHANTOM_GEM,  name = 'Puppet in Peril Phantom Gem',       cost = 10 },
    -- { ki = xi.ki.LEGACY_PHANTOM_GEM,           name = 'Legacy Phantom Gem',                cost = 10 },
    -- ── Wings of the Goddess ─────────────────────────────────────────────────
    -- { ki = xi.ki.MAIDEN_PHANTOM_GEM,           name = 'Maiden Phantom Gem',                cost = 10 },
    -- ── Abyssea ──────────────────────────────────────────────────────────────
    -- { ki = xi.ki.WYRM_GOD_PHANTOM_GEM,         name = 'Wyrm God Phantom Gem',              cost = 30 },
    -- ── Avatar Primes (not yet implemented) ──────────────────────────────────
    -- { ki = xi.ki.DIVINE_PHANTOM_GEM,           name = 'Divine Phantom Gem',                cost = 10 },
    -- { ki = xi.ki.STYGIAN_PACT_PHANTOM_GEM,     name = 'Stygian Pact Phantom Gem',          cost = 10 },
    -- { ki = xi.ki.CHAMPION_PHANTOM_GEM,         name = 'Champion Phantom Gem',              cost = 10 },
    -- ── Rhapsodies of Vana'diel ──────────────────────────────────────────────
    -- { ki = xi.ki.ORB_OF_RADIANCE_PHANTOM_GEM,  name = 'Orb of Radiance Phantom Gem',       cost = 30 },
}

---Attempt to purchase a Phantom Gem.
---Checks for duplicate possession and sufficient merits before spending.
---@param player CBaseEntity
---@param gem    PhantomGemEntry
local function tryPurchase(player, gem)
    -- Duplicate check
    if player:hasKeyItem(gem.ki) then
        player:printToPlayer(
            string.format('You already possess a %s.', gem.name),
            xi.msg.channel.NS_SAY
        )
        return
    end

    -- Merit check
    local available = player:getMeritCount()
    if available < gem.cost then
        player:printToPlayer(
            string.format(
                'You do not have enough merit points. (%u required, %u available)',
                gem.cost,
                available
            ),
            xi.msg.channel.NS_SAY
        )
        return
    end

    -- Spend merits and award key item
    player:setMerits(available - gem.cost)
    npcUtil.giveKeyItem(player, gem.ki)
end

---Build and display the Phantom Gem selection menu.
---Uses a paginated layout (itemsPerPage gems per page) with
---Previous/Next navigation.
---@param player   CBaseEntity
---@param menuTitle string  Title string shown at the top of the menu
local function showMenu(player, menuTitle)
    local totalGems  = #gemList
    local totalPages = math.ceil(totalGems / itemsPerPage)
    local menu       = { title = menuTitle, options = {} }

    -- Build options for a given page and (re)display the menu.
    -- For page transitions a short timer is required to allow the engine
    -- to clear the previous menu context before opening the new one.
    local function buildPage(pageNum, useTimer)
        local function draw(p)
            local options  = {}
            local first    = (pageNum - 1) * itemsPerPage + 1
            local last     = math.min(pageNum * itemsPerPage, totalGems)

            for i = first, last do
                local gem   = gemList[i]
                local label = string.format('%s (%u merit%s)',
                    gem.name, gem.cost, gem.cost == 1 and '' or 's')

                table.insert(options, {
                    label,
                    function(playerArg)
                        tryPurchase(playerArg, gem)
                    end,
                })
            end

            -- Previous page navigation
            if pageNum > 1 then
                local prevPage = pageNum - 1
                table.insert(options, {
                    string.format('<< Prev  (Page %u/%u)', prevPage, totalPages),
                    function(playerArg)
                        buildPage(prevPage, true)
                    end,
                })
            end

            -- Next page navigation
            if pageNum < totalPages then
                local nextPage = pageNum + 1
                table.insert(options, {
                    string.format('Next >>  (Page %u/%u)', nextPage, totalPages),
                    function(playerArg)
                        buildPage(nextPage, true)
                    end,
                })
            end

            menu.options = options
            p:customMenu(menu)
        end

        if useTimer then
            player:timer(50, function(p)
                draw(p)
            end)
        else
            draw(player)
        end
    end

    buildPage(1, false)
end

---Entry point called by each NPC's onTrigger handler.
---@param player    CBaseEntity
---@param npc       CBaseEntity  (unused, reserved for future use)
---@param menuTitle string       NPC-specific menu title
---@param lowLvlMsg string       Message shown when player is below minLevel
function xi.htbf.onTrigger(player, npc, menuTitle, lowLvlMsg)
    -- Level requirement
    if player:getMainLvl() < minLevel then
        player:printToPlayer(lowLvlMsg, xi.msg.channel.NS_SAY)
        return
    end

    showMenu(player, menuTitle)
end
