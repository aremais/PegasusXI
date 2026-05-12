-----------------------------------
-- Domain Invasion helpers
-----------------------------------

xi = xi or {}
xi.domainInvasion = xi.domainInvasion or {}

xi.domainInvasion.baseReward = 10
xi.domainInvasion.dailyCap = 80
xi.domainInvasion.rewardRange = 120
xi.domainInvasion.rotationDuration = 30 * 60
xi.domainInvasion.elvorsealDuration = 30 * 60
xi.domainInvasion.explanationCost = 10

xi.domainInvasion.rotation =
{
    [1] =
    {
        zoneId = xi.zone.ESCHA_ZITAH,
        zoneName = "Escha - Zi'Tah",
        npcName = 'Affi',
        mobName = 'Azi Dahaka',
        mobId = 17957397,
        explanationVar = '[DI]AffiExplained',
        x = -12.000,
        y = -0.425,
        z = 24.500,
        rotation = 192,
    },

    [2] =
    {
        zoneId = xi.zone.ESCHA_RUAUN,
        zoneName = "Escha - Ru'Aun",
        npcName = 'Dremi',
        mobName = 'Naga Raja',
        mobId = 17961638,
        explanationVar = '[DI]DremiExplained',
        x = -10.000,
        y = -44.099,
        z = -220.000,
        rotation = 64,
    },

    [3] =
    {
        zoneId = xi.zone.REISENJIMA,
        zoneName = 'Reisenjima',
        npcName = 'Shiftrix',
        mobName = 'Quetzalcoatl',
        mobId = 17969868,
        explanationVar = '[DI]ShiftrixExplained',
        x = 605.200,
        y = -372.000,
        z = -957.800,
        rotation = 225,
    },
}

local function distanceSquared(player, mob)
    local dx = player:getXPos() - mob:getXPos()
    local dy = player:getYPos() - mob:getYPos()
    local dz = player:getZPos() - mob:getZPos()

    return dx * dx + dy * dy + dz * dz
end

xi.domainInvasion.getActiveIndex = function()
    return math.floor(os.time() / xi.domainInvasion.rotationDuration) % #xi.domainInvasion.rotation + 1
end

xi.domainInvasion.getActiveEntry = function()
    return xi.domainInvasion.rotation[xi.domainInvasion.getActiveIndex()]
end

xi.domainInvasion.messageZonePlayers = function(zoneId, message)
    local zone = GetZone(zoneId)

    if zone == nil then
        return
    end

    for _, player in pairs(zone:getPlayers()) do
        player:printToPlayer(message, xi.msg.channel.NS_SHOUT)
    end
end

xi.domainInvasion.announceActiveWindow = function()
    local activeIndex = xi.domainInvasion.getActiveIndex()
    local lastAnnouncedIndex = GetServerVariable('[DI]LastAnnouncedWindow')

    if lastAnnouncedIndex == activeIndex then
        return
    end

    SetServerVariable('[DI]LastAnnouncedWindow', activeIndex)

    local activeEntry = xi.domainInvasion.rotation[activeIndex]
    local message = string.format(
        '[Domain Invasion] %s is currently active in %s. Speak with %s to participate.',
        activeEntry.mobName,
        activeEntry.zoneName,
        activeEntry.npcName
    )

    for _, entry in pairs(xi.domainInvasion.rotation) do
        xi.domainInvasion.messageZonePlayers(entry.zoneId, message)
    end
end

xi.domainInvasion.spawnMobIfMissing = function(mobId)
    local mob = GetMobByID(mobId)

    if mob ~= nil and not mob:isSpawned() then
        SpawnMob(mobId)
    end
end

xi.domainInvasion.grantElvorseal = function(player)
    if not player:hasStatusEffect(xi.effect.ELVORSEAL) then
        player:addStatusEffect(xi.effect.ELVORSEAL, {
            duration = xi.domainInvasion.elvorsealDuration,
            origin = player,
        })
    end
end

xi.domainInvasion.handleExplanation = function(player, entry)
    if player:getCharVar(entry.explanationVar) == 1 then
        return true
    end

    local silt = player:getCurrency('escha_silt') or 0

    if silt < xi.domainInvasion.explanationCost then
        player:printToPlayer(string.format(
            '%s requires %u escha silt before explaining Domain Invasion.',
            entry.npcName,
            xi.domainInvasion.explanationCost
        ))

        return false
    end

    player:delCurrency('escha_silt', xi.domainInvasion.explanationCost)
    player:setCharVar(entry.explanationVar, 1)
    xi.domainInvasion.grantElvorseal(player)

    player:printToPlayer(string.format(
        '%s accepts %u escha silt and grants you an Elvorseal.',
        entry.npcName,
        xi.domainInvasion.explanationCost
    ))

    return true
end

xi.domainInvasion.enterBattlefield = function(player, requestedIndex)
    if player:getMainLvl() < 99 then
        player:printToPlayer('You must be level 99 to participate in Domain Invasion.')
        return
    end

    local requestedEntry = xi.domainInvasion.rotation[requestedIndex]

    if requestedEntry == nil then
        return
    end

    if not xi.domainInvasion.handleExplanation(player, requestedEntry) then
        return
    end

    xi.domainInvasion.grantElvorseal(player)
    xi.domainInvasion.announceActiveWindow()

    local activeIndex = xi.domainInvasion.getActiveIndex()
    local activeEntry = xi.domainInvasion.rotation[activeIndex]

    if requestedIndex ~= activeIndex then
        player:printToPlayer(string.format(
            'Domain Invasion is currently active in %s. Speak with %s.',
            activeEntry.zoneName,
            activeEntry.npcName
        ))

        return
    end

    xi.domainInvasion.spawnMobIfMissing(activeEntry.mobId)

    player:printToPlayer(string.format(
        '%s grants you passage to the Domain Invasion battlefield.',
        activeEntry.npcName
    ))

    player:setPos(activeEntry.x, activeEntry.y, activeEntry.z, activeEntry.rotation)
end

xi.domainInvasion.awardDomainPoints = function(mob, title)
    local zone = mob:getZone()

    if zone == nil then
        return
    end

    local players = zone:getPlayers()
    local rewardRangeSquared = xi.domainInvasion.rewardRange * xi.domainInvasion.rewardRange

    for _, player in pairs(players) do
        if
            player:getMainLvl() >= 99 and
            distanceSquared(player, mob) <= rewardRangeSquared
        then
            local dailyPoints = player:getCurrency('domain_points_daily') or 0
            local totalPoints = player:getCurrency('domain_points') or 0

            if dailyPoints < xi.domainInvasion.dailyCap then
                local reward = math.min(xi.domainInvasion.baseReward, xi.domainInvasion.dailyCap - dailyPoints)

                player:addCurrency('domain_points', reward)
                player:addCurrency('domain_points_daily', reward)

                if title ~= nil then
                    player:addTitle(title)
                end

                player:printToPlayer(string.format(
                    'You earned %u Domain Point%s. Daily total: %u/%u. Current total: %u.',
                    reward,
                    reward == 1 and '' or 's',
                    dailyPoints + reward,
                    xi.domainInvasion.dailyCap,
                    totalPoints + reward
                ))
            else
                player:printToPlayer(string.format(
                    "You have reached today's Domain Point limit. Daily total: %u/%u. Current total: %u.",
                    dailyPoints,
                    xi.domainInvasion.dailyCap,
                    totalPoints
                ))
            end
        end
    end
end
