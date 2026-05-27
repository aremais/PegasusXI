local ID = zones[xi.zone.QUICKSAND_CAVES]

local function onPlateTrigger(player, npc)
    local door = GetNPCByID(npc:getID() - 1)
    player:messageText(door or npc, ID.text.DOOR_FIRMLY_SHUT)
end

local ornateDoors =
{
    '_5s0', '_5s1', '_5s2', '_5s3', '_5s4', '_5s5', '_5s6', '_5s7',
    '_5s8', '_5s9', '_5sa', '_5sb', '_5sc',
}

local actions =
{
    ['blank']             = onPlateTrigger,
    ['qm_amk']            = { messageSpecial = ID.text.NOTHING_OUT_OF_ORDINARY },
    ['qm2']               = { messageSpecial = ID.text.NOTHING_OUT_OF_ORDINARY },
    ['qm3']               = { messageSpecial = ID.text.NOTHING_OUT_OF_ORDINARY },
    ['qm4']               = { messageSpecial = ID.text.YOU_FIND_NOTHING_OUT },
    ['qm5']               = { messageSpecial = ID.text.NOTHING_OUT_OF_ORDINARY },
    ['qm6']               = { messageSpecial = ID.text.ANCIENT_LETTERS_UNREAD },
    ['qm7']               = { messageSpecial = ID.text.SOMETHING_IS_BURIED },
    ['Fountain_of_Kings'] = { messageSpecial = ID.text.POOL_OF_WATER },
}

for _, doorName in ipairs(ornateDoors) do
    actions[doorName] = { text = ID.text.DOOR_FIRMLY_SHUT }
end

return actions
