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

#include "search_handler.h"

#include "common/md52.h"
#include "common/settings.h"
#include "common/timer.h"
#include "common/utils.h"

#include "data_loader.h"
#include "enums/search_type.h"

#include <algorithm>
#include <map>
#include <unordered_set>

#include "packets/auction_history.h"
#include "packets/auction_list.h"
#include "packets/linkshell_list.h"
#include "packets/party_list.h"
#include "packets/search_comment.h"
#include "packets/search_list.h"

#include <asio/write.hpp>

#include <chrono>

SearchHandler::SearchHandler(Scheduler& scheduler, asio::ip::tcp::socket socket, SynchronizedShared<std::map<std::string, uint16_t>>& IPAddressesInUseList, SynchronizedShared<std::unordered_set<std::string>>& IPAddressWhitelist)
: scheduler_(scheduler)
, socket_(std::move(socket))
, buffer_{}
, IPAddressesInUse_(IPAddressesInUseList)
, IPAddressWhitelist_(IPAddressWhitelist)
{
    DebugSocketsFmt("New connection from IP {}", socket_.lowest_layer().remote_endpoint().address().to_string());

    asio::error_code ec = {};
    socket_.lowest_layer().set_option(asio::socket_base::reuse_address(true));
    socket_.lowest_layer().set_option(asio::socket_base::keep_alive(true));
    ipAddress_ = socket_.lowest_layer().remote_endpoint(ec).address().to_string();

    if (ec)
    {
        ipAddress_ = "error";
        socket_.lowest_layer().close();
    }
    else
    {
        const auto maxConnectionsPerIp = std::max<uint16_t>(1, settings::get<uint16>("search.MAX_CONNECTIONS_PER_IP"));

        // Count existing sessions before registering this one (whitelist returns 0 and skips tracking).
        if (getNumSessionsInUse(ipAddress_) >= maxConnectionsPerIp)
        {
            ShowErrorFmt("More than {} simultaneous connections from {}. Closing socket.", maxConnectionsPerIp, ipAddress_);
            socket_.lowest_layer().close();
            return;
        }

        addToUsedIPAddresses(ipAddress_);
    }
}

SearchHandler::~SearchHandler()
{
    DebugSocketsFmt("Connection from IP {} closed", ipAddress_);
    removeFromUsedIPAddresses(ipAddress_);
}

auto SearchHandler::run() -> Task<void>
{
    auto self = shared_from_this();

    try
    {
        while (socket_.lowest_layer().is_open() && !scheduler_.closeRequested())
        {
            // Clients often send nothing while the AH UI is open (browsing, buying on map, etc.).
            // A short idle timeout here drops the TCP session and the next AH action fails until
            // reconnect — looks like intermittent "Search failed" after the first good request.
            auto result = co_await scheduler_.withTimeout(
                socket_.async_read_some(asio::buffer(readBuffer_.data(), readBuffer_.size()), asio::use_awaitable),
                std::chrono::minutes(15));

            if (!result.has_value()) // timed out
            {
                DebugSocketsFmt("Socket timed out from {}", ipAddress_);
                break;
            }

            const auto length = result.value();
            if (length == 0) // EOF
            {
                break;
            }

            DebugSocketsFmt("Received stream data from IP {} ({} bytes)", ipAddress_, length);

            receiveStream_.insert(receiveStream_.end(), readBuffer_.begin(), readBuffer_.begin() + length);

            while (receiveStream_.size() >= 2)
            {
                const auto expectedLength = ref<uint16>(receiveStream_.data(), 0x00);

                // Bad framing/noise: slide one byte and try to resync.
                if (expectedLength < 28 || expectedLength > buffer_.size())
                {
                    ShowWarningFmt("Search packet framing desync from {}. Header size {} invalid; skipping 1 byte.", ipAddress_, expectedLength);
                    receiveStream_.erase(receiveStream_.begin());
                    continue;
                }

                if (receiveStream_.size() < expectedLength)
                {
                    break;
                }

                std::memset(buffer_.data(), 0, buffer_.size());
                std::memcpy(buffer_.data(), receiveStream_.data(), expectedLength);
                receiveStream_.erase(receiveStream_.begin(), receiveStream_.begin() + expectedLength);

                co_await read_func(expectedLength);
            }

            while (!searchPackets_.empty())
            {
                auto packet    = searchPackets_.front();
                auto write_len = packet.getSize();

                std::memset(buffer_.data(), 0, buffer_.size());
                std::memcpy(buffer_.data(), packet.getData(), write_len);

                searchPackets_.pop_front();

                encrypt(write_len);

                DebugSocketsFmt("Sending packet to IP {} ({} bytes)", ipAddress_, write_len);

                // Must send the full frame: async_write_some can truncate, which corrupts the stream and
                // makes the client show "Search failed" (especially on large AH result sets).
                co_await asio::async_write(socket_, asio::buffer(buffer_.data(), write_len), asio::use_awaitable);
            }
        }
    }
    catch (const std::exception& e)
    {
        DebugSocketsFmt("Socket error from IP {}: {}", ipAddress_, e.what());
    }

    asio::error_code ec;
    socket_.lowest_layer().close(ec);
}

void SearchHandler::decrypt(uint16_t length)
{
    DebugSocketsFmt("Decrypting packet from IP {} ({} bytes)", ipAddress_, length);

    // Get key from packet
    ref<uint32>(key, 16) = ref<uint32>(buffer_.data(), length - 4);

    // Decrypt packet
    md5(reinterpret_cast<uint8*>(key), blowfish_.hash, 20);

    blowfish_init(reinterpret_cast<int8*>(blowfish_.hash), 16, blowfish_.P, blowfish_.S[0]);

    uint16_t tmp = (length - 12) / 4;
    tmp -= tmp % 2;

    for (uint16_t i = 0; i < tmp; i += 2)
    {
        blowfish_decipher(reinterpret_cast<uint32*>(buffer_.data()) + i + 2, reinterpret_cast<uint32*>(buffer_.data()) + i + 3, blowfish_.P, blowfish_.S[0]);
    }

    ref<uint32>(key, 20) = ref<uint32>(buffer_.data(), length - 0x18);
}

void SearchHandler::encrypt(uint16_t length)
{
    DebugSocketsFmt("Encrypting packet for IP {} ({} bytes)", ipAddress_, length);

    ref<uint16>(buffer_.data(), 0x00) = length;     // packet size
    ref<uint32>(buffer_.data(), 0x04) = 0x46465849; // "IXFF"

    md5(reinterpret_cast<uint8*>(key), blowfish_.hash, 24);

    blowfish_init((int8*)blowfish_.hash, 16, blowfish_.P, blowfish_.S[0]);

    md5(buffer_.data() + 8, buffer_.data() + length - 0x18 + 0x04, length - 0x18 - 0x04);

    uint8 tmp = (length - 12) / 4;
    tmp -= tmp % 2;

    for (uint8 i = 0; i < tmp; i += 2)
    {
        blowfish_encipher(reinterpret_cast<uint32*>(buffer_.data()) + i + 2, reinterpret_cast<uint32*>(buffer_.data()) + i + 3, blowfish_.P, blowfish_.S[0]);
    }

    memcpy(&buffer_[length] - 0x04, key + 16, 4);
}

bool SearchHandler::validatePacket(uint16_t length)
{
    DebugSocketsFmt("Validating packet from IP {} ({} bytes)", ipAddress_, length);

    // Check if packet is valid
    uint8 PacketHash[16]{};

    int32 toHash = length; // whole packet

    toHash -= 0x08; // -headersize
    toHash -= 0x10; // -hashsize
    toHash -= 0x04; // -keysize

    md5(reinterpret_cast<uint8*>(&buffer_[8]), PacketHash, toHash);

    for (uint8 i = 0; i < 16; ++i)
    {
        if (buffer_[length - 0x14 + i] != PacketHash[i])
        {
            ShowErrorFmt("Search hash wrong byte {}: {} should be {}", i, hex8ToString(PacketHash[i]), hex8ToString(buffer_[length - 0x14 + i]));
            return false;
        }
    }

    return true;
}

inline std::string searchTypeToString(uint8 type)
{
    switch (type)
    {
        case TCP_SEARCH:
            return "SEARCH";
        case TCP_SEARCH_ALL:
            return "SEARCH_ALL";
        case TCP_SEARCH_COMMENT:
            return "SEARCH_COMMENT";
        case TCP_GROUP_LIST:
            return "GROUP_LIST";
        case TCP_AH_REQUEST:
            return "AH_REQUEST";
        case TCP_AH_REQUEST_MORE:
            return "AH_REQUEST_MORE";
        case TCP_AH_HISTORY_SINGLE:
            return "AH_HISTORY_SINGLE";
        case TCP_AH_HISTORY_STACK:
            return "AH_HISTORY_STACK";
        default:
            return "UNKNOWN";
    }
}

auto SearchHandler::read_func(uint16_t length) -> Task<void>
{
    if (length != ref<uint16>(buffer_.data(), 0x00) || length < 28)
    {
        ShowErrorFmt("Search packetsize wrong. Size {} should be {}.", length, ref<uint16>(buffer_.data(), 0x00));
        co_return;
    }

    decrypt(length);

    if (validatePacket(length))
    {
        uint8 packetType = buffer_[0x0B];

        // AH traffic is high volume; Info level here looks like failures and obscures real issues.
        const bool isAhTraffic = packetType == TCP_AH_REQUEST || packetType == TCP_AH_REQUEST_MORE ||
                                 packetType == TCP_AH_HISTORY_SINGLE || packetType == TCP_AH_HISTORY_STACK;
        if (isAhTraffic)
        {
            ShowTraceFmt("Search Request: {} ({}), size: {}, ip: {}", searchTypeToString(packetType), packetType, length, ipAddress_);
        }
        else
        {
            ShowInfoFmt("Search Request: {} ({}), size: {}, ip: {}", searchTypeToString(packetType), packetType, length, ipAddress_);
        }

        switch (packetType)
        {
            case TCP_SEARCH:
            case TCP_SEARCH_ALL:
            {
                HandleSearchRequest();
            }
            break;
            case TCP_SEARCH_COMMENT:
            {
                HandleSearchComment();
            }
            break;
            case TCP_GROUP_LIST:
            {
                HandleGroupListRequest();
            }
            break;
            case TCP_AH_REQUEST:
            case TCP_AH_REQUEST_MORE:
            {
                // MORE reuses the same payload layout but does not carry sort params at 0x12 (see below).
                // Ignoring MORE leaves the client waiting for a reply and stalls the AH session.
                co_await HandleAuctionHouseRequest();
            }
            break;
            case TCP_AH_HISTORY_SINGLE:
            case TCP_AH_HISTORY_STACK:
            {
                co_await HandleAuctionHouseHistory();
            }
            break;
            default:
            {
                ShowErrorFmt("Unknown packet type: {}", packetType);
            }
        }
    }
}

// Mostly copy-pasted DSP era code. It works, so why change it?
/************************************************************************
 *                                                                       *
 *  Prints the contents of the packet in `data` to the console.          *
 *                                                                       *
 ************************************************************************/

void DebugPrintPacket(char* data, uint16_t size)
{
    if (!settings::get<bool>("logging.DEBUG_PACKETS"))
    {
        return;
    }

    std::string outStr = "\n";
    for (int32 y = 0; y < size; y++)
    {
        outStr += fmt::format("{:02X} ", (uint8)data[y]);
        if (((y + 1) % 16) == 0)
        {
            outStr += "\n";
        }
    }

    ShowDebug(outStr);
}

/************************************************************************
 *                                                                       *
 *  Character list request (party/linkshell)                             *
 *                                                                       *
 ************************************************************************/

void SearchHandler::HandleGroupListRequest()
{
    uint32 partyid      = ref<uint32>(buffer_.data(), 0x10);
    uint32 allianceid   = ref<uint32>(buffer_.data(), 0x14);
    uint32 linkshellid1 = ref<uint32>(buffer_.data(), 0x18);
    uint32 linkshellid2 = ref<uint32>(buffer_.data(), 0x1C);

    ShowInfoFmt("SEARCH::PartyID = {}", partyid);
    ShowInfoFmt("SEARCH::LinkshellIDs = {}, {}", linkshellid1, linkshellid2);

    CDataLoader PDataLoader;

    if (partyid != 0 || allianceid != 0)
    {
        std::list<SearchEntity*> PartyList = PDataLoader.GetPartyList(partyid, allianceid);

        CPartyListPacket PPartyPacket(partyid, (uint32)PartyList.size());

        for (auto& it : PartyList)
        {
            PPartyPacket.AddPlayer(*it);
        }

        uint16_t length = PPartyPacket.GetSize();

        DebugPrintPacket((char*)PPartyPacket.GetData(), length);
        searchPackets_.emplace_back(PPartyPacket.GetData(), length);
    }
    else if (linkshellid1 != 0 || linkshellid2 != 0)
    {
        uint32                   linkshellid   = linkshellid1 == 0 ? linkshellid2 : linkshellid1;
        std::list<SearchEntity*> LinkshellList = PDataLoader.GetLinkshellList(linkshellid);

        uint32 totalResults  = (uint32)LinkshellList.size();
        uint32 currentResult = 0;

        // Iterate through the linkshell list, splitting up the results into
        // smaller chunks.
        std::list<SearchEntity*>::iterator it = LinkshellList.begin();

        do
        {
            CLinkshellListPacket PLinkshellPacket(linkshellid, totalResults);

            while (currentResult < totalResults)
            {
                bool success = PLinkshellPacket.AddPlayer(**it);
                if (!success)
                {
                    break;
                }

                currentResult++;
                ++it;
            }

            if (currentResult == totalResults)
            {
                PLinkshellPacket.SetFinal();
            }

            uint16_t length = PLinkshellPacket.GetSize();

            DebugPrintPacket((char*)PLinkshellPacket.GetData(), length);
            searchPackets_.emplace_back(PLinkshellPacket.GetData(), length);

        } while (currentResult < totalResults);
    }
}

void SearchHandler::HandleSearchComment()
{
    uint32 playerId = ref<uint32>(buffer_.data(), 0x10);

    CDataLoader PDataLoader;
    std::string comment = PDataLoader.GetSearchComment(playerId);
    if (comment.empty())
    {
        return;
    }

    SearchCommentPacket commentPacket(playerId, comment);

    uint16_t length = commentPacket.GetSize();

    DebugPrintPacket((char*)commentPacket.GetData(), length);
    searchPackets_.emplace_back(commentPacket.GetData(), length);
}

void SearchHandler::HandleSearchRequest()
{
    const SearchRequest sr = _HandleSearchRequest();

    CDataLoader PDataLoader;
    int         totalCount = 0;

    std::list<SearchEntity*> SearchList = PDataLoader.GetPlayersList(sr, &totalCount);

    uint32 totalResults  = (uint32)SearchList.size();
    uint32 currentResult = 0;

    // Iterate through the search list, splitting up the results into
    // smaller chunks.
    std::list<SearchEntity*>::iterator it = SearchList.begin();

    do
    {
        CSearchListPacket PSearchPacket(totalCount);

        while (currentResult < totalResults)
        {
            bool success = PSearchPacket.AddPlayer(**it);
            if (!success)
            {
                break;
            }

            currentResult++;
            ++it;
        }

        if (currentResult == totalResults)
        {
            PSearchPacket.SetFinal();
        }

        uint16_t length = PSearchPacket.GetSize();

        DebugPrintPacket((char*)PSearchPacket.GetData(), length);
        searchPackets_.emplace_back(PSearchPacket.GetData(), length);

    } while (currentResult < totalResults);
}

auto SearchHandler::HandleAuctionHouseRequest() -> Task<void>
{
    uint8 AHCatID = ref<uint8>(buffer_.data(), 0x16);

    // 2 - level
    // 3 - race
    // 4 - job
    // 5 - damage
    // 6 - delay
    // 7 - defense
    // 8 - resistance
    // 9 - name
    std::string OrderByString = "ORDER BY";
    const uint16 packetLen  = ref<uint16>(buffer_.data(), 0x00);
    const uint8  packetType = buffer_[0x0B];

    // Only TCP_AH_REQUEST (0x15) carries sort param count at 0x12. TCP_AH_REQUEST_MORE (0x10) is a
    // small continuation packet (~76 bytes); that offset is not paramCount — reading it produced
    // garbage (e.g. 247) and spammed "clamp" warnings.
    uint8 paramCount = 0;
    if (packetType == TCP_AH_REQUEST)
    {
        paramCount = ref<uint8>(buffer_.data(), 0x12);

        if (packetLen >= 0x1C)
        {
            // Last sort param i = paramCount-1 reads uint32 ending at 0x18 + 8*(paramCount-1) + 3
            const uint8 maxParams = static_cast<uint8>((packetLen - 0x1C) / 8 + 1);
            if (paramCount > maxParams)
            {
                ShowTraceFmt("AH_REQUEST paramCount {} exceeds safe count {} for packet size {}; clamping.",
                             paramCount, maxParams, packetLen);
                paramCount = maxParams;
            }
        }
        else
        {
            paramCount = 0;
        }
    }

    for (uint8 i = 0; i < paramCount; ++i) // Item sort options
    {
        uint8 param = ref<uint32>(buffer_.data(), 0x18 + 8 * i);
        ShowTraceFmt(" Param{}: {}", i, param);
        switch (param)
        {
            case 2:
                OrderByString.append(" item_equipment.level DESC,");
                break;
            case 5:
                OrderByString.append(" item_weapon.dmg DESC,");
                break;
            case 6:
                OrderByString.append(" item_weapon.delay DESC,");
                break;
            case 9:
                OrderByString.append(" item_basic.sortname,");
                break;
        }
    }

    // Outer query aliases aggregated rows as "ah" (see CDataLoader::GetAHItemsToCategory).
    OrderByString.append(" ah.itemid");
    const char* OrderByArray = OrderByString.data();

    CDataLoader PDataLoader;
    std::vector<AuctionHouseItem*> ItemList = co_await PDataLoader.GetAHItemsToCategoryAsync(scheduler_, AHCatID, OrderByArray);

    const std::size_t nItems = ItemList.size();
    const std::size_t PacketsCount =
        (nItems / 20) + ((nItems % 20) != 0 ? 1U : 0U) + (nItems == 0 ? 1U : 0U);

    for (std::size_t i = 0; i < PacketsCount; ++i)
    {
        CAHItemsListPacket PAHPacket(static_cast<uint16>(20 * i));
        uint16             itemListSize = static_cast<uint16>(ItemList.size());

        PAHPacket.SetItemCount(itemListSize);

        const std::size_t chunkEnd = std::min(20 * (i + 1), nItems);
        for (std::size_t y = 20 * i; y < chunkEnd; ++y)
        {
            PAHPacket.AddItem(*ItemList.at(y));
        }

        uint16_t length = PAHPacket.GetSize();
        DebugPrintPacket((char*)PAHPacket.GetData(), length);

        searchPackets_.emplace_back(PAHPacket.GetData(), length);
    }
}

auto SearchHandler::HandleAuctionHouseHistory() -> Task<void>
{
    uint16 ItemID = ref<uint16>(buffer_.data(), 0x12);
    uint8  stack  = ref<uint8>(buffer_.data(), 0x15);

    CDataLoader PDataLoader;
    auto [HistoryList, item] = co_await PDataLoader.GetAHItemHistoryAsync(scheduler_, ItemID, stack != 0);

    CAHHistoryPacket PAHPacket = CAHHistoryPacket(item, stack);

    for (auto& i : HistoryList)
    {
        PAHPacket.AddItem(*i);
    }

    uint16_t length = PAHPacket.GetSize();

    DebugPrintPacket((char*)PAHPacket.GetData(), length);
    searchPackets_.emplace_back(PAHPacket.GetData(), length);
}

SearchRequest SearchHandler::_HandleSearchRequest()
{
    // This function constructs a `SearchRequest` based on which query should be sent to the database.
    // The results from the database will eventually be sent to the client.
    SearchRequest sr;

    uint32 bitOffset = 0;

    unsigned char sortDescending = 0;
    unsigned char isPresent      = 0;
    unsigned char areaCount      = 0;

    char  name[16] = {};
    uint8 nameLen  = 0;

    uint8 minLvl = 0;
    uint8 maxLvl = 0;

    uint8 jobid    = 0;
    uint8 raceid   = 255; // 255 because race 0 is an actual filter (hume)
    uint8 nationid = 255; // 255 because nation 0 is an actual filter (sandoria)

    uint8 minRank = 0;
    uint8 maxRank = 0;

    uint16 areas[15] = {};

    uint32 flags = 0;

    uint8 size = ref<uint8>(buffer_.data(), 0x10);

    uint16 workloadBits = size * 8;

    uint8 commentType = 0;

    while (bitOffset < workloadBits)
    {
        if ((bitOffset + 5) >= workloadBits)
        {
            bitOffset = workloadBits;
            break;
        }

        const auto EntryType = static_cast<SearchType>(unpackBitsLE(&buffer_[0x11], bitOffset, 5));
        bitOffset += 5;

        if ((EntryType != SearchType::Friend) && (EntryType != SearchType::Linkshell) && (EntryType != SearchType::Linkshell2) && (EntryType != SearchType::Comment) && (EntryType != SearchType::Flags2))
        {
            if ((bitOffset + 3) >= workloadBits) // so 0000000 at the end does not get interpreted as name entry
            {
                bitOffset = workloadBits;
                break;
            }
            sortDescending = (unsigned char)unpackBitsLE(&buffer_[0x11], bitOffset, 1);
            bitOffset += 1;

            isPresent = (unsigned char)unpackBitsLE(&buffer_[0x11], bitOffset, 1);
            bitOffset += 1;
        }

        switch (EntryType)
        {
            case SearchType::Name:
            {
                if (isPresent == 0x1) // Name send
                {
                    if ((bitOffset + 5) >= workloadBits)
                    {
                        bitOffset = workloadBits;
                        break;
                    }
                    nameLen       = (unsigned char)unpackBitsLE(&buffer_[0x11], bitOffset, 5);
                    name[nameLen] = '\0';

                    bitOffset += 5;

                    for (unsigned char i = 0; i < nameLen; i++)
                    {
                        name[i] = (char)unpackBitsLE(&buffer_[0x11], bitOffset, 7);
                        bitOffset += 7;
                    }
                }
                break;
            }
            case SearchType::Area: // Area Code Entry - 10 bit
            {
                if (isPresent == 0) // no more Area entries
                {
                    ShowTraceFmt("Area List End found.");
                }
                else // 8 Bit = 1 Byte per Area Code
                {
                    areas[areaCount] = (uint16)unpackBitsLE(&buffer_[0x11], bitOffset, 10);
                    areaCount++;
                    bitOffset += 10;
                }
                break;
            }
            case SearchType::Nation: // Country - 2 bit
            {
                if (isPresent == 0x1)
                {
                    unsigned char country = (unsigned char)unpackBitsLE(&buffer_[0x11], bitOffset, 2);
                    bitOffset += 2;
                    nationid = country;

                    ShowInfoFmt("Nationality Entry found. ({}) Sorting: ({}).", hex8ToString(country), (sortDescending == 0x00) ? "ascending" : "descending");
                }
                break;
            }
            case SearchType::Job: // Job - 5 bit
            {
                if (isPresent == 0x1)
                {
                    unsigned char job = (unsigned char)unpackBitsLE(&buffer_[0x11], bitOffset, 5);
                    bitOffset += 5;
                    jobid = job;
                }
                break;
            }
            case SearchType::Level: // Level- 16 bit
            {
                if (isPresent == 0x1)
                {
                    unsigned char fromLvl = (unsigned char)unpackBitsLE(&buffer_[0x11], bitOffset, 8);
                    bitOffset += 8;
                    unsigned char toLvl = (unsigned char)unpackBitsLE(&buffer_[0x11], bitOffset, 8);
                    bitOffset += 8;
                    minLvl = fromLvl;
                    maxLvl = toLvl;
                }
                break;
            }
            case SearchType::Race: // Race - 4 bit
            {
                if (isPresent == 0x1)
                {
                    unsigned char race = (unsigned char)unpackBitsLE(&buffer_[0x11], bitOffset, 4);
                    bitOffset += 4;
                    raceid = race;

                    ShowInfoFmt("Race Entry found. ({}) Sorting: ({}).", hex8ToString(race), (sortDescending == 0x00) ? "ascending" : "descending");
                }
                ShowInfoFmt("SortByRace: {}.", (sortDescending == 0x00) ? "ascending" : "descending");
                break;
            }
            case SearchType::Rank: // Rank - 2 byte
            {
                if (isPresent == 0x1)
                {
                    unsigned char fromRank = (unsigned char)unpackBitsLE(&buffer_[0x11], bitOffset, 8);
                    bitOffset += 8;
                    minRank              = fromRank;
                    unsigned char toRank = (unsigned char)unpackBitsLE(&buffer_[0x11], bitOffset, 8);
                    bitOffset += 8;
                    maxRank = toRank;

                    ShowInfoFmt("Rank Entry found. ({} - {}) Sorting: ({}).", fromRank, toRank, (sortDescending == 0x00) ? "ascending" : "descending");
                }
                ShowInfoFmt("SortByRank: {}.", (sortDescending == 0x00) ? "ascending" : "descending");
                break;
            }
            case SearchType::Comment: // 4 Byte
            {
                commentType = (uint8)unpackBitsLE(&buffer_[0x11], bitOffset, 32);
                bitOffset += 32;

                ShowInfoFmt("Comment Entry found. ({}).", hex8ToString(commentType));
                break;
            }
            // the following 4 Entries were generated with /sea (ballista|friend|linkshell|away|inv)
            // so they may be off
            case SearchType::Linkshell: // 4 Byte
            {
                sr.lsId = static_cast<uint32>(unpackBitsLE(&buffer_[0x11], bitOffset, 32));
                bitOffset += 32;

                ShowInfoFmt("Linkshell Entry found. Value: {}", hex32ToString(sr.lsId.value()));
                break;
            }
            case SearchType::Linkshell2: // 4 Byte
            {
                sr.lsId = static_cast<uint32>(unpackBitsLE(&buffer_[0x11], bitOffset, 32));
                bitOffset += 32;

                ShowInfoFmt("Linkshell2 Entry found. Value: {}", hex32ToString(sr.lsId.value()));
                break;
            }
            case SearchType::Friend: // Friend Packet, 0 byte
            {
                ShowInfoFmt("Friend Entry found.");
                break;
            }
            case SearchType::Flags1: // Flag Entry #1, 2 byte,
            {
                if (isPresent == 0x1)
                {
                    unsigned short flags1 = (unsigned short)unpackBitsLE(&buffer_[0x11], bitOffset, 16);
                    bitOffset += 16;

                    ShowInfoFmt("Flag Entry #1 ({}) found. Sorting: ({}).", hex16ToString(flags1), (sortDescending == 0x00) ? "ascending" : "descending");

                    flags = flags1;
                }
                ShowInfoFmt("SortByFlags: {}", (sortDescending == 0 ? "ascending" : "descending"));
                break;
            }
            case SearchType::Flags2: // Flag Entry #2 - 4 byte
            {
                unsigned int flags2 = (unsigned int)unpackBitsLE(&buffer_[0x11], bitOffset, 32);

                bitOffset += 32;
                flags = flags2;
                break;
            }
            default:
            {
                ShowInfoFmt("Unknown Search Param {}!", static_cast<uint8>(EntryType));
                break;
            }
        }
    }

    const auto printableName = nameLen > 0 ? name : "<empty>";
    ShowInfoFmt("Name: {} Job: {} Lvls: {} ~ {}", printableName, jobid, minLvl, maxLvl);

    sr.jobid  = jobid;
    sr.maxlvl = maxLvl;
    sr.minlvl = minLvl;

    sr.race        = raceid;
    sr.nation      = nationid;
    sr.minRank     = minRank;
    sr.maxRank     = maxRank;
    sr.flags       = flags;
    sr.commentType = commentType;

    sr.nameLen = nameLen;
    memcpy(&sr.zoneid, areas, sizeof(sr.zoneid));
    if (nameLen > 0)
    {
        sr.name.insert(0, name);
    }

    return sr;
    // Do not process the last bits, which can interfere with other operations
    // For example: "/blacklist delete Name" and "/sea all Name"
}

uint16_t SearchHandler::getNumSessionsInUse(const std::string& ipAddressStr) const
{
    DebugSocketsFmt("Checking if IP is in use: {}", ipAddressStr);

    if (IPAddressWhitelist_.read(
            [ipAddressStr](const auto& ipWhitelist)
            {
                return ipWhitelist.find(ipAddressStr) != ipWhitelist.end();
            }))
    {
        return 0;
    }

    return IPAddressesInUse_.read(
        [ipAddressStr](const auto& ipAddrsInUse) -> uint16_t
        {
            if (ipAddrsInUse.find(ipAddressStr) != ipAddrsInUse.end())
            {
                return ipAddrsInUse.at(ipAddressStr);
            }

            return 0;
        });
}

void SearchHandler::removeFromUsedIPAddresses(const std::string& ipAddressStr) const
{
    DebugSocketsFmt("Removing IP from active set: {}", ipAddressStr);

    if (IPAddressWhitelist_.read(
            [ipAddressStr](const auto& ipWhitelist)
            {
                return ipWhitelist.find(ipAddressStr) != ipWhitelist.end();
            }))
    {
        return;
    }

    IPAddressesInUse_.write(
        [ipAddressStr](auto& ipAddrsInUse)
        {
            if (ipAddrsInUse.find(ipAddressStr) != ipAddrsInUse.end())
            {
                ipAddrsInUse[ipAddressStr] -= 1;
            }
            else // Removing nothing, do nothing.
            {
                return;
            }

            // If we got here, check if we want to remove an IP from the map
            if (ipAddrsInUse[ipAddressStr] <= 0)
            {
                ipAddrsInUse.erase(ipAddressStr);
            }
        });
}

void SearchHandler::addToUsedIPAddresses(const std::string& ipAddressStr) const
{
    DebugSocketsFmt("Adding IP to active set: {}", ipAddressStr);

    if (IPAddressWhitelist_.read(
            [ipAddressStr](const auto& ipWhitelist)
            {
                return ipWhitelist.find(ipAddressStr) != ipWhitelist.end();
            }))
    {
        return;
    }

    IPAddressesInUse_.write(
        [ipAddressStr](auto& ipAddrsInUse)
        {
            if (ipAddrsInUse.find(ipAddressStr) == ipAddrsInUse.end())
            {
                ipAddrsInUse[ipAddressStr] = 1;
            }
            else
            {
                ipAddrsInUse[ipAddressStr] += 1;
            }
        });
}
