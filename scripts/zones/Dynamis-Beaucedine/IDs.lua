-----------------------------------
-- Area: Dynamis-Beaucedine
-----------------------------------
zones = zones or {}

zones[xi.zone.DYNAMIS_BEAUCEDINE] =
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
        CONQUEST_BASE                 = 7175, -- Tallying conquest results...
        DYNAMIS_TIME_BEGIN            = 7334, -- The sands of the <item> have begun to fall. You have <number> minutes (Earth time) remaining in Dynamis.
        DYNAMIS_TIME_EXTEND           = 7335, -- our stay in Dynamis has been extended by <number> minute[/s].
        DYNAMIS_TIME_UPDATE_1         = 7336, -- ou will be expelled from Dynamis in <number> [second/minute] (Earth time).
        DYNAMIS_TIME_UPDATE_2         = 7337, -- ou will be expelled from Dynamis in <number> [seconds/minutes] (Earth time).
        DYNAMIS_TIME_EXPIRED          = 7339, -- The sands of the hourglass have emptied...
        OMINOUS_PRESENCE              = 7351, -- You feel an ominous presence, as if something might happen if you possessed <item>.
    },
    mob =
    {
        TIME_EXTENSION =
        {
            { minutes = 10, ki = xi.ki.CRIMSON_GRANULES_OF_TIME,   mob = 17326207 },
            { minutes = 10, ki = xi.ki.AZURE_GRANULES_OF_TIME,     mob = 17326279 },
            { minutes = 10, ki = xi.ki.AMBER_GRANULES_OF_TIME,     mob = 17326353 },
            { minutes = 10, ki = xi.ki.ALABASTER_GRANULES_OF_TIME, mob = 17326468 },
            { minutes = 20, ki = xi.ki.OBSIDIAN_GRANULES_OF_TIME,  mob = { 17326742, 17326748, 17326754, 17326760, 17326765, 17326771 } },
        },

        REFILL_STATUE =
        {
            {
                { mob = 17326203, eye = xi.dynamis.eye.RED  }, -- Adamantking_Effigy
                { mob = 17326204, eye = xi.dynamis.eye.BLUE },
            },

            {
                { mob = 17326205, eye = xi.dynamis.eye.RED   }, -- Adamantking_Effigy
                { mob = 17326206, eye = xi.dynamis.eye.GREEN },
            },

            {
                { mob = 17326275, eye = xi.dynamis.eye.RED  }, -- Serjeant_Tombstone
                { mob = 17326276, eye = xi.dynamis.eye.BLUE },
            },

            {
                { mob = 17326277, eye = xi.dynamis.eye.RED   }, -- Serjeant_Tombstone
                { mob = 17326278, eye = xi.dynamis.eye.GREEN },
            },

            {
                { mob = 17326349, eye = xi.dynamis.eye.RED  }, -- Avatar_Icon
                { mob = 17326350, eye = xi.dynamis.eye.BLUE },
            },

            {
                { mob = 17326351, eye = xi.dynamis.eye.RED   }, -- Avatar_Icon
                { mob = 17326352, eye = xi.dynamis.eye.GREEN },
            },

            {
                { mob = 17326464, eye = xi.dynamis.eye.RED  }, -- Goblin_Replica
                { mob = 17326465, eye = xi.dynamis.eye.BLUE },
            },

            {
                { mob = 17326466, eye = xi.dynamis.eye.RED   }, -- Goblin_Replica
                { mob = 17326467, eye = xi.dynamis.eye.GREEN },
            },
        },

        -- Fallback mobids: sql/mob_spawn_points (Dynamis - Beaucedine). PopulateIDLookups requires
        -- ((mobid >> 12) & 0xFFF) = 134; if mobids drift, GetFirstID is nil and lottery NM scripts break.
        MOLTENOX_STUBTHUMBS      = GetFirstID('Moltenox_Stubthumbs')      or 17326374,
        DROPRIX_GRANITEPALMS     = GetFirstID('Droprix_Granitepalms')     or 17326379,
        BREWNIX_BITTYPUPILS      = GetFirstID('Brewnix_Bittypupils')      or 17326387,
        ASCETOX_RATGUMS          = GetFirstID('Ascetox_Ratgums')          or 17326397,
        GIBBEROX_PIMPLEBEAK      = GetFirstID('Gibberox_Pimplebeak')      or 17326401,
        BORDOX_KITTYBACK         = GetFirstID('Bordox_Kittyback')         or 17326410,
        RUFFBIX_JUMBOLOBES       = GetFirstID('Ruffbix_Jumbolobes')       or 17326415,
        TOCKTIX_THINLIDS         = GetFirstID('Tocktix_Thinlids')         or 17326427,
        ROUTSIX_RUBBERTENDON     = GetFirstID('Routsix_Rubbertendon')     or 17326439,
        WHISTRIX_TOADTHROAT      = GetFirstID('Whistrix_Toadthroat')      or 17326452,
        SLINKIX_TRUFFLESNIFF     = GetFirstID('Slinkix_Trufflesniff')     or 17326458,
        SHISOX_WIDEBROW          = GetFirstID('Shisox_Widebrow')          or 17326463,
        SWYPESTIX_TIGERSHINS     = GetFirstID('Swypestix_Tigershins')     or 17326405,
        DRAKLIX_SCALECRUST       = GetFirstID('Draklix_Scalecrust')       or 17326421,
        MORBLOX_CHUBBYCHIN       = GetFirstID('Morblox_Chubbychin')       or 17326446,
        HUMEGUTTER_ADZJBADJ      = GetFirstID('Humegutter_Adzjbadj')      or 17326212,
        COBRACLAW_BUCHZVOTCH     = GetFirstID('Cobraclaw_Buchzvotch')     or 17326218,
        WRAITHDANCER_GIDBNOD     = GetFirstID('Wraithdancer_Gidbnod')     or 17326223,
        TARUROASTER_BIGGSJIG     = GetFirstID('Taruroaster_Biggsjig')     or 17326262,
        SPINALSUCKER_GALFLMALL   = GetFirstID('Spinalsucker_Galflmall')   or 17326237,
        LOCKBUSTER_ZAPDJIPP      = GetFirstID('Lockbuster_Zapdjipp')      or 17326243,
        HEAVYMAIL_DJIDZBAD       = GetFirstID('Heavymail_Djidzbad')       or 17326248,
        SKINMASK_UGGHFOGG        = GetFirstID('Skinmask_Ugghfogg')        or 17326258,
        MITHRASLAVER_DEBHABOB    = GetFirstID('Mithraslaver_Debhabob')    or 17326265,
        ULTRASONIC_ZEKNAJAK      = GetFirstID('Ultrasonic_Zeknajak')      or 17326270,
        GALKARIDER_RETZPRATZ     = GetFirstID('Galkarider_Retzpratz')     or 17326229,
        ELVAANLOPPER_GROKDOK     = GetFirstID('Elvaanlopper_Grokdok')     or 17326255,
        JEUNORAIDER_GEPKZIP      = GetFirstID('Jeunoraider_Gepkzip')      or 17326216,
        DRAKEFEAST_WUBMFUB       = GetFirstID('Drakefeast_Wubmfub')       or 17326273,
        DEATHCALLER_BIDFBID      = GetFirstID('Deathcaller_Bidfbid')      or 17326233,
        GUNHA_WALLSTORMER        = GetFirstID('GuNha_Wallstormer')        or 17326106,
        SOZHO_METALBENDER        = GetFirstID('SoZho_Metalbender')        or 17326168,
        GAFHO_VENOMTOUCH         = GetFirstID('GaFho_Venomtouch')         or 17326135,
        DEBHO_PYROHAND           = GetFirstID('DeBho_Pyrohand')           or 17326156,
        NAHYA_FLOODMAKER         = GetFirstID('NaHya_Floodmaker')         or 17326114,
        JIFHU_INFILTRATOR        = GetFirstID('JiFhu_Infiltrator')        or 17326126,
        MUGHA_LEGIONKILLER       = GetFirstID('MuGha_Legionkiller')       or 17326173,
        TAHYU_GALLANTHUNTER      = GetFirstID('TaHyu_Gallanthunter')      or 17326145,
        SOGHO_ADDERHANDLER       = GetFirstID('SoGho_Adderhandler')       or 17326179,
        NUBHI_SPIRALEYE          = GetFirstID('NuBhi_Spiraleye')          or 17326151,
        GUKHU_DUKESNIPER         = GetFirstID('GuKhu_Dukesniper')         or 17326185,
        JIKHU_TOWERCLEAVER       = GetFirstID('JiKhu_Towercleaver')       or 17326190,
        MIRHE_WHISPERBLADE       = GetFirstID('MiRhe_Whisperblade')       or 17326195,
        GOTYO_MAGENAPPER         = GetFirstID('GoTyo_Magenapper')         or 17326162,
        BEZHE_KEEPRAZER          = GetFirstID('BeZhe_Keeprazer')          or 17326201,
        FOO_PEKU_THE_BLOODCLOAK  = GetFirstID('Foo_Peku_the_Bloodcloak')  or 17326284,
        XAA_CHAU_THE_ROCTALON    = GetFirstID('Xaa_Chau_the_Roctalon')    or 17326289,
        KOO_SAXU_THE_EVERFAST    = GetFirstID('Koo_Saxu_the_Everfast')    or 17326295,
        BHUU_WJATO_THE_FIREPOOL  = GetFirstID('Bhuu_Wjato_the_Firepool')  or 17326300,
        CAA_XAZA_THE_MADPIERCER  = GetFirstID('Caa_Xaza_the_Madpiercer')  or 17326304,
        RYY_QIHI_THE_IDOLROBBER  = GetFirstID('Ryy_Qihi_the_Idolrobber')  or 17326313,
        GUU_WAJI_THE_PREACHER    = GetFirstID('Guu_Waji_the_Preacher')    or 17326319,
        NEE_HUXA_THE_JUDGMENTAL  = GetFirstID('Nee_Huxa_the_Judgmental')  or 17326323,
        SOO_JOPO_THE_FIENDKING   = GetFirstID('Soo_Jopo_the_Fiendking')   or 17326328,
        XHOO_FUZA_THE_SUBLIME    = GetFirstID('Xhoo_Fuza_the_Sublime')    or 17326335,
        HEE_MIDA_THE_METICULOUS  = GetFirstID('Hee_Mida_the_Meticulous')  or 17326340,
        KNII_HOQO_THE_BISECTOR   = GetFirstID('Knii_Hoqo_the_Bisector')   or 17326344,
        KUU_XUKA_THE_NIMBLE      = GetFirstID('Kuu_Xuka_the_Nimble')      or 17326325,
        MAA_ZAUA_THE_WYRMKEEPER  = GetFirstID('Maa_Zaua_the_Wyrmkeeper')  or 17326307,
        PUU_TIMU_THE_PHANTASMAL  = GetFirstID('Puu_Timu_the_Phantasmal')  or 17326347,
    },
    npc =
    {
        QM =
        {
            [17326801] =
            {
                param = { 3357, 3424, 3425, 3426, 3427, 3428 },
                trade =
                {
                    { item = 3357,                             mob = 17326081 }, -- Angra Mainyu
                    { item = { 3424, 3425, 3426, 3427, 3428 }, mob = 17326098 }, -- Arch Angra Mainyu
                }
            },

            [17326802] = { trade = { { item = 3396, mob = 17326093 } } }, -- Taquede
            [17326803] = { trade = { { item = 3397, mob = 17326095 } } }, -- Pignonpausard
            [17326804] = { trade = { { item = 3398, mob = 17326096 } } }, -- Hitaume
            [17326805] = { trade = { { item = 3399, mob = 17326097 } } }, -- Cavanneche
            [17326806] = { trade = { { item = 3359, mob = 17326086 } } }, -- Goublefaupe
            [17326807] = { trade = { { item = 3360, mob = 17326087 } } }, -- Quiebitiel
            [17326808] = { trade = { { item = 3361, mob = 17326088 } } }, -- Mildaunegeux
            [17326809] = { trade = { { item = 3362, mob = 17326089 } } }, -- Velosareon
            [17326810] = { trade = { { item = 3363, mob = 17326090 } } }, -- Dagourmarche
        },
    },
}

return zones[xi.zone.DYNAMIS_BEAUCEDINE]
