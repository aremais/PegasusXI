-----------------------------------
-- Area: Port Jeuno
--  NPC: Monisette
-- !pos -6 0 -11 246
-- Reforges Artifact, Relic, and Empyrean armor to i109/i119 variants.
-- Stores Rem's Tales chapters for players.
-- Custom changes: No Sagheera interaction required, no Limbus access
-- required, no Vagary items required for Empyrean reforge.
-----------------------------------
local ID = zones[xi.zone.PORT_JEUNO]
-----------------------------------
---@type TNpcEntity
local entity = {}

-----------------------------------
-- Rem's Tales storage
-- Tracks stored chapter counts per player via character variables.
-----------------------------------
local remsTaleItems =
{
    xi.item.COPY_OF_REMS_TALE_CHAPTER_1,
    xi.item.COPY_OF_REMS_TALE_CHAPTER_2,
    xi.item.COPY_OF_REMS_TALE_CHAPTER_3,
    xi.item.COPY_OF_REMS_TALE_CHAPTER_4,
    xi.item.COPY_OF_REMS_TALE_CHAPTER_5,
    xi.item.COPY_OF_REMS_TALE_CHAPTER_6,
    xi.item.COPY_OF_REMS_TALE_CHAPTER_7,
    xi.item.COPY_OF_REMS_TALE_CHAPTER_8,
    xi.item.COPY_OF_REMS_TALE_CHAPTER_9,
    xi.item.COPY_OF_REMS_TALE_CHAPTER_10,
}

local maxStoredTales = 99

local function getStoredTales(player, chapter)
    return player:getCharVar('MonisetteRemsTale' .. chapter)
end

local function setStoredTales(player, chapter, count)
    player:setCharVar('MonisetteRemsTale' .. chapter, count)
end

-----------------------------------
-- Artifact Armor Reforge i109
-- Path 1: Base AF + 10x Rem's Tale (Ch.1 head/Ch.2 body/Ch.3 hands/Ch.4 legs/Ch.5 feet)
--         + job ingredient + slot ingredient -> Reforged i109 (P2)
-- Path 2: AF+1 + 5x same Rem's Tale -> same Reforged i109 (P2)
--
-- Entries   1-105: Path 1 (base AF piece)
-- Entries 106-200: Path 2 (AF+1 piece, WAR-DNC/M)
-- Entries 316-325: Path 2 (AF+1 piece, DNC/F and SCH — offset to avoid key collision with afReforgeI119 [201-315])
--
-- P2 output layout: base 23040 + job_offset + slot_offset
--   WAR=0 MNK=1 WHM=2 BLM=3 RDM=4 THF=5 PLD=6 DRK=7 BST=8 BRD=9
--   RNG=10 SAM=11 NIN=12 DRG=13 SMN=14 BLU=15 COR=16 PUP=17 DNC(M)=18 DNC(F)=19 SCH=20
--   Head+0  Body+67  Hands+134  Legs+201  Feet+268
-----------------------------------
local afReforgeI109 =
{
    -- WAR (Pummeler's) - Tiger Leather
    [  1] = { trade = { 12511, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, xi.item.PHOENIX_FEATHER         }, reward = 23040 }, -- head
    [  2] = { trade = { 12638, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 23107 }, -- body
    [  3] = { trade = { 13961, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 23174 }, -- hands
    [  4] = { trade = { 14214, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 23241 }, -- legs
    [  5] = { trade = { 14089, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, xi.item.PIECE_OF_OXBLOOD           }, reward = 23308 }, -- feet
    -- MNK (Anchorite's) - Gold Thread
    [  6] = { trade = { 12512, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.PHOENIX_FEATHER         }, reward = 23041 },
    [  7] = { trade = { 12639, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 23108 },
    [  8] = { trade = { 13962, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 23175 },
    [  9] = { trade = { 14215, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 23242 },
    [ 10] = { trade = { 14090, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.PIECE_OF_OXBLOOD           }, reward = 23309 },
    -- WHM (Theophany) - Imp. Silk Cloth
    [ 11] = { trade = { 13855, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.PHOENIX_FEATHER         }, reward = 23042 },
    [ 12] = { trade = { 12640, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 23109 },
    [ 13] = { trade = { 13963, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 23176 },
    [ 14] = { trade = { 14216, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 23243 },
    [ 15] = { trade = { 14091, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.PIECE_OF_OXBLOOD           }, reward = 23310 },
    -- BLM (Spaekona's) - Karakul Cloth
    [ 16] = { trade = { 13856, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.PHOENIX_FEATHER         }, reward = 23043 },
    [ 17] = { trade = { 12641, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 23110 },
    [ 18] = { trade = { 13964, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 23177 },
    [ 19] = { trade = { 14217, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 23244 },
    [ 20] = { trade = { 14092, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.PIECE_OF_OXBLOOD           }, reward = 23311 },
    -- RDM (Atrophy) - Scarlet Linen
    [ 21] = { trade = { 12513, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.PHOENIX_FEATHER         }, reward = 23044 },
    [ 22] = { trade = { 12642, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 23111 },
    [ 23] = { trade = { 13965, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 23178 },
    [ 24] = { trade = { 14218, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 23245 },
    [ 25] = { trade = { 14093, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.PIECE_OF_OXBLOOD           }, reward = 23312 },
    -- THF (Pillager's) - Gold Thread
    [ 26] = { trade = { 12514, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.PHOENIX_FEATHER         }, reward = 23045 },
    [ 27] = { trade = { 12643, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 23112 },
    [ 28] = { trade = { 13966, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 23179 },
    [ 29] = { trade = { 14219, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 23246 },
    [ 30] = { trade = { 14094, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.PIECE_OF_OXBLOOD           }, reward = 23313 },
    -- PLD (Reverence) - Gold Sheet
    [ 31] = { trade = { 12515, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.GOLD_SHEET, xi.item.PHOENIX_FEATHER         }, reward = 23046 },
    [ 32] = { trade = { 12644, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.GOLD_SHEET, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 23113 },
    [ 33] = { trade = { 13967, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.GOLD_SHEET, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 23180 },
    [ 34] = { trade = { 14220, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.GOLD_SHEET, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 23247 },
    [ 35] = { trade = { 14095, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.GOLD_SHEET, xi.item.PIECE_OF_OXBLOOD           }, reward = 23314 },
    -- DRK (Ignominy) - Darksteel Sheet
    [ 36] = { trade = { 12516, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.DARKSTEEL_SHEET, xi.item.PHOENIX_FEATHER         }, reward = 23047 },
    [ 37] = { trade = { 12645, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.DARKSTEEL_SHEET, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 23114 },
    [ 38] = { trade = { 13968, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.DARKSTEEL_SHEET, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 23181 },
    [ 39] = { trade = { 14221, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.DARKSTEEL_SHEET, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 23248 },
    [ 40] = { trade = { 14096, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.DARKSTEEL_SHEET, xi.item.PIECE_OF_OXBLOOD           }, reward = 23315 },
    -- BST (Totemic) - Tiger Leather
    [ 41] = { trade = { 12517, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, xi.item.PHOENIX_FEATHER         }, reward = 23048 },
    [ 42] = { trade = { 12646, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 23115 },
    [ 43] = { trade = { 13969, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 23182 },
    [ 44] = { trade = { 14222, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 23249 },
    [ 45] = { trade = { 14097, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, xi.item.PIECE_OF_OXBLOOD           }, reward = 23316 },
    -- BRD (Brioso) - Imp. Silk Cloth
    [ 46] = { trade = { 13857, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.PHOENIX_FEATHER         }, reward = 23049 },
    [ 47] = { trade = { 12647, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 23116 },
    [ 48] = { trade = { 13970, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 23183 },
    [ 49] = { trade = { 14223, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 23250 },
    [ 50] = { trade = { 14098, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.PIECE_OF_OXBLOOD           }, reward = 23317 },
    -- RNG (Orion) - Karakul Cloth
    [ 51] = { trade = { 12518, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.PHOENIX_FEATHER         }, reward = 23050 },
    [ 52] = { trade = { 12648, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 23117 },
    [ 53] = { trade = { 13971, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 23184 },
    [ 54] = { trade = { 14224, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 23251 },
    [ 55] = { trade = { 14099, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.PIECE_OF_OXBLOOD           }, reward = 23318 },
    -- SAM (Wakido) - Tama-Hagane
    [ 56] = { trade = { 13868, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.LUMP_OF_TAMA_HAGANE, xi.item.PHOENIX_FEATHER         }, reward = 23051 },
    [ 57] = { trade = { 13781, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.LUMP_OF_TAMA_HAGANE, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 23118 },
    [ 58] = { trade = { 13972, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.LUMP_OF_TAMA_HAGANE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 23185 },
    [ 59] = { trade = { 14225, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.LUMP_OF_TAMA_HAGANE, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 23252 },
    [ 60] = { trade = { 14100, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.LUMP_OF_TAMA_HAGANE, xi.item.PIECE_OF_OXBLOOD           }, reward = 23319 },
    -- NIN (Hachiya) - Tama-Hagane
    [ 61] = { trade = { 13869, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.LUMP_OF_TAMA_HAGANE, xi.item.PHOENIX_FEATHER         }, reward = 23052 },
    [ 62] = { trade = { 13782, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.LUMP_OF_TAMA_HAGANE, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 23119 },
    [ 63] = { trade = { 13973, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.LUMP_OF_TAMA_HAGANE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 23186 },
    [ 64] = { trade = { 14226, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.LUMP_OF_TAMA_HAGANE, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 23253 },
    [ 65] = { trade = { 14101, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.LUMP_OF_TAMA_HAGANE, xi.item.PIECE_OF_OXBLOOD           }, reward = 23320 },
    -- DRG (Vishap) - Gold Sheet
    [ 66] = { trade = { 12519, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.GOLD_SHEET, xi.item.PHOENIX_FEATHER         }, reward = 23053 },
    [ 67] = { trade = { 12649, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.GOLD_SHEET, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 23120 },
    [ 68] = { trade = { 13974, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.GOLD_SHEET, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 23187 },
    [ 69] = { trade = { 14227, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.GOLD_SHEET, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 23254 },
    [ 70] = { trade = { 14102, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.GOLD_SHEET, xi.item.PIECE_OF_OXBLOOD           }, reward = 23321 },
    -- SMN (Convoker's) - Scarlet Linen
    [ 71] = { trade = { 12520, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.PHOENIX_FEATHER         }, reward = 23054 },
    [ 72] = { trade = { 12650, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 23121 },
    [ 73] = { trade = { 13975, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 23188 },
    [ 74] = { trade = { 14228, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 23255 },
    [ 75] = { trade = { 14103, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.PIECE_OF_OXBLOOD           }, reward = 23322 },
    -- BLU (Assimilator's) - Imp. Silk Cloth
    [ 76] = { trade = { 15265, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.PHOENIX_FEATHER         }, reward = 23055 },
    [ 77] = { trade = { 14521, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 23122 },
    [ 78] = { trade = { 14928, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 23189 },
    [ 79] = { trade = { 15600, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 23256 },
    [ 80] = { trade = { 15684, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.PIECE_OF_OXBLOOD           }, reward = 23323 },
    -- COR (Laksamana's) - Karakul Cloth
    [ 81] = { trade = { 15266, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.PHOENIX_FEATHER         }, reward = 23056 },
    [ 82] = { trade = { 14522, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 23123 },
    [ 83] = { trade = { 14929, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 23190 },
    [ 84] = { trade = { 15601, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 23257 },
    [ 85] = { trade = { 15685, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.PIECE_OF_OXBLOOD           }, reward = 23324 },
    -- PUP (Foire) - Karakul Cloth
    [ 86] = { trade = { 15267, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.PHOENIX_FEATHER         }, reward = 23057 },
    [ 87] = { trade = { 14523, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 23124 },
    [ 88] = { trade = { 14930, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 23191 },
    [ 89] = { trade = { 15602, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 23258 },
    [ 90] = { trade = { 15686, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.PIECE_OF_OXBLOOD           }, reward = 23325 },
    -- DNC/M (Maxixi) - Gold Thread
    [ 91] = { trade = { 16138, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.PHOENIX_FEATHER         }, reward = 23058 },
    [ 92] = { trade = { 14578, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 23125 },
    [ 93] = { trade = { 15002, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 23192 },
    [ 94] = { trade = { 15659, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 23259 },
    [ 95] = { trade = { 15746, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.PIECE_OF_OXBLOOD           }, reward = 23326 },
    -- DNC/F (Maxixi) - Gold Thread
    [ 96] = { trade = { 16139, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.PHOENIX_FEATHER         }, reward = 23059 },
    [ 97] = { trade = { 14579, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 23126 },
    [ 98] = { trade = { 15003, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 23193 },
    [ 99] = { trade = { 15660, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 23260 },
    [100] = { trade = { 15747, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.PIECE_OF_OXBLOOD           }, reward = 23327 },
    -- SCH (Academic's) - Scarlet Linen
    [101] = { trade = { 16140, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.PHOENIX_FEATHER         }, reward = 23060 },
    [102] = { trade = { 14580, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 23127 },
    [103] = { trade = { 15004, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 23194 },
    [104] = { trade = { 16311, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 23261 },
    [105] = { trade = { 15748, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.PIECE_OF_OXBLOOD           }, reward = 23328 },
    -- Path 2: AF+1 + 5x Rem's Tale -> same i109 output (no extra ingredients needed)
    -- WAR
    [106] = { trade = { 15225, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 23040 },
    [107] = { trade = { 14473, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 23107 },
    [108] = { trade = { 14890, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 23174 },
    [109] = { trade = { 15561, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 23241 },
    [110] = { trade = { 15352, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 23308 },
    -- MNK
    [111] = { trade = { 15226, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 23041 },
    [112] = { trade = { 14474, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 23108 },
    [113] = { trade = { 14891, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 23175 },
    [114] = { trade = { 15562, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 23242 },
    [115] = { trade = { 15353, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 23309 },
    -- WHM
    [116] = { trade = { 15227, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 23042 },
    [117] = { trade = { 14475, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 23109 },
    [118] = { trade = { 14892, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 23176 },
    [119] = { trade = { 15563, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 23243 },
    [120] = { trade = { 15354, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 23310 },
    -- BLM
    [121] = { trade = { 15228, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 23043 },
    [122] = { trade = { 14476, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 23110 },
    [123] = { trade = { 14893, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 23177 },
    [124] = { trade = { 15564, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 23244 },
    [125] = { trade = { 15355, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 23311 },
    -- RDM
    [126] = { trade = { 15229, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 23044 },
    [127] = { trade = { 14477, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 23111 },
    [128] = { trade = { 14894, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 23178 },
    [129] = { trade = { 15565, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 23245 },
    [130] = { trade = { 15356, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 23312 },
    -- THF
    [131] = { trade = { 15230, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 23045 },
    [132] = { trade = { 14478, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 23112 },
    [133] = { trade = { 14895, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 23179 },
    [134] = { trade = { 15566, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 23246 },
    [135] = { trade = { 15357, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 23313 },
    -- PLD
    [136] = { trade = { 15231, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 23046 },
    [137] = { trade = { 14479, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 23113 },
    [138] = { trade = { 14896, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 23180 },
    [139] = { trade = { 15567, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 23247 },
    [140] = { trade = { 15358, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 23314 },
    -- DRK
    [141] = { trade = { 15232, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 23047 },
    [142] = { trade = { 14480, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 23114 },
    [143] = { trade = { 14897, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 23181 },
    [144] = { trade = { 15568, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 23248 },
    [145] = { trade = { 15359, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 23315 },
    -- BST
    [146] = { trade = { 15233, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 23048 },
    [147] = { trade = { 14481, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 23115 },
    [148] = { trade = { 14898, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 23182 },
    [149] = { trade = { 15569, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 23249 },
    [150] = { trade = { 15360, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 23316 },
    -- BRD
    [151] = { trade = { 15234, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 23049 },
    [152] = { trade = { 14482, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 23116 },
    [153] = { trade = { 14899, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 23183 },
    [154] = { trade = { 15570, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 23250 },
    [155] = { trade = { 15361, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 23317 },
    -- RNG
    [156] = { trade = { 15235, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 23050 },
    [157] = { trade = { 14483, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 23117 },
    [158] = { trade = { 14900, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 23184 },
    [159] = { trade = { 15571, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 23251 },
    [160] = { trade = { 15362, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 23318 },
    -- SAM
    [161] = { trade = { 15236, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 23051 },
    [162] = { trade = { 14484, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 23118 },
    [163] = { trade = { 14901, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 23185 },
    [164] = { trade = { 15572, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 23252 },
    [165] = { trade = { 15363, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 23319 },
    -- NIN
    [166] = { trade = { 15237, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 23052 },
    [167] = { trade = { 14485, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 23119 },
    [168] = { trade = { 14902, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 23186 },
    [169] = { trade = { 15573, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 23253 },
    [170] = { trade = { 15364, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 23320 },
    -- DRG
    [171] = { trade = { 15238, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 23053 },
    [172] = { trade = { 14486, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 23120 },
    [173] = { trade = { 14903, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 23187 },
    [174] = { trade = { 15574, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 23254 },
    [175] = { trade = { 15365, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 23321 },
    -- SMN
    [176] = { trade = { 15239, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 23054 },
    [177] = { trade = { 14487, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 23121 },
    [178] = { trade = { 14904, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 23188 },
    [179] = { trade = { 15575, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 23255 },
    [180] = { trade = { 15366, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 23322 },
    -- BLU
    [181] = { trade = { 11464, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 23055 },
    [182] = { trade = { 11291, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 23122 },
    [183] = { trade = { 15024, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 23189 },
    [184] = { trade = { 16345, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 23256 },
    [185] = { trade = { 11381, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 23323 },
    -- COR
    [186] = { trade = { 11467, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 23056 },
    [187] = { trade = { 11294, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 23123 },
    [188] = { trade = { 15027, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 23190 },
    [189] = { trade = { 16348, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 23257 },
    [190] = { trade = { 11384, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 23324 },
    -- PUP
    [191] = { trade = { 11470, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 23057 },
    [192] = { trade = { 11297, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 23124 },
    [193] = { trade = { 15030, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 23191 },
    [194] = { trade = { 16351, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 23258 },
    [195] = { trade = { 11387, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 23325 },
    -- DNC/M
    [196] = { trade = { 11475, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 23058 },
    [197] = { trade = { 11302, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 23125 },
    [198] = { trade = { 15035, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 23192 },
    [199] = { trade = { 16357, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 23259 },
    [200] = { trade = { 11393, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 23326 },
    -- DNC/F (keys 316-320: offset to avoid collision with afReforgeI119 [201-315])
    [316] = { trade = { 11476, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 23059 },
    [317] = { trade = { 11303, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 23126 },
    [318] = { trade = { 15036, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 23193 },
    [319] = { trade = { 16358, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 23260 },
    [320] = { trade = { 11394, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 23327 },
    -- SCH (keys 321-325)
    [321] = { trade = { 11477, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 23060 },
    [322] = { trade = { 11304, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 23127 },
    [323] = { trade = { 15037, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 23194 },
    [324] = { trade = { 16359, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 23261 },
    [325] = { trade = { 11395, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 23328 },
}

-----------------------------------
-- Artifact Armor Reforge i119
-- Trade: i109 (P2) piece + 8x Rem's Tale (Ch.6 head/Ch.7 body/Ch.8 hands/Ch.9 legs/Ch.10 feet)
--         + job ingredient + slot ingredient -> i119 (P3)
--
-- Slot ingredients: Maliyakaleya Orb(head) / Hepatizon Ingot(body) / Beryllium Ingot(hands)
--                   Exalted Lumber(legs) / Sif's Macrame(feet)
-- GEO/RUN entries included (P2=23061/23062 range -> P3=23396/23397 range)
-----------------------------------
local afReforgeI119 =
{
    -- WAR (Pummeler's) - Behemoth Leather
    [201] = { trade = { 23040, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SQUARE_OF_BEHEMOTH_LEATHER,     xi.item.MALIYAKALEYA_CORAL }, reward = 23375 }, -- head
    [202] = { trade = { 23107, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SQUARE_OF_BEHEMOTH_LEATHER,     xi.item.HEPATIZON_ORE      }, reward = 23442 }, -- body
    [203] = { trade = { 23174, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SQUARE_OF_BEHEMOTH_LEATHER,     xi.item.BERYLLIUM_ORE      }, reward = 23509 }, -- hands
    [204] = { trade = { 23241, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SQUARE_OF_BEHEMOTH_LEATHER,     xi.item.EXALTED_LOG        }, reward = 23576 }, -- legs
    [205] = { trade = { 23308, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SQUARE_OF_BEHEMOTH_LEATHER,     xi.item.SIFS_LOCK          }, reward = 23643 }, -- feet
    -- MNK (Anchorite's) - Platinum Silk Thread
    [206] = { trade = { 23041, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.MALIYAKALEYA_CORAL }, reward = 23376 },
    [207] = { trade = { 23108, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.HEPATIZON_ORE      }, reward = 23443 },
    [208] = { trade = { 23175, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.BERYLLIUM_ORE      }, reward = 23510 },
    [209] = { trade = { 23242, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.EXALTED_LOG        }, reward = 23577 },
    [210] = { trade = { 23309, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.SIFS_LOCK          }, reward = 23644 },
    -- WHM (Theophany) - Raxa
    [211] = { trade = { 23042, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.MALIYAKALEYA_CORAL }, reward = 23377 },
    [212] = { trade = { 23109, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.HEPATIZON_ORE      }, reward = 23444 },
    [213] = { trade = { 23176, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.BERYLLIUM_ORE      }, reward = 23511 },
    [214] = { trade = { 23243, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.EXALTED_LOG        }, reward = 23578 },
    [215] = { trade = { 23310, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SQUARE_OF_RAXA,                xi.item.SIFS_LOCK          }, reward = 23645 },
    -- BLM (Spaekona's) - Twill Damask
    [216] = { trade = { 23043, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.TWILL_DAMASK,                  xi.item.MALIYAKALEYA_CORAL }, reward = 23378 },
    [217] = { trade = { 23110, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.TWILL_DAMASK,                  xi.item.HEPATIZON_ORE      }, reward = 23445 },
    [218] = { trade = { 23177, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.TWILL_DAMASK,                  xi.item.BERYLLIUM_ORE      }, reward = 23512 },
    [219] = { trade = { 23244, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.TWILL_DAMASK,                  xi.item.EXALTED_LOG        }, reward = 23579 },
    [220] = { trade = { 23311, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.TWILL_DAMASK,                  xi.item.SIFS_LOCK          }, reward = 23646 },
    -- RDM (Atrophy) - Siren's Hair
    [221] = { trade = { 23044, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.MALIYAKALEYA_CORAL }, reward = 23379 },
    [222] = { trade = { 23111, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.HEPATIZON_ORE      }, reward = 23446 },
    [223] = { trade = { 23178, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.BERYLLIUM_ORE      }, reward = 23513 },
    [224] = { trade = { 23245, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.EXALTED_LOG        }, reward = 23580 },
    [225] = { trade = { 23312, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.SIFS_LOCK          }, reward = 23647 },
    -- THF (Pillager's) - Platinum Silk Thread
    [226] = { trade = { 23045, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.MALIYAKALEYA_CORAL }, reward = 23380 },
    [227] = { trade = { 23112, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.HEPATIZON_ORE      }, reward = 23447 },
    [228] = { trade = { 23179, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.BERYLLIUM_ORE      }, reward = 23514 },
    [229] = { trade = { 23246, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.EXALTED_LOG        }, reward = 23581 },
    [230] = { trade = { 23313, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.SIFS_LOCK          }, reward = 23648 },
    -- PLD (Reverence) - Orichalcum Sheet
    [231] = { trade = { 23046, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.ORICHALCUM_SHEET,              xi.item.MALIYAKALEYA_CORAL }, reward = 23381 },
    [232] = { trade = { 23113, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.ORICHALCUM_SHEET,              xi.item.HEPATIZON_ORE      }, reward = 23448 },
    [233] = { trade = { 23180, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.ORICHALCUM_SHEET,              xi.item.BERYLLIUM_ORE      }, reward = 23515 },
    [234] = { trade = { 23247, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.ORICHALCUM_SHEET,              xi.item.EXALTED_LOG        }, reward = 23582 },
    [235] = { trade = { 23314, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.ORICHALCUM_SHEET,              xi.item.SIFS_LOCK          }, reward = 23649 },
    -- DRK (Ignominy) - Durium Sheet
    [236] = { trade = { 23047, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.DURIUM_SHEET,                  xi.item.MALIYAKALEYA_CORAL }, reward = 23382 },
    [237] = { trade = { 23114, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.DURIUM_SHEET,                  xi.item.HEPATIZON_ORE      }, reward = 23449 },
    [238] = { trade = { 23181, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.DURIUM_SHEET,                  xi.item.BERYLLIUM_ORE      }, reward = 23516 },
    [239] = { trade = { 23248, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.DURIUM_SHEET,                  xi.item.EXALTED_LOG        }, reward = 23583 },
    [240] = { trade = { 23315, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.DURIUM_SHEET,                  xi.item.SIFS_LOCK          }, reward = 23650 },
    -- BST (Totemic) - Behemoth Leather
    [241] = { trade = { 23048, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SQUARE_OF_BEHEMOTH_LEATHER,     xi.item.MALIYAKALEYA_CORAL }, reward = 23383 },
    [242] = { trade = { 23115, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SQUARE_OF_BEHEMOTH_LEATHER,     xi.item.HEPATIZON_ORE      }, reward = 23450 },
    [243] = { trade = { 23182, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SQUARE_OF_BEHEMOTH_LEATHER,     xi.item.BERYLLIUM_ORE      }, reward = 23517 },
    [244] = { trade = { 23249, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SQUARE_OF_BEHEMOTH_LEATHER,     xi.item.EXALTED_LOG        }, reward = 23584 },
    [245] = { trade = { 23316, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SQUARE_OF_BEHEMOTH_LEATHER,     xi.item.SIFS_LOCK          }, reward = 23651 },
    -- BRD (Brioso) - Raxa
    [246] = { trade = { 23049, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.MALIYAKALEYA_CORAL }, reward = 23384 },
    [247] = { trade = { 23116, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.HEPATIZON_ORE      }, reward = 23451 },
    [248] = { trade = { 23183, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.BERYLLIUM_ORE      }, reward = 23518 },
    [249] = { trade = { 23250, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.EXALTED_LOG        }, reward = 23585 },
    [250] = { trade = { 23317, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SQUARE_OF_RAXA,                xi.item.SIFS_LOCK          }, reward = 23652 },
    -- RNG (Orion) - Twill Damask
    [251] = { trade = { 23050, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.TWILL_DAMASK,                  xi.item.MALIYAKALEYA_CORAL }, reward = 23385 },
    [252] = { trade = { 23117, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.TWILL_DAMASK,                  xi.item.HEPATIZON_ORE      }, reward = 23452 },
    [253] = { trade = { 23184, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.TWILL_DAMASK,                  xi.item.BERYLLIUM_ORE      }, reward = 23519 },
    [254] = { trade = { 23251, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.TWILL_DAMASK,                  xi.item.EXALTED_LOG        }, reward = 23586 },
    [255] = { trade = { 23318, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.TWILL_DAMASK,                  xi.item.SIFS_LOCK          }, reward = 23653 },
    -- SAM (Wakido) - Damascus Ingot
    [256] = { trade = { 23051, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.MALIYAKALEYA_CORAL }, reward = 23386 },
    [257] = { trade = { 23118, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.HEPATIZON_ORE      }, reward = 23453 },
    [258] = { trade = { 23185, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.BERYLLIUM_ORE      }, reward = 23520 },
    [259] = { trade = { 23252, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.EXALTED_LOG        }, reward = 23587 },
    [260] = { trade = { 23319, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.DAMASCUS_INGOT,                xi.item.SIFS_LOCK          }, reward = 23654 },
    -- NIN (Hachiya) - Damascus Ingot
    [261] = { trade = { 23052, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.MALIYAKALEYA_CORAL }, reward = 23387 },
    [262] = { trade = { 23119, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.HEPATIZON_ORE      }, reward = 23454 },
    [263] = { trade = { 23186, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.BERYLLIUM_ORE      }, reward = 23521 },
    [264] = { trade = { 23253, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.EXALTED_LOG        }, reward = 23588 },
    [265] = { trade = { 23320, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.DAMASCUS_INGOT,                xi.item.SIFS_LOCK          }, reward = 23655 },
    -- DRG (Vishap) - Orichalcum Sheet
    [266] = { trade = { 23053, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.ORICHALCUM_SHEET,              xi.item.MALIYAKALEYA_CORAL }, reward = 23388 },
    [267] = { trade = { 23120, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.ORICHALCUM_SHEET,              xi.item.HEPATIZON_ORE      }, reward = 23455 },
    [268] = { trade = { 23187, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.ORICHALCUM_SHEET,              xi.item.BERYLLIUM_ORE      }, reward = 23522 },
    [269] = { trade = { 23254, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.ORICHALCUM_SHEET,              xi.item.EXALTED_LOG        }, reward = 23589 },
    [270] = { trade = { 23321, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.ORICHALCUM_SHEET,              xi.item.SIFS_LOCK          }, reward = 23656 },
    -- SMN (Convoker's) - Siren's Hair
    [271] = { trade = { 23054, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.MALIYAKALEYA_CORAL }, reward = 23389 },
    [272] = { trade = { 23121, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.HEPATIZON_ORE      }, reward = 23456 },
    [273] = { trade = { 23188, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.BERYLLIUM_ORE      }, reward = 23523 },
    [274] = { trade = { 23255, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.EXALTED_LOG        }, reward = 23590 },
    [275] = { trade = { 23322, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.SIFS_LOCK          }, reward = 23657 },
    -- BLU (Assimilator's) - Raxa
    [276] = { trade = { 23055, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.MALIYAKALEYA_CORAL }, reward = 23390 },
    [277] = { trade = { 23122, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.HEPATIZON_ORE      }, reward = 23457 },
    [278] = { trade = { 23189, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.BERYLLIUM_ORE      }, reward = 23524 },
    [279] = { trade = { 23256, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.EXALTED_LOG        }, reward = 23591 },
    [280] = { trade = { 23323, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SQUARE_OF_RAXA,                xi.item.SIFS_LOCK          }, reward = 23658 },
    -- COR (Laksamana's) - Twill Damask
    [281] = { trade = { 23056, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.TWILL_DAMASK,                  xi.item.MALIYAKALEYA_CORAL }, reward = 23391 },
    [282] = { trade = { 23123, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.TWILL_DAMASK,                  xi.item.HEPATIZON_ORE      }, reward = 23458 },
    [283] = { trade = { 23190, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.TWILL_DAMASK,                  xi.item.BERYLLIUM_ORE      }, reward = 23525 },
    [284] = { trade = { 23257, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.TWILL_DAMASK,                  xi.item.EXALTED_LOG        }, reward = 23592 },
    [285] = { trade = { 23324, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.TWILL_DAMASK,                  xi.item.SIFS_LOCK          }, reward = 23659 },
    -- PUP (Foire) - Twill Damask
    [286] = { trade = { 23057, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.TWILL_DAMASK,                  xi.item.MALIYAKALEYA_CORAL }, reward = 23392 },
    [287] = { trade = { 23124, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.TWILL_DAMASK,                  xi.item.HEPATIZON_ORE      }, reward = 23459 },
    [288] = { trade = { 23191, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.TWILL_DAMASK,                  xi.item.BERYLLIUM_ORE      }, reward = 23526 },
    [289] = { trade = { 23258, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.TWILL_DAMASK,                  xi.item.EXALTED_LOG        }, reward = 23593 },
    [290] = { trade = { 23325, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.TWILL_DAMASK,                  xi.item.SIFS_LOCK          }, reward = 23660 },
    -- DNC/M (Maxixi) - Platinum Silk Thread
    [291] = { trade = { 23058, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.MALIYAKALEYA_CORAL }, reward = 23393 },
    [292] = { trade = { 23125, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.HEPATIZON_ORE      }, reward = 23460 },
    [293] = { trade = { 23192, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.BERYLLIUM_ORE      }, reward = 23527 },
    [294] = { trade = { 23259, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.EXALTED_LOG        }, reward = 23594 },
    [295] = { trade = { 23326, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.SIFS_LOCK          }, reward = 23661 },
    -- DNC/F (Maxixi) - Platinum Silk Thread
    [296] = { trade = { 23059, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.MALIYAKALEYA_CORAL }, reward = 23394 },
    [297] = { trade = { 23126, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.HEPATIZON_ORE      }, reward = 23461 },
    [298] = { trade = { 23193, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.BERYLLIUM_ORE      }, reward = 23528 },
    [299] = { trade = { 23260, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.EXALTED_LOG        }, reward = 23595 },
    [300] = { trade = { 23327, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.SIFS_LOCK          }, reward = 23662 },
    -- SCH (Academic's) - Siren's Hair
    [301] = { trade = { 23060, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.MALIYAKALEYA_CORAL }, reward = 23395 },
    [302] = { trade = { 23127, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.HEPATIZON_ORE      }, reward = 23462 },
    [303] = { trade = { 23194, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.BERYLLIUM_ORE      }, reward = 23529 },
    [304] = { trade = { 23261, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.EXALTED_LOG        }, reward = 23596 },
    [305] = { trade = { 23328, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.SIFS_LOCK          }, reward = 23663 },
    -- GEO (Geomancy) - Raxa
    [306] = { trade = { 23061, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.MALIYAKALEYA_CORAL }, reward = 23396 },
    [307] = { trade = { 23128, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.HEPATIZON_ORE      }, reward = 23463 },
    [308] = { trade = { 23195, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.BERYLLIUM_ORE      }, reward = 23530 },
    [309] = { trade = { 23262, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.EXALTED_LOG        }, reward = 23597 },
    [310] = { trade = { 23329, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SQUARE_OF_RAXA,                xi.item.SIFS_LOCK          }, reward = 23664 },
    -- RUN (Runeist) - Damascus Ingot
    [311] = { trade = { 23062, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.MALIYAKALEYA_CORAL }, reward = 23397 },
    [312] = { trade = { 23129, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.HEPATIZON_ORE      }, reward = 23464 },
    [313] = { trade = { 23196, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.BERYLLIUM_ORE      }, reward = 23531 },
    [314] = { trade = { 23263, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.EXALTED_LOG        }, reward = 23598 },
    [315] = { trade = { 23330, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.DAMASCUS_INGOT,                xi.item.SIFS_LOCK          }, reward = 23665 },
}

-----------------------------------
-- Relic Armor Reforge i109
-- Path A: Relic+2 + 10x Rem's Tale (Ch.1-5 by slot) + job ingredient + slot ingredient -> i109 (P2)
-- Path B: Relic+1 + 10x Rem's Tale (Byne Bills removed) -> i109 (P2)
-- Path C: Relic base + 10x Rem's Tale (Byne Bills removed) -> i109 (P2)
--
-- Entries 401-500: Path A (+2 input, 4-item trade)
-- Entries 501-600: Path B (+1 input, 2-item trade)
-- Entries 701-800: Path C (base input, 2-item trade)
--
-- Slot Rem's Tale: Head=Ch.1 / Body=Ch.2 / Hands=Ch.3 / Legs=Ch.4 / Feet=Ch.5
-- Slot ingredients: Phoenix Feather(head) / Malboro Fiber(body) / Beetle Blood(hands)
--                   Damascene Cloth(legs) / Oxblood(feet)
-- P2 output: Head 23063+j / Body 23130+j / Hands 23197+j / Legs 23264+j / Feet 23331+j
--   j: WAR=0 MNK=1 WHM=2 BLM=3 RDM=4 THF=5 PLD=6 DRK=7 BST=8 BRD=9
--      RNG=10 SAM=11 NIN=12 DRG=13 SMN=14 BLU=15 COR=16 PUP=17 DNC=18 SCH=19
-----------------------------------
local relicReforgeI109 =
{
    -- WAR (Agoge) - Wootz Ore
    [401] = { trade = { xi.item.WARRIORS_MASK_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.PHOENIX_FEATHER            }, reward = 23063 },
    [402] = { trade = { xi.item.WARRIORS_LORICA_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 23130 },
    [403] = { trade = { xi.item.WARRIORS_MUFFLERS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 23197 },
    [404] = { trade = { xi.item.WARRIORS_CUISSES_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 23264 },
    [405] = { trade = { xi.item.WARRIORS_CALLIGAE_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.PIECE_OF_OXBLOOD            }, reward = 23331 },
    -- MNK (Hesychast's) - Griffon Hide
    [406] = { trade = { xi.item.MELEE_CROWN_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.GRIFFON_HIDE, xi.item.PHOENIX_FEATHER            }, reward = 23064 },
    [407] = { trade = { xi.item.MELEE_CYCLAS_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.GRIFFON_HIDE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 23131 },
    [408] = { trade = { xi.item.MELEE_GLOVES_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.GRIFFON_HIDE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 23198 },
    [409] = { trade = { xi.item.MELEE_HOSE_P2,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.GRIFFON_HIDE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 23265 },
    [410] = { trade = { xi.item.MELEE_GAITERS_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.GRIFFON_HIDE, xi.item.PIECE_OF_OXBLOOD            }, reward = 23332 },
    -- WHM (Piety) - Sparkling Stone
    [411] = { trade = { xi.item.CLERICS_CAP_P2,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SPARKLING_STONE, xi.item.PHOENIX_FEATHER            }, reward = 23065 },
    [412] = { trade = { xi.item.CLERICS_BLIAUT_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SPARKLING_STONE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 23132 },
    [413] = { trade = { xi.item.CLERICS_MITTS_P2,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SPARKLING_STONE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 23199 },
    [414] = { trade = { xi.item.CLERICS_PANTALOONS_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SPARKLING_STONE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 23266 },
    [415] = { trade = { xi.item.CLERICS_DUCKBILLS_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SPARKLING_STONE, xi.item.PIECE_OF_OXBLOOD            }, reward = 23333 },
    -- BLM (Archmage's) - Sparkling Stone
    [416] = { trade = { xi.item.SORCERERS_PETASOS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SPARKLING_STONE, xi.item.PHOENIX_FEATHER            }, reward = 23066 },
    [417] = { trade = { xi.item.SORCERERS_COAT_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SPARKLING_STONE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 23133 },
    [418] = { trade = { xi.item.SORCERERS_GLOVES_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SPARKLING_STONE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 23200 },
    [419] = { trade = { xi.item.SORCERERS_TONBAN_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SPARKLING_STONE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 23267 },
    [420] = { trade = { xi.item.SORCERERS_SABOTS_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SPARKLING_STONE, xi.item.PIECE_OF_OXBLOOD            }, reward = 23334 },
    -- RDM (Vitiation) - Griffon Hide
    [421] = { trade = { xi.item.DUELISTS_CHAPEAU_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.GRIFFON_HIDE, xi.item.PHOENIX_FEATHER            }, reward = 23067 },
    [422] = { trade = { xi.item.DUELISTS_TABARD_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.GRIFFON_HIDE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 23134 },
    [423] = { trade = { xi.item.DUELISTS_GLOVES_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.GRIFFON_HIDE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 23201 },
    [424] = { trade = { xi.item.DUELISTS_TIGHTS_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.GRIFFON_HIDE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 23268 },
    [425] = { trade = { xi.item.DUELISTS_BOOTS_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.GRIFFON_HIDE, xi.item.PIECE_OF_OXBLOOD            }, reward = 23335 },
    -- THF (Plunderer's) - Griffon Hide
    [426] = { trade = { xi.item.ASSASSINS_BONNET_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.GRIFFON_HIDE, xi.item.PHOENIX_FEATHER            }, reward = 23068 },
    [427] = { trade = { xi.item.ASSASSINS_VEST_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.GRIFFON_HIDE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 23135 },
    [428] = { trade = { xi.item.ASSASSINS_ARMLETS_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.GRIFFON_HIDE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 23202 },
    [429] = { trade = { xi.item.ASSASSINS_CULOTTES_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.GRIFFON_HIDE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 23269 },
    [430] = { trade = { xi.item.ASSASSINS_POULAINES_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.GRIFFON_HIDE, xi.item.PIECE_OF_OXBLOOD            }, reward = 23336 },
    -- PLD (Caballarius) - Wootz Ore
    [431] = { trade = { xi.item.VALOR_CORONET_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.PHOENIX_FEATHER            }, reward = 23069 },
    [432] = { trade = { xi.item.VALOR_SURCOAT_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 23136 },
    [433] = { trade = { xi.item.VALOR_GAUNTLETS_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 23203 },
    [434] = { trade = { xi.item.VALOR_BREECHES_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 23270 },
    [435] = { trade = { xi.item.VALOR_LEGGINGS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.PIECE_OF_OXBLOOD            }, reward = 23337 },
    -- DRK (Fallen's) - Wootz Ore
    [436] = { trade = { xi.item.ABYSS_BURGEONET_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.PHOENIX_FEATHER            }, reward = 23070 },
    [437] = { trade = { xi.item.ABYSS_CUIRASS_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 23137 },
    [438] = { trade = { xi.item.ABYSS_GAUNTLETS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 23204 },
    [439] = { trade = { xi.item.ABYSS_FLANCHARD_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 23271 },
    [440] = { trade = { xi.item.ABYSS_SOLLERETS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.PIECE_OF_OXBLOOD            }, reward = 23338 },
    -- BST (Ankusa) - Mammoth Tusk
    [441] = { trade = { xi.item.MONSTER_HELM_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.MAMMOTH_TUSK, xi.item.PHOENIX_FEATHER            }, reward = 23071 },
    [442] = { trade = { xi.item.MONSTER_JACKCOAT_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.MAMMOTH_TUSK, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 23138 },
    [443] = { trade = { xi.item.MONSTER_GLOVES_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.MAMMOTH_TUSK, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 23205 },
    [444] = { trade = { xi.item.MONSTER_TROUSERS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.MAMMOTH_TUSK, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 23272 },
    [445] = { trade = { xi.item.MONSTER_GAITERS_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.MAMMOTH_TUSK, xi.item.PIECE_OF_OXBLOOD            }, reward = 23339 },
    -- BRD (Bihu) - Griffon Hide
    [446] = { trade = { xi.item.BARDS_ROUNDLET_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.GRIFFON_HIDE, xi.item.PHOENIX_FEATHER            }, reward = 23072 },
    [447] = { trade = { xi.item.BARDS_JUSTAUCORPS_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.GRIFFON_HIDE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 23139 },
    [448] = { trade = { xi.item.BARDS_CUFFS_P2,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.GRIFFON_HIDE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 23206 },
    [449] = { trade = { xi.item.BARDS_CANNIONS_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.GRIFFON_HIDE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 23273 },
    [450] = { trade = { xi.item.BARDS_SLIPPERS_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.GRIFFON_HIDE, xi.item.PIECE_OF_OXBLOOD            }, reward = 23340 },
    -- RNG (Arcadian) - Griffon Hide
    [451] = { trade = { xi.item.SCOUTS_BERET_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.GRIFFON_HIDE, xi.item.PHOENIX_FEATHER            }, reward = 23073 },
    [452] = { trade = { xi.item.SCOUTS_JERKIN_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.GRIFFON_HIDE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 23140 },
    [453] = { trade = { xi.item.SCOUTS_BRACERS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.GRIFFON_HIDE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 23207 },
    [454] = { trade = { xi.item.SCOUTS_BRACCAE_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.GRIFFON_HIDE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 23274 },
    [455] = { trade = { xi.item.SCOUTS_SOCKS_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.GRIFFON_HIDE, xi.item.PIECE_OF_OXBLOOD            }, reward = 23341 },
    -- SAM (Sakonji) - Relic Iron
    [456] = { trade = { xi.item.SAOTOME_KABUTO_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.PILE_OF_RELIC_IRON, xi.item.PHOENIX_FEATHER            }, reward = 23074 },
    [457] = { trade = { xi.item.SAOTOME_DOMARU_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.PILE_OF_RELIC_IRON, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 23141 },
    [458] = { trade = { xi.item.SAOTOME_KOTE_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.PILE_OF_RELIC_IRON, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 23208 },
    [459] = { trade = { xi.item.SAOTOME_HAIDATE_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.PILE_OF_RELIC_IRON, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 23275 },
    [460] = { trade = { xi.item.SAOTOME_SUNE_ATE_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.PILE_OF_RELIC_IRON, xi.item.PIECE_OF_OXBLOOD            }, reward = 23342 },
    -- NIN (Mochizuki) - Relic Iron
    [461] = { trade = { xi.item.KOGA_HATSUBURI_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.PILE_OF_RELIC_IRON, xi.item.PHOENIX_FEATHER            }, reward = 23075 },
    [462] = { trade = { xi.item.KOGA_CHAINMAIL_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.PILE_OF_RELIC_IRON, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 23142 },
    [463] = { trade = { xi.item.KOGA_TEKKO_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.PILE_OF_RELIC_IRON, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 23209 },
    [464] = { trade = { xi.item.KOGA_HAKAMA_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.PILE_OF_RELIC_IRON, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 23276 },
    [465] = { trade = { xi.item.KOGA_KYAHAN_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.PILE_OF_RELIC_IRON, xi.item.PIECE_OF_OXBLOOD            }, reward = 23343 },
    -- DRG (Pteroslaver) - Griffon Hide
    [466] = { trade = { xi.item.WYRM_ARMET_P2,             { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.GRIFFON_HIDE, xi.item.PHOENIX_FEATHER            }, reward = 23076 },
    [467] = { trade = { xi.item.WYRM_MAIL_P2,              { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.GRIFFON_HIDE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 23143 },
    [468] = { trade = { xi.item.WYRM_FINGER_GAUNTLETS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.GRIFFON_HIDE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 23210 },
    [469] = { trade = { xi.item.WYRM_BRAIS_P2,             { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.GRIFFON_HIDE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 23277 },
    [470] = { trade = { xi.item.WYRM_GREAVES_P2,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.GRIFFON_HIDE, xi.item.PIECE_OF_OXBLOOD            }, reward = 23344 },
    -- SMN (Glyphic) - Lancewood Log
    [471] = { trade = { xi.item.SUMMONERS_HORN_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.LANCEWOOD_LOG, xi.item.PHOENIX_FEATHER            }, reward = 23077 },
    [472] = { trade = { xi.item.SUMMONERS_DOUBLET_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.LANCEWOOD_LOG, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 23144 },
    [473] = { trade = { xi.item.SUMMONERS_BRACERS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.LANCEWOOD_LOG, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 23211 },
    [474] = { trade = { xi.item.SUMMONERS_SPATS_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.LANCEWOOD_LOG, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 23278 },
    [475] = { trade = { xi.item.SUMMONERS_PIGACHES_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.LANCEWOOD_LOG, xi.item.PIECE_OF_OXBLOOD            }, reward = 23345 },
    -- BLU (Luhlaza) - Griffon Hide
    [476] = { trade = { xi.item.MIRAGE_KEFFIYEH_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.GRIFFON_HIDE, xi.item.PHOENIX_FEATHER            }, reward = 23078 },
    [477] = { trade = { xi.item.MIRAGE_JUBBAH_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.GRIFFON_HIDE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 23145 },
    [478] = { trade = { xi.item.MIRAGE_BAZUBANDS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.GRIFFON_HIDE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 23212 },
    [479] = { trade = { xi.item.MIRAGE_SHALWAR_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.GRIFFON_HIDE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 23279 },
    [480] = { trade = { xi.item.MIRAGE_CHARUQS_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.GRIFFON_HIDE, xi.item.PIECE_OF_OXBLOOD            }, reward = 23346 },
    -- COR (Lanun) - Sparkling Stone
    [481] = { trade = { xi.item.COMMODORES_TRICORNE_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SPARKLING_STONE, xi.item.PHOENIX_FEATHER            }, reward = 23079 },
    [482] = { trade = { xi.item.COMMODORE_FRAC_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SPARKLING_STONE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 23146 },
    [483] = { trade = { xi.item.COMMODORE_GANTS_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SPARKLING_STONE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 23213 },
    [484] = { trade = { xi.item.COMMODORE_TREWS_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SPARKLING_STONE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 23280 },
    [485] = { trade = { xi.item.COMMODORE_BOTTES_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SPARKLING_STONE, xi.item.PIECE_OF_OXBLOOD            }, reward = 23347 },
    -- PUP (Pitre) - Lancewood Log
    [486] = { trade = { xi.item.PANTIN_TAJ_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.LANCEWOOD_LOG, xi.item.PHOENIX_FEATHER            }, reward = 23080 },
    [487] = { trade = { xi.item.PANTIN_TOBE_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.LANCEWOOD_LOG, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 23147 },
    [488] = { trade = { xi.item.PANTIN_DASTANAS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.LANCEWOOD_LOG, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 23214 },
    [489] = { trade = { xi.item.PANTIN_CHURIDARS_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.LANCEWOOD_LOG, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 23281 },
    [490] = { trade = { xi.item.PANTIN_BABOUCHES_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.LANCEWOOD_LOG, xi.item.PIECE_OF_OXBLOOD            }, reward = 23348 },
    -- DNC (Horos) - Mammoth Tusk
    [491] = { trade = { xi.item.ETOILE_TIARA_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.MAMMOTH_TUSK, xi.item.PHOENIX_FEATHER            }, reward = 23081 },
    [492] = { trade = { xi.item.ETOILE_CASAQUE_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.MAMMOTH_TUSK, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 23148 },
    [493] = { trade = { xi.item.ETOILE_BANGLES_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.MAMMOTH_TUSK, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 23215 },
    [494] = { trade = { xi.item.ETOILE_TIGHTS_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.MAMMOTH_TUSK, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 23282 },
    [495] = { trade = { xi.item.ETOILE_TOE_SHOES_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.MAMMOTH_TUSK, xi.item.PIECE_OF_OXBLOOD            }, reward = 23349 },
    -- SCH (Pedagogy) - Lancewood Log
    [496] = { trade = { xi.item.ARGUTE_MORTARBOARD_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.LANCEWOOD_LOG, xi.item.PHOENIX_FEATHER            }, reward = 23082 },
    [497] = { trade = { xi.item.ARGUTE_GOWN_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.LANCEWOOD_LOG, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 23149 },
    [498] = { trade = { xi.item.ARGUTE_BRACERS_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.LANCEWOOD_LOG, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 23216 },
    [499] = { trade = { xi.item.ARGUTE_PANTS_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.LANCEWOOD_LOG, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 23283 },
    [500] = { trade = { xi.item.ARGUTE_LOAFERS_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.LANCEWOOD_LOG, xi.item.PIECE_OF_OXBLOOD            }, reward = 23350 },
    -- WAR (Agoge) - Path B (+1 input)
    [501] = { trade = { xi.item.WARRIORS_MASK_P1,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23063 },
    [502] = { trade = { xi.item.WARRIORS_LORICA_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23130 },
    [503] = { trade = { xi.item.WARRIORS_MUFFLERS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23197 },
    [504] = { trade = { xi.item.WARRIORS_CUISSES_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23264 },
    [505] = { trade = { xi.item.WARRIORS_CALLIGAE_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23331 },
    -- MNK (Hesychast's) - Path B
    [506] = { trade = { xi.item.MELEE_CROWN_P1,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23064 },
    [507] = { trade = { xi.item.MELEE_CYCLAS_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23131 },
    [508] = { trade = { xi.item.MELEE_GLOVES_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23198 },
    [509] = { trade = { xi.item.MELEE_HOSE_P1,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23265 },
    [510] = { trade = { xi.item.MELEE_GAITERS_P1,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23332 },
    -- WHM (Piety) - Path B
    [511] = { trade = { xi.item.CLERICS_CAP_P1,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23065 },
    [512] = { trade = { xi.item.CLERICS_BLIAUT_P1,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23132 },
    [513] = { trade = { xi.item.CLERICS_MITTS_P1,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23199 },
    [514] = { trade = { xi.item.CLERICS_PANTALOONS_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23266 },
    [515] = { trade = { xi.item.CLERICS_DUCKBILLS_P1,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23333 },
    -- BLM (Archmage's) - Path B
    [516] = { trade = { xi.item.SORCERERS_PETASOS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23066 },
    [517] = { trade = { xi.item.SORCERERS_COAT_P1,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23133 },
    [518] = { trade = { xi.item.SORCERERS_GLOVES_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23200 },
    [519] = { trade = { xi.item.SORCERERS_TONBAN_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23267 },
    [520] = { trade = { xi.item.SORCERERS_SABOTS_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23334 },
    -- RDM (Vitiation) - Path B
    [521] = { trade = { xi.item.DUELISTS_CHAPEAU_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23067 },
    [522] = { trade = { xi.item.DUELISTS_TABARD_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23134 },
    [523] = { trade = { xi.item.DUELISTS_GLOVES_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23201 },
    [524] = { trade = { xi.item.DUELISTS_TIGHTS_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23268 },
    [525] = { trade = { xi.item.DUELISTS_BOOTS_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23335 },
    -- THF (Plunderer's) - Path B
    [526] = { trade = { xi.item.ASSASSINS_BONNET_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23068 },
    [527] = { trade = { xi.item.ASSASSINS_VEST_P1,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23135 },
    [528] = { trade = { xi.item.ASSASSINS_ARMLETS_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23202 },
    [529] = { trade = { xi.item.ASSASSINS_CULOTTES_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23269 },
    [530] = { trade = { xi.item.ASSASSINS_POULAINES_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23336 },
    -- PLD (Caballarius) - Path B
    [531] = { trade = { xi.item.VALOR_CORONET_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23069 },
    [532] = { trade = { xi.item.VALOR_SURCOAT_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23136 },
    [533] = { trade = { xi.item.VALOR_GAUNTLETS_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23203 },
    [534] = { trade = { xi.item.VALOR_BREECHES_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23270 },
    [535] = { trade = { xi.item.VALOR_LEGGINGS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23337 },
    -- DRK (Fallen's) - Path B
    [536] = { trade = { xi.item.ABYSS_BURGEONET_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23070 },
    [537] = { trade = { xi.item.ABYSS_CUIRASS_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23137 },
    [538] = { trade = { xi.item.ABYSS_GAUNTLETS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23204 },
    [539] = { trade = { xi.item.ABYSS_FLANCHARD_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23271 },
    [540] = { trade = { xi.item.ABYSS_SOLLERETS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23338 },
    -- BST (Ankusa) - Path B
    [541] = { trade = { xi.item.MONSTER_HELM_P1,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23071 },
    [542] = { trade = { xi.item.MONSTER_JACKCOAT_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23138 },
    [543] = { trade = { xi.item.MONSTER_GLOVES_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23205 },
    [544] = { trade = { xi.item.MONSTER_TROUSERS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23272 },
    [545] = { trade = { xi.item.MONSTER_GAITERS_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23339 },
    -- BRD (Bihu) - Path B
    [546] = { trade = { xi.item.BARDS_ROUNDLET_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23072 },
    [547] = { trade = { xi.item.BARDS_JUSTAUCORPS_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23139 },
    [548] = { trade = { xi.item.BARDS_CUFFS_P1,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23206 },
    [549] = { trade = { xi.item.BARDS_CANNIONS_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23273 },
    [550] = { trade = { xi.item.BARDS_SLIPPERS_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23340 },
    -- RNG (Arcadian) - Path B
    [551] = { trade = { xi.item.SCOUTS_BERET_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23073 },
    [552] = { trade = { xi.item.SCOUTS_JERKIN_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23140 },
    [553] = { trade = { xi.item.SCOUTS_BRACERS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23207 },
    [554] = { trade = { xi.item.SCOUTS_BRACCAE_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23274 },
    [555] = { trade = { xi.item.SCOUTS_SOCKS_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23341 },
    -- SAM (Sakonji) - Path B
    [556] = { trade = { xi.item.SAOTOME_KABUTO_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23074 },
    [557] = { trade = { xi.item.SAOTOME_DOMARU_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23141 },
    [558] = { trade = { xi.item.SAOTOME_KOTE_P1,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23208 },
    [559] = { trade = { xi.item.SAOTOME_HAIDATE_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23275 },
    [560] = { trade = { xi.item.SAOTOME_SUNE_ATE_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23342 },
    -- NIN (Mochizuki) - Path B
    [561] = { trade = { xi.item.KOGA_HATSUBURI_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23075 },
    [562] = { trade = { xi.item.KOGA_CHAINMAIL_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23142 },
    [563] = { trade = { xi.item.KOGA_TEKKO_P1,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23209 },
    [564] = { trade = { xi.item.KOGA_HAKAMA_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23276 },
    [565] = { trade = { xi.item.KOGA_KYAHAN_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23343 },
    -- DRG (Pteroslaver) - Path B
    [566] = { trade = { xi.item.WYRM_ARMET_P1,             { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23076 },
    [567] = { trade = { xi.item.WYRM_MAIL_P1,              { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23143 },
    [568] = { trade = { xi.item.WYRM_FINGER_GAUNTLETS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23210 },
    [569] = { trade = { xi.item.WYRM_BRAIS_P1,             { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23277 },
    [570] = { trade = { xi.item.WYRM_GREAVES_P1,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23344 },
    -- SMN (Glyphic) - Path B
    [571] = { trade = { xi.item.SUMMONERS_HORN_P1,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23077 },
    [572] = { trade = { xi.item.SUMMONERS_DOUBLET_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23144 },
    [573] = { trade = { xi.item.SUMMONERS_BRACERS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23211 },
    [574] = { trade = { xi.item.SUMMONERS_SPATS_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23278 },
    [575] = { trade = { xi.item.SUMMONERS_PIGACHES_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23345 },
    -- BLU (Luhlaza) - Path B
    [576] = { trade = { xi.item.MIRAGE_KEFFIYEH_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23078 },
    [577] = { trade = { xi.item.MIRAGE_JUBBAH_P1,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23145 },
    [578] = { trade = { xi.item.MIRAGE_BAZUBANDS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23212 },
    [579] = { trade = { xi.item.MIRAGE_SHALWAR_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23279 },
    [580] = { trade = { xi.item.MIRAGE_CHARUQS_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23346 },
    -- COR (Lanun) - Path B
    [581] = { trade = { xi.item.COMMODORE_TRICORNE_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23079 },
    [582] = { trade = { xi.item.COMMODORE_FRAC_P1,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23146 },
    [583] = { trade = { xi.item.COMMODORE_GANTS_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23213 },
    [584] = { trade = { xi.item.COMMODORE_TREWS_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23280 },
    [585] = { trade = { xi.item.COMMODORE_BOTTES_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23347 },
    -- PUP (Pitre) - Path B
    [586] = { trade = { xi.item.PANTIN_TAJ_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23080 },
    [587] = { trade = { xi.item.PANTIN_TOBE_P1,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23147 },
    [588] = { trade = { xi.item.PANTIN_DASTANAS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23214 },
    [589] = { trade = { xi.item.PANTIN_CHURIDARS_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23281 },
    [590] = { trade = { xi.item.PANTIN_BABOUCHES_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23348 },
    -- DNC (Horos) - Path B
    [591] = { trade = { xi.item.ETOILE_TIARA_P1,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23081 },
    [592] = { trade = { xi.item.ETOILE_CASAQUE_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23148 },
    [593] = { trade = { xi.item.ETOILE_BANGLES_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23215 },
    [594] = { trade = { xi.item.ETOILE_TIGHTS_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23282 },
    [595] = { trade = { xi.item.ETOILE_TOE_SHOES_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23349 },
    -- SCH (Pedagogy) - Path B
    [596] = { trade = { xi.item.ARGUTE_MORTARBOARD_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23082 },
    [597] = { trade = { xi.item.ARGUTE_GOWN_P1,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23149 },
    [598] = { trade = { xi.item.ARGUTE_BRACERS_P1,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23216 },
    [599] = { trade = { xi.item.ARGUTE_PANTS_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23283 },
    [600] = { trade = { xi.item.ARGUTE_LOAFERS_P1,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23350 },
    -- WAR (Agoge) - Path C (base input)
    [701] = { trade = { xi.item.WARRIORS_MASK,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23063 },
    [702] = { trade = { xi.item.WARRIORS_LORICA,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23130 },
    [703] = { trade = { xi.item.WARRIORS_MUFFLERS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23197 },
    [704] = { trade = { xi.item.WARRIORS_CUISSES,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23264 },
    [705] = { trade = { xi.item.WARRIORS_CALLIGAE,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23331 },
    -- MNK (Hesychast's) - Path C
    [706] = { trade = { xi.item.MELEE_CROWN,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23064 },
    [707] = { trade = { xi.item.MELEE_CYCLAS,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23131 },
    [708] = { trade = { xi.item.MELEE_GLOVES,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23198 },
    [709] = { trade = { xi.item.MELEE_HOSE,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23265 },
    [710] = { trade = { xi.item.MELEE_GAITERS,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23332 },
    -- WHM (Piety) - Path C
    [711] = { trade = { xi.item.CLERICS_CAP,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23065 },
    [712] = { trade = { xi.item.CLERICS_BLIAUT,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23132 },
    [713] = { trade = { xi.item.CLERICS_MITTS,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23199 },
    [714] = { trade = { xi.item.CLERICS_PANTALOONS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23266 },
    [715] = { trade = { xi.item.CLERICS_DUCKBILLS,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23333 },
    -- BLM (Archmage's) - Path C
    [716] = { trade = { xi.item.SORCERERS_PETASOS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23066 },
    [717] = { trade = { xi.item.SORCERERS_COAT,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23133 },
    [718] = { trade = { xi.item.SORCERERS_GLOVES,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23200 },
    [719] = { trade = { xi.item.SORCERERS_TONBAN,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23267 },
    [720] = { trade = { xi.item.SORCERERS_SABOTS,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23334 },
    -- RDM (Vitiation) - Path C
    [721] = { trade = { xi.item.DUELISTS_CHAPEAU,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23067 },
    [722] = { trade = { xi.item.DUELISTS_TABARD,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23134 },
    [723] = { trade = { xi.item.DUELISTS_GLOVES,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23201 },
    [724] = { trade = { xi.item.DUELISTS_TIGHTS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23268 },
    [725] = { trade = { xi.item.DUELISTS_BOOTS,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23335 },
    -- THF (Plunderer's) - Path C
    [726] = { trade = { xi.item.ASSASSINS_BONNET,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23068 },
    [727] = { trade = { xi.item.ASSASSINS_VEST,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23135 },
    [728] = { trade = { xi.item.ASSASSINS_ARMLETS,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23202 },
    [729] = { trade = { xi.item.ASSASSINS_CULOTTES,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23269 },
    [730] = { trade = { xi.item.ASSASSINS_POULAINES, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23336 },
    -- PLD (Caballarius) - Path C
    [731] = { trade = { xi.item.VALOR_CORONET,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23069 },
    [732] = { trade = { xi.item.VALOR_SURCOAT,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23136 },
    [733] = { trade = { xi.item.VALOR_GAUNTLETS, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23203 },
    [734] = { trade = { xi.item.VALOR_BREECHES,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23270 },
    [735] = { trade = { xi.item.VALOR_LEGGINGS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23337 },
    -- DRK (Fallen's) - Path C
    [736] = { trade = { xi.item.ABYSS_BURGEONET,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23070 },
    [737] = { trade = { xi.item.ABYSS_CUIRASS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23137 },
    [738] = { trade = { xi.item.ABYSS_GAUNTLETS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23204 },
    [739] = { trade = { xi.item.ABYSS_FLANCHARD,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23271 },
    [740] = { trade = { xi.item.ABYSS_SOLLERETS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23338 },
    -- BST (Ankusa) - Path C
    [741] = { trade = { xi.item.MONSTER_HELM,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23071 },
    [742] = { trade = { xi.item.MONSTER_JACKCOAT,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23138 },
    [743] = { trade = { xi.item.MONSTER_GLOVES,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23205 },
    [744] = { trade = { xi.item.MONSTER_TROUSERS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23272 },
    [745] = { trade = { xi.item.MONSTER_GAITERS,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23339 },
    -- BRD (Bihu) - Path C
    [746] = { trade = { xi.item.BARDS_ROUNDLET,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23072 },
    [747] = { trade = { xi.item.BARDS_JUSTAUCORPS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23139 },
    [748] = { trade = { xi.item.BARDS_CUFFS,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23206 },
    [749] = { trade = { xi.item.BARDS_CANNIONS,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23273 },
    [750] = { trade = { xi.item.BARDS_SLIPPERS,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23340 },
    -- RNG (Arcadian) - Path C
    [751] = { trade = { xi.item.SCOUTS_BERET,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23073 },
    [752] = { trade = { xi.item.SCOUTS_JERKIN,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23140 },
    [753] = { trade = { xi.item.SCOUTS_BRACERS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23207 },
    [754] = { trade = { xi.item.SCOUTS_BRACCAE,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23274 },
    [755] = { trade = { xi.item.SCOUTS_SOCKS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23341 },
    -- SAM (Sakonji) - Path C
    [756] = { trade = { xi.item.SAOTOME_KABUTO,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23074 },
    [757] = { trade = { xi.item.SAOTOME_DOMARU,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23141 },
    [758] = { trade = { xi.item.SAOTOME_KOTE,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23208 },
    [759] = { trade = { xi.item.SAOTOME_HAIDATE,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23275 },
    [760] = { trade = { xi.item.SAOTOME_SUNE_ATE, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23342 },
    -- NIN (Mochizuki) - Path C
    [761] = { trade = { xi.item.KOGA_HATSUBURI, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23075 },
    [762] = { trade = { xi.item.KOGA_CHAINMAIL, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23142 },
    [763] = { trade = { xi.item.KOGA_TEKKO,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23209 },
    [764] = { trade = { xi.item.KOGA_HAKAMA,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23276 },
    [765] = { trade = { xi.item.KOGA_KYAHAN,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23343 },
    -- DRG (Pteroslaver) - Path C
    [766] = { trade = { xi.item.WYRM_ARMET,             { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23076 },
    [767] = { trade = { xi.item.WYRM_MAIL,              { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23143 },
    [768] = { trade = { xi.item.WYRM_FINGER_GAUNTLETS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23210 },
    [769] = { trade = { xi.item.WYRM_BRAIS,             { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23277 },
    [770] = { trade = { xi.item.WYRM_GREAVES,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23344 },
    -- SMN (Glyphic) - Path C
    [771] = { trade = { xi.item.SUMMONERS_HORN,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23077 },
    [772] = { trade = { xi.item.SUMMONERS_DOUBLET,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23144 },
    [773] = { trade = { xi.item.SUMMONERS_BRACERS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23211 },
    [774] = { trade = { xi.item.SUMMONERS_SPATS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23278 },
    [775] = { trade = { xi.item.SUMMONERS_PIGACHES, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23345 },
    -- BLU (Luhlaza) - Path C
    [776] = { trade = { xi.item.MIRAGE_KEFFIYEH,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23078 },
    [777] = { trade = { xi.item.MIRAGE_JUBBAH,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23145 },
    [778] = { trade = { xi.item.MIRAGE_BAZUBANDS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23212 },
    [779] = { trade = { xi.item.MIRAGE_SHALWAR,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23279 },
    [780] = { trade = { xi.item.MIRAGE_CHARUQS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23346 },
    -- COR (Lanun) - Path C
    [781] = { trade = { xi.item.COMMODORE_TRICORNE, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23079 },
    [782] = { trade = { xi.item.COMMODORE_FRAC,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23146 },
    [783] = { trade = { xi.item.COMMODORE_GANTS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23213 },
    [784] = { trade = { xi.item.COMMODORE_TREWS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23280 },
    [785] = { trade = { xi.item.COMMODORE_BOTTES,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23347 },
    -- PUP (Pitre) - Path C
    [786] = { trade = { xi.item.PANTIN_TAJ,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23080 },
    [787] = { trade = { xi.item.PANTIN_TOBE,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23147 },
    [788] = { trade = { xi.item.PANTIN_DASTANAS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23214 },
    [789] = { trade = { xi.item.PANTIN_CHURIDARS, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23281 },
    [790] = { trade = { xi.item.PANTIN_BABOUCHES, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23348 },
    -- DNC (Horos) - Path C
    [791] = { trade = { xi.item.ETOILE_TIARA,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23081 },
    [792] = { trade = { xi.item.ETOILE_CASAQUE,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23148 },
    [793] = { trade = { xi.item.ETOILE_BANGLES,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23215 },
    [794] = { trade = { xi.item.ETOILE_TIGHTS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23282 },
    [795] = { trade = { xi.item.ETOILE_TOE_SHOES, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23349 },
    -- SCH (Pedagogy) - Path C
    [796] = { trade = { xi.item.ARGUTE_MORTARBOARD, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 23082 },
    [797] = { trade = { xi.item.ARGUTE_GOWN,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 23149 },
    [798] = { trade = { xi.item.ARGUTE_BRACERS,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 23216 },
    [799] = { trade = { xi.item.ARGUTE_PANTS,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 23283 },
    [800] = { trade = { xi.item.ARGUTE_LOAFERS,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 23350 },
}

-----------------------------------
-- Relic Armor Reforge i119
-- Trade: Relic i109 (P2) piece + 8x Rem's Tale (Ch.6-10 by slot) + job ingredient + slot ingredient -> i119 (P3)
--
-- Slot Rem's Tale: Head=Ch.6 / Body=Ch.7 / Hands=Ch.8 / Legs=Ch.9 / Feet=Ch.10
-- Slot ingredients: Gabbrath Horn(head) / Yggdreant Bole(body) / Bztavian Stinger(hands)
--                   Waktza Rostrum(legs) / Rockfin Tooth(feet)
-- P2 input:  Head 23063+j / Body 23130+j / Hands 23197+j / Legs 23264+j / Feet 23331+j
-- P3 output: Head 23398+j / Body 23465+j / Hands 23532+j / Legs 23599+j / Feet 23666+j
--   j: WAR=0 MNK=1 WHM=2 BLM=3 RDM=4 THF=5 PLD=6 DRK=7 BST=8 BRD=9
--      RNG=10 SAM=11 NIN=12 DRG=13 SMN=14 BLU=15 COR=16 PUP=17 DNC=18 SCH=19
-----------------------------------
local relicReforgeI119 =
{
    -- WAR (Agoge +1) - Voidwrought Plate
    [601] = { trade = { 23063, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.GABBRATH_HORN      }, reward = 23398 },
    [602] = { trade = { 23130, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.YGGDREANT_BOLE     }, reward = 23465 },
    [603] = { trade = { 23197, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.BZTAVIAN_STINGER   }, reward = 23532 },
    [604] = { trade = { 23264, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.WAKTZA_ROSTRUM     }, reward = 23599 },
    [605] = { trade = { 23331, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.ROCKFIN_TOOTH      }, reward = 23666 },
    -- MNK (Hesychast's +1) - Kaggen's Cuticle
    [606] = { trade = { 23064, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.GABBRATH_HORN      }, reward = 23399 },
    [607] = { trade = { 23131, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.YGGDREANT_BOLE     }, reward = 23466 },
    [608] = { trade = { 23198, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.BZTAVIAN_STINGER   }, reward = 23533 },
    [609] = { trade = { 23265, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.WAKTZA_ROSTRUM     }, reward = 23600 },
    [610] = { trade = { 23332, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.KAGGENS_CUTICLE,      xi.item.ROCKFIN_TOOTH      }, reward = 23667 },
    -- WHM (Piety +1) - Akvan's Pennon
    [611] = { trade = { 23065, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.AKVANS_PENNON,        xi.item.GABBRATH_HORN      }, reward = 23400 },
    [612] = { trade = { 23132, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.AKVANS_PENNON,        xi.item.YGGDREANT_BOLE     }, reward = 23467 },
    [613] = { trade = { 23199, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.AKVANS_PENNON,        xi.item.BZTAVIAN_STINGER   }, reward = 23534 },
    [614] = { trade = { 23266, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.AKVANS_PENNON,        xi.item.WAKTZA_ROSTRUM     }, reward = 23601 },
    [615] = { trade = { 23333, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.AKVANS_PENNON,        xi.item.ROCKFIN_TOOTH      }, reward = 23668 },
    -- BLM (Archmage's +1) - Akvan's Pennon
    [616] = { trade = { 23066, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.AKVANS_PENNON,        xi.item.GABBRATH_HORN      }, reward = 23401 },
    [617] = { trade = { 23133, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.AKVANS_PENNON,        xi.item.YGGDREANT_BOLE     }, reward = 23468 },
    [618] = { trade = { 23200, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.AKVANS_PENNON,        xi.item.BZTAVIAN_STINGER   }, reward = 23535 },
    [619] = { trade = { 23267, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.AKVANS_PENNON,        xi.item.WAKTZA_ROSTRUM     }, reward = 23602 },
    [620] = { trade = { 23334, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.AKVANS_PENNON,        xi.item.ROCKFIN_TOOTH      }, reward = 23669 },
    -- RDM (Vitiation +1) - Pil's Tuille
    [621] = { trade = { 23067, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.PILS_TUILLE,          xi.item.GABBRATH_HORN      }, reward = 23402 },
    [622] = { trade = { 23134, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.PILS_TUILLE,          xi.item.YGGDREANT_BOLE     }, reward = 23469 },
    [623] = { trade = { 23201, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.PILS_TUILLE,          xi.item.BZTAVIAN_STINGER   }, reward = 23536 },
    [624] = { trade = { 23268, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.PILS_TUILLE,          xi.item.WAKTZA_ROSTRUM     }, reward = 23603 },
    [625] = { trade = { 23335, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.PILS_TUILLE,          xi.item.ROCKFIN_TOOTH      }, reward = 23670 },
    -- THF (Plunderer's +1) - Kaggen's Cuticle
    [626] = { trade = { 23068, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.GABBRATH_HORN      }, reward = 23403 },
    [627] = { trade = { 23135, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.YGGDREANT_BOLE     }, reward = 23470 },
    [628] = { trade = { 23202, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.BZTAVIAN_STINGER   }, reward = 23537 },
    [629] = { trade = { 23269, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.WAKTZA_ROSTRUM     }, reward = 23604 },
    [630] = { trade = { 23336, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.KAGGENS_CUTICLE,      xi.item.ROCKFIN_TOOTH      }, reward = 23671 },
    -- PLD (Caballarius +1) - Pil's Tuille
    [631] = { trade = { 23069, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.PILS_TUILLE,          xi.item.GABBRATH_HORN      }, reward = 23404 },
    [632] = { trade = { 23136, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.PILS_TUILLE,          xi.item.YGGDREANT_BOLE     }, reward = 23471 },
    [633] = { trade = { 23203, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.PILS_TUILLE,          xi.item.BZTAVIAN_STINGER   }, reward = 23538 },
    [634] = { trade = { 23270, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.PILS_TUILLE,          xi.item.WAKTZA_ROSTRUM     }, reward = 23605 },
    [635] = { trade = { 23337, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.PILS_TUILLE,          xi.item.ROCKFIN_TOOTH      }, reward = 23672 },
    -- DRK (Fallen's +1) - Pil's Tuille
    [636] = { trade = { 23070, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.PILS_TUILLE,          xi.item.GABBRATH_HORN      }, reward = 23405 },
    [637] = { trade = { 23137, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.PILS_TUILLE,          xi.item.YGGDREANT_BOLE     }, reward = 23472 },
    [638] = { trade = { 23204, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.PILS_TUILLE,          xi.item.BZTAVIAN_STINGER   }, reward = 23539 },
    [639] = { trade = { 23271, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.PILS_TUILLE,          xi.item.WAKTZA_ROSTRUM     }, reward = 23606 },
    [640] = { trade = { 23338, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.PILS_TUILLE,          xi.item.ROCKFIN_TOOTH      }, reward = 23673 },
    -- BST (Ankusa +1) - Hahava's Mail
    [641] = { trade = { 23071, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.GABBRATH_HORN      }, reward = 23406 },
    [642] = { trade = { 23138, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.YGGDREANT_BOLE     }, reward = 23473 },
    [643] = { trade = { 23205, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.BZTAVIAN_STINGER   }, reward = 23540 },
    [644] = { trade = { 23272, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.WAKTZA_ROSTRUM     }, reward = 23607 },
    [645] = { trade = { 23339, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.ROCKFIN_TOOTH      }, reward = 23674 },
    -- BRD (Bihu +1) - Kaggen's Cuticle
    [646] = { trade = { 23072, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.GABBRATH_HORN      }, reward = 23407 },
    [647] = { trade = { 23139, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.YGGDREANT_BOLE     }, reward = 23474 },
    [648] = { trade = { 23206, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.BZTAVIAN_STINGER   }, reward = 23541 },
    [649] = { trade = { 23273, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.WAKTZA_ROSTRUM     }, reward = 23608 },
    [650] = { trade = { 23340, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.KAGGENS_CUTICLE,      xi.item.ROCKFIN_TOOTH      }, reward = 23675 },
    -- RNG (Arcadian +1) - Celaeno's Cloth
    [651] = { trade = { 23073, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.CELAENOS_CLOTH,       xi.item.GABBRATH_HORN      }, reward = 23408 },
    [652] = { trade = { 23140, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.CELAENOS_CLOTH,       xi.item.YGGDREANT_BOLE     }, reward = 23475 },
    [653] = { trade = { 23207, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.CELAENOS_CLOTH,       xi.item.BZTAVIAN_STINGER   }, reward = 23542 },
    [654] = { trade = { 23274, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.CELAENOS_CLOTH,       xi.item.WAKTZA_ROSTRUM     }, reward = 23609 },
    [655] = { trade = { 23341, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.CELAENOS_CLOTH,       xi.item.ROCKFIN_TOOTH      }, reward = 23676 },
    -- SAM (Sakonji +1) - Pil's Tuille
    [656] = { trade = { 23074, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.PILS_TUILLE,          xi.item.GABBRATH_HORN      }, reward = 23409 },
    [657] = { trade = { 23141, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.PILS_TUILLE,          xi.item.YGGDREANT_BOLE     }, reward = 23476 },
    [658] = { trade = { 23208, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.PILS_TUILLE,          xi.item.BZTAVIAN_STINGER   }, reward = 23543 },
    [659] = { trade = { 23275, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.PILS_TUILLE,          xi.item.WAKTZA_ROSTRUM     }, reward = 23610 },
    [660] = { trade = { 23342, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.PILS_TUILLE,          xi.item.ROCKFIN_TOOTH      }, reward = 23677 },
    -- NIN (Mochizuki +1) - Voidwrought Plate
    [661] = { trade = { 23075, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.GABBRATH_HORN      }, reward = 23410 },
    [662] = { trade = { 23142, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.YGGDREANT_BOLE     }, reward = 23477 },
    [663] = { trade = { 23209, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.BZTAVIAN_STINGER   }, reward = 23544 },
    [664] = { trade = { 23276, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.WAKTZA_ROSTRUM     }, reward = 23611 },
    [665] = { trade = { 23343, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.ROCKFIN_TOOTH      }, reward = 23678 },
    -- DRG (Pteroslaver +1) - Voidwrought Plate
    [666] = { trade = { 23076, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.GABBRATH_HORN      }, reward = 23411 },
    [667] = { trade = { 23143, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.YGGDREANT_BOLE     }, reward = 23478 },
    [668] = { trade = { 23210, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.BZTAVIAN_STINGER   }, reward = 23545 },
    [669] = { trade = { 23277, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.WAKTZA_ROSTRUM     }, reward = 23612 },
    [670] = { trade = { 23344, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.ROCKFIN_TOOTH      }, reward = 23679 },
    -- SMN (Glyphic +1) - Hahava's Mail
    [671] = { trade = { 23077, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.GABBRATH_HORN      }, reward = 23412 },
    [672] = { trade = { 23144, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.YGGDREANT_BOLE     }, reward = 23479 },
    [673] = { trade = { 23211, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.BZTAVIAN_STINGER   }, reward = 23546 },
    [674] = { trade = { 23278, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.WAKTZA_ROSTRUM     }, reward = 23613 },
    [675] = { trade = { 23345, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.ROCKFIN_TOOTH      }, reward = 23680 },
    -- BLU (Luhlaza +1) - Pil's Tuille
    [676] = { trade = { 23078, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.PILS_TUILLE,          xi.item.GABBRATH_HORN      }, reward = 23413 },
    [677] = { trade = { 23145, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.PILS_TUILLE,          xi.item.YGGDREANT_BOLE     }, reward = 23480 },
    [678] = { trade = { 23212, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.PILS_TUILLE,          xi.item.BZTAVIAN_STINGER   }, reward = 23547 },
    [679] = { trade = { 23279, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.PILS_TUILLE,          xi.item.WAKTZA_ROSTRUM     }, reward = 23614 },
    [680] = { trade = { 23346, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.PILS_TUILLE,          xi.item.ROCKFIN_TOOTH      }, reward = 23681 },
    -- COR (Lanun +1) - Kaggen's Cuticle
    [681] = { trade = { 23079, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.GABBRATH_HORN      }, reward = 23414 },
    [682] = { trade = { 23146, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.YGGDREANT_BOLE     }, reward = 23481 },
    [683] = { trade = { 23213, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.BZTAVIAN_STINGER   }, reward = 23548 },
    [684] = { trade = { 23280, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.WAKTZA_ROSTRUM     }, reward = 23615 },
    [685] = { trade = { 23347, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.KAGGENS_CUTICLE,      xi.item.ROCKFIN_TOOTH      }, reward = 23682 },
    -- PUP (Pitre +1) - Hahava's Mail
    [686] = { trade = { 23080, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.GABBRATH_HORN      }, reward = 23415 },
    [687] = { trade = { 23147, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.YGGDREANT_BOLE     }, reward = 23482 },
    [688] = { trade = { 23214, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.BZTAVIAN_STINGER   }, reward = 23549 },
    [689] = { trade = { 23281, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.WAKTZA_ROSTRUM     }, reward = 23616 },
    [690] = { trade = { 23348, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.ROCKFIN_TOOTH      }, reward = 23683 },
    -- DNC (Horos +1) - Celaeno's Cloth
    [691] = { trade = { 23081, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.CELAENOS_CLOTH,       xi.item.GABBRATH_HORN      }, reward = 23416 },
    [692] = { trade = { 23148, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.CELAENOS_CLOTH,       xi.item.YGGDREANT_BOLE     }, reward = 23483 },
    [693] = { trade = { 23215, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.CELAENOS_CLOTH,       xi.item.BZTAVIAN_STINGER   }, reward = 23550 },
    [694] = { trade = { 23282, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.CELAENOS_CLOTH,       xi.item.WAKTZA_ROSTRUM     }, reward = 23617 },
    [695] = { trade = { 23349, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.CELAENOS_CLOTH,       xi.item.ROCKFIN_TOOTH      }, reward = 23684 },
    -- SCH (Pedagogy +1) - Akvan's Pennon
    [696] = { trade = { 23082, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.AKVANS_PENNON,        xi.item.GABBRATH_HORN      }, reward = 23417 },
    [697] = { trade = { 23149, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.AKVANS_PENNON,        xi.item.YGGDREANT_BOLE     }, reward = 23484 },
    [698] = { trade = { 23216, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.AKVANS_PENNON,        xi.item.BZTAVIAN_STINGER   }, reward = 23551 },
    [699] = { trade = { 23283, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.AKVANS_PENNON,        xi.item.WAKTZA_ROSTRUM     }, reward = 23618 },
    [700] = { trade = { 23350, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.AKVANS_PENNON,        xi.item.ROCKFIN_TOOTH      }, reward = 23685 },
    -- GEO (Bagua +1) - Akvan's Pennon
    [1101] = { trade = { xi.item.BAGUA_GALERO_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.AKVANS_PENNON,  xi.item.GABBRATH_HORN    }, reward = 23418 },
    [1102] = { trade = { xi.item.BAGUA_TUNIC_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.AKVANS_PENNON,  xi.item.YGGDREANT_BOLE   }, reward = 23485 },
    [1103] = { trade = { xi.item.BAGUA_MITAINES_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.AKVANS_PENNON,  xi.item.BZTAVIAN_STINGER }, reward = 23552 },
    [1104] = { trade = { xi.item.BAGUA_PANTS_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.AKVANS_PENNON,  xi.item.WAKTZA_ROSTRUM   }, reward = 23619 },
    [1105] = { trade = { xi.item.BAGUA_SANDALS_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.AKVANS_PENNON,  xi.item.ROCKFIN_TOOTH    }, reward = 23686 },
    -- RUN (Futhark +1) - Celaeno's Cloth
    [1106] = { trade = { xi.item.FUTHARK_BANDEAU_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.CELAENOS_CLOTH, xi.item.GABBRATH_HORN    }, reward = 23419 },
    [1107] = { trade = { xi.item.FUTHARK_COAT_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.CELAENOS_CLOTH, xi.item.YGGDREANT_BOLE   }, reward = 23486 },
    [1108] = { trade = { xi.item.FUTHARK_MITONS_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.CELAENOS_CLOTH, xi.item.BZTAVIAN_STINGER }, reward = 23553 },
    [1109] = { trade = { xi.item.FUTHARK_TROUSERS_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.CELAENOS_CLOTH, xi.item.WAKTZA_ROSTRUM   }, reward = 23620 },
    [1110] = { trade = { xi.item.FUTHARK_BOOTS_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.CELAENOS_CLOTH, xi.item.ROCKFIN_TOOTH    }, reward = 23687 },
}

-----------------------------------
-- Empyrean Armor Reforge i109
-- Path A: Emp+2 + 5x Rem's Tale (Ch.1-5 by slot) + Abyssea job drop + slot ingredient -> i109
-- Path B: Emp+1 + 10x Rem's Tale (Ch.1-5 by slot) -> i109
--
-- Entries 801-900:  Path A (+2 input, 4-item trade)
-- Entries 1001-1100: Path B (+1 input, 2-item trade)
--
-- Slot Rem's Tale: Head=Ch.1 / Body=Ch.2 / Hands=Ch.3 / Legs=Ch.4 / Feet=Ch.5
-- Slot ingredients: Phoenix Feather(head) / Malboro Fiber(body) / Beetle Blood(hands)
--                   Damascene Cloth(legs) / Oxblood(feet)
-- Abyssea job drops:
--   WAR/DRK: Helm of Briareus     MNK: Itzpapalotl's Scale   WHM: Orthrus's Claw
--   BLM: Glavoid Shell             RDM: Cirein-croin's Lantern THF: Alfard's Fang
--   PLD: Kulkulkan's Fang          BST/SMN/PUP: Carabosse's Gem BRD: Dragua's Scale
--   RNG: Ulhuadshi's Fang          SAM: Apademak's Horn        NIN: Bukhis's Wing
--   DRG: Azdaja's Horn             BLU: Isgebind's Heart       COR: Sobek's Skin
--   DNC: Two-Leaf Chloris Bud      SCH: Sedna's Tusk
-----------------------------------
local empReforgeI109 =
{
    -- WAR (Ravager's -> Boii) - Path A - Helm of Briareus
    [801] = { trade = { xi.item.RAVAGERS_MASK_P2,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 }, xi.item.HELM_OF_BRIAREUS,         xi.item.PHOENIX_FEATHER           }, reward = 26740 },
    [802] = { trade = { xi.item.RAVAGERS_LORICA_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 }, xi.item.HELM_OF_BRIAREUS,         xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 26898 },
    [803] = { trade = { xi.item.RAVAGERS_MUFFLERS_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 }, xi.item.HELM_OF_BRIAREUS,         xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27052 },
    [804] = { trade = { xi.item.RAVAGERS_CUISSES_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 }, xi.item.HELM_OF_BRIAREUS,         xi.item.SQUARE_OF_DAMASCENE_CLOTH }, reward = 27237 },
    [805] = { trade = { xi.item.RAVAGERS_CALLIGAE_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 }, xi.item.HELM_OF_BRIAREUS,         xi.item.PIECE_OF_OXBLOOD          }, reward = 27411 },
    -- MNK (Tantra -> Bhikku) - Path A - Itzpapalotl's Scale
    [806] = { trade = { xi.item.TANTRA_CROWN_P2,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 }, xi.item.ITZPAPALOTLS_SCALE,       xi.item.PHOENIX_FEATHER           }, reward = 26742 },
    [807] = { trade = { xi.item.TANTRA_CYCLAS_P2,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 }, xi.item.ITZPAPALOTLS_SCALE,       xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 26900 },
    [808] = { trade = { xi.item.TANTRA_GLOVES_P2,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 }, xi.item.ITZPAPALOTLS_SCALE,       xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27054 },
    [809] = { trade = { xi.item.TANTRA_HOSE_P2,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 }, xi.item.ITZPAPALOTLS_SCALE,       xi.item.SQUARE_OF_DAMASCENE_CLOTH }, reward = 27239 },
    [810] = { trade = { xi.item.TANTRA_GAITERS_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 }, xi.item.ITZPAPALOTLS_SCALE,       xi.item.PIECE_OF_OXBLOOD          }, reward = 27413 },
    -- WHM (Orison -> Ebers) - Path A - Orthrus's Claw
    [811] = { trade = { xi.item.ORISON_CAP_P2,            { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 }, xi.item.ORTHRUSS_CLAW,            xi.item.PHOENIX_FEATHER           }, reward = 26744 },
    [812] = { trade = { xi.item.ORISON_BLIAUT_P2,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 }, xi.item.ORTHRUSS_CLAW,            xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 26902 },
    [813] = { trade = { xi.item.ORISON_MITTS_P2,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 }, xi.item.ORTHRUSS_CLAW,            xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27056 },
    [814] = { trade = { xi.item.ORISON_PANTALOONS_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 }, xi.item.ORTHRUSS_CLAW,            xi.item.SQUARE_OF_DAMASCENE_CLOTH }, reward = 27241 },
    [815] = { trade = { xi.item.ORISON_DUCKBILLS_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 }, xi.item.ORTHRUSS_CLAW,            xi.item.PIECE_OF_OXBLOOD          }, reward = 27415 },
    -- BLM (Goetia -> Wicce) - Path A - Glavoid Shell
    [816] = { trade = { xi.item.GOETIA_PETASOS_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 }, xi.item.GLAVOID_SHELL,            xi.item.PHOENIX_FEATHER           }, reward = 26746 },
    [817] = { trade = { xi.item.GOETIA_COAT_P2,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 }, xi.item.GLAVOID_SHELL,            xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 26904 },
    [818] = { trade = { xi.item.GOETIA_GLOVES_P2,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 }, xi.item.GLAVOID_SHELL,            xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27058 },
    [819] = { trade = { xi.item.GOETIA_CHAUSSES_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 }, xi.item.GLAVOID_SHELL,            xi.item.SQUARE_OF_DAMASCENE_CLOTH }, reward = 27243 },
    [820] = { trade = { xi.item.GOETIA_SABOTS_P2,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 }, xi.item.GLAVOID_SHELL,            xi.item.PIECE_OF_OXBLOOD          }, reward = 27417 },
    -- RDM (Estoqueur's -> Lethargy) - Path A - Cirein-croin's Lantern
    [821] = { trade = { xi.item.ESTOQUEURS_CHAPPEL_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 }, xi.item.CIREIN_CROINS_LANTERN,    xi.item.PHOENIX_FEATHER           }, reward = 26748 },
    [822] = { trade = { xi.item.ESTOQUEURS_SAYON_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 }, xi.item.CIREIN_CROINS_LANTERN,    xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 26906 },
    [823] = { trade = { xi.item.ESTOQUEURS_GANTHEROTS_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 }, xi.item.CIREIN_CROINS_LANTERN,    xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27060 },
    [824] = { trade = { xi.item.ESTOQUEURS_FUSEAU_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 }, xi.item.CIREIN_CROINS_LANTERN,    xi.item.SQUARE_OF_DAMASCENE_CLOTH }, reward = 27245 },
    [825] = { trade = { xi.item.ESTOQUEURS_HOUSEAUX_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 }, xi.item.CIREIN_CROINS_LANTERN,    xi.item.PIECE_OF_OXBLOOD          }, reward = 27419 },
    -- THF (Raider's -> Skulker's) - Path A - Alfard's Fang
    [826] = { trade = { xi.item.RAIDERS_BONNET_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 }, xi.item.ALFARDS_FANG,             xi.item.PHOENIX_FEATHER           }, reward = 26750 },
    [827] = { trade = { xi.item.RAIDERS_VEST_P2,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 }, xi.item.ALFARDS_FANG,             xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 26908 },
    [828] = { trade = { xi.item.RAIDERS_ARMLETS_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 }, xi.item.ALFARDS_FANG,             xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27062 },
    [829] = { trade = { xi.item.RAIDERS_CULOTTES_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 }, xi.item.ALFARDS_FANG,             xi.item.SQUARE_OF_DAMASCENE_CLOTH }, reward = 27247 },
    [830] = { trade = { xi.item.RAIDERS_POULAINES_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 }, xi.item.ALFARDS_FANG,             xi.item.PIECE_OF_OXBLOOD          }, reward = 27421 },
    -- PLD (Creed -> Chevalier's) - Path A - Kulkulkan's Fang
    [831] = { trade = { xi.item.CREED_ARMET_P2,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 }, xi.item.KULKULKANS_FANG,          xi.item.PHOENIX_FEATHER           }, reward = 26752 },
    [832] = { trade = { xi.item.CREED_CUIRASS_P2,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 }, xi.item.KULKULKANS_FANG,          xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 26910 },
    [833] = { trade = { xi.item.CREED_GAUNTLETS_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 }, xi.item.KULKULKANS_FANG,          xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27064 },
    [834] = { trade = { xi.item.CREED_CUISSES_P2,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 }, xi.item.KULKULKANS_FANG,          xi.item.SQUARE_OF_DAMASCENE_CLOTH }, reward = 27249 },
    [835] = { trade = { xi.item.CREED_SABATONS_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 }, xi.item.KULKULKANS_FANG,          xi.item.PIECE_OF_OXBLOOD          }, reward = 27423 },
    -- DRK (Bale -> Heathen's) - Path A - Helm of Briareus
    [836] = { trade = { xi.item.BALE_BURGEONET_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 }, xi.item.HELM_OF_BRIAREUS,         xi.item.PHOENIX_FEATHER           }, reward = 26754 },
    [837] = { trade = { xi.item.BALE_CUIRASS_P2,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 }, xi.item.HELM_OF_BRIAREUS,         xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 26912 },
    [838] = { trade = { xi.item.BALE_GAUNTLETS_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 }, xi.item.HELM_OF_BRIAREUS,         xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27066 },
    [839] = { trade = { xi.item.BALE_FLANCHARD_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 }, xi.item.HELM_OF_BRIAREUS,         xi.item.SQUARE_OF_DAMASCENE_CLOTH }, reward = 27251 },
    [840] = { trade = { xi.item.BALE_SOLLERETS_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 }, xi.item.HELM_OF_BRIAREUS,         xi.item.PIECE_OF_OXBLOOD          }, reward = 27425 },
    -- BST (Ferine -> Nukumi) - Path A - Carabosse's Gem
    [841] = { trade = { xi.item.FERINE_CABASSET_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 }, xi.item.CARABOSSES_GEM,           xi.item.PHOENIX_FEATHER           }, reward = 26756 },
    [842] = { trade = { xi.item.FERINE_GAUSAPE_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 }, xi.item.CARABOSSES_GEM,           xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 26914 },
    [843] = { trade = { xi.item.FERINE_MANOPLAS_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 }, xi.item.CARABOSSES_GEM,           xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27068 },
    [844] = { trade = { xi.item.FERINE_QUIJOTES_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 }, xi.item.CARABOSSES_GEM,           xi.item.SQUARE_OF_DAMASCENE_CLOTH }, reward = 27253 },
    [845] = { trade = { xi.item.FERINE_OCREAE_P2,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 }, xi.item.CARABOSSES_GEM,           xi.item.PIECE_OF_OXBLOOD          }, reward = 27427 },
    -- BRD (Aoidos' -> Fili) - Path A - Dragua's Scale
    [846] = { trade = { xi.item.AOIDOS_CALOT_P2,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 }, xi.item.DRAGUAS_SCALE,            xi.item.PHOENIX_FEATHER           }, reward = 26758 },
    [847] = { trade = { xi.item.AOIDOS_HONGRELINE_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 }, xi.item.DRAGUAS_SCALE,            xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 26916 },
    [848] = { trade = { xi.item.AOIDOS_MANCHETTES_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 }, xi.item.DRAGUAS_SCALE,            xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27070 },
    [849] = { trade = { xi.item.AOIDOS_RHINGRAVE_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 }, xi.item.DRAGUAS_SCALE,            xi.item.SQUARE_OF_DAMASCENE_CLOTH }, reward = 27255 },
    [850] = { trade = { xi.item.AOIDOS_COTHURNES_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 }, xi.item.DRAGUAS_SCALE,            xi.item.PIECE_OF_OXBLOOD          }, reward = 27429 },
    -- RNG (Sylvan -> Amini) - Path A - Ulhuadshi's Fang
    [851] = { trade = { xi.item.SYLVAN_GAPETTE_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 }, xi.item.ULHUADSHIS_FANG,          xi.item.PHOENIX_FEATHER           }, reward = 26760 },
    [852] = { trade = { xi.item.SYLVAN_CABAN_P2,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 }, xi.item.ULHUADSHIS_FANG,          xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 26918 },
    [853] = { trade = { xi.item.SYLVAN_GLOVELETTES_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 }, xi.item.ULHUADSHIS_FANG,          xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27072 },
    [854] = { trade = { xi.item.SYLVAN_BRAGUES_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 }, xi.item.ULHUADSHIS_FANG,          xi.item.SQUARE_OF_DAMASCENE_CLOTH }, reward = 27257 },
    [855] = { trade = { xi.item.SYLVAN_BOTTILLONS_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 }, xi.item.ULHUADSHIS_FANG,          xi.item.PIECE_OF_OXBLOOD          }, reward = 27431 },
    -- SAM (Unkai -> Kasuga) - Path A - Apademak's Horn
    [856] = { trade = { xi.item.UNKAI_KABUTO_P2,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 }, xi.item.APADEMAKS_HORN,           xi.item.PHOENIX_FEATHER           }, reward = 26762 },
    [857] = { trade = { xi.item.UNKAI_DOMARU_P2,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 }, xi.item.APADEMAKS_HORN,           xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 26920 },
    [858] = { trade = { xi.item.UNKAI_KOTE_P2,            { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 }, xi.item.APADEMAKS_HORN,           xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27074 },
    [859] = { trade = { xi.item.UNKAI_HAIDATE_P2,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 }, xi.item.APADEMAKS_HORN,           xi.item.SQUARE_OF_DAMASCENE_CLOTH }, reward = 27259 },
    [860] = { trade = { xi.item.UNKAI_SUNE_ATE_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 }, xi.item.APADEMAKS_HORN,           xi.item.PIECE_OF_OXBLOOD          }, reward = 27433 },
    -- NIN (Iga -> Hattori) - Path A - Bukhis's Wing
    [861] = { trade = { xi.item.IGA_ZUKIN_P2,             { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 }, xi.item.BUKHISS_WING,             xi.item.PHOENIX_FEATHER           }, reward = 26764 },
    [862] = { trade = { xi.item.IGA_NINGI_P2,             { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 }, xi.item.BUKHISS_WING,             xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 26922 },
    [863] = { trade = { xi.item.IGA_TEKKO_P2,             { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 }, xi.item.BUKHISS_WING,             xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27076 },
    [864] = { trade = { xi.item.IGA_HAKAMA_P2,            { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 }, xi.item.BUKHISS_WING,             xi.item.SQUARE_OF_DAMASCENE_CLOTH }, reward = 27261 },
    [865] = { trade = { xi.item.IGA_KYAHAN_P2,            { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 }, xi.item.BUKHISS_WING,             xi.item.PIECE_OF_OXBLOOD          }, reward = 27435 },
    -- DRG (Lancer's -> Peltast's) - Path A - Azdaja's Horn
    [866] = { trade = { xi.item.LANCERS_MEZAIL_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 }, xi.item.AZDAJAS_HORN,             xi.item.PHOENIX_FEATHER           }, reward = 26766 },
    [867] = { trade = { xi.item.LANCERS_PLACKART_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 }, xi.item.AZDAJAS_HORN,             xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 26924 },
    [868] = { trade = { xi.item.LANCERS_VAMBRACES_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 }, xi.item.AZDAJAS_HORN,             xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27078 },
    [869] = { trade = { xi.item.LANCERS_CUISSOTS_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 }, xi.item.AZDAJAS_HORN,             xi.item.SQUARE_OF_DAMASCENE_CLOTH }, reward = 27263 },
    [870] = { trade = { xi.item.LANCERS_SCHYNBALDS_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 }, xi.item.AZDAJAS_HORN,             xi.item.PIECE_OF_OXBLOOD          }, reward = 27437 },
    -- SMN (Caller's -> Beckoner's) - Path A - Carabosse's Gem
    [871] = { trade = { xi.item.CALLERS_HORN_P2,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 }, xi.item.CARABOSSES_GEM,           xi.item.PHOENIX_FEATHER           }, reward = 26768 },
    [872] = { trade = { xi.item.CALLERS_DOUBLET_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 }, xi.item.CARABOSSES_GEM,           xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 26926 },
    [873] = { trade = { xi.item.CALLERS_BRACERS_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 }, xi.item.CARABOSSES_GEM,           xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27080 },
    [874] = { trade = { xi.item.CALLERS_SPATS_P2,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 }, xi.item.CARABOSSES_GEM,           xi.item.SQUARE_OF_DAMASCENE_CLOTH }, reward = 27265 },
    [875] = { trade = { xi.item.CALLERS_PIGACHES_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 }, xi.item.CARABOSSES_GEM,           xi.item.PIECE_OF_OXBLOOD          }, reward = 27439 },
    -- BLU (Mavi -> Hashishin) - Path A - Isgebind's Heart
    [876] = { trade = { xi.item.MAVI_KAVUK_P2,            { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 }, xi.item.ISGEBINDS_HEART,          xi.item.PHOENIX_FEATHER           }, reward = 26770 },
    [877] = { trade = { xi.item.MAVI_MINTAN_P2,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 }, xi.item.ISGEBINDS_HEART,          xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 26928 },
    [878] = { trade = { xi.item.MAVI_BAZUBANDS_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 }, xi.item.ISGEBINDS_HEART,          xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27082 },
    [879] = { trade = { xi.item.MAVI_TAYT_P2,             { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 }, xi.item.ISGEBINDS_HEART,          xi.item.SQUARE_OF_DAMASCENE_CLOTH }, reward = 27267 },
    [880] = { trade = { xi.item.MAVI_BASMAK_P2,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 }, xi.item.ISGEBINDS_HEART,          xi.item.PIECE_OF_OXBLOOD          }, reward = 27441 },
    -- COR (Navarch's -> Chasseur's) - Path A - Sobek's Skin
    [881] = { trade = { xi.item.NAVARCHS_TRICORNE_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 }, xi.item.SOBEKS_SKIN,              xi.item.PHOENIX_FEATHER           }, reward = 26772 },
    [882] = { trade = { xi.item.NAVARCHS_FRAC_P2,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 }, xi.item.SOBEKS_SKIN,              xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 26930 },
    [883] = { trade = { xi.item.NAVARCHS_GANTS_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 }, xi.item.SOBEKS_SKIN,              xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27084 },
    [884] = { trade = { xi.item.NAVARCHS_CULOTTES_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 }, xi.item.SOBEKS_SKIN,              xi.item.SQUARE_OF_DAMASCENE_CLOTH }, reward = 27269 },
    [885] = { trade = { xi.item.NAVARCHS_BOTTES_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 }, xi.item.SOBEKS_SKIN,              xi.item.PIECE_OF_OXBLOOD          }, reward = 27443 },
    -- PUP (Cirque -> Karagoz) - Path A - Carabosse's Gem
    [886] = { trade = { xi.item.CIRQUE_CAPPELLO_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 }, xi.item.CARABOSSES_GEM,           xi.item.PHOENIX_FEATHER           }, reward = 26774 },
    [887] = { trade = { xi.item.CIRQUE_FARSETTO_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 }, xi.item.CARABOSSES_GEM,           xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 26932 },
    [888] = { trade = { xi.item.CIRQUE_GUANTI_P2,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 }, xi.item.CARABOSSES_GEM,           xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27086 },
    [889] = { trade = { xi.item.CIRQUE_PANTALONI_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 }, xi.item.CARABOSSES_GEM,           xi.item.SQUARE_OF_DAMASCENE_CLOTH }, reward = 27271 },
    [890] = { trade = { xi.item.CIRQUE_SCARPE_P2,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 }, xi.item.CARABOSSES_GEM,           xi.item.PIECE_OF_OXBLOOD          }, reward = 27445 },
    -- DNC (Charis -> Maculele) - Path A - Two-Leaf Chloris Bud
    [891] = { trade = { xi.item.CHARIS_TIARA_P2,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 }, xi.item.TWO_LEAF_CHLORIS_BUD,     xi.item.PHOENIX_FEATHER           }, reward = 26776 },
    [892] = { trade = { xi.item.CHARIS_CASAQUE_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 }, xi.item.TWO_LEAF_CHLORIS_BUD,     xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 26934 },
    [893] = { trade = { xi.item.CHARIS_BANGLES_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 }, xi.item.TWO_LEAF_CHLORIS_BUD,     xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27088 },
    [894] = { trade = { xi.item.CHARIS_TIGHTS_P2,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 }, xi.item.TWO_LEAF_CHLORIS_BUD,     xi.item.SQUARE_OF_DAMASCENE_CLOTH }, reward = 27273 },
    [895] = { trade = { xi.item.CHARIS_TOE_SHOES_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 }, xi.item.TWO_LEAF_CHLORIS_BUD,     xi.item.PIECE_OF_OXBLOOD          }, reward = 27447 },
    -- SCH (Savant's -> Arbatel) - Path A - Sedna's Tusk
    [896] = { trade = { xi.item.SAVANTS_BONNET_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 }, xi.item.SEDNAS_TUSK,              xi.item.PHOENIX_FEATHER           }, reward = 26778 },
    [897] = { trade = { xi.item.SAVANTS_GOWN_P2,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 }, xi.item.SEDNAS_TUSK,              xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 26936 },
    [898] = { trade = { xi.item.SAVANTS_BRACERS_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 }, xi.item.SEDNAS_TUSK,              xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27090 },
    [899] = { trade = { xi.item.SAVANTS_PANTS_P2,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 }, xi.item.SEDNAS_TUSK,              xi.item.SQUARE_OF_DAMASCENE_CLOTH }, reward = 27275 },
    [900] = { trade = { xi.item.SAVANTS_LOAFERS_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 }, xi.item.SEDNAS_TUSK,              xi.item.PIECE_OF_OXBLOOD          }, reward = 27449 },
    -- WAR (Ravager's -> Boii) - Path B
    [1001] = { trade = { xi.item.RAVAGERS_MASK_P1,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26740 },
    [1002] = { trade = { xi.item.RAVAGERS_LORICA_P1,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26898 },
    [1003] = { trade = { xi.item.RAVAGERS_MUFFLERS_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27052 },
    [1004] = { trade = { xi.item.RAVAGERS_CUISSES_P1,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27237 },
    [1005] = { trade = { xi.item.RAVAGERS_CALLIGAE_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27411 },
    -- MNK (Tantra -> Bhikku) - Path B
    [1006] = { trade = { xi.item.TANTRA_CROWN_P1,            { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26742 },
    [1007] = { trade = { xi.item.TANTRA_CYCLAS_P1,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26900 },
    [1008] = { trade = { xi.item.TANTRA_GLOVES_P1,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27054 },
    [1009] = { trade = { xi.item.TANTRA_HOSE_P1,             { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27239 },
    [1010] = { trade = { xi.item.TANTRA_GAITERS_P1,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27413 },
    -- WHM (Orison -> Ebers) - Path B
    [1011] = { trade = { xi.item.ORISON_CAP_P1,              { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26744 },
    [1012] = { trade = { xi.item.ORISON_BLIAUT_P1,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26902 },
    [1013] = { trade = { xi.item.ORISON_MITTS_P1,            { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27056 },
    [1014] = { trade = { xi.item.ORISON_PANTALOONS_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27241 },
    [1015] = { trade = { xi.item.ORISON_DUCKBILLS_P1,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27415 },
    -- BLM (Goetia -> Wicce) - Path B
    [1016] = { trade = { xi.item.GOETIA_PETASOS_P1,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26746 },
    [1017] = { trade = { xi.item.GOETIA_COAT_P1,             { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26904 },
    [1018] = { trade = { xi.item.GOETIA_GLOVES_P1,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27058 },
    [1019] = { trade = { xi.item.GOETIA_CHAUSSES_P1,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27243 },
    [1020] = { trade = { xi.item.GOETIA_SABOTS_P1,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27417 },
    -- RDM (Estoqueur's -> Lethargy) - Path B
    [1021] = { trade = { xi.item.ESTOQUEURS_CHAPPEL_P1,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26748 },
    [1022] = { trade = { xi.item.ESTOQUEURS_SAYON_P1,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26906 },
    [1023] = { trade = { xi.item.ESTOQUEURS_GANTHEROTS_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27060 },
    [1024] = { trade = { xi.item.ESTOQUEURS_FUSEAU_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27245 },
    [1025] = { trade = { xi.item.ESTOQUEURS_HOUSEAUX_P1,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27419 },
    -- THF (Raider's -> Skulker's) - Path B
    [1026] = { trade = { xi.item.RAIDERS_BONNET_P1,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26750 },
    [1027] = { trade = { xi.item.RAIDERS_VEST_P1,            { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26908 },
    [1028] = { trade = { xi.item.RAIDERS_ARMLETS_P1,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27062 },
    [1029] = { trade = { xi.item.RAIDERS_CULOTTES_P1,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27247 },
    [1030] = { trade = { xi.item.RAIDERS_POULAINES_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27421 },
    -- PLD (Creed -> Chevalier's) - Path B
    [1031] = { trade = { xi.item.CREED_ARMET_P1,             { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26752 },
    [1032] = { trade = { xi.item.CREED_CUIRASS_P1,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26910 },
    [1033] = { trade = { xi.item.CREED_GAUNTLETS_P1,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27064 },
    [1034] = { trade = { xi.item.CREED_CUISSES_P1,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27249 },
    [1035] = { trade = { xi.item.CREED_SABATONS_P1,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27423 },
    -- DRK (Bale -> Heathen's) - Path B
    [1036] = { trade = { xi.item.BALE_BURGEONET_P1,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26754 },
    [1037] = { trade = { xi.item.BALE_CUIRASS_P1,            { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26912 },
    [1038] = { trade = { xi.item.BALE_GAUNTLETS_P1,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27066 },
    [1039] = { trade = { xi.item.BALE_FLANCHARD_P1,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27251 },
    [1040] = { trade = { xi.item.BALE_SOLLERETS_P1,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27425 },
    -- BST (Ferine -> Nukumi) - Path B
    [1041] = { trade = { xi.item.FERINE_CABASSET_P1,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26756 },
    [1042] = { trade = { xi.item.FERINE_GAUSAPE_P1,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26914 },
    [1043] = { trade = { xi.item.FERINE_MANOPLAS_P1,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27068 },
    [1044] = { trade = { xi.item.FERINE_QUIJOTES_P1,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27253 },
    [1045] = { trade = { xi.item.FERINE_OCREAE_P1,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27427 },
    -- BRD (Aoidos' -> Fili) - Path B
    [1046] = { trade = { xi.item.AOIDOS_CALOT_P1,            { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26758 },
    [1047] = { trade = { xi.item.AOIDOS_HONGRELINE_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26916 },
    [1048] = { trade = { xi.item.AOIDOS_MANCHETTES_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27070 },
    [1049] = { trade = { xi.item.AOIDOS_RHINGRAVE_P1,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27255 },
    [1050] = { trade = { xi.item.AOIDOS_COTHURNES_P1,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27429 },
    -- RNG (Sylvan -> Amini) - Path B
    [1051] = { trade = { xi.item.SYLVAN_GAPETTE_P1,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26760 },
    [1052] = { trade = { xi.item.SYLVAN_CABAN_P1,            { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26918 },
    [1053] = { trade = { xi.item.SYLVAN_GLOVELETTES_P1,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27072 },
    [1054] = { trade = { xi.item.SYLVAN_BRAGUES_P1,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27257 },
    [1055] = { trade = { xi.item.SYLVAN_BOTTILLONS_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27431 },
    -- SAM (Unkai -> Kasuga) - Path B
    [1056] = { trade = { xi.item.UNKAI_KABUTO_P1,            { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26762 },
    [1057] = { trade = { xi.item.UNKAI_DOMARU_P1,            { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26920 },
    [1058] = { trade = { xi.item.UNKAI_KOTE_P1,              { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27074 },
    [1059] = { trade = { xi.item.UNKAI_HAIDATE_P1,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27259 },
    [1060] = { trade = { xi.item.UNKAI_SUNE_ATE_P1,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27433 },
    -- NIN (Iga -> Hattori) - Path B
    [1061] = { trade = { xi.item.IGA_ZUKIN_P1,               { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26764 },
    [1062] = { trade = { xi.item.IGA_NINGI_P1,               { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26922 },
    [1063] = { trade = { xi.item.IGA_TEKKO_P1,               { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27076 },
    [1064] = { trade = { xi.item.IGA_HAKAMA_P1,              { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27261 },
    [1065] = { trade = { xi.item.IGA_KYAHAN_P1,              { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27435 },
    -- DRG (Lancer's -> Peltast's) - Path B
    [1066] = { trade = { xi.item.LANCERS_MEZAIL_P1,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26766 },
    [1067] = { trade = { xi.item.LANCERS_PLACKART_P1,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26924 },
    [1068] = { trade = { xi.item.LANCERS_VAMBRACES_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27078 },
    [1069] = { trade = { xi.item.LANCERS_CUISSOTS_P1,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27263 },
    [1070] = { trade = { xi.item.LANCERS_SCHYNBALDS_P1,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27437 },
    -- SMN (Caller's -> Beckoner's) - Path B
    [1071] = { trade = { xi.item.CALLERS_HORN_P1,            { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26768 },
    [1072] = { trade = { xi.item.CALLERS_DOUBLET_P1,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26926 },
    [1073] = { trade = { xi.item.CALLERS_BRACERS_P1,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27080 },
    [1074] = { trade = { xi.item.CALLERS_SPATS_P1,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27265 },
    [1075] = { trade = { xi.item.CALLERS_PIGACHES_P1,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27439 },
    -- BLU (Mavi -> Hashishin) - Path B
    [1076] = { trade = { xi.item.MAVI_KAVUK_P1,              { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26770 },
    [1077] = { trade = { xi.item.MAVI_MINTAN_P1,             { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26928 },
    [1078] = { trade = { xi.item.MAVI_BAZUBANDS_P1,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27082 },
    [1079] = { trade = { xi.item.MAVI_TAYT_P1,               { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27267 },
    [1080] = { trade = { xi.item.MAVI_BASMAK_P1,             { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27441 },
    -- COR (Navarch's -> Chasseur's) - Path B
    [1081] = { trade = { xi.item.NAVARCHS_TRICORNE_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26772 },
    [1082] = { trade = { xi.item.NAVARCHS_FRAC_P1,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26930 },
    [1083] = { trade = { xi.item.NAVARCHS_GANTS_P1,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27084 },
    [1084] = { trade = { xi.item.NAVARCHS_CULOTTES_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27269 },
    [1085] = { trade = { xi.item.NAVARCHS_BOTTES_P1,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27443 },
    -- PUP (Cirque -> Karagoz) - Path B
    [1086] = { trade = { xi.item.CIRQUE_CAPPELLO_P1,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26774 },
    [1087] = { trade = { xi.item.CIRQUE_FARSETTO_P1,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26932 },
    [1088] = { trade = { xi.item.CIRQUE_GUANTI_P1,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27086 },
    [1089] = { trade = { xi.item.CIRQUE_PANTALONI_P1,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27271 },
    [1090] = { trade = { xi.item.CIRQUE_SCARPE_P1,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27445 },
    -- DNC (Charis -> Maculele) - Path B
    [1091] = { trade = { xi.item.CHARIS_TIARA_P1,            { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26776 },
    [1092] = { trade = { xi.item.CHARIS_CASAQUE_P1,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26934 },
    [1093] = { trade = { xi.item.CHARIS_BANGLES_P1,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27088 },
    [1094] = { trade = { xi.item.CHARIS_TIGHTS_P1,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27273 },
    [1095] = { trade = { xi.item.CHARIS_TOE_SHOES_P1,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27447 },
    -- SCH (Savant's -> Arbatel) - Path B
    [1096] = { trade = { xi.item.SAVANTS_BONNET_P1,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26778 },
    [1097] = { trade = { xi.item.SAVANTS_GOWN_P1,            { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26936 },
    [1098] = { trade = { xi.item.SAVANTS_BRACERS_P1,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27090 },
    [1099] = { trade = { xi.item.SAVANTS_PANTS_P1,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27275 },
    [1100] = { trade = { xi.item.SAVANTS_LOAFERS_P1,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27449 },
}

-----------------------------------
-- Empyrean Armor Reforge i119
-- Trade: Emp i109 piece + 8x Rem's Tale (Ch.6-10 by slot) + Etched Memory (qty by slot) + slot ingredient -> i119
-- NOTE: Vagary drop requirements deliberately removed (custom change).
--
-- Slot Rem's Tale: Head=Ch.6 / Body=Ch.7 / Hands=Ch.8 / Legs=Ch.9 / Feet=Ch.10
-- Etched Memory qty: Head=15 / Body=25 / Hands=15 / Legs=20 / Feet=15
-- Slot ingredients: Vial of Defiant Sweat(head) / Chunk of Dark Matter(body) / Macuil Horn(hands)
--                   Tartarian Chain(legs) / Vial of Plovid Effluvium(feet)
-- i109 input:  Head 26740+2j / Body 26898+2j / Hands 27052+2j / Legs 27237+2j / Feet 27411+2j
-- i119 output: i109 input + 1
--   j: WAR=0 MNK=1 WHM=2 BLM=3 RDM=4 THF=5 PLD=6 DRK=7 BST=8 BRD=9
--      RNG=10 SAM=11 NIN=12 DRG=13 SMN=14 BLU=15 COR=16 PUP=17 DNC=18 SCH=19
-----------------------------------
local empReforgeI119 =
{
    -- WAR (Boii -> Boii +1)
    [901]  = { trade = { 26740, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26741 },
    [902]  = { trade = { 26898, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26899 },
    [903]  = { trade = { 27052, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27053 },
    [904]  = { trade = { 27237, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27238 },
    [905]  = { trade = { 27411, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27412 },
    -- MNK (Bhikku -> Bhikku +1)
    [906]  = { trade = { 26742, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26743 },
    [907]  = { trade = { 26900, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26901 },
    [908]  = { trade = { 27054, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27055 },
    [909]  = { trade = { 27239, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27240 },
    [910]  = { trade = { 27413, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27414 },
    -- WHM (Ebers -> Ebers +1)
    [911]  = { trade = { 26744, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26745 },
    [912]  = { trade = { 26902, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26903 },
    [913]  = { trade = { 27056, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27057 },
    [914]  = { trade = { 27241, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27242 },
    [915]  = { trade = { 27415, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27416 },
    -- BLM (Wicce -> Wicce +1)
    [916]  = { trade = { 26746, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26747 },
    [917]  = { trade = { 26904, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26905 },
    [918]  = { trade = { 27058, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27059 },
    [919]  = { trade = { 27243, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27244 },
    [920]  = { trade = { 27417, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27418 },
    -- RDM (Lethargy -> Lethargy +1)
    [921]  = { trade = { 26748, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26749 },
    [922]  = { trade = { 26906, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26907 },
    [923]  = { trade = { 27060, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27061 },
    [924]  = { trade = { 27245, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27246 },
    [925]  = { trade = { 27419, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27420 },
    -- THF (Skulker's -> Skulker's +1)
    [926]  = { trade = { 26750, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26751 },
    [927]  = { trade = { 26908, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26909 },
    [928]  = { trade = { 27062, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27063 },
    [929]  = { trade = { 27247, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27248 },
    [930]  = { trade = { 27421, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27422 },
    -- PLD (Chevalier's -> Chevalier's +1)
    [931]  = { trade = { 26752, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26753 },
    [932]  = { trade = { 26910, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26911 },
    [933]  = { trade = { 27064, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27065 },
    [934]  = { trade = { 27249, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27250 },
    [935]  = { trade = { 27423, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27424 },
    -- DRK (Heathen's -> Heathen's +1)
    [936]  = { trade = { 26754, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26755 },
    [937]  = { trade = { 26912, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26913 },
    [938]  = { trade = { 27066, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27067 },
    [939]  = { trade = { 27251, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27252 },
    [940]  = { trade = { 27425, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27426 },
    -- BST (Nukumi -> Nukumi +1)
    [941]  = { trade = { 26756, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26757 },
    [942]  = { trade = { 26914, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26915 },
    [943]  = { trade = { 27068, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27069 },
    [944]  = { trade = { 27253, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27254 },
    [945]  = { trade = { 27427, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27428 },
    -- BRD (Fili -> Fili +1)
    [946]  = { trade = { 26758, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26759 },
    [947]  = { trade = { 26916, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26917 },
    [948]  = { trade = { 27070, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27071 },
    [949]  = { trade = { 27255, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27256 },
    [950]  = { trade = { 27429, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27430 },
    -- RNG (Amini -> Amini +1)
    [951]  = { trade = { 26760, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26761 },
    [952]  = { trade = { 26918, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26919 },
    [953]  = { trade = { 27072, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27073 },
    [954]  = { trade = { 27257, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27258 },
    [955]  = { trade = { 27431, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27432 },
    -- SAM (Kasuga -> Kasuga +1)
    [956]  = { trade = { 26762, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26763 },
    [957]  = { trade = { 26920, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26921 },
    [958]  = { trade = { 27074, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27075 },
    [959]  = { trade = { 27259, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27260 },
    [960]  = { trade = { 27433, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27434 },
    -- NIN (Hattori -> Hattori +1)
    [961]  = { trade = { 26764, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26765 },
    [962]  = { trade = { 26922, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26923 },
    [963]  = { trade = { 27076, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27077 },
    [964]  = { trade = { 27261, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27262 },
    [965]  = { trade = { 27435, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27436 },
    -- DRG (Peltast's -> Peltast's +1)
    [966]  = { trade = { 26766, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26767 },
    [967]  = { trade = { 26924, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26925 },
    [968]  = { trade = { 27078, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27079 },
    [969]  = { trade = { 27263, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27264 },
    [970]  = { trade = { 27437, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27438 },
    -- SMN (Beckoner's -> Beckoner's +1)
    [971]  = { trade = { 26768, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26769 },
    [972]  = { trade = { 26926, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26927 },
    [973]  = { trade = { 27080, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27081 },
    [974]  = { trade = { 27265, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27266 },
    [975]  = { trade = { 27439, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27440 },
    -- BLU (Hashishin -> Hashishin +1)
    [976]  = { trade = { 26770, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26771 },
    [977]  = { trade = { 26928, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26929 },
    [978]  = { trade = { 27082, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27083 },
    [979]  = { trade = { 27267, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27268 },
    [980]  = { trade = { 27441, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27442 },
    -- COR (Chasseur's -> Chasseur's +1)
    [981]  = { trade = { 26772, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26773 },
    [982]  = { trade = { 26930, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26931 },
    [983]  = { trade = { 27084, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27085 },
    [984]  = { trade = { 27269, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27270 },
    [985]  = { trade = { 27443, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27444 },
    -- PUP (Karagoz -> Karagoz +1)
    [986]  = { trade = { 26774, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26775 },
    [987]  = { trade = { 26932, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26933 },
    [988]  = { trade = { 27086, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27087 },
    [989]  = { trade = { 27271, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27272 },
    [990]  = { trade = { 27445, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27446 },
    -- DNC (Maculele -> Maculele +1)
    [991]  = { trade = { 26776, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26777 },
    [992]  = { trade = { 26934, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26935 },
    [993]  = { trade = { 27088, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27089 },
    [994]  = { trade = { 27273, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27274 },
    [995]  = { trade = { 27447, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27448 },
    -- SCH (Arbatel -> Arbatel +1)
    [996]  = { trade = { 26778, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26779 },
    [997]  = { trade = { 26936, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26937 },
    [998]  = { trade = { 27090, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27091 },
    [999]  = { trade = { 27275, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27276 },
    [1000] = { trade = { 27449, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27450 },
    -- GEO (Azimuth -> Azimuth +1)
    [1111] = { trade = { xi.item.AZIMUTH_HOOD,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26781 },
    [1112] = { trade = { xi.item.AZIMUTH_COAT,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26939 },
    [1113] = { trade = { xi.item.AZIMUTH_GLOVES,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27093 },
    [1114] = { trade = { xi.item.AZIMUTH_TIGHTS,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27278 },
    [1115] = { trade = { xi.item.AZIMUTH_GAITERS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27452 },
    -- RUN (Erilaz -> Erilaz +1)
    [1116] = { trade = { xi.item.ERILAZ_GALEA,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_DEFIANT_SWEAT       }, reward = 26783 },
    [1117] = { trade = { xi.item.ERILAZ_SURCOAT,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, { xi.item.ETCHED_MEMORY, 25 }, xi.item.CHUNK_OF_DARK_MATTER         }, reward = 26941 },
    [1118] = { trade = { xi.item.ERILAZ_GAUNTLETS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.MACUIL_HORN                  }, reward = 27095 },
    [1119] = { trade = { xi.item.ERILAZ_LEG_GUARDS,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, { xi.item.ETCHED_MEMORY, 20 }, xi.item.TARTARIAN_CHAIN              }, reward = 27280 },
    [1120] = { trade = { xi.item.ERILAZ_GREAVES,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, { xi.item.ETCHED_MEMORY, 15 }, xi.item.VIAL_OF_PLOVID_EFFLUVIUM     }, reward = 27454 },
}

-----------------------------------
-- Build a single lookup map from all trade tables for efficient matching.
-----------------------------------
local allUpgrades = {}
for k, v in pairs(afReforgeI109) do
    allUpgrades[k] = v
end

for k, v in pairs(afReforgeI119) do
    allUpgrades[k] = v
end

for k, v in pairs(relicReforgeI109) do
    allUpgrades[k] = v
end

for k, v in pairs(relicReforgeI119) do
    allUpgrades[k] = v
end

for k, v in pairs(empReforgeI109) do
    allUpgrades[k] = v
end

for k, v in pairs(empReforgeI119) do
    allUpgrades[k] = v
end

-----------------------------------
-- Deposit Rem's Tales that appear in the trade.
-- Returns true if any tales were deposited.
-----------------------------------
local function depositRemsTales(player, trade)
    local deposited = false

    for chapter, itemId in ipairs(remsTaleItems) do
        local qty = trade:getItemQty(itemId)

        if qty > 0 then
            local stored  = getStoredTales(player, chapter)
            local canTake = math.min(qty, maxStoredTales - stored)

            if canTake > 0 then
                setStoredTales(player, chapter, stored + canTake)
                deposited = true
            end
        end
    end

    return deposited
end

-----------------------------------
-- Returns true if the trade contains only Rem's Tale items (deposit intent).
-----------------------------------
local function isRemsTaleOnlyTrade(trade)
    local remsTaleSet = {}
    for _, itemId in ipairs(remsTaleItems) do
        remsTaleSet[itemId] = true
    end

    for i = 0, trade:getSlotCount() - 1 do
        local itemId = trade:getItemId(i)

        if not remsTaleSet[itemId] then
            return false
        end
    end

    return true
end

-----------------------------------
entity.onTrade = function(player, npc, trade)
    -- Rem's Tales deposit: only Rem's Tales in trade
    if isRemsTaleOnlyTrade(trade) then
        if depositRemsTales(player, trade) then
            player:confirmTrade()
            player:messageSpecial(ID.text.ITEM_OBTAINED, xi.item.COPY_OF_REMS_TALE_CHAPTER_1) -- generic confirmation
        end

        return
    end

    -- Armor upgrade trades
    for _, entry in pairs(allUpgrades) do
        if npcUtil.tradeHasExactly(trade, entry.trade) then
            if npcUtil.giveItem(player, entry.reward) then
                player:confirmTrade()
            end

            return
        end
    end
end

-----------------------------------
entity.onTrigger = function(player, npc)
    local stored = {}
    for chapter = 1, 10 do
        stored[chapter] = getStoredTales(player, chapter)
    end

    -- Pass stored chapter counts as event parameters (ch1-8 fit in 8 slots).
    -- Chapter 9/10 counts are packed into one parameter if needed.
    player:startEvent(384, stored[1], stored[2], stored[3], stored[4], stored[5], stored[6], stored[7], stored[8])
end

-----------------------------------
entity.onEventFinish = function(player, csid, option, npc)
    if csid ~= 384 or option == 0 then
        return
    end

    -- option encodes: chapter (bits 0-3) and quantity to retrieve (bits 4+)
    local chapter  = bit.band(option, 0xF)
    local quantity = bit.rshift(option, 4)

    if chapter < 1 or chapter > 10 then
        return
    end

    local stored  = getStoredTales(player, chapter)
    local give    = math.min(quantity > 0 and quantity or stored, stored)
    local itemId  = remsTaleItems[chapter]

    if give > 0 and npcUtil.giveItem(player, { { itemId, give } }) then
        setStoredTales(player, chapter, stored - give)
    end
end

return entity
