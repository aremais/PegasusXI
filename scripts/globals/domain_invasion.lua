-----------------------------------
-- Domain Invasion helpers
-----------------------------------

xi = xi or {}
xi.domainInvasion = xi.domainInvasion or {}

xi.domainInvasion.baseReward = 10
xi.domainInvasion.dailyCap = 80
xi.domainInvasion.rewardRange = 120

local function distanceSquared(player, mob)
    local dx = player:getXPos() - mob:getXPos()
    local dy = player:getYPos() - mob:getYPos()
    local dz = player:getZPos() - mob:getZPos()

    return dx * dx + dy * dy + dz * dz
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

xi.domainInvasion.spawnMobIfMissing = function(mobId)
    local mob = GetMobByID(mobId)

    if mob ~= nil and not mob:isSpawned() then
        SpawnMob(mobId)
    end
end
