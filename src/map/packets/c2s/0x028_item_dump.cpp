/*
===========================================================================

  Copyright (c) 2025 LandSandBoat Dev Teams

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

#include "0x028_item_dump.h"

#include "entities/char_entity.h"
#include "enums/msg_std.h"
#include "items.h"
#include "items/item_linkshell.h"
#include "linkshell.h"
#include "utils/charutils.h"

#include <chrono>
#include <fstream>

namespace
{

// Retail honors _every_ container but Recycle Bin, even if you do not presently have access.
const std::set validContainers = {
    LOC_INVENTORY,
    LOC_MOGSAFE,
    LOC_MOGSAFE2,
    LOC_STORAGE,
    LOC_TEMPITEMS,
    LOC_MOGLOCKER,
    LOC_MOGSATCHEL,
    LOC_MOGSACK,
    LOC_MOGCASE,
    LOC_WARDROBE,
    LOC_WARDROBE2,
    LOC_WARDROBE3,
    LOC_WARDROBE4,
    LOC_WARDROBE5,
    LOC_WARDROBE6,
    LOC_WARDROBE7,
    LOC_WARDROBE8,
};

} // namespace

auto GP_CLI_COMMAND_ITEM_DUMP::validate(MapSession* PSession, const CCharEntity* PChar) const -> PacketValidationResult
{
    return PacketValidator(PChar)
        .blockedBy({ BlockedState::InEvent })
        .oneOf("Category", static_cast<CONTAINER_ID>(this->Category), validContainers)
        .range("ItemNum", this->ItemNum, 0, 99); // Retail honors 0 quantity.
}

void GP_CLI_COMMAND_ITEM_DUMP::process(MapSession* PSession, CCharEntity* PChar) const
{
    // #region agent log
    {
        std::ofstream _dbg("d:/server/debug-e28540.log", std::ios::app);
        if (_dbg)
        {
            const auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(
                                std::chrono::system_clock::now().time_since_epoch())
                                .count();
            _dbg << "{\"sessionId\":\"e28540\",\"hypothesisId\":\"C\",\"location\":\"0x028_item_dump.cpp:process\","
                    "\"message\":\"ITEM_DUMP received\",\"data\":{\"category\":"
                 << static_cast<int>(this->Category) << ",\"slot\":" << static_cast<int>(this->ItemIndex)
                 << ",\"qty\":" << this->ItemNum << "},\"timestamp\":" << ms << "}\n";
        }
    }
    // #endregion

    // Gil cannot be dropped.
    if (this->Category == LOC_INVENTORY && this->ItemIndex == 0)
    {
        PChar->pushPacket<GP_SERV_COMMAND_MESSAGE>(ITEMID::GIL, MsgStd::UnableToThrowAway);
        return;
    }

    CItem* PItem = PChar->getStorage(this->Category)->GetItem(this->ItemIndex);

    if (!PItem || PItem->isSubType(ITEM_LOCKED))
    {
        ShowWarning("GP_CLI_COMMAND_ITEM_DUMP: Attempt of removal of invalid item from slot %u", this->ItemIndex);
        // #region agent log
        {
            std::ofstream _dbg("d:/server/debug-e28540.log", std::ios::app);
            if (_dbg)
            {
                const auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(
                                    std::chrono::system_clock::now().time_since_epoch())
                                    .count();
                _dbg << "{\"sessionId\":\"e28540\",\"hypothesisId\":\"E\",\"location\":\"0x028_item_dump.cpp:process\","
                        "\"message\":\"reject invalid/locked\",\"data\":{\"slot\":"
                     << static_cast<int>(this->ItemIndex) << ",\"hasItem\":" << (PItem ? 1 : 0)
                     << "},\"timestamp\":" << ms << "}\n";
            }
        }
        // #endregion
        return;
    }

    if (PItem->getQuantity() - PItem->getReserve() < this->ItemNum)
    {
        ShowWarning("GP_CLI_COMMAND_ITEM_DUMP: Trying to drop too much quantity from location %u slot %u", this->Category, this->ItemIndex);
        return;
    }

    // Retail accurate: Slips with stored items cannot be thrown away.
    if (PItem->isStorageSlip())
    {
        int slipData = 0;
        for (int i = 0; i < CItem::extra_size; i++)
        {
            slipData += PItem->m_extra[i];
        }

        if (slipData != 0)
        {
            PChar->pushPacket<GP_SERV_COMMAND_MESSAGE>(PItem->getID(), MsgStd::UnableToThrowAway);
            return;
        }
    }

    // Break linkshell if the main shell was disposed of.
    if (auto* itemLinkshell = dynamic_cast<CItemLinkshell*>(PItem))
    {
        if (itemLinkshell->GetLSType() == LSTYPE_LINKSHELL)
        {
            const uint32 lsid       = itemLinkshell->GetLSID();
            CLinkshell*  PLinkshell = linkshell::GetLinkshell(lsid);
            if (!PLinkshell)
            {
                PLinkshell = linkshell::LoadLinkshell(lsid);
            }
            PLinkshell->BreakLinkshell();
            linkshell::UnloadLinkshell(lsid);
        }
    }

    // Retail accurate: Any item dropped from a container other than inventory skips the recycle bin.
    // Items with the NoRecycle flag bypass the recycle bin entirely (e.g. linkshells).
    if (!settings::get<bool>("map.ENABLE_ITEM_RECYCLE_BIN") || this->Category != CONTAINER_ID::LOC_INVENTORY || PItem->hasFlag(ItemFlag::NoRecycle))
    {
        charutils::DropItem(PChar, this->Category, this->ItemIndex, this->ItemNum, PItem->getID());
        return;
    }

    // Otherwise, to the recycle bin!
    // Note: AddItemToRecycleBin moves the whole item without using ItemNum which is not retail accurate.
    charutils::AddItemToRecycleBin(PChar, this->Category, this->ItemIndex, this->ItemNum);
}
