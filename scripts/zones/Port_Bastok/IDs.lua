-----------------------------------
-- Area: Port_Bastok
-----------------------------------
zones = zones or {}

zones[xi.zone.PORT_BASTOK] =
{
    text =
    {
        NOTHING_HAPPENS               = 119,   -- Nothing happens...
        ASSIST_CHANNEL                = 6380,  -- You will be able to use the Assist Channel until #/#/# at #:# (JST).
        ITEM_CANNOT_BE_OBTAINED       = 6386,  -- You cannot obtain the <item>. Come back after sorting your inventory.
        FULL_INVENTORY_AFTER_TRADE    = 6387,  -- You cannot obtain the <item>. Try trading again after sorting your inventory.
        ITEM_OBTAINED                 = 6391,  -- Obtained: <item>.
        GIL_OBTAINED                  = 6392,  -- Obtained <number> gil.
        KEYITEM_OBTAINED              = 6394,  -- Obtained key item: <keyitem>.
        KEYITEM_LOST                  = 6395,  -- Lost key item: <keyitem>.
        NOT_HAVE_ENOUGH_GIL           = 6396,  -- You do not have enough gil.
        ITEM_RETURNED                 = 6400,  -- The <item> is returned to you.
        CARRIED_OVER_POINTS           = 6410,  -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY       = 6411,  -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!
        LOGIN_NUMBER                  = 6412,  -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        MEMBERS_LEVELS_ARE_RESTRICTED = 6432,  -- Your party is unable to participate because certain members' levels are restricted.
        YOU_LEARNED_TRUST             = 6835,  -- You learned Trust: <name>!
        CALL_MULTIPLE_ALTER_EGO       = 6836,  -- You are now able to call multiple alter egos.
        HOMEPOINT_SET                 = 6526,  -- Home point set!
        CONQUEST_BASE                 = 6549,  -- Tallying conquest results...
        TENSHODO_SHOP_OPEN_DIALOG     = 6649,  -- Ah, one of our members. Welcome to the Tenshodo shop.
        MOG_LOCKER_OFFSET             = 6745,  -- Your Mog Locker lease is valid until <timestamp>, kupo.
        MAP_MARKER_TUTORIAL           = 7110,  -- Selecting Map from the main menu opens the map of the area in which you currently reside. Select Markers and press the right arrow key to see all the markers placed on your map.
        FISHING_MESSAGE_OFFSET        = 7121,  -- You can't fish here.
        RECEIVE_BAYLD                 = 7219,  -- You receive <number> bayld!
        POWHATAN_DIALOG_1             = 7332,  -- I'm sick and tired of entertaining guests.
        YOU_ACCEPT_THE_MISSION        = 7381,  -- You have accepted the mission.
        ORIGINAL_MISSION_OFFSET       = 7386,  -- You can consult the Mission section of the main menu to review your objectives. Speed and efficiency are your priorities. Dismissed.
        RONAN_DIALOG_1                = 7906,  -- Do something! Isn't there anything you can do to make him come out of his shell?
        EVELYN_CLOSED_DIALOG          = 7915,  -- Sorry, I don't have anything to sell you. I'm trying to start a business selling goods from Gustaberg, but it's not easy getting stuff from areas that aren't under Bastokan control.
        ROSSWALD_CLOSED_DIALOG        = 7916,  -- Sorry, I don't have anything to sell you. I'm trying to start a business selling goods from Zulkheim, but it's not easy getting stuff from areas that aren't under Bastokan control.
        BELKA_CLOSED_DIALOG           = 7917,  -- Sorry, I don't have anything to sell you. I'm trying to start a business selling goods from Derfland, but it's not easy getting stuff from areas that aren't under Bastokan control.
        VATTIAN_CLOSED_DIALOG         = 7918,  -- I'm trying to start a business selling goods from Kuzotz, but it's not easy getting stuff from areas that aren't under Bastokan control.
        VALERIANO_SHOP_DIALOG         = 7954,  -- Welcome to the Troupe Valeriano. Valeriano, at your service! Have a laugh, then spend some cash! Treats and sweets from exotic lands!
        DAHJAL_BASTOK_CIT             = 7976,  -- You guys must've worked real hard. Bastok is a much nicer place now than when I left it. I wish I could go back to bashing monsters again, like in the old days.
        DAHJAL_NOT_BASTOK_CIT         = 7977,  -- How do you like Bastok? It's my hometown, you know! Sure, there are still some...unsightly elements, but it's still the best city in the world!
        MOKOP_BASTOK_CIT              = 7978,  -- The music store here sells really good instruments! Shh, don't tell the boss...but I'm gonna-wanna sneak off and go there later.
        MOKOP_NOT_BASTOK_CIT          = 7979,  -- There are plenty of bards around, but I'm the best harpist in Vana'diel. You don't believe me? Then stay awhile and listen.
        CHEH_WINDY_CIT                = 7980,  -- The food here's terrrible! C'mon, Windurrrstians, work harder! I miss Windurstian cuisine!
        CHEH_NOT_WINDY_CIT            = 7981,  -- Like to see my new knife trrrick? Good, but keep your distance if you value your various extremities and bodily protrusions!
        NALTA_SANDY_CIT               = 7982,  -- This place...is tiring...
        NALTA_NOT_SANDY_CIT           = 7983,  -- ... (I'm a mime.)
        SAWYER_SHOP_DIALOG            = 7984,  -- Hi, there. For here or to go?
        MELLOA_SHOP_DIALOG            = 7985,  -- Welcome to the Steaming Sheep. Would you like something to drink?
        ARRIVING_PASSENGER_DIALOG     = 7989,  -- Hello. This concourse is for arriving passengers.
        DEPARTING_PASSENGER_DIALOG    = 7990,  -- Hello. This concourse is for departing passengers.
        EVELYN_OPEN_DIALOG            = 7991,  -- Hello! Might I interest you in some specialty goods from Gustaberg?
        GALVIN_SHOP_DIALOG            = 7992,  -- Welcome to Galvin's Travel Gear! We do our best to get the best for only the best!
        NUMA_SHOP_DIALOG              = 7994,  -- Hello, hello! Won't you buy something? I'll give you a rebate!
        BELKA_OPEN_DIALOG             = 7993,  -- Welcome. I've got goods from Derfland. Interested?
        ROSSWALD_OPEN_DIALOG          = 7995,  -- Hello, hello! Everything I have is imported directly from Zulkheim!
        ILITA_SHOP_DIALOG             = 7996,  -- Hello there. How about buying <item> to stay in touch with your friends?
        SUGANDHI_SHOP_DIALOG          = 7997,  -- Traveler! I am sure my wares will prove useful on your journey. Why don't you buy some?
        DENVIHR_SHOP_DIALOG           = 7998,  -- Ah, interested in my wares, are you? You can only buy these in Bastok, my friend.
        PAUJEAN_DIALOG_1              = 7999,  -- Where can you find them? If you're the kind of adventurer I think you are, you should have a pretty good idea. Just don't do anything I wouldn't...heh heh.
        MOGHOUSE_EXIT                 = 8000,  -- You have learned your way through the back alleys of Bastok! Now you can exit to any area from your residence.
        CONQUEST                      = 8041,  -- You've earned conquest points!
        RECEIVED_CONQUEST_POINTS      = 8166,  -- You received <number> conquest points!
        VATTIAN_OPEN_DIALOG           = 8169,  -- Welcome to my humble establishment. I have a wide variety of specialty goods from Kuzotz.
        ZOBYQUHYO_OPEN_DIALOG         = 8402,  -- Hey therrre! I've got lots of wonderrrful goodies, fresh from the Elshimo Lowlands.
        ZOBYQUHYO_CLOSED_DIALOG       = 8403,  -- I'm trrrying to start a business selling goods from the Elshimo Lowlands, but it's not easy getting stuff from areas that aren't under Bastokan contrrrol.
        DHENTEVRYUKOH_OPEN_DIALOG     = 8404,  -- Welcome! Welcome! Take a wonderrr at these specialty goods from the Elshimo Uplands!
        DHENTEVRYUKOH_CLOSED_DIALOG   = 8405,  -- I'm trrrying to start a business selling goods from the Elshimo Uplands, but it's not easy transporting goods from areas that aren't under Bastokan contrrrol.
        UNLOCK_NINJA                  = 8468,  -- You can now become a ninja.
        EXTENDED_MISSION_OFFSET       = 8503,  -- Go to Ore Street and talk to Medicine Eagle. He says he was there when the commotion started.
        TITAN_UNLOCKED                = 8528,  -- You are now able to summon [Ifrit/Titan/Leviathan/Garuda/Shiva/Ramuh].
        BLABBIVIX_SHOP_DIALOG         = 8599,  -- <Pshooowaaaaa> I come from the underworld. These chipshhh, you knooow, are popular among us Goblinshhh. Use with heart of shhhtatue.
        NOKKHI_BAD_COUNT              = 8836,  -- What kinda smart-alecky baloney is this!? I told you to bring me the same kinda ammunition in complete sets. And don't forget the flowers, neither.
        NOKKHI_GOOD_TRADE             = 8837,  -- And here you go! Come back soon, and bring your friends!
        NOKKHI_BAD_ITEM               = 8838,  -- I'm real sorry, but there's nothing I can do with those.
        ASURAN_FISTS_LEARNED          = 8846,  -- You have learned the weapon skill Asuran Fists!
        SUSPICIOUS_CHARACTERS         = 8855,  -- It's my job to look out for suspicious characters coming in on the airships.
        BAGNOBROK_CLOSED_DIALOG       = 9106,  -- Kbastok sis kweak! Smoblins yonly twant gstrong sfriends! Non sgoods mfrom Smovalpolos ytoday!
        BAGNOBROK_OPEN_DIALOG         = 9107,  -- Kbastok! Crepublic sis gstrong! Smoblins lsell sgoods oto gstrong sfriends!
        CLOUD_BAD_COUNT               = 9262,  -- Well, don't just stand there like an idiot! I can't do any bundlin' until you fork over a set of 99 tools and <item>! And I ain't doin' no more than seven sets at one time, so don't even try it!
        CLOUD_GOOD_TRADE              = 9263,  -- Here, take 'em and scram. And don't say I ain't never did nothin' for you!
        CLOUD_BAD_ITEM                = 9264,  -- What the hell is this junk!? Why don't you try bringin' what I asked for before I shove one of my sandals up your...nose!
        IMPERIAL_STANDING_INCREASED   = 12708, -- Your Imperial Standing has increased!
        EARNED_ALLIED_NOTES           = 12709, -- You have earned <number> Allied Note[/s]!
        OBTAINED_GUILD_POINTS         = 12710, -- Obtained: <number> guild points.
        OBTAINED_NUM_KEYITEMS         = 13104, -- Obtained key item: <number> <keyitem>!
        NOT_ACQUAINTED                = 14106, -- I'm sorry, but I don't believe we're acquainted. Please leave me be.
        UNABLE_RACE_CHANGE            = 14209, -- You were unable to use the specified appearance for your character.
    },
    mob =
    {
    },
    npc =
    {
        DRAWBRIDGE_1 = GetFirstID('_6ke'),
        DRAWBRIDGE_2 = GetFirstID('_6ks'),
        DRAWBRIDGE_3 = GetFirstID('_6kt'),
    },
}

return zones[xi.zone.PORT_BASTOK]
