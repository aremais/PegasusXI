-----------------------------------
-- Area: Dynamis-Jeuno
-----------------------------------
zones = zones or {}

zones[xi.zone.DYNAMIS_JEUNO] =
{
    text =
    {
        ITEM_CANNOT_BE_OBTAINED       = 6385, -- You cannot obtain the <item>. Come back after sorting your inventory.
        ITEM_OBTAINED                 = 6391, -- Obtained: <item>.
        GIL_OBTAINED                  = 6392, -- Obtained <number> gil.
        KEYITEM_OBTAINED              = 6394, -- Obtained key item: <keyitem>.
        CARRIED_OVER_POINTS           = 7002, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY       = 7003, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!
        LOGIN_NUMBER                  = 7004, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        MEMBERS_LEVELS_ARE_RESTRICTED = 7024, -- Your party is unable to participate because certain members' levels are restricted.
        CONQUEST_BASE                 = 7075, -- Tallying conquest results...
        DYNAMIS_TIME_BEGIN            = 7234, -- The sands of the <item> have begun to fall. You have <number> minutes (Earth time) remaining in Dynamis.
        DYNAMIS_TIME_EXTEND           = 7235, -- our stay in Dynamis has been extended by <number> minute[/s].
        DYNAMIS_TIME_UPDATE_1         = 7236, -- ou will be expelled from Dynamis in <number> [second/minute] (Earth time).
        DYNAMIS_TIME_UPDATE_2         = 7237, -- ou will be expelled from Dynamis in <number> [seconds/minutes] (Earth time).
        DYNAMIS_TIME_EXPIRED          = 7239, -- The sands of the hourglass have emptied...
        OMINOUS_PRESENCE              = 7251, -- You feel an ominous presence, as if something might happen if you possessed <item>.
    },
    mob =
    {
        -- Classic Dynamis - Jeuno (zone 188), not Dynamis - Jeuno [D] / Divergence (separate zone in this project).
        -- Primary reference: https://www.bg-wiki.com/ffxi/Dynamis_-_Jeuno (odious job mapping, forced pops, chapters).
        -- Mob positions/ids: sql/mob_spawn_points.sql (Dynamis - Jeuno block).
        TIME_EXTENSION =
        {
            { minutes = 10, ki = xi.ki.CRIMSON_GRANULES_OF_TIME,   mob = { 17547301, 17547302, 17547303 } },
            { minutes = 10, ki = xi.ki.AZURE_GRANULES_OF_TIME,     mob = 17547389 },
            { minutes = 10, ki = xi.ki.AMBER_GRANULES_OF_TIME,     mob = 17547390 },
            { minutes = 15, ki = xi.ki.ALABASTER_GRANULES_OF_TIME, mob = 17547420 },
            { minutes = 15, ki = xi.ki.OBSIDIAN_GRANULES_OF_TIME,  mob = 17547467 },
        },

        REFILL_STATUE =
        {
            {
                { mob = 17547295, eye = xi.dynamis.eye.RED   }, -- Goblin_Replica
                { mob = 17547296, eye = xi.dynamis.eye.BLUE  },
                { mob = 17547297, eye = xi.dynamis.eye.GREEN },
            },

            {
                { mob = 17547391, eye = xi.dynamis.eye.RED   }, -- Goblin_Replica
                { mob = 17547392, eye = xi.dynamis.eye.BLUE  },
                { mob = 17547393, eye = xi.dynamis.eye.GREEN },
            },

            {
                { mob = 17547421, eye = xi.dynamis.eye.RED   }, -- Goblin_Replica
                { mob = 17547422, eye = xi.dynamis.eye.BLUE  },
                { mob = 17547423, eye = xi.dynamis.eye.GREEN },
            },

            {
                { mob = 17547456, eye = xi.dynamis.eye.RED   }, -- Goblin_Replica
                { mob = 17547457, eye = xi.dynamis.eye.BLUE  },
                { mob = 17547458, eye = xi.dynamis.eye.GREEN },
            },
        },

        -- Fallback mobids match sql/mob_spawn_points (Dynamis-Jeuno). PopulateIDLookups only lists rows
        -- where ((mobid >> 12) & 0xFFF) = 188; if mobids are off-by-4096 in DB, GetFirstID returns nil
        -- and lottery NM scripts (phOnDespawn) never run; see sql/fix_spire_of_vahzl_mob_spawn_ids.sql.
        GABBLOX_MAGPIETONGUE    = GetFirstID('Gabblox_Magpietongue')    or 17547277,
        TUFFLIX_LOGLIMBS        = GetFirstID('Tufflix_Loglimbs')        or 17547291,
        CLOKTIX_LONGNAIL        = GetFirstID('Cloktix_Longnail')        or 17547294,
        HERMITRIX_TOOTHROT      = GetFirstID('Hermitrix_Toothrot')      or 17547311,
        WYRMWIX_SNAKESPECS      = GetFirstID('Wyrmwix_Snakespecs')      or 17547312,
        MORTILOX_WARTPAWS       = GetFirstID('Mortilox_Wartpaws')        or 17547438,
        RUTRIX_HAMGAMS          = GetFirstID('Rutrix_Hamgams')          or 17547454,
        ANVILIX_SOOTWRISTS      = GetFirstID('Anvilix_Sootwrists')      or 17547472,
        BOOTRIX_JAGGEDELBOW     = GetFirstID('Bootrix_Jaggedelbow')     or 17547473,
        MOBPIX_MUCOUSMOUTH      = GetFirstID('Mobpix_Mucousmouth')      or 17547474,
        DISTILIX_STICKYTOES     = GetFirstID('Distilix_Stickytoes')     or 17547478,
        EREMIX_SNOTTYNOSTRIL    = GetFirstID('Eremix_Snottynostril')    or 17547479,
        JABBROX_GRANNYGUISE     = GetFirstID('Jabbrox_Grannyguise')     or 17547480,
        PROWLOX_BARRELBELLY     = GetFirstID('Prowlox_Barrelbelly')     or 17547490,
        SCRUFFIX_SHAGGYCHEST    = GetFirstID('Scruffix_Shaggychest')    or 17547485,
        TYMEXOX_NINEFINGERS     = GetFirstID('Tymexox_Ninefingers')     or 17547486,
        BLAZOX_BONEYBOD         = GetFirstID('Blazox_Boneybod')         or 17547487,
        SLYSTIX_MEGAPEEPERS     = GetFirstID('Slystix_Megapeepers')     or 17547492,
    },
    npc =
    {
        QM =
        {
            [17547510] =
            {
                param = { 3356, 3419, 3420, 3421, 3422, 3423 },
                trade =
                {
                    { item = 3356,                             mob = 17547265 }, -- Goblin Golem
                    { item = { 3419, 3420, 3421, 3422, 3423 }, mob = 17547499 }, -- Arch Goblin Golem
                }
            },
            [17547511] = { trade = { { item = 3392, mob = 17547493 } } }, -- Quicktrix Hexhands
            [17547512] = { trade = { { item = 3393, mob = 17547494 } } }, -- Feralox Honeylips
            [17547513] = { trade = { { item = 3394, mob = 17547496 } } }, -- Scourquix Scaleskin
            [17547514] = { trade = { { item = 3395, mob = 17547498 } } }, -- Wilywox Tenderpalm
        },
    },
}

return zones[xi.zone.DYNAMIS_JEUNO]
