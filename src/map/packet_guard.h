/*
===========================================================================

  Packet guard hooks (optional; gated by map.PACKETGUARD_ENABLED).

  This tree referenced PacketGuard from map_networking without shipping the
  implementation file. These defaults preserve prior behavior when the guard
  is off, and act as safe permissive stubs when it is on until a full guard
  is wired in.

===========================================================================
*/

#pragma once

#include "common/cbasetypes.h"

class CCharEntity;

struct PacketGuard
{
    static bool IsRateLimitedPacket(CCharEntity* /*PChar*/, uint16 /*packetType*/)
    {
        return false;
    }

    static bool PacketIsValidForPlayerState(CCharEntity* /*PChar*/, uint16 /*packetType*/)
    {
        return true;
    }

    static bool PacketsArrivingInCorrectOrder(CCharEntity* /*PChar*/, uint16 /*packetType*/)
    {
        return true;
    }

    static void PrintPacketList(CCharEntity* /*PChar*/)
    {
    }
};
