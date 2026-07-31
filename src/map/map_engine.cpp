/*
===========================================================================

  Copyright (c) 2010-2015 Darkstar Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see http://www.gnu.org/licenses/

===========================================================================
*/

#include "map_engine.h"

#include "common/blowfish.h"
#include "common/console_service.h"
#include "common/database.h"
#include "common/debug.h"
#include "common/ipp.h"
#include "common/logging.h"
#include "common/macros.h"
#include "common/settings.h"
#include "common/timer.h"
#include "common/utils.h"
#include "common/vana_time.h"
#include "common/version.h"
#include "common/zlib.h"

#include "ability.h"
#include "daily_system.h"
#include "ipc_client.h"
#include "lua/luautils.h"
#include "job_points.h"
#include "latent_effect_container.h"
#include "map_networking.h"
#include "map_statistics.h"
#include "mob_spell_list.h"
#include "monstrosity.h"
#include "roe.h"
#include "spell.h"
#include "status_effect_container.h"
#include "time_server.h"
#include "transport.h"
#include "zone.h"
#include "zone_entities.h"

#include "ai/controllers/automaton_controller.h"

#include "items/item_equipment.h"

#include "packets/s2c/0x017_chat_std.h"

#include "utils/battleutils.h"
#include "utils/charutils.h"
#include "utils/fishingutils.h"
#include "utils/gardenutils.h"
#include "utils/guildutils.h"
#include "utils/instanceutils.h"
#include "utils/itemutils.h"
#include "utils/mobutils.h"
#include "utils/moduleutils.h"
#include "utils/petutils.h"
#include "utils/serverutils.h"
#include "utils/synergyutils.h"
#include "utils/synthutils.h"
#include "utils/trustutils.h"
#include "utils/zoneutils.h"

#include "linkshell.h"

#include <array>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <thread>

#ifdef _WIN32
#include <io.h>
#endif

MapEngine::MapEngine(Application& application, MapConfig& config)
: application_(application)
, scheduler_(application_.scheduler())
, mapStatistics_(std::make_unique<MapStatistics>())
, networking_(std::make_unique<MapNetworking>(scheduler_, *mapStatistics_, config))
, config_(config)
{
}

MapEngine::~MapEngine()
{
    itemutils::FreeItemList();
    battleutils::FreeWeaponSkillsList();
    battleutils::FreeMobSkillList();
    battleutils::FreePetSkillList();
    fishingutils::CleanupFishing();
    guildutils::Cleanup();
    mobutils::Cleanup();
    traits::ClearTraitsList();

    petutils::FreePetList();
    zoneutils::FreeZoneList();

    luautils::cleanup();
}

auto MapEngine::init() -> Task<void>
{
    TracyZoneScoped;

#ifdef TRACY_ENABLE
    ShowInfo("*** TRACY IS ENABLED ***");
#endif // TRACY_ENABLE

    ShowInfo(fmt::format("Last Branch: {}", version::GetGitBranch()));
    ShowInfo(fmt::format("SHA: {} ({})", version::GetGitSha(), version::GetGitDate()));

    ShowInfo("do_init: begin server initialization");

    const auto mapIPP = networking_->ipp();

    ShowInfoFmt("map_ip: {}", mapIPP.getIPString());
    ShowInfoFmt("map_port: {}", mapIPP.getPort());

    ShowInfoFmt("Zones assigned to this process: {}", zoneutils::GetZonesAssignedToThisProcess(mapIPP).size());

    ShowInfo(fmt::format("Random samples (integer): {}", utils::getRandomSampleString(0, 255)));
    ShowInfo(fmt::format("Random samples (float): {}", utils::getRandomSampleString(0.0f, 1.0f)));

    ShowInfo("do_init: connecting to database");
    ShowInfo(fmt::format("database name: {}", db::getDatabaseSchema()).c_str());
    ShowInfo(fmt::format("database server version: {}", db::getDatabaseVersion()).c_str());
    ShowInfo(fmt::format("database client version: {}", db::getDriverVersion()).c_str());

    if (!config_.inCI)
    {
        db::checkCharset();
    }

    db::checkTriggers();

    luautils::init(mapIPP, config_.inCI); // Also calls moduleutils::LoadLuaModules();
    luautils::setMapScheduler(&scheduler_);

    // Delete sessions that are associated with this map process, but leave others alone
    db::preparedStmt("DELETE FROM accounts_sessions WHERE IF(? = 0 AND ? = 0, true, server_addr = ? AND server_port = ?)",
                     mapIPP.getIP(),
                     mapIPP.getPort(),
                     mapIPP.getIP(),
                     mapIPP.getPort());

    ShowInfo("do_init: zlib is reading");
    zlib_init();

    ShowInfo("do_init: starting ZMQ thread");
    message::init(networking());

    ShowInfo("do_init: loading items");
    itemutils::Initialize();

    ShowInfo("do_init: loading plants");
    gardenutils::Initialize();

    ShowInfo("do_init: loading spells");
    spell::LoadSpellList();
    mobSpellList::LoadMobSpellList();
    automaton::LoadAutomatonSpellList();
    automaton::LoadAutomatonAbilities();

    guildutils::Initialize();
    charutils::LoadExpTable();
    traits::LoadTraitsList();
    effects::LoadEffectsParameters();
    battleutils::LoadSkillTable();
    meritNameSpace::LoadMeritsList();
    ability::LoadAbilitiesList();
    battleutils::LoadWeaponSkillsList();
    battleutils::LoadMobSkillsList();
    battleutils::LoadPetSkillsList();
    battleutils::LoadSkillChainDamageModifiers();
    petutils::LoadPetList();
    trustutils::LoadTrustList();
    mobutils::LoadSqlModifiers();
    jobpointutils::LoadGifts();
    daily::LoadDailyItems();
    roeutils::UpdateUnityRankings();
    synthutils::LoadSynthRecipes();
    synergyutils::LoadSynergyRecipes();
    CItemEquipment::LoadAugmentData(); // TODO: Move to itemutils

    if (!std::filesystem::exists("./ximeshes/") || std::filesystem::is_empty("./ximeshes/"))
    {
        ShowError("./ximeshes/ directory isn't present or is empty");
    }

    if (!std::filesystem::exists("./navmeshes/") || std::filesystem::is_empty("./navmeshes/"))
    {
        ShowWarning("./navmeshes/ directory isn't present or is empty");
    }

    co_await zoneutils::Initialize(scheduler_, config_);
    zoneutils::SetLoginZoneLoadContext(&scheduler_, &config_);
    instanceutils::Initialize(config_);

    if (!config_.lazyZones)
    {
        CTransportHandler::getInstance()->InitializeTransport(mapIPP);
    }

    fishingutils::InitializeFishingSystem();

    monstrosity::LoadStaticData();

    if (!config_.controlledWeather)
    {
        zoneutils::InitializeWeather(); // Need VanaTime initialized
    }

    //
    // Queue up regular tasks for the Scheduler
    //

    if (!config_.isTestServer)
    {
        mapCleanupToken_        = scheduler_.intervalOnMainThread(kSessionCleanupInterval, std::bind(&MapEngine::sessionCleanup, this));
        mapGarbageCollectToken_ = scheduler_.intervalOnMainThread(kGarbageCollectionInterval, std::bind(&MapEngine::garbageCollect, this));

        timeServerToken_ = scheduler_.intervalOnMainThread(
            kTimeServerTickInterval,
            [this]() -> Task<void>
            {
                co_await time_server(scheduler_, config_);
            });

        persistVolatileServerVarsToken_ = scheduler_.intervalOnMainThread(kPersistVolatileServerVarsInterval, serverutils::PersistVolatileServerVars);
        pumpIPCToken_                   = scheduler_.intervalOnMainThread(kIPCPumpInterval, message::handle_incoming);
        flushStatisticsToken_           = scheduler_.intervalOnMainThread(kTimeServerTickInterval, std::bind(&MapNetworking::flushStatistics, networking_.get()));
    }

    zoneutils::TOTDChange(vanadiel_time::get_totd()); // This tells the zones to spawn stuff based on time of day conditions (such as undead at night)

    ShowInfo("do_init: Removing expired database variables");
    uint32 currentTimestamp = earth_time::timestamp();
    db::preparedStmt("DELETE FROM char_vars WHERE expiry > 0 AND expiry <= ?", currentTimestamp);
    db::preparedStmt("DELETE FROM server_variables WHERE expiry > 0 AND expiry <= ?", currentTimestamp);

    moduleutils::OnInit();

    luautils::OnServerStart();

    if (!config_.isTestServer)
    {
        moduleutils::ReportLuaModuleUsage();
    }

    db::enableTimers();

    //
    // Set up the watchdog tasks
    //

    if (!config_.isTestServer)
    {
        scheduler_.postToMainThread(watchdogUpdater());
        scheduler_.postToWorkerThread(watchdogWatcher());
    }

#ifdef TRACY_ENABLE
    ShowInfo("*** TRACY IS ENABLED ***");
#endif // TRACY_ENABLE

    //
    // At this point, the scheduler is loaded up with all the tasks it will need
    // to run everything.
    //

    application_.markLoaded();
}

auto MapEngine::watchdogUpdater() -> Task<void>
{
    // Run "forever"
    while (!scheduler_.closeRequested())
    {
        // If something manages to block the main thread, this task won't be run, and the watcher
        // will kill the server from a worker thread.
        // We do this because if the main thread is blocked severely enough to trigger the watchdog,
        // your server is degraded - likely beyond repair.
        watchdogLastUpdate_ = timer::now();
        co_await scheduler_.yieldFor(kMainThreadBacklogThreshold);
    }
}

auto MapEngine::watchdogWatcher() -> Task<void>
{
    auto period = settings::get<uint32>("main.INACTIVITY_WATCHDOG_PERIOD");

    if (config_.inCI)
    {
        // Double the timer period, to account for the slower CI environment
        period *= 2;
    }

    const auto periodMs = (period > 0) ? std::chrono::milliseconds(period) : 2000ms;

    watchdogLastUpdate_ = timer::now();

    // Run "forever"
    while (!scheduler_.closeRequested())
    {
        const auto lastUpdate = watchdogLastUpdate_.load();
        if ((timer::now() - lastUpdate) >= periodMs)
        {
            if (debug::isRunningUnderDebugger())
            {
                ShowCriticalFmt("!!! INACTIVITY WATCHDOG HAS TRIGGERED !!!");
                ShowCriticalFmt("Process main tick has taken {}ms or more.", period);
                ShowCriticalFmt("Detaching watchdog thread, it will not fire again until restart.");
                break;
            }
            else if (!settings::get<bool>("main.DISABLE_INACTIVITY_WATCHDOG"))
            {
                ShowCriticalFmt("!!! INACTIVITY WATCHDOG HAS TRIGGERED !!!");
                ShowCriticalFmt("Process main tick has taken {}ms or more.", period);
                ShowCriticalFmt("Killing Process!!!");

                // Allow some time for logging to flush
                std::this_thread::sleep_for(200ms);

                // Terminate directly rather than throwing.
                crash();
            }
        }

        co_await scheduler_.yieldFor(periodMs);
    }
}

void MapEngine::sessionCleanup() const
{
    TracyZoneScoped;

    networking().sessions().cleanupSessions(networking().ipp());

    zoneutils::ForEachZone(
        [](CZone* PZone)
        {
            PZone->GetZoneEntities()->EraseStaleDynamicTargIDs();
        });
}

void MapEngine::garbageCollect() const
{
    TracyZoneScoped;

    luautils::garbageCollectFull();
}

void MapEngine::onStats(std::vector<std::string>& inputs) const
{
    mapStatistics_->print();
}

void MapEngine::onBacktrace(std::vector<std::string>& inputs) const
{
    const auto backtrace = logging::GetBacktrace();
    for (const auto& line : backtrace)
    {
        fmt::print("{}\n", line);
    }
}

void MapEngine::onReloadRecipes(std::vector<std::string>& inputs) const
{
    fmt::print("> Reloading crafting recipes\n");
    synthutils::LoadSynthRecipes();
}

void MapEngine::onGM(const std::vector<std::string>& inputs) const
{
    if (inputs.size() != 3)
    {
        fmt::print("Usage: gm <char_name> <level>. example: gm Testo 1\n");
        return;
    }

    const auto& name  = inputs[1];
    auto*       PChar = zoneutils::GetCharByName(name);
    if (!PChar)
    {
        fmt::print("Couldnt find character: {}\n", name);
        return;
    }

    const auto level = std::clamp<uint8>(static_cast<uint8>(stoi(inputs[2])), 0, 5);

    PChar->m_GMlevel = level;

    charutils::SaveCharGMLevel(PChar);

    fmt::print("> Promoting {} to GM level {}\n", PChar->name, level);
    PChar->pushPacket<GP_SERV_COMMAND_CHAT_STD>(PChar, MESSAGE_SYSTEM_3, fmt::format("You have been set to GM level {}.", level));
}

void MapEngine::onFixFabiontLinkshell(std::vector<std::string>& inputs) const
{
    (void)inputs;
    constexpr const char* kFabChar    = "Fabiont";
    constexpr const char* kOwner    = "Aremais";
    constexpr const char* kLsName   = "PegasusXI";
    constexpr uint8_t     SLOT_LINK1 = 0x10;
    constexpr uint8_t     SLOT_LINK2 = 0x11;
    constexpr uint8_t     LOC_INVENTORY = 0;
    constexpr uint16_t    ITEM_LINKSHELL = 513;
    constexpr uint16_t    ITEM_EMPTY     = 65535;
    constexpr uint8_t     LSTYPE_LINKSHELL = 1; // item_linkshell.h

    const auto fabR = db::preparedStmt("SELECT charid FROM chars WHERE charname = ? LIMIT 1", std::string(kFabChar));
    if (!fabR || fabR->rowsCount() == 0 || !fabR->next())
    {
        fmt::print("fix_fabiont_ls: character '{}' not found.\n", kFabChar);
        return;
    }
    const uint32_t fabId = fabR->get<uint32>("charid");

    const auto arR = db::preparedStmt("SELECT charid FROM chars WHERE charname = ? LIMIT 1", std::string(kOwner));
    if (!arR || arR->rowsCount() == 0 || !arR->next())
    {
        fmt::print("fix_fabiont_ls: character '{}' not found.\n", kOwner);
        return;
    }
    const uint32_t arId = arR->get<uint32>("charid");

    uint8_t     fabLoc = 0;
    uint8_t     fabSlot = 0;
    uint16_t    fabItemId = 0;
    std::string fabExtra;
    bool        found = false;

    for (const uint8_t equipSlot : { SLOT_LINK1, SLOT_LINK2 })
    {
        const auto eqR = db::preparedStmt(
            "SELECT slotid, containerid FROM char_equip WHERE charid = ? AND equipslotid = ? LIMIT 1",
            fabId,
            equipSlot);
        if (!eqR || eqR->rowsCount() == 0 || !eqR->next())
        {
            continue;
        }
        const uint8_t slotid      = eqR->get<uint8>("slotid");
        const uint8_t containerid = eqR->get<uint8>("containerid");

        const auto invR = db::preparedStmt(
            "SELECT itemId, extra FROM char_inventory WHERE charid = ? AND location = ? AND slot = ? LIMIT 1",
            fabId,
            containerid,
            slotid);
        if (!invR || invR->rowsCount() == 0 || !invR->next())
        {
            continue;
        }
        const uint16_t iid = invR->get<uint16>("itemId");
        if (iid != ITEM_LINKSHELL && iid != 514 && iid != 515)
        {
            continue;
        }
        fabLoc     = containerid;
        fabSlot    = slotid;
        fabItemId  = iid;
        fabExtra   = invR->get<std::string>("extra");
        found      = true;
        break;
    }

    if (!found)
    {
        fmt::print("fix_fabiont_ls: no linkshell-type item (513/514/515) in {}'s LS1/LS2 equip slots.\n", kFabChar);
        return;
    }

    std::array<uint8_t, 24> fabBuf{};
    if (!fabExtra.empty())
    {
        const auto n = std::min(fabExtra.size(), fabBuf.size());
        std::memcpy(fabBuf.data(), fabExtra.data(), n);
    }

    uint32_t groupId = 0;
    std::memcpy(&groupId, fabBuf.data(), sizeof(groupId));
    if (groupId == 0)
    {
        fmt::print("fix_fabiont_ls: equipped item has GroupId 0; cannot resolve linkshell row.\n");
        return;
    }

    char encodedName[LinkshellStringLength]{};
    EncodeStringLinkshell(std::string(kLsName), encodedName);
    std::memcpy(fabBuf.data() + 9, encodedName, 15);

    const auto updLs = db::preparedStmt(
        "UPDATE linkshells SET name = ?, poster = ? WHERE linkshellid = ? LIMIT 1",
        std::string(kLsName),
        std::string(kOwner),
        groupId);
    if (!updLs || updLs->rowsAffected() == 0)
    {
        fmt::print("fix_fabiont_ls: UPDATE linkshells failed for linkshellid {}.\n", groupId);
        return;
    }

    const std::string fabExtraOut(reinterpret_cast<const char*>(fabBuf.data()), fabBuf.size());
    const auto        updFab = db::preparedStmt(
        "UPDATE char_inventory SET signature = ?, extra = ? WHERE charid = ? AND location = ? AND slot = ? LIMIT 1",
        std::string(kLsName),
        fabExtraOut,
        fabId,
        fabLoc,
        fabSlot);
    if (!updFab || updFab->rowsAffected() == 0)
    {
        fmt::print("fix_fabiont_ls: failed to update {}'s equipped item row.\n", kFabChar);
        return;
    }

    std::array<uint8_t, 24> holderBuf{};
    std::memcpy(holderBuf.data(), fabBuf.data(), 8);
    holderBuf[8] = LSTYPE_LINKSHELL;
    std::memcpy(holderBuf.data() + 9, encodedName, 15);

    const auto freeR = db::preparedStmt(
        "SELECT slot FROM char_inventory WHERE charid = ? AND location = ? AND itemId = ? ORDER BY slot ASC LIMIT 1",
        arId,
        LOC_INVENTORY,
        ITEM_EMPTY);
    if (!freeR || freeR->rowsCount() == 0 || !freeR->next())
    {
        fmt::print("fix_fabiont_ls: {} has no free inventory slot (itemId {}).\n", kOwner, ITEM_EMPTY);
        return;
    }
    const uint8_t freeSlot = freeR->get<uint8>("slot");

    const std::string holderExtra(reinterpret_cast<const char*>(holderBuf.data()), holderBuf.size());
    const auto        updAr = db::preparedStmt(
        "UPDATE char_inventory SET itemId = ?, quantity = 1, signature = ?, extra = ? "
        "WHERE charid = ? AND location = ? AND slot = ? LIMIT 1",
        ITEM_LINKSHELL,
        std::string(kLsName),
        holderExtra,
        arId,
        LOC_INVENTORY,
        freeSlot);
    if (!updAr || updAr->rowsAffected() == 0)
    {
        fmt::print("fix_fabiont_ls: failed to give {} the linkshell holder (slot {}).\n", kOwner, freeSlot);
        return;
    }

    linkshell::UnloadLinkshell(groupId);
    linkshell::LoadLinkshell(groupId);

    fmt::print("fix_fabiont_ls: OK linkshellid={} name={} poster={}; updated {} equip (item {}); {} holder at inv slot {}.\n",
               groupId,
               kLsName,
               kOwner,
               kFabChar,
               fabItemId,
               kOwner,
               freeSlot);
    fmt::print("fix_fabiont_ls: If either character is online, have them zone or relog to refresh items.\n");
}

auto MapEngine::networking() const -> MapNetworking&
{
    return *networking_;
}

auto MapEngine::statistics() const -> MapStatistics&
{
    return *mapStatistics_;
}

auto MapEngine::zones() const -> std::map<xi::ZoneId, CZone*>&
{
    return g_PZoneList;
}

auto MapEngine::scheduler() -> Scheduler&
{
    return scheduler_;
}

auto MapEngine::config() const -> MapConfig&
{
    return config_;
}
