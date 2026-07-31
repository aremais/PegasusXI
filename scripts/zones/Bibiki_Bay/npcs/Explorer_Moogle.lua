-----------------------------------
-- Area: Bibiki Bay
-- NPC: Explorer Moogle (custom menu version)
-- Notes:
--  - This does NOT use zone cutscenes/events.
--  - Provides a real selectable menu server-side.
-----------------------------------

---@type TNpcEntity
local entity = {}

local price = 300

-- These match your scripts/globals/teleports.lua explorer moogle destinations:
-- 243, 231, 234, 240, 248, 249
local destinations =
{
    { label = 'Ru\'Lude Gardens',       zone = 243 },
    { label = 'Southern San d\'Oria', zone = 231 },
    { label = 'Bastok Markets',       zone = 234 },
    { label = 'Port Windurst',        zone = 240 },
    { label = 'Selbina',              zone = 248 },
    { label = 'Mhaura',               zone = 249 },
}

local function canUseExplorerMoogle(player)
    local minLv = xi.settings.main.EXPLORER_MOOGLE_LV or 1
    if player:getMainLvl() < minLv then
        player:printToPlayer(string.format('You must be level %u or higher to use this service.', minLv))
        return false
    end

    if player:getGil() < price then
        player:printToPlayer(string.format('You need %u gil.', price))
        return false
    end

    return true
end

local function openExplorerMenu(player)
    -- Build a menu using the same custom-menu system your server already has (commands/menu.lua).
    local menu =
    {
        title = string.format('Explorer Moogle (%u gil)', price),
        options = {},
    }

    for _, dest in ipairs(destinations) do
        table.insert(menu.options, {
            dest.label,
            function(p)
                if not canUseExplorerMoogle(p) then
                    return
                end

                if p:delGil(price) then
                    xi.teleport.toExplorerMoogle(p, dest.zone)
                else
                    p:printToPlayer(string.format('You need %u gil.', price))
                end
            end
        })
    end

    table.insert(menu.options, {
        'Cancel',
        function(_)
        end,
    })

    player:customMenu(menu)
end

entity.onTrigger = function(player, npc)
    openExplorerMenu(player)
end

return entity
