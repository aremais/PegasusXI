/*
===========================================================================

  Copyright (c) 2018 Darkstar Dev Teams

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

#include "common/utils.h"

#include "entity_set_name.h"

#include "entities/base_entity.h"
#include "entities/trust_entity.h"

#include <algorithm>
#include <cstring>

CEntitySetNamePacket::CEntitySetNamePacket(CBaseEntity* PEntity)
{
    // One of the purposes of this packet is to make the client aware that this pet is a trust, and hence
    // to show trust options in the menu (like "Release").
    // It is also reported to be used to name Pankration entities, and sometimes Fellows.
    // Mode 3 copies up to 24 name bytes (see atom0s/XiPackets 0x0067).
    this->setType(0x67);

    const auto& name    = PEntity->packetName.empty() ? PEntity->getName() : PEntity->packetName;
    const auto  nameLen = std::min(name.size(), size_t{ 24 });
    // Name starts at 0x18; grow so longer names are not truncated.
    this->setSize(std::max<std::size_t>(0x2C, (0x18 + nameLen + 1 + 3) & ~std::size_t{ 3 }));

    ref<uint8>(0x04) = 0x03;
    ref<uint8>(0x05) = 0x05;

    ref<uint16>(0x06) = PEntity->targid;
    ref<uint32>(0x08) = PEntity->id;

    if (auto* PTrust = dynamic_cast<CTrustEntity*>(PEntity); PTrust && PTrust->PMaster)
    {
        ref<uint16>(0x0C) = PTrust->PMaster->targid;
    }

    packBitsBE(buffer_.data() + 0x04, static_cast<uint32>(0x18 + nameLen), 0, 6, 10); // Message Size
    std::memset(buffer_.data() + 0x18, 0, nameLen + 1);
    if (nameLen > 0)
    {
        std::memcpy(buffer_.data() + 0x18, name.c_str(), nameLen);
    }

    // Unknown, maybe entity flags?
    ref<uint8>(0x10) = 0x04;
}
