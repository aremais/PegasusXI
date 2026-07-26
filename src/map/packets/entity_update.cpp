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

#include "common/utils.h"

#include <algorithm>
#include <cstring>

#include "entity_update.h"

#include "entities/base_entity.h"
#include "entities/mob_entity.h"
#include "entities/npc_entity.h"
#include "status_effect_container.h"
#include "zone.h"

namespace
{

// https://github.com/atom0s/XiPackets/blob/main/world/server/0x000E

// PS2: (Non-defined bitfield type.)
struct sendflags_t
{
    uint8_t Position : 1;
    uint8_t ClaimStatus : 1;
    uint8_t General : 1;
    uint8_t Name : 1;
    uint8_t Model : 1;
    uint8_t Despawn : 1;
    uint8_t Name2 : 1;
    uint8_t unused : 1;
};

// PS2: (Unnamed bitfield struct.)
struct flags0_t
{
    uint32_t MovTime : 13;    // PS2: MovTime
    uint32_t RunMode : 1;     // PS2: RunMode
    uint32_t unknown_1_6 : 1; // PS2: TargetMode
    uint32_t GroundFlag : 1;  // PS2: GroundFlag
    uint32_t KingFlag : 1;    // PS2: KingFlag
    uint32_t facetarget : 15; // PS2: facetarget
};

// PS2: (Unnamed bitfield struct.)
struct flags1_t
{
    uint32_t MonsterFlag : 1;     // PS2: MonsterFlag
    uint32_t HideFlag : 1;        // PS2: HideFlag
    uint32_t SleepFlag : 1;       // PS2: SleepFlag
    uint32_t unknown_0_3 : 1;     // PS2: MonStat
    uint32_t unknown_0_4 : 1;     // PS2: (unknown)
    uint32_t ChocoboIndex : 3;    // PS2: ChocoboIndex
    uint32_t CliPosInitFlag : 1;  // PS2: CliPosInitFlag
    uint32_t GraphSize : 2;       // PS2: GraphSize
    uint32_t LfgFlag : 1;         // PS2: LfgFlag
    uint32_t AnonymousFlag : 1;   // PS2: AnonymousFlag
    uint32_t YellFlag : 1;        // PS2: YellFlag
    uint32_t AwayFlag : 1;        // PS2: AwayFlag
    uint32_t Gender : 1;          // PS2: Gender
    uint32_t PlayOnelineFlag : 1; // PS2: PlayOnelineFlag
    uint32_t LinkShellFlag : 1;   // PS2: LinkShellFlag
    uint32_t LinkDeadFlag : 1;    // PS2: LinkDeadFlag
    uint32_t TargetOffFlag : 1;   // PS2: TargetOffFlag
    uint32_t TalkUcoffFlag : 1;   // PS2: TalkUcoffFlag
    uint32_t unknown_2_5 : 1;     // PS2: PartyLeaderFlg
    uint32_t unknown_2_6 : 1;     // PS2: AllianceLeaderFlg
    uint32_t unknown_2_7 : 1;     // PS2: DebugClientFlg
    uint32_t GmLevel : 3;         // PS2: GmLevel
    uint32_t HackMove : 1;        // PS2: HackMove
    uint32_t unknown_3_4 : 1;     // PS2: GMInvisFlag
    uint32_t InvisFlag : 1;       // PS2: InvisFlag
    uint32_t TurnFlag : 1;        // PS2: TurnFlag
    uint32_t BazaarFlag : 1;      // PS2: BazaarFlag
};

// PS2: (Unnamed bitfield struct.)
struct flags2_t
{
    uint32_t r : 8;             // PS2: r
    uint32_t g : 8;             // PS2: g
    uint32_t b : 8;             // PS2: b
    uint32_t PvPFlag : 1;       // PS2: PvPFlag
    uint32_t ShadowFlag : 1;    // PS2: ShadowFlag
    uint32_t ShipStartMode : 1; // PS2: ShipStartMode
    uint32_t CharmFlag : 1;     // PS2: CharmFlag
    uint32_t GmIconFlag : 1;    // PS2: GmIconFlag
    uint32_t NamedFlag : 1;     // PS2: NamedFlag
    uint32_t SingleFlag : 1;    // PS2: SingleFlag
    uint32_t AutoPartyFlag : 1; // PS2: AutoPartyFlag
};

// PS2: (Unnamed bitfield struct. This has been fully repurposed.)
struct flags3_t
{
    uint32_t TrustFlag : 1;        // PS2: (New; replaced 'PetMode'.)
    uint32_t LfgMasterFlag : 1;    // PS2: (New; replaced 'PetMode'.)
    uint32_t PetNewFlag : 1;       // PS2: PetNewFlag
    uint32_t unknown_0_3 : 1;      // PS2: PetKillFlag
    uint32_t MotStopFlag : 1;      // PS2: MotStopFlag
    uint32_t CliPriorityFlag : 1;  // PS2: CliPriorityFlag
    uint32_t PetFlag : 1;          // PS2: NpcPetFlag
    uint32_t OcclusionoffFlag : 1; // PS2: OcclusionoffFlag
    uint32_t BallistaTeam : 8;     // PS2: (New; did not exist.)
    uint32_t MonStat : 3;          // PS2: (New; did not exist.)
    uint32_t unknown_2_3 : 1;      // PS2: (New; did not exist.)
    uint32_t unknown_2_4 : 1;      // PS2: (New; did not exist.)
    uint32_t SilenceFlag : 1;      // PS2: (New; did not exist.)
    uint32_t unknown_2_6 : 1;      // PS2: (New; did not exist.)
    uint32_t NewCharacterFlag : 1; // PS2: (New; did not exist.)
    uint32_t MentorFlag : 1;       // PS2: (New; did not exist.)
    uint32_t unknown_3_1 : 1;      // PS2: (New; did not exist.)
    uint32_t unknown_3_2 : 1;      // PS2: (New; did not exist.)
    uint32_t unknown_3_3 : 1;      // PS2: (New; did not exist.)
    uint32_t unknown_3_4 : 1;      // PS2: (New; did not exist.)
    uint32_t unknown_3_5 : 1;      // PS2: (New; did not exist.)
    uint32_t unknown_3_6 : 1;      // PS2: (New; did not exist.)
    uint32_t unknown_3_7 : 1;      // PS2: (New; did not exist.)
};

struct packet_data_0
{
    uint16_t model_id;
};

struct packet_data_1
{
    uint16_t GrapIDTbl[9];
};

struct packet_data_2
{
    uint16_t unused;
    uint32_t DoorId;
};

struct packet_data_3
{
    uint16_t unused;
    uint32_t DoorId;
    uint32_t Time;
    uint32_t EndTime;
};

struct packet_data_4
{
    uint16_t unused;
    uint32_t DoorId;
    uint32_t Time;
    uint32_t EndTime;
};

struct packet_data_5
{
    uint16_t model_id;
};

struct packet_data_6
{
    uint16_t model_id;
};

struct packet_data_7
{
    uint16_t GrapIDTbl[9];
};

// PS2: GP_SERV_CHAR_NPC
struct GP_SERV_CHAR_NPC
{
    uint16_t id : 9;
    uint16_t size : 7;
    uint16_t sync;

    // PS2: GP_SERV_POS_HEAD
    uint32_t    UniqueNo;      // PS2: UniqueNo
    uint16_t    ActIndex;      // PS2: ActIndex
    sendflags_t SendFlg;       // PS2: SendFlg
    uint8_t     dir;           // PS2: dir
    float       x;             // PS2: x
    float       z;             // PS2: z
    float       y;             // PS2: y
    flags0_t    Flags0;        // PS2: <bits> (Nameless bitfield.)
    uint8_t     Speed;         // PS2: Speed
    uint8_t     SpeedBase;     // PS2: SpeedBase
    uint8_t     Hpp;           // PS2: HpMax
    uint8_t     server_status; // PS2: server_status
    flags1_t    Flags1;        // PS2: <bits> (Nameless bitfield.)
    flags2_t    Flags2;        // PS2: <bits> (Nameless bitfield.)
    flags3_t    Flags3;        // PS2: <bits> (Nameless bitfield.)
    uint32_t    BtTargetID;    // PS2: BtTargetID

    // PS2: GP_SERV_CHAR_NPC_HEAD
    uint16_t SubKind : 3; // PS2: SubKind
    uint16_t Status : 13; // PS2: Status

    // PS2: GP_SERV_CHAR_NPC remaining fields.
    // This will be treated as packet_data_0, packet_data_1, etc. based on the SubKind value.
    // It is set to the maximum possible size.
    uint8_t Data[18]; // PS2: (New; did not exist.) (Data that fills the rest of the packet is based on the SendFlg and SubKind values!)
};

// constexpr uint32_t nonspecific_size = offsetof(GP_SERV_CHAR_PC, MonstrosityFlags);
// constexpr uint32_t general_size     = offsetof(GP_SERV_CHAR_PC, GrapIDTbl[0]);
// constexpr uint32_t model_size       = offsetof(GP_SERV_CHAR_PC, name[0]);
// constexpr uint32_t name_size        = offsetof(GP_SERV_CHAR_PC, name[0]);

std::string getTransportNPCName(CBaseEntity* PEntity)
{
    bool isElevator = PEntity->look.size == MODEL_ELEVATOR;
    auto strSize    = isElevator ? 10 : 8;

    std::string str(strSize, '\0');
    std::memcpy(str.data() + 0, PEntity->name.data(), std::min<size_t>(PEntity->name.size(), 4));

    auto timestamp = PEntity->GetLocalVar("TransportTimestamp");
    std::memcpy(str.data() + 4, &timestamp, 4);

    if (isElevator)
    {
        std::memset(str.data() + 8, 8, 1);
    }

    return str;
}

} // namespace

CEntityUpdatePacket::CEntityUpdatePacket(CBaseEntity* PEntity, ENTITYUPDATE type, uint8 updatemask)
{
    this->setType(0x0E);
    this->setSize(0x58);

    ref<uint32>(0x04) = PEntity->id;
    updateWith(PEntity, type, updatemask);
}

void CEntityUpdatePacket::updateWith(CBaseEntity* PEntity, ENTITYUPDATE type, uint8 updatemask)
{
    uint32 currentId = ref<uint32>(0x04);
    if (currentId != PEntity->id)
    {
        // Should only be able to update packets about the same character.
        ShowError("Unable to update entity update packet for %d with data from %d", currentId, PEntity->id);
        return;
    }

    auto packet = this->as<GP_SERV_CHAR_NPC>();

    packet->id = 0x0E;
    // packet->size     = roundUpToNearestFour(nonspecific_size) / 4; // Client recieves this and multiplies by 4

    packet->UniqueNo = PEntity->id;
    packet->ActIndex = PEntity->targid; // 0x0E entity updates are valid for 0 to 1023 and 1792 to 2303

    ref<uint8>(0x0A) |= updatemask;

    switch (type)
    {
        case ENTITY_DESPAWN:
        {
            ref<uint8>(0x1F) = 0x02; // despawn animation
            ref<uint8>(0x0A) = 0x30;
            updatemask       = UPDATE_ALL_MOB;
        }
        break;
        case ENTITY_SPAWN:
        {
            updatemask = UPDATE_ALL_MOB;

            if (PEntity->look.size == MODEL_EQUIPPED || PEntity->look.size == MODEL_CHOCOBO)
            {
                updatemask = 0x57;
            }
            if (PEntity->animationsub != 0)
            {
                ref<uint8>(0x2A) = 4;
            }
            if (PEntity->spawnAnimation == xi::SpawnAnimation::Special)
            {
                ref<uint8>(0x28) |= 0x04;
            }
            ref<uint8>(0x0A) = updatemask;
        }
        break;
        default:
        {
            break;
        }
    }

    if (updatemask & UPDATE_POS)
    {
        ref<uint8>(0x0B)  = PEntity->loc.p.rotation;
        ref<float>(0x0C)  = PEntity->loc.p.x;
        ref<float>(0x10)  = PEntity->loc.p.y;
        ref<float>(0x14)  = PEntity->loc.p.z;
        ref<uint16>(0x18) = PEntity->loc.p.moving;
        ref<uint16>(0x1A) = PEntity->m_TargID << 1;
        ref<uint8>(0x1C)  = PEntity->GetSpeed();
        ref<uint8>(0x1D)  = PEntity->animationSpeed;
    }

    if (PEntity->allegiance == xi::Allegiance::Player && PEntity->status == xi::Status::Update)
    {
        ref<uint8>(0x20) = static_cast<uint8>(xi::Status::Normal);
    }
    else
    {
        ref<uint8>(0x20) = static_cast<uint8>(PEntity->status);
    }

    // General flags and data
    switch (PEntity->objtype)
    {
        case TYPE_NPC:
        {
            auto* PNpc = static_cast<CNpcEntity*>(PEntity);

            if (updatemask & UPDATE_HP)
            {
                ref<uint8>(0x1E) = 0x64; // HPP: 100
                ref<uint8>(0x1F) = PEntity->animation;
                ref<uint8>(0x2A) |= PEntity->animationsub;

                ref<uint32>(0x21) = static_cast<uint32>(PNpc->m_flags);
                ref<uint8>(0x27)  = PNpc->name_prefix; // gender and something else

                if (PNpc->triggerable())
                {
                    ref<uint8>(0x28) |= 0x40;
                }

                ref<uint8>(0x29) = static_cast<uint8>(PEntity->allegiance);
                ref<uint8>(0x2B) = static_cast<uint8>(PEntity->namevis);
            }

            // TODO: Unify name logic
            if (updatemask & UPDATE_NAME)
            {
                // Prefer polutils/packet name so clients without matching DAT entries
                // (e.g. SOA NPCs) display "Ancestry Moogle" instead of "Ancestry_Moogle"/"NPC".
                auto name = !PNpc->packetName.empty() ? PNpc->packetName : PNpc->getName();
                if (PNpc->look.size == MODEL_ELEVATOR || PNpc->look.size == MODEL_SHIP)
                {
                    name = getTransportNPCName(PNpc);
                }

                // depending on size of name, this can be 0x20, 0x22, or 0x24
                // Static NPC rename field is Name[16] (15 chars + NUL). Longer names are
                // upgraded after this packet via 0x67 in CCharEntity::updateEntityPacket.
                constexpr size_t nameOffset               = 0x34;
                constexpr size_t MaxStaticNpcNameLength = PacketNameLength - 1;
                const size_t     nameBytes                = std::min(name.size(), MaxStaticNpcNameLength);
                size_t           packetSize               = std::max<size_t>(0x48, nameOffset + nameBytes + 1);
                packetSize                                = (packetSize + 3) & ~size_t{ 3 };
                this->setSize(packetSize);
                auto* start = buffer_.data() + nameOffset;
                std::memset(start, 0U, this->getSize() - nameOffset);
                std::memcpy(start, name.c_str(), nameBytes);
            }
        }
        break;
        case TYPE_MOB:
        case TYPE_PET:
        case TYPE_TRUST:
        {
            CMobEntity* PMob = static_cast<CMobEntity*>(PEntity);

            if (updatemask & UPDATE_HP)
            {
                ref<uint8>(0x1E) = PMob->GetHPP();
                ref<uint8>(0x1F) = PEntity->animation;
                ref<uint8>(0x2A) |= PEntity->animationsub;

                ref<uint32>(0x21) = static_cast<uint32>(PMob->m_flags);
                ref<uint8>(0x25)  = PMob->health.hp > 0 ? 0x08 : 0;
                ref<uint8>(0x27)  = PMob->m_name_prefix;
                if (PMob->PMaster != nullptr && PMob->PMaster->objtype == TYPE_PC)
                {
                    ref<uint8>(0x27) |= 0x08;
                }
                ref<uint8>(0x28) |= PMob->StatusEffectContainer->HasStatusEffect(xi::StatusEffect::Terror) ? 0x10 : 0x00;

                // Giga hack -- mobs in Pso'Xja for some reason are less "visible"
                // Set CliPriorityFlag to force them to render on the client if they receive 0x00Es
                // TODO: make this a MOBMOD or some other way to set this flag without hardcoding.
                if (PMob->getZone() == ZONEID::ZONE_PSOXJA)
                {
                    // Enable CliPriorityFlag
                    ref<uint8>(0x28) |= 0x20;
                }

                ref<uint8>(0x28) |= PMob->health.hp > 0 && PMob->animation == ANIMATION_DEATH ? 0x08 : 0;
                ref<uint8>(0x28) |= PMob->status == xi::Status::Normal && PMob->objtype == TYPE_MOB ? 0x40 : 0; // Make the entity triggerable if a mob and normal status
                ref<uint8>(0x29) = static_cast<uint8>(PEntity->allegiance);
                ref<uint8>(0x2B) = static_cast<uint8>(PEntity->namevis);
            }

            // TODO: make flags struct for 0x00E when it's decompped
            if (PEntity->priorityRender)
            {
                // Enable CliPriorityFlag
                ref<uint8>(0x28) |= 0x20;
            }

            if (updatemask & UPDATE_STATUS)
            {
                ref<uint32>(0x2C) = PMob->m_OwnerID.id;
            }

            if (updatemask & UPDATE_NAME)
            {
                // depending on size of name, this can be 0x20, 0x22, or 0x24
                this->setSize(0x48);
                if (PMob->packetName.empty())
                {
                    std::memcpy(buffer_.data() + 0x34, PEntity->getName().c_str(), std::min<size_t>(PEntity->getName().size(), PacketNameLength));
                }
                else
                {
                    std::memcpy(buffer_.data() + 0x34, PMob->packetName.c_str(), std::min<size_t>(PMob->packetName.size(), PacketNameLength));
                }
            }
        }
        break;
        default:
        {
            break;
        }
    }

    if (PEntity->objtype == TYPE_TRUST)
    {
        // Special spawn animation
        // This also allows trusts to be despawned
        ref<uint8>(0x28) |= 0x45;
    }

    // Set look data
    switch (PEntity->look.size)
    {
        case MODEL_STANDARD:
        case MODEL_UNK_5:
        case MODEL_AUTOMATON:
        {
            ref<uint32>(0x30) = ::ref<uint32>(&PEntity->look, 0);
        }
        break;
        case MODEL_EQUIPPED:
        case MODEL_CHOCOBO:
        {
            this->setSize(0x48);
            std::memcpy(buffer_.data() + 0x30, &PEntity->look, sizeof(look_t));
        }
        break;
        case MODEL_DOOR:
        {
            this->setSize(0x48);
            ref<uint16>(0x30) = PEntity->look.size;
            std::memcpy(buffer_.data() + 0x34, PEntity->getName().c_str(), (PEntity->getName().size() > 12 ? 12 : PEntity->getName().size()));
        }
        break;
        case MODEL_SHIP:
        case MODEL_ELEVATOR:
        {
            this->setSize(0x48);
            ref<uint16>(0x30) = PEntity->look.size;
            auto name         = getTransportNPCName(PEntity);
            std::memcpy(buffer_.data() + 0x34, name.data(), name.size());
        }
        break;
    }

    // TODO: Fill this in
    switch (packet->SubKind)
    {
        case 0:
        {
            auto data   = ::as<packet_data_0>(packet->Data);
            std::ignore = data;
        }
        break;
        case 1:
        {
            auto data   = ::as<packet_data_1>(packet->Data);
            std::ignore = data;
        }
        break;
        case 2:
        {
            auto data   = ::as<packet_data_2>(packet->Data);
            std::ignore = data;
        }
        break;
        case 3:
        {
            auto data   = ::as<packet_data_3>(packet->Data);
            std::ignore = data;
        }
        break;
        case 4:
        {
            auto data   = ::as<packet_data_4>(packet->Data);
            std::ignore = data;
        }
        break;
        case 5:
        {
            auto data   = ::as<packet_data_5>(packet->Data);
            std::ignore = data;
        }
        break;
        case 6:
        {
            auto data   = ::as<packet_data_6>(packet->Data);
            std::ignore = data;
        }
        break;
        case 7:
        {
            auto data   = ::as<packet_data_7>(packet->Data);
            std::ignore = data;
        }
    }

    // Equipped/chocobo look data occupies 0x30-0x43, so a custom name must be placed at 0x44.
    // Used for dynamic entities and zone NPCs whose polutils_name differs from the internal name
    // (e.g. A.M.A.N. Liaison — not present in older client DATs).
    //
    // Client 0x0E name field is Name[16] (15 chars + NUL) for static NPCs / renames.
    // See atom0s/XiPackets 0x000E — enQueStrCpy(..., 0x10, ...). Do not send 16 visible
    // characters or the last glyph is dropped ("A.M.A.N. Liaison" -> "A.M.A.N. Liaiso").
    constexpr size_t MaxStaticNpcNameLength = PacketNameLength - 1; // 15
    const bool       equippedModel            = PEntity->look.size == MODEL_EQUIPPED || PEntity->look.size == MODEL_CHOCOBO;
    if (PEntity->isRenamed && equippedModel && type != ENTITY_DESPAWN)
    {
        const auto&      name       = PEntity->packetName;
        constexpr size_t nameOffset = 0x44;
        const size_t     nameBytes  = std::min(name.size(), MaxStaticNpcNameLength);
        size_t           packetSize = std::max<size_t>(0x56, nameOffset + nameBytes + 1);
        packetSize                  = (packetSize + 3) & ~size_t{ 3 };

        this->setSize(packetSize);

        // Temporarily override UpdateFlags (0x0A) to perform black magic:
        ref<uint8>(0x0A) = 0x57; // Carefully chosen bits to make FUNC_Packet_Incoming_0x000E behave (Same type as first 0x00E Fellow packet)
        ref<uint8>(0x18) = 0x01; // Name follows look data at 0x44

        std::memcpy(buffer_.data() + 0x30, &PEntity->look, sizeof(look_t));

        auto* start = buffer_.data() + nameOffset;
        std::memset(start, 0U, this->getSize() - nameOffset);
        std::memcpy(start, name.c_str(), nameBytes);
    }
    // If the entity has been renamed, we have to re-send the name during every update.
    // Otherwise it will revert to it's default name (if applicable).
    // Do not apply to doors/ships/elevators: their 0x34+ payload is mesh/trigger identity
    // (written above), not a display name — stomping it prevents client door animation.
    else if (PEntity->isRenamed && PEntity->look.size != MODEL_DOOR && PEntity->look.size != MODEL_SHIP &&
             PEntity->look.size != MODEL_ELEVATOR)
    {
        updatemask |= UPDATE_NAME;
        ref<uint8>(0x0A) |= updatemask;

        const auto& name       = PEntity->packetName;
        size_t      nameOffset = 0x34;

        // Mobs and NPC's targid's live in the range 0-1023
        if (PEntity->targid < 1024)
        {
            nameOffset = 0x35;
        }

        const size_t nameBytes  = std::min(name.size(), MaxStaticNpcNameLength);
        size_t       packetSize = std::max<size_t>(0x48, nameOffset + nameBytes + 1);
        packetSize              = (packetSize + 3) & ~size_t{ 3 };
        this->setSize(packetSize);

        if (PEntity->targid < 1024)
        {
            ref<uint16>(0x34) = 0x01;
        }

        auto* start = buffer_.data() + nameOffset;
        std::memset(start, 0U, this->getSize() - nameOffset);
        std::memcpy(start, name.c_str(), nameBytes);
    }

    //  Don't overwrite data for model size and hitbox size from look string on NPCs
    if (packet->SendFlg.General && (PEntity->objtype == TYPE_PC || PEntity->objtype == TYPE_PET || PEntity->objtype == TYPE_MOB))
    {
        packet->Flags1.GraphSize = PEntity->modelSize;
        // For some reason, SE reused a player struct where this "g" value is the hitbox size.
        packet->Flags2.g = static_cast<uint8_t>(PEntity->modelHitboxSize * 10);

        // Fenced content ID
        const uint8 gateId = static_cast<CBattleEntity*>(PEntity)->StatusEffectContainer->GetConfrontationSubPower() & 0x0F;
        packet->Flags2.b   = (packet->Flags2.b & 0x0F) | (gateId << 4);
    }
}
