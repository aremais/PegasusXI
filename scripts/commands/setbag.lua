-----------------------------------
-- func: setbag <size> (player)
-- desc: Sets the Gobbiebag size for the target player (or self) and marks the
--       matching Gobbiebag Part I-X quests complete/incomplete to match -- the
--       same logic as the stock command, but able to target a player by name.
--       Place in: scripts/commands/setbag.lua  (replaces the self-only version)
-----------------------------------
---@type TCommand
local commandObj = {}

local bagparam =
{
    { bagsize = 30, questid = xi.quest.id.jeuno.THE_GOBBIEBAG_PART_I    },
    { bagsize = 35, questid = xi.quest.id.jeuno.THE_GOBBIEBAG_PART_II   },
    { bagsize = 40, questid = xi.quest.id.jeuno.THE_GOBBIEBAG_PART_III  },
    { bagsize = 45, questid = xi.quest.id.jeuno.THE_GOBBIEBAG_PART_IV   },
    { bagsize = 50, questid = xi.quest.id.jeuno.THE_GOBBIEBAG_PART_V    },
    { bagsize = 55, questid = xi.quest.id.jeuno.THE_GOBBIEBAG_PART_VI   },
    { bagsize = 60, questid = xi.quest.id.jeuno.THE_GOBBIEBAG_PART_VII  },
    { bagsize = 65, questid = xi.quest.id.jeuno.THE_GOBBIEBAG_PART_VIII },
    { bagsize = 70, questid = xi.quest.id.jeuno.THE_GOBBIEBAG_PART_IX   },
    { bagsize = 75, questid = xi.quest.id.jeuno.THE_GOBBIEBAG_PART_X    },
    { bagsize = 80, questid = nil                                       },
}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'is'
}

local function error(player, msg)
    player:printToPlayer(msg)
    player:printToPlayer('!setbag <30-80, multiple of 5> (player)')
end

commandObj.onTrigger = function(player, bagsize, target)
    -- validate size
    if bagsize == nil or bagsize < 30 or bagsize > 80 or (bagsize % 5 ~= 0) then
        error(player, 'Invalid bag size.')
        return
    end

    -- target defaults to self
    local targ
    if target == nil then
        targ = player
    else
        targ = GetPlayerByName(target)
        if targ == nil then
            error(player, string.format('Player named "%s" not found!', target))
            return
        end
    end

    local currentBagSize = targ:getContainerSize(xi.inv.INVENTORY)
    local adjustment = bagsize - currentBagSize

    -- mark Gobbiebag quests complete/incomplete to match the chosen size
    for i = 1, 10 do
        if bagsize > bagparam[i].bagsize then
            targ:completeQuest(xi.questLog.JEUNO, bagparam[i].questid)
        else
            targ:delQuest(xi.questLog.JEUNO, bagparam[i].questid)
        end
    end

    -- resize inventory + mog satchel
    targ:changeContainerSize(xi.inv.INVENTORY, adjustment)
    targ:changeContainerSize(xi.inv.MOGSATCHEL, adjustment)

    player:printToPlayer(string.format('%s bag size: %u -> %u', targ:getName(), currentBagSize, bagsize))
    if targ ~= player then
        targ:printToPlayer(string.format('Your bag size has been set to %u (zone or relog to refresh).', bagsize))
    end
end

return commandObj
