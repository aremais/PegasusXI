-----------------------------------
-- New characters: PegasusXI linkpearl equipped to LS2.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/player')
-----------------------------------
local m = Module:new('new_player_linkshell')

local lsName = 'PegasusXI'

m:addOverride('xi.player.charCreate', function(player)
    super(player)

    if not player:addLinkpearl(lsName, true) then
        printf('new_player_linkshell: addLinkpearl failed for %s (missing linkshell "%s" in DB, or duplicate setup?)',
            player:getName(), lsName)
    end
end)

return m
