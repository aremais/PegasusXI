-----------------------------------
-- Area: Walk_of_Echoes
-----------------------------------
zones = zones or {}

zones[xi.zone.WALK_OF_ECHOES] =
{
    text =
    {
        ITEM_CANNOT_BE_OBTAINED       = 6385, -- You cannot obtain the <item>. Come back after sorting your inventory.
        ITEM_OBTAINED                 = 6391, -- Obtained: <item>.
        GIL_OBTAINED                  = 6392, -- Obtained <number> gil.
        KEYITEM_OBTAINED              = 6394, -- Obtained key item: <keyitem>.
        NOTHING_OUT_OF_ORDINARY       = 6405, -- There is nothing out of the ordinary here.
        CARRIED_OVER_POINTS           = 7002, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY       = 7003, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!
        LOGIN_NUMBER                  = 7004, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        MEMBERS_LEVELS_ARE_RESTRICTED = 7024, -- Your party is unable to participate because certain members' levels are restricted.
        CANNOT_PROGRESS_MISSION       = 7048, -- ou are unable to make further progress in Rhapsodies of Vana'diel due to an event occurring in the [Chains of Promathia/Treasures of Aht Urhgan/Wings of the Goddess/Seekers of Adoulin/Rise of the Zilart] missions.
        CANNOT_PROGRESS_QUEST         = 7049, -- ou are unable to make further progress in Rhapsodies of Vana'diel due to an event occurring in the quest [Champion of the Dawn/A Forbidden Reunion].
        TIME_IN_THE_BATTLEFIELD_IS_UP = 7072, -- Your time in the battlefield is up! Now exiting...
        PARTY_MEMBERS_ARE_ENGAGED     = 7087, -- The battlefield where your party members are engaged in combat is locked. Access is denied.
        NO_BATTLEFIELD_ENTRY          = 7099, -- You can hear a faint scraping sound from within, but the way is barred by some strange membrane...
        MEMBERS_OF_YOUR_PARTY         = 7378, -- Currently, # members of your party (including yourself) have clearance to enter the battlefield.
        MEMBERS_OF_YOUR_ALLIANCE      = 7379, -- Currently, # members of your alliance (including yourself) have clearance to enter the battlefield.
        TIME_LIMIT_FOR_THIS_BATTLE_IS = 7381, -- The time limit for this battle is <number> minutes.
        ENTERING_THE_BATTLEFIELD_FOR  = 7604, -- Entering the battlefield for [Flames for the Dead/Follow the White Rabbit/When Hell Freezes Over/Brothers/Holy Cow/Taurassic Park]!
        PARTY_MEMBERS_HAVE_FALLEN     = 7659, -- All party members have fallen in battle. Now leaving the battlefield.
        THE_PARTY_WILL_BE_REMOVED     = 7666, -- If all party members' HP are still zero after # minute[/s], the party will be removed from the battlefield.
        GATHERED_DAWNDROPS_LIGHT      = 7979, -- The gathered dawndrops unleash a brilliant light, melding together to form <keyitem>!
        RETRACED_ALL_JUNCTIONS        = 7980, -- You have retraced all junctions of eventualities. Hasten back to where Cait Sith and Lilisette await.
    },
    mob =
    {
        -- Maiden of the Dusk (BCNM, sql/mob_spawn_points "Maiden of the Dusk (WOTG51)")
        LADY_LILITH                = 17523185,
        LILITH_ASCENDANT           = 17523186,
        ELEMENTAL_GYVES_OFFSET     = 17523187, -- 17523187..17523196 (10)
    },
    npc =
    {
    },
}

return zones[xi.zone.WALK_OF_ECHOES]
