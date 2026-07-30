-----------------------------------
-- Area: Yhoator_Jungle
-----------------------------------
zones = zones or {}

zones[xi.zone.YHOATOR_JUNGLE] =
{
    text =
    {
        ITEM_CANNOT_BE_OBTAINED       = 6386,  -- You cannot obtain the <item>. Come back after sorting your inventory.
        ITEM_OBTAINED                 = 6391,  -- Obtained: <item>.
        GIL_OBTAINED                  = 6392,  -- Obtained <number> gil.
        KEYITEM_OBTAINED              = 6394,  -- Obtained key item: <keyitem>.
        KEYITEM_LOST                  = 6395,  -- Lost key item: <keyitem>.
        NOTHING_OUT_OF_ORDINARY       = 6405,  -- There is nothing out of the ordinary here.
        FELLOW_MESSAGE_OFFSET         = 6420,  -- I'm ready. I suppose.
        CARRIED_OVER_POINTS           = 7002,  -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY       = 7003,  -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!
        LOGIN_NUMBER                  = 7004,  -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        MEMBERS_LEVELS_ARE_RESTRICTED = 7024,  -- Your party is unable to participate because certain members' levels are restricted.
        CONQUEST_BASE                 = 7069,  -- Tallying conquest results...
        REGION_POINTS_SANDORIA        = 7134,  -- San d'Oria's region points have increased!
        EXP_FORCE_KILL_SANDORIA       = 7137,  -- San d'Orian E.F. defeats beastmen hordes... Maintain current momentum.
        BEASTMEN_BANNER_CURSE         = 7148,  -- There was a curse on the beastmen's banner!
        BEASTMEN_BANNER_LIFTED        = 7149,  -- The curse of the beastmen's banner has been lifted!
        BEASTMEN_BANNER               = 7150,  -- There is a beastmen's banner.
        CONQUEST                      = 7237,  -- You've earned conquest points!
        FISHING_MESSAGE_OFFSET        = 7570,  -- You can't fish here.
        DIG_THROW_AWAY                = 7583,  -- You dig up <item>, but your inventory is full. You regretfully throw the <item> away.
        FIND_NOTHING                  = 7585,  -- You dig and you dig, but find nothing.
        AMK_DIGGING_OFFSET            = 7651,  -- You spot some familiar footprints. You are convinced that your moogle friend has been digging in the immediate vicinity.
        FOUND_ITEM_WITH_EASE          = 7660,  -- It appears your chocobo found this item with ease.
        ALREADY_OBTAINED_TELE         = 7671,  -- You already possess the gate crystal for this telepoint.
        LOGGING_IS_POSSIBLE_HERE      = 7684,  -- Logging is possible here if you have <item>.
        HARVESTING_IS_POSSIBLE_HERE   = 7691,  -- Harvesting is possible here if you have <item>.
        TREE_CHECK                    = 7698,  -- The hole in this tree is filled with a sweet-smelling liquid.
        TREE_FULL                     = 7699,  -- Your wine barrel is already full.
        CHILL_RUNS_DOWN               = 7700,  -- A chill runs down your spine...
        WATER_HOLE                    = 7702,  -- There is an Opo-opo drinking well here. It seems they feast here, too.
        FAINT_CRY                     = 7703,  -- You hear the cry of a famished Opo-opo!
        PAMAMAS                       = 7706,  -- You might be able to draw an Opo-opo here if you had more pamamas.
        SOMETHING_IS_BURIED_HERE      = 7743,  -- It looks like something is buried here. If you had <item> you could dig it up.
        GARRISON_BASE                 = 7753,  -- Hm? What is this? %? How do I know this is not some [San d'Orian/Bastokan/Windurstian] trick?
        TIME_ELAPSED                  = 7800,  -- Time elapsed: <number> [hour/hours] (Vana'diel time) <number> [minute/minutes] and <number> [second/seconds] (Earth time)
        PLAYER_OBTAINS_ITEM           = 7832,  -- <name> obtains <item>!
        UNABLE_TO_OBTAIN_ITEM         = 7833,  -- You were unable to obtain the item.
        PLAYER_OBTAINS_TEMP_ITEM      = 7834,  -- <name> obtains the temporary item: <item>!
        ALREADY_POSSESS_TEMP          = 7835,  -- You already possess that temporary item.
        NO_COMBINATION                = 7840,  -- You were unable to enter a combination.
        UNITY_WANTED_BATTLE_INTERACT  = 7902,  -- Those who have accepted % must pay # Unity accolades to participate. The content for this Wanted battle is #. [Ready to begin?/You do not have the appropriate object set, so your rewards will be limited.]
        REGIME_REGISTERED             = 10018, -- New training regime registered!
        COMMON_SENSE_SURVIVAL         = 11137, -- It appears that you have arrived at a new survival guide provided by the Adventurers' Mutual Aid Network. Common sense dictates that you should now be able to teleport here from similar tomes throughout the world.
    },
    mob =
    {
        BISQUE_HEELED_SUNBERRY = GetFirstID('Bisque-heeled_Sunberry'),
        BRIGHT_HANDED_KUNBERRY = GetFirstID('Bright-handed_Kunberry'),
        EDACIOUS_OPO_OPO       = GetFirstID('Edacious_Opo-opo'),
        HOAR_KNUCKLED_RIMBERRY = GetFirstID('Hoar-knuckled_Rimberry'),
        HOBGOBLIN_BEASTMASTER  = GetFirstID('Hobgoblin_Beastmaster'),
        HOBGOBLIN_BLACK_MAGE   = GetFirstID('Hobgoblin_Black_Mage'),
        HOBGOBLIN_DARK_KNIGHT  = GetFirstID('Hobgoblin_Dark_Knight'),
        HOBGOBLIN_RANGER       = GetFirstID('Hobgoblin_Ranger'),
        HOBGOBLIN_RED_MAGE     = GetFirstID('Hobgoblin_Red_Mage'),
        HOBGOBLIN_THIEF        = GetFirstID('Hobgoblin_Thief'),
        HOBGOBLIN_WARRIOR      = GetFirstID('Hobgoblin_Warrior'),
        HOBGOBLIN_WHITE_MAGE   = GetFirstID('Hobgoblin_White_Mage'),
        KAPPA_AKUSO            = GetFirstID('Kappa_Akuso'),
        KAPPA_BIWA             = GetFirstID('Kappa_Biwa'),
        KAPPA_BONZE            = GetFirstID('Kappa_Bonze'),
        NOCTONBERRY_BLACK_MAGE = GetFirstID('Noctonberry_Black_Mage'),
        NOCTONBERRY_NINJA      = GetFirstID('Noctonberry_Ninja'),
        NOCTONBERRY_SUMMONER   = GetFirstID('Noctonberry_Summoner'),
        NOCTONBERRY_THIEF      = GetFirstID('Noctonberry_Thief'),
        POWDERER_PENNY         = GetFirstID('Powderer_Penny'),
        WOODLAND_SAGE          = GetFirstID('Woodland_Sage'),
    },
    npc =
    {
        BEASTMEN_TREASURE_OFFSET = GetFirstID('qm4'),
        BEASTMENS_BANNER         = GetFirstID('Beastmens_Banner'),
        OVERSEER_BASE            = GetFirstID('Ilieumort_RK'),
        PEDDLESTOX               = GetFirstID('Peddlestox'),

        HARVESTING = GetTableOfIDs('Harvesting_Point'),
        LOGGING    = GetTableOfIDs('Logging_Point'),
    },
}

return zones[xi.zone.YHOATOR_JUNGLE]
