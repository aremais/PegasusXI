/*
===========================================================================

  Copyright (c) 2023 LandSandBoat Dev Teams

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

#include "login_helpers.h"

#include "common/database.h"
#include "common/lua.h"
#include "common/md52.h"
#include "common/settings.h"

#include <cctype>
#include <map>

namespace loginHelpers
{

namespace
{
    // Permanent movement speed for new characters on this account (see scripts/globals/player.lua).
    constexpr uint32 AREMAIS_ACCOUNT_ID          = 1022;
    constexpr int32  AREMAIS_PERM_MOVE_SPEED     = 80;
    constexpr const char* AREMAIS_MOVE_SPEED_VAR = "AremaisPermMoveSpeed";

    // New characters were inserted with 0,0,0 which triggers moghouse "exit" reposition in Zone.lua
    // before other logic and can confuse the client. Coordinates match `xi.moghouse.exits` entrance 1.
    struct NewCharSpawn
    {
        float   x;
        float   y;
        float   z;
        uint8_t rotation;
    };

    constexpr auto newCharSpawnForZone(xi::ZoneId zoneId) -> NewCharSpawn
    {
        switch (zoneId)
        {
            case xi::ZoneId::BastokMines:
                return { 117.0F, 0.99F, -72.0F, 127 };
            case xi::ZoneId::BastokMarkets:
                return { -177.0F, -8.0F, -30.0F, 128 };
            case xi::ZoneId::PortBastok:
                return { 60.0F, 8.5F, -239.0F, 192 };
            case xi::ZoneId::SouthernSanDoria:
                return { 159.5F, -2.0F, 160.0F, 95 };
            case xi::ZoneId::NorthernSanDoria:
                return { 130.0F, -0.2F, -3.0F, 160 };
            case xi::ZoneId::PortSanDoria:
                return { 79.4F, -16.0F, -135.5F, 165 };
            case xi::ZoneId::WindurstWaters:
                return { 160.0F, -2.65F, -53.7F, 192 };
            case xi::ZoneId::PortWindurst:
                return { 198.0F, -15.65F, 258.0F, 65 };
            case xi::ZoneId::WindurstWoods:
                return { -130.0F, -7.65F, 40.0F, 0 };
            default:
                return { 0.0F, 0.0F, 0.0F, 0 };
        }
    }
} // namespace

// [ip_addr][session_hash] = session
HashMap<std::string, std::map<std::string, session_t>> authenticatedSessions_;

HashMap<std::string, std::map<std::string, session_t>>& getAuthenticatedSessions()
{
    return authenticatedSessions_;
}

bool isStringMalformed(const std::string& str, std::size_t max_length)
{
    const auto unprintableChar = [](char const& c) -> bool
    {
        return c < 0x20;
    };

    const bool isEmpty   = str.empty();
    const bool isTooLong = str.size() > max_length;

    const bool hasInvalidChar = std::any_of(
        str.cbegin(),
        str.cend(),
        unprintableChar);

    return isEmpty || isTooLong || hasInvalidChar;
}

session_t& get_authenticated_session(const std::string& ipAddr, const std::string& sessionHash)
{
    return authenticatedSessions_[ipAddr][sessionHash]; // NOTE: Will construct if doesn't exist
}

// https://github.com/atom0s/XiPackets/blob/main/lobby/S2C_0x0004_ResponseError.md
void generateErrorMessage(uint8* packet, uint16 errorCode)
{
    std::memset(packet, 0, 0x24);

    packet[0] = 0x24; // size

    packet[4] = 0x49; // I
    packet[5] = 0x58; // X
    packet[6] = 0x46; // F
    packet[7] = 0x46; // F

    packet[8] = 0x04; // result

    packet[28] = 0x10; // This field is never referenced within the client. It was always observed to be 0x10, but the actual value or its purpose is unknown.

    ref<uint16>(packet, 32) = errorCode;

    uint8 hash[16];
    md5(packet, hash, 0x24);
    std::memcpy(packet + 12, hash, 16);
}

uint16 generateExpansionBitmask()
{
    uint16 mask = EXPANSION_DISPLAY::BASE_GAME;

    std::map<std::string, uint16> expansions = {
        { "login.RISE_OF_ZILART", EXPANSION_DISPLAY::RISE_OF_ZILART },
        { "login.CHAINS_OF_PROMATHIA", EXPANSION_DISPLAY::CHAINS_OF_PROMATHIA },
        { "login.TREASURES_OF_AHT_URGHAN", EXPANSION_DISPLAY::TREASURES_OF_AHT_URGHAN },
        { "login.WINGS_OF_THE_GODDESS", EXPANSION_DISPLAY::WINGS_OF_THE_GODDESS },
        { "login.A_CRYSTALLINE_PROPHECY", EXPANSION_DISPLAY::A_CRYSTALLINE_PROPHECY },
        { "login.A_MOOGLE_KUPOD_ETAT", EXPANSION_DISPLAY::A_MOOGLE_KUPOD_ETAT },
        { "login.A_SHANTOTTO_ASCENSION", EXPANSION_DISPLAY::A_SHANTOTTO_ASCENSION },
        { "login.VISIONS_OF_ABYSSEA", EXPANSION_DISPLAY::VISIONS_OF_ABYSSEA },
        { "login.SCARS_OF_ABYSSEA", EXPANSION_DISPLAY::SCARS_OF_ABYSSEA },
        { "login.HEROES_OF_ABYSSEA", EXPANSION_DISPLAY::HEROES_OF_ABYSSEA },
        { "login.SEEKERS_OF_ADOULIN", EXPANSION_DISPLAY::SEEKERS_OF_ADOULIN },
    };

    // apply the expansion masks where available
    for (const auto& expansion : expansions)
    {
        if (settings::get<bool>(expansion.first))
        {
            mask |= expansion.second;
        }
    }
    return mask;
}

uint16 generateFeatureBitmask(const bool& needsOTP)
{
    uint16 mask = 0;

    std::map<std::string, uint16> features = {
        { "login.MOG_WARDROBE_3", FEATURE_DISPLAY::MOG_WARDROBE_3 },
        { "login.MOG_WARDROBE_4", FEATURE_DISPLAY::MOG_WARDROBE_4 },
        { "login.MOG_WARDROBE_5", FEATURE_DISPLAY::MOG_WARDROBE_5 },
        { "login.MOG_WARDROBE_6", FEATURE_DISPLAY::MOG_WARDROBE_6 },
        { "login.MOG_WARDROBE_7", FEATURE_DISPLAY::MOG_WARDROBE_7 },
        { "login.MOG_WARDROBE_8", FEATURE_DISPLAY::MOG_WARDROBE_8 }
    };

    // apply the feature masks where available
    for (const auto& feature : features)
    {
        if (settings::get<bool>(feature.first))
        {
            mask |= feature.second;
        }
    }

    if (needsOTP)
    {
        mask |= FEATURE_DISPLAY::SECURE_TOKEN;
    }

    return mask;
}

Maybe<std::string> validateCharacterName(const std::string& name)
{
    // Sanitize name & check for invalid characters
    for (const auto& letter : name)
    {
        if (!std::isalpha(static_cast<unsigned char>(letter)))
        {
            return "Invalid characters present in name.";
        }
    }

    // Check for invalid length name
    // NOTE: The client checks for this. This is to guard against packet injection.
    if (name.size() < 3 || name.size() > 15)
    {
        return "Invalid name length.";
    }

    // Check if the name is already in use by another character
    const auto rset0 = db::preparedStmt("SELECT charname FROM chars WHERE charname LIKE ?", name);
    if (!rset0)
    {
        return "Internal entity name query failed.";
    }
    else if (rset0->rowsCount() != 0)
    {
        return "Name already in use.";
    }

    // (optional) Check if the name is in use by NPC or Mob entities
    if (settings::get<bool>("login.DISABLE_MOB_NPC_CHAR_NAMES"))
    {
        const auto query =
            "SELECT polutils_name AS `name` FROM npc_list "
            "WHERE REPLACE(REPLACE(UPPER(polutils_name), '-', ''), '_', '') "
            "LIKE REPLACE(REPLACE(UPPER(?), '-', ''), '_', '') "
            "UNION "
            "SELECT packet_name AS `name` FROM mob_pools "
            "WHERE REPLACE(REPLACE(UPPER(packet_name), '-', ''), '_', '') "
            "LIKE REPLACE(REPLACE(UPPER(?), '-', ''), '_', '')";

        const auto rset1 = db::preparedStmt(query, name, name);
        if (!rset1)
        {
            return "Internal entity name query failed";
        }
        else if (rset1->rowsCount() != 0)
        {
            return "Name already in use.";
        }
    }

    // TODO: Don't raw-access Lua like this outside of Lua helper code.
    // (optional) Check if the name contains any words on the bad word list
    const auto loginSettingsTable = lua["xi"]["settings"]["login"].get_or<sol::table>(sol::lua_nil);
    if (loginSettingsTable.valid())
    {
        if (auto badWordsList = loginSettingsTable.get_or<sol::table>("BANNED_WORDS_LIST", sol::lua_nil); badWordsList.valid())
        {
            const auto potentialName = to_upper(name);
            for (const auto& entry : badWordsList)
            {
                const auto badWord = to_upper(entry.second.as<std::string>());
                if (potentialName.find(badWord) != std::string::npos)
                {
                    return fmt::format("Name matched with bad words list <{}>.", badWord);
                }
            }
        }
    }

    return std::nullopt;
}

int32 saveCharacter(uint32 accid, uint32 charid, char_mini* createchar)
{
    const auto charName = asStringFromUntrustedSource(createchar->m_name);

    const NewCharSpawn spawn = newCharSpawnForZone(createchar->m_zone);

    if (!db::preparedStmt("INSERT INTO chars(charid,accid,charname,pos_zone,nation,pos_x,pos_y,pos_z,pos_rot,home_zone,home_x,home_y,home_z,home_rot) "
                         "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                         charid,
                         accid,
                         charName,
                         createchar->m_zone,
                         createchar->m_nation,
                         spawn.x,
                         spawn.y,
                         spawn.z,
                         spawn.rotation,
                         createchar->m_zone,
                         spawn.x,
                         spawn.y,
                         spawn.z,
                         spawn.rotation))
    {
        ShowDebug(fmt::format("lobby_ccsave: char<{}>, accid: {}, charid: {}", charName, accid, charid));
        return -1;
    }

    if (!db::preparedStmt("INSERT INTO char_look(charid,face,race,size) VALUES(?, ?, ?, ?)", charid, createchar->m_look.face, createchar->m_look.race, createchar->m_look.size))
    {
        ShowDebug(fmt::format("lobby_cLook: char<{}>, charid: {}", charName, charid));
        return -1;
    }

    if (!db::preparedStmt("INSERT INTO char_stats(charid,mjob) VALUES(?, ?)", charid, createchar->m_mjob))
    {
        ShowDebug(fmt::format("lobby_cStats: charid: {}", charid));
        return -1;
    }

    if (!db::preparedStmt("INSERT INTO char_exp(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid = charid", charid))
    {
        return -1;
    }

    if (!db::preparedStmt("INSERT INTO char_flags(charid) VALUES(?) ON DUPLICATE KEY UPDATE disconnecting = disconnecting", charid))
    {
        return -1;
    }

    if (!db::preparedStmt("INSERT INTO char_jobs(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid = charid", charid))
    {
        return -1;
    }

    if (!db::preparedStmt("INSERT INTO char_points(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid = charid", charid))
    {
        return -1;
    }

    if (!db::preparedStmt("INSERT INTO char_unlocks(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid = charid", charid))
    {
        return -1;
    }

    if (!db::preparedStmt("INSERT INTO char_profile(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid = charid", charid))
    {
        return -1;
    }

    if (!db::preparedStmt("INSERT INTO char_storage(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid = charid", charid))
    {
        return -1;
    }

    if (!db::preparedStmt("DELETE FROM char_inventory WHERE charid = ?", charid))
    {
        return -1;
    }

    if (!db::preparedStmt("INSERT INTO char_inventory(charid) VALUES(?)", charid))
    {
        return -1;
    }

    if (settings::get<bool>("main.NEW_CHARACTER_CUTSCENE"))
    {
        if (!db::preparedStmt("INSERT INTO char_vars(charid, varname, value) VALUES(?, ?, ?)",
                              charid,
                              "HQuest[newCharacterCS]notSeen",
                              1))
        {
            return -1;
        }
    }

    if (accid == AREMAIS_ACCOUNT_ID)
    {
        if (!db::preparedStmt("INSERT INTO char_vars(charid, varname, value) VALUES(?, ?, ?)",
                              charid,
                              AREMAIS_MOVE_SPEED_VAR,
                              AREMAIS_PERM_MOVE_SPEED))
        {
            return -1;
        }
    }

    return 0;
}

int32 createCharacter(session_t& session, uint8* buf, lpkt_chr_info_sub2& charInfo)
{
    char_mini createchar{};

    std::memcpy(createchar.m_name, session.requestedNewCharacterName.c_str(), 16);

    const auto charName = asStringFromUntrustedSource(createchar.m_name);

    createchar.m_look.race = ref<uint8>(buf, 48);
    createchar.m_look.size = ref<uint8>(buf, 57);
    createchar.m_look.face = ref<uint8>(buf, 60);

    if (createchar.m_look.race < 1 || createchar.m_look.race > 8) // 1(HumeM) to 8(Galka)
    {
        ShowError(fmt::format("{} attempted to create character with invalid race {}", charName, createchar.m_look.race));
        return -1;
    }

    if (createchar.m_look.size > 2) // Large
    {
        ShowError(fmt::format("{} attempted to create character with invalid size {}", charName, createchar.m_look.size));
        return -1;
    }

    if (createchar.m_look.face > 15) // Face 8B
    {
        ShowError(fmt::format("{} attempted to create character with invalid face {}", charName, createchar.m_look.face));
        return -1;
    }

    // Validate that the job is a starting job.
    uint8 mjob        = ref<uint8>(buf, 50);
    createchar.m_mjob = std::clamp<uint8>(mjob, 1, 6);

    // Log that the character attempting to create a non-starting job.
    if (mjob != createchar.m_mjob)
    {
        ShowInfo(fmt::format("{} attempted to create invalid starting job {} substituting {}",
                             charName,
                             mjob,
                             createchar.m_mjob));
    }

    createchar.m_nation = ref<uint8>(buf, 54);

    if (createchar.m_nation > 2) // 0x00 = San d'Oria, 0x01 = Bastok, 0x02 = Windurst
    {
        ShowError(fmt::format("{} attempted to create character with invalid nation {}", charName, createchar.m_nation));
        return -1;
    }

    const std::vector<xi::ZoneId> bastokStartingZones   = { xi::ZoneId::BastokMines, xi::ZoneId::BastokMarkets, xi::ZoneId::PortBastok };
    const std::vector<xi::ZoneId> sandoriaStartingZones = { xi::ZoneId::SouthernSanDoria, xi::ZoneId::NorthernSanDoria, xi::ZoneId::PortSanDoria };
    const std::vector<xi::ZoneId> windurstStartingZones = { xi::ZoneId::WindurstWaters, xi::ZoneId::PortWindurst, xi::ZoneId::WindurstWoods };

    switch (createchar.m_nation)
    {
        case 0x02: // windy start
        {
            createchar.m_zone = windurstStartingZones[xirand::GetRandomNumber(3)];
            break;
        }
        case 0x01: // bastok start
        {
            createchar.m_zone = bastokStartingZones[xirand::GetRandomNumber(3)];
            break;
        }
        case 0x00: // sandy start
        {
            createchar.m_zone = sandoriaStartingZones[xirand::GetRandomNumber(3)];
            break;
        }
    }

    const auto rset = db::preparedStmt("SELECT COALESCE(MAX(charid), 0) AS max_id FROM chars");
    if (!rset)
    {
        return -1;
    }

    uint32 charID = 0;
    if (rset->rowsCount() != 0 && rset->next())
    {
        charID = rset->get<uint32>("max_id") + 1;
    }

    if (saveCharacter(session.accountID, charID, &createchar) == -1)
    {
        return -1;
    }

    // The client expects to fill some data in on character creation. We never _see_ the character, so we don't need to set Race/Face/Model etc.
    // We are making an assumption on what it wants - so for now just copy what is probably required (name, charid and some other stuff related to IDs.)
    std::memcpy(&charInfo.character_name, charName.c_str(), std::min(charName.size(), sizeof(charInfo.character_name)));

    uint8  worldId     = 0;      // Use when multiple worlds are supported.
    uint32 contentId   = charID; // Reusing the character ID as the content ID (which is also the name of character folder within the USER directory) at the moment
    uint16 charIdMain  = charID & 0xFFFF;
    uint8  charIdExtra = (charID >> 16) & 0xFF;

    charInfo.ffxi_id           = contentId;
    charInfo.ffxi_id_world     = charIdMain;
    charInfo.worldid           = worldId;
    charInfo.status            = 1; // 0 = Invalid/Hidden, 1 = Available, 2 = Disabled (unpaid)
    charInfo.race_change       = 0; // 0 = no race change service, 1 = race change service (gold star icon) (NOT YET SUPPORTED!)
    charInfo.renamef           = 0; // 0 = no rename required, 1 = rename required (NOT YET SUPPORTED!)
    charInfo.ffxi_id_world_tbl = charIdExtra;

    ShowDebug(fmt::format("char <{}> successfully saved", charName));
    return 0;
}

std::string getHashFromPacket(const std::string& ip_str, uint8* data)
{
    // 16-byte MD5 at offset 12 (IXFF lobby header). Do not use strnlen-based helpers here:
    // session hashes are binary and often contain 0x00 bytes; truncating breaks lookup vs. xiloader.
    const std::string hash(reinterpret_cast<const char*>(data + 12), 16);
    if (authenticatedSessions_[ip_str].find(hash) == authenticatedSessions_[ip_str].end())
    {
        return "";
    }
    return hash;
}

uint32 getAccountId(std::string accountName)
{
    const auto rset = db::preparedStmt("SELECT id FROM accounts WHERE accounts.login = ? LIMIT 1", accountName);
    if (rset && rset->next())
    {
        return rset->get<uint32>("id");
    }

    return 0;
}

} // namespace loginHelpers
