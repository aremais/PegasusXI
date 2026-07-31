-----------------------------------
-- Maiden of the Dusk
-- Wings of the Goddess mission (MAIDEN_OF_THE_DUSK): Ornate Door _521
-- Requires: Mission charvar Status == 3, key item PRIMAL_GLOW (removed on entry)
-- !addmission 5 50
-- !setplayervar Mission[5][50]Status 3
-- !addkeyitem PRIMAL_GLOW
-----------------------------------
require('scripts/globals/interaction/mission')

local ID = zones[xi.zone.WALK_OF_ECHOES]

local maidenMission = Mission:new(xi.mission.log_id.WOTG, xi.mission.id.wotg.MAIDEN_OF_THE_DUSK)

local gyveMobs = {}
for i = 0, 9 do
    table.insert(gyveMobs, ID.mob.ELEMENTAL_GYVES_OFFSET + i)
end

local phaseOneMobs = {}
for _, mobId in ipairs(gyveMobs) do
    table.insert(phaseOneMobs, mobId)
end

table.insert(phaseOneMobs, ID.mob.LADY_LILITH)

local content = Battlefield:new({
    zoneId           = xi.zone.WALK_OF_ECHOES,
    battlefieldId    = xi.battlefield.id.MAIDEN_OF_THE_DUSK,
    isMission        = true,
    allowTrusts      = true,
    maxPlayers       = 6,
    levelCap         = 0,
    timeLimit        = utils.minutes(30),
    index            = 0,
    entryNpc         = '_521',
    exitNpcs         = { '_524' },
    canLoseExp       = false,
    requiredKeyItems = { xi.ki.PRIMAL_GLOW },
})

function content:entryRequirement(player, npc, isRegistrant, trade)
    if player:getCurrentMission(xi.mission.log_id.WOTG) ~= xi.mission.id.wotg.MAIDEN_OF_THE_DUSK then
        return false
    end

    if maidenMission:getVar(player, 'Status') ~= 3 then
        return false
    end

    return true
end

content.groups =
{
    {
        mobIds   = phaseOneMobs,
        isParty  = true,
        allDeath = function(battlefield, mob)
            local ascendant = GetMobByID(ID.mob.LILITH_ASCENDANT)
            if ascendant == nil or ascendant:isSpawned() then
                return
            end

            ascendant:spawn()
            local players = battlefield:getPlayers()
            local _, first = next(players)
            if first then
                ascendant:updateEnmity(first)
            end
        end,
    },

    {
        mobIds   = { ID.mob.LILITH_ASCENDANT },
        spawned  = false,
        death    = function(battlefield, mob)
            battlefield:setStatus(xi.battlefield.status.WON)
        end,
    },
}

return content:register()
