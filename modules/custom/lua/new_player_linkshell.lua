-----------------------------------
-- New characters: PegasusXI linkpearl equipped to LS2.
-- Requires: (1) this file listed in modules/init.txt, (2) a row in `linkshells` with
--   name = PegasusXI and broken = 0, (3) map server restart after init.txt changes.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/player')
-----------------------------------
local m = Module:new('new_player_linkshell')

local lsName = 'PegasusXI'

m:addOverride('xi.player.charCreate', function(player)
    -- Run default creation first so inventory/gear exist before the pearl.
    super(player)

    if not player:addLinkpearl(lsName, true) then
        printf('new_player_linkshell: addLinkpearl failed for %s (missing or broken linkshell "%s" in `linkshells`?)',
            player:getName(), lsName)
    end
end)

return m
