-----------------------------------
-- func: aremais
-- desc: One-shot GM setup package for a target player.
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 4,
    parameters = "s"
}

local function msg(player, text)
    player:printToPlayer(text, xi.msg.channel.SYSTEM_3)
end

local function getTarget(player, targetName)
    if targetName == nil or targetName == "" then
        return player
    end

    local targ = GetPlayerByName(targetName)
    if not targ then
        player:printToPlayer(string.format('Player named "%s" not found.', targetName))
        return nil
    end

    return targ
end

local function setContainerToSize(player, containerId, desiredSize)
    local current = player:getContainerSize(containerId)
    if current < desiredSize then
        player:changeContainerSize(containerId, desiredSize - current)
    end
end

local function enableGodMode(targ)
    local state = targ:getCharVar("GodMode")
    if state == 1 then
        return
    end

    -- If Tier 1 was active, clear those effects before switching to full god mode.
    if state == 2 then
        targ:delStatusEffect(xi.effect.MAX_HP_BOOST)
        targ:delStatusEffect(xi.effect.REGAIN)
        targ:delStatusEffect(xi.effect.REFRESH)
        targ:delStatusEffect(xi.effect.REGEN)
        targ:delStatusEffect(xi.effect.CHAINSPELL)
        targ:delStatusEffect(xi.effect.MANAFONT)
    end

    targ:setCharVar("GodMode", 1)

    targ:addStatusEffect(xi.effect.MAX_HP_BOOST, { power = 1000, origin = targ })
    targ:addStatusEffect(xi.effect.MAX_MP_BOOST, { power = 1000, origin = targ })
    targ:addStatusEffect(xi.effect.MIGHTY_STRIKES, { power = 1, origin = targ })
    targ:addStatusEffect(xi.effect.HUNDRED_FISTS, { power = 1, origin = targ })
    targ:addStatusEffect(xi.effect.CHAINSPELL, { power = 1, origin = targ })
    targ:addStatusEffect(xi.effect.PERFECT_DODGE, { power = 1, origin = targ })
    targ:addStatusEffect(xi.effect.INVINCIBLE, { power = 1, origin = targ })
    targ:addStatusEffect(xi.effect.ELEMENTAL_SFORZO, { power = 1, origin = targ })
    targ:addStatusEffect(xi.effect.MANAFONT, { power = 1, origin = targ })
    targ:addStatusEffect(xi.effect.REGAIN, { power = 300, origin = targ })
    targ:addStatusEffect(xi.effect.REFRESH, { power = 99, origin = targ })
    targ:addStatusEffect(xi.effect.REGEN, { power = 99, origin = targ })

    targ:addMod(xi.mod.RACC, 2500)
    targ:addMod(xi.mod.RATT, 2500)
    targ:addMod(xi.mod.ACC, 2500)
    targ:addMod(xi.mod.ATT, 2500)
    targ:addMod(xi.mod.MATT, 2500)
    targ:addMod(xi.mod.MACC, 2500)
    targ:addMod(xi.mod.RDEF, 2500)
    targ:addMod(xi.mod.DEF, 2500)
    targ:addMod(xi.mod.MDEF, 2500)

    targ:addHP(50000)
    targ:setMP(50000)
end

commandObj.onTrigger = function(player, targetName)
    local targ = getTarget(player, targetName)
    if not targ then
        return
    end

    require('scripts/globals/player_job_levels')

    local name = targ:getName()
    msg(player, string.format('Running @aremais package for %s...', name))

    -- Unlock all jobs + subjob (job 0 grants support-job access).
    for jobId = 0, xi.MAX_JOB_TYPE - 1 do
        targ:unlockJob(jobId)
    end

    -- Mirror !unlocksubjob quest completion so the client treats subjob as unlocked.
    targ:completeQuest(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.ELDER_MEMORIES)

    -- Set all job levels to 99.
    local ok, levelMsg = xi.player_job_levels.setAllJobLevels(targ, 99)
    if not ok then
        msg(player, levelMsg or 'Could not set all job levels.')
        return
    end

    -- Gil.
    targ:setGil(999999999)

    -- Fame.
    local fameBaseValues = { 0, 50, 125, 225, 325, 425, 488, 550, 613 }
    local fameMultiplier = xi.settings.map.FAME_MULTIPLIER
    for fameZone = 0, 15 do
        local maxLevel = (fameZone >= 6 and fameZone <= 14) and 6 or 9
        targ:setFame(fameZone, fameBaseValues[maxLevel] / fameMultiplier)
    end

    -- Teleport crystals.
    local gateCrystals =
    {
        xi.ki.HOLLA_GATE_CRYSTAL,
        xi.ki.DEM_GATE_CRYSTAL,
        xi.ki.MEA_GATE_CRYSTAL,
        xi.ki.VAHZL_GATE_CRYSTAL,
        xi.ki.YHOATOR_GATE_CRYSTAL,
        xi.ki.ALTEPA_GATE_CRYSTAL,
        xi.ki.JUGNER_GATE_CRYSTAL,
        xi.ki.PASHHOW_GATE_CRYSTAL,
        xi.ki.MERIPHATAUD_GATE_CRYSTAL,
    }
    for _, ki in ipairs(gateCrystals) do
        targ:addKeyItem(ki)
    end

    -- All outpost warps.
    local nations = { xi.nation.SANDORIA, xi.nation.BASTOK, xi.nation.WINDURST }
    for _, nation in ipairs(nations) do
        for region = xi.region.RONFAURE, xi.region.TAVNAZIANARCH do
            targ:addTeleport(nation, region + 5)
        end
    end

    -- All spells and trusts (trusts delayed so their batch timers do not overlap spells).
    if xi.commands.addallspells and type(xi.commands.addallspells.onTrigger) == 'function' then
        msg(player, string.format('Queueing all non-trust spells for %s...', name))
        xi.commands.addallspells.onTrigger(player, name)
    else
        msg(player, 'Warning: !addallspells is unavailable; spells were not unlocked.')
    end

    if xi.commands.addalltrusts and type(xi.commands.addalltrusts.onTrigger) == 'function' then
        -- Spell unlock batches typically finish well under 90s; start trusts after that.
        player:timer(90000, function(playerArg)
            local target = GetPlayerByName(name)
            if target then
                msg(playerArg, string.format('Queueing all trust spells for %s...', name))
                xi.commands.addalltrusts.onTrigger(playerArg, name)
            end
        end)
    else
        msg(player, 'Warning: !addalltrusts is unavailable; trusts were not unlocked.')
    end

    -- All mounts.
    if xi.commands.addallmounts and type(xi.commands.addallmounts.onTrigger) == 'function' then
        xi.commands.addallmounts.onTrigger(player, name)
    else
        msg(player, 'Warning: !addallmounts is unavailable; mounts were not unlocked.')
    end

    -- All attachments.
    if xi.commands.addallattachments and type(xi.commands.addallattachments.onTrigger) == 'function' then
        xi.commands.addallattachments.onTrigger(player, name)
    else
        msg(player, 'Warning: !addallattachments is unavailable; attachments were not unlocked.')
    end

    -- All learned weapon skills.
    for _, wsUnlockId in pairs(xi.wsUnlock) do
        targ:addLearnedWeaponskill(wsUnlockId)
    end

    -- Cap all skills and craft ranks/levels.
    targ:capAllSkills()
    for skillId = xi.skill.FISHING, xi.skill.SYNERGY do
        targ:setSkillRank(skillId, xi.craftRank.LEGEND)
        targ:setSkillLevel(skillId, 700)
    end

    -- Max all char_points currencies (using DB-safe ranges by column size class).
    local maxInt = 999999999
    local maxSmall = 65535
    local maxTiny = 255

    local intCurrencies =
    {
        "sandoria_cp", "bastok_cp", "windurst_cp",
        "beastman_seal", "guild_fishing", "guild_woodworking", "guild_smithing", "guild_goldsmithing",
        "guild_weaving", "guild_leathercraft", "guild_bonecraft", "guild_alchemy", "guild_cooking",
        "cinder", "research_mark", "ballista_point", "fellow_point", "moblin_marble", "legion_point", "spark_of_eminence",
        "shining_star", "imperial_standing", "leujaoam_assault_point", "mamool_assault_point",
        "lebros_assault_point", "periqia_assault_point", "ilrusi_assault_point", "nyzul_isle_assault_point",
        "zeni_point", "jetton", "therion_ichor", "allied_notes", "bayld", "obsidian_fragment",
        "mweya_plasm", "cruor", "resistance_credit", "dominion_note", "traverser_stones", "voidstones",
        "kupofried_corundums", "unity_accolades", "current_accolades", "prev_accolades", "escha_silt",
        "potpourri", "current_hallmarks", "total_hallmarks", "gallantry", "crafter_points",
        "silver_aman_voucher", "domain_points", "domain_points_daily", "mog_segments", "gallimaufry",
        "temenos_units", "apollyon_units",
    }

    local smallCurrencies =
    {
        "daily_tally",
        "kindred_seal", "kindred_crest", "high_kindred_crest", "sacred_kindred_crest", "ancient_beastcoin",
        "valor_point", "scyld", "chocobuck_sandoria", "chocobuck_bastok", "chocobuck_windurst",
        "infamy", "prestige", "aman_vouchers", "login_points", "kinetic_unit", "lebondopt_wing",
        "pulchridopt_wing", "mellidopt_wing", "reclamation_marks", "deeds", "plaudits", "bloodshed_plans", "umbrage_plans",
        "ritualistic_plans", "tutelary_plans", "primacy_plans", "escha_beads",
        "fire_crystals", "ice_crystals", "wind_crystals", "earth_crystals", "lightning_crystals",
        "water_crystals", "light_crystals", "dark_crystals", "is_accolades",
    }

    local tinyCurrencies =
    {
        "fire_fewell", "ice_fewell", "wind_fewell", "earth_fewell", "lightning_fewell", "water_fewell",
        "light_fewell", "dark_fewell", "tunnel_worm", "morion_worm", "phantom_worm",
        "fifth_echelon_trophy", "fourth_echelon_trophy", "third_echelon_trophy", "second_echelon_trophy",
        "first_echelon_trophy", "cave_points", "id_tags", "op_credits", "imprimaturs", "pheromone_sacks",
        "rems_ch1", "rems_ch2", "rems_ch3", "rems_ch4", "rems_ch5", "rems_ch6", "rems_ch7", "rems_ch8",
        "rems_ch9", "rems_ch10", "mystical_canteen", "ghastly_stone", "ghastly_stone_1", "ghastly_stone_2",
        "verdigris_stone", "verdigris_stone_1", "verdigris_stone_2", "wailing_stone", "wailing_stone_1",
        "wailing_stone_2", "snowslit_stone", "snowslit_stone_1", "snowslit_stone_2", "snowtip_stone",
        "snowtip_stone_1", "snowtip_stone_2", "snowdim_stone", "snowdim_stone_1", "snowdim_stone_2",
        "snoworb_stone", "snoworb_stone_1", "snoworb_stone_2", "leafslit_stone", "leafslit_stone_1",
        "leafslit_stone_2", "leaftip_stone", "leaftip_stone_1", "leaftip_stone_2", "leafdim_stone",
        "leafdim_stone_1", "leafdim_stone_2", "leaforb_stone", "leaforb_stone_1", "leaforb_stone_2",
        "duskslit_stone", "duskslit_stone_1", "duskslit_stone_2", "dusktip_stone", "dusktip_stone_1",
        "dusktip_stone_2", "duskdim_stone", "duskdim_stone_1", "duskdim_stone_2", "duskorb_stone",
        "duskorb_stone_1", "duskorb_stone_2", "pellucid_stone", "fern_stone", "taupe_stone",
        "fire_crystal_set", "ice_crystal_set", "wind_crystal_set", "earth_crystal_set", "lightning_crystal_set",
        "water_crystal_set", "light_crystal_set", "dark_crystal_set", "mc_s_sr01_set", "mc_s_sr02_set",
        "mc_s_sr03_set", "liquefaction_spheres_set", "induration_spheres_set", "detonation_spheres_set",
        "scission_spheres_set", "impaction_spheres_set", "reverberation_spheres_set", "transfixion_spheres_set",
        "compression_spheres_set", "fusion_spheres_set", "distortion_spheres_set", "fragmentation_spheres_set",
        "gravitation_spheres_set", "light_spheres_set", "darkness_spheres_set",
    }

    for _, currency in ipairs(intCurrencies) do
        targ:setCurrency(currency, maxInt)
    end
    for _, currency in ipairs(smallCurrencies) do
        targ:setCurrency(currency, maxSmall)
    end
    for _, currency in ipairs(tinyCurrencies) do
        targ:setCurrency(currency, maxTiny)
    end

    -- Traverser stones displayed value is time-derived from traverser epoch in char_unlocks.
    -- Initialize the epoch if needed so stones can accrue/appear correctly.
    if targ:getTraverserEpoch() == 0 then
        targ:setTraverserEpoch()
    end

    -- Max inventory / storage / wardrobes.
    local maxSlots = 80
    setContainerToSize(targ, xi.inv.INVENTORY, maxSlots)
    setContainerToSize(targ, xi.inv.MOGSAFE, maxSlots)
    setContainerToSize(targ, xi.inv.MOGSAFE2, maxSlots)
    setContainerToSize(targ, xi.inv.MOGLOCKER, maxSlots)
    setContainerToSize(targ, xi.inv.MOGSATCHEL, maxSlots)
    setContainerToSize(targ, xi.inv.MOGSACK, maxSlots)
    setContainerToSize(targ, xi.inv.MOGCASE, maxSlots)
    setContainerToSize(targ, xi.inv.WARDROBE, maxSlots)
    setContainerToSize(targ, xi.inv.WARDROBE2, maxSlots)
    setContainerToSize(targ, xi.inv.WARDROBE3, maxSlots)
    setContainerToSize(targ, xi.inv.WARDROBE4, maxSlots)
    setContainerToSize(targ, xi.inv.WARDROBE5, maxSlots)
    setContainerToSize(targ, xi.inv.WARDROBE6, maxSlots)
    setContainerToSize(targ, xi.inv.WARDROBE7, maxSlots)
    setContainerToSize(targ, xi.inv.WARDROBE8, maxSlots)

    -- GM toggle on (visible GM icon/flags).
    targ:setVisibleGMLevel(math.min(7, targ:getGMLevel() + 3))

    -- Immortal on (persistent + active).
    targ:setCharVar('Immortal', 1)
    targ:addStatusEffect(xi.effect.NONE, { origin = targ, icon = xi.effect.TRANSCENDENCY })
    targ:setUnkillable(true)

    -- Godmode on (persistent + active).
    enableGodMode(targ)

    -- Permanent movement speed override (reapplied on zone-in via player.lua).
    targ:setCharVar('AremaisPermMoveSpeed', 100)
    targ:setMod(xi.mod.MOVE_SPEED_OVERRIDE, 100)
    targ:recalculateStats()

    msg(player, string.format('@aremais core setup complete for %s. (Spell/trust unlocks will finish asynchronously.)', name))

    -- Best-effort "fully completed" notice: spells then trusts are queued in batches.
    player:timer(180000, function(playerArg)
        local targ2 = GetPlayerByName(name)
        if targ2 then
            msg(playerArg, string.format('@aremais command run finished for %s (queued batches should be complete by now).', name))
        end
    end)
end

return commandObj
