-----------------------------------
-- New characters: PegasusXI linkpearl equipped to LS2.
-- Aremais: one-time grant of physical linkshell (owner item) on LS1 when `linkshells` row exists.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/player')
-----------------------------------
local m = Module:new('new_player_linkshell')

local lsName       = 'PegasusXI'
local ownerCharVar = 'PEGASUSXI_SHELL_OWNER' -- set when Aremais has received the holder item

m:addOverride('xi.player.charCreate', function(player)
    super(player)

    if not player:addLinkpearl(lsName, true) then
        printf('new_player_linkshell: addLinkpearl failed for %s (missing linkshell "%s" in DB, or duplicate setup?)',
            player:getName(), lsName)
    end
end)

m:addOverride('xi.player.onGameIn', function(player, firstLogin, zoning)
    super(player, firstLogin, zoning)

    if zoning or player:getCharVar(ownerCharVar) ~= 0 then
        return
    end

    if player:getName() == 'Aremais' then
        if player:addLinkshellHolder(lsName, 1) then
            player:setCharVar(ownerCharVar, 1)
        else
            printf('new_player_linkshell: addLinkshellHolder failed for Aremais (LS missing, inventory full, or already holds a rare linkshell item).')
        end
    end
end)

return m
