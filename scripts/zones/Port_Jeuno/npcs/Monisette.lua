-----------------------------------
-- Area: Port Jeuno
--  NPC: Monisette
-- !pos -6 0 -11 246
-- Reforges Artifact, Relic, and Empyrean armor to i109/i119 variants.
-- Stores Rem's Tales chapters for players.
-- Custom changes: No Sagheera interaction required, no Limbus access
-- required, no Vagary items required for Empyrean reforge.
-----------------------------------
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
--         + job ingredient + slot ingredient -> Reforged i109
-- Path 2: AF+1 + 5x same Rem's Tale -> same Reforged i109
--
-- Entries   1-105: Path 1 (base AF piece)
-- Entries 106-200: Path 2 (AF+1 piece, WAR-DNC/M)
-- Entries 316-325: Path 2 (AF+1 piece, DNC/F and SCH — offset to avoid key collision with afReforgeI119 [201-315])
--
-- Output layout (actual Monisette i109 items, job_index j):
--   WAR=0 MNK=1 WHM=2 BLM=3 RDM=4 THF=5 PLD=6 DRK=7 BST=8 BRD=9
--   RNG=10 SAM=11 NIN=12 DRG=13 SMN=14 BLU=15 COR=16 PUP=17 DNC(M)=18 DNC(F)=19 SCH=20
--   Head 27663+j  Body 27807+j  Hands 27943+j  Legs 28090+j  Feet 28223+j
-----------------------------------
local afReforgeI109 =
{
    -- WAR (Pummeler's) - Tiger Leather
    [  1] = { trade = { 12511, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, xi.item.PHOENIX_FEATHER         }, reward = 27663 }, -- head
    [  2] = { trade = { 12638, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 27807 }, -- body
    [  3] = { trade = { 13961, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27943 }, -- hands
    [  4] = { trade = { 14214, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 28090 }, -- legs
    [  5] = { trade = { 14089, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, xi.item.PIECE_OF_OXBLOOD           }, reward = 28223 }, -- feet
    -- MNK (Anchorite's) - Gold Thread
    [  6] = { trade = { 12512, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.PHOENIX_FEATHER         }, reward = 27664 },
    [  7] = { trade = { 12639, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 27808 },
    [  8] = { trade = { 13962, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27944 },
    [  9] = { trade = { 14215, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 28091 },
    [ 10] = { trade = { 14090, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.PIECE_OF_OXBLOOD           }, reward = 28224 },
    -- WHM (Theophany) - Imp. Silk Cloth
    [ 11] = { trade = { 13855, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.PHOENIX_FEATHER         }, reward = 27665 },
    [ 12] = { trade = { 12640, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 27809 },
    [ 13] = { trade = { 13963, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27945 },
    [ 14] = { trade = { 14216, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 28092 },
    [ 15] = { trade = { 14091, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.PIECE_OF_OXBLOOD           }, reward = 28225 },
    -- BLM (Spaekona's) - Karakul Cloth
    [ 16] = { trade = { 13856, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.PHOENIX_FEATHER         }, reward = 27666 },
    [ 17] = { trade = { 12641, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 27810 },
    [ 18] = { trade = { 13964, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27946 },
    [ 19] = { trade = { 14217, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 28093 },
    [ 20] = { trade = { 14092, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.PIECE_OF_OXBLOOD           }, reward = 28226 },
    -- RDM (Atrophy) - Scarlet Linen
    [ 21] = { trade = { 12513, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.PHOENIX_FEATHER         }, reward = 27667 },
    [ 22] = { trade = { 12642, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 27811 },
    [ 23] = { trade = { 13965, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27947 },
    [ 24] = { trade = { 14218, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 28094 },
    [ 25] = { trade = { 14093, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.PIECE_OF_OXBLOOD           }, reward = 28227 },
    -- THF (Pillager's) - Gold Thread
    [ 26] = { trade = { 12514, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.PHOENIX_FEATHER         }, reward = 27668 },
    [ 27] = { trade = { 12643, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 27812 },
    [ 28] = { trade = { 13966, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27948 },
    [ 29] = { trade = { 14219, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 28095 },
    [ 30] = { trade = { 14094, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.PIECE_OF_OXBLOOD           }, reward = 28228 },
    -- PLD (Reverence) - Gold Sheet
    [ 31] = { trade = { 12515, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.GOLD_SHEET, xi.item.PHOENIX_FEATHER         }, reward = 27669 },
    [ 32] = { trade = { 12644, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.GOLD_SHEET, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 27813 },
    [ 33] = { trade = { 13967, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.GOLD_SHEET, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27949 },
    [ 34] = { trade = { 14220, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.GOLD_SHEET, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 28096 },
    [ 35] = { trade = { 14095, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.GOLD_SHEET, xi.item.PIECE_OF_OXBLOOD           }, reward = 28229 },
    -- DRK (Ignominy) - Darksteel Sheet
    [ 36] = { trade = { 12516, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.DARKSTEEL_SHEET, xi.item.PHOENIX_FEATHER         }, reward = 27670 },
    [ 37] = { trade = { 12645, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.DARKSTEEL_SHEET, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 27814 },
    [ 38] = { trade = { 13968, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.DARKSTEEL_SHEET, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27950 },
    [ 39] = { trade = { 14221, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.DARKSTEEL_SHEET, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 28097 },
    [ 40] = { trade = { 14096, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.DARKSTEEL_SHEET, xi.item.PIECE_OF_OXBLOOD           }, reward = 28230 },
    -- BST (Totemic) - Tiger Leather
    [ 41] = { trade = { 12517, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, xi.item.PHOENIX_FEATHER         }, reward = 27671 },
    [ 42] = { trade = { 12646, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 27815 },
    [ 43] = { trade = { 13969, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27951 },
    [ 44] = { trade = { 14222, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 28098 },
    [ 45] = { trade = { 14097, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, xi.item.PIECE_OF_OXBLOOD           }, reward = 28231 },
    -- BRD (Brioso) - Imp. Silk Cloth
    [ 46] = { trade = { 13857, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.PHOENIX_FEATHER         }, reward = 27672 },
    [ 47] = { trade = { 12647, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 27816 },
    [ 48] = { trade = { 13970, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27952 },
    [ 49] = { trade = { 14223, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 28099 },
    [ 50] = { trade = { 14098, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.PIECE_OF_OXBLOOD           }, reward = 28232 },
    -- RNG (Orion) - Karakul Cloth
    [ 51] = { trade = { 12518, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.PHOENIX_FEATHER         }, reward = 27673 },
    [ 52] = { trade = { 12648, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 27817 },
    [ 53] = { trade = { 13971, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27953 },
    [ 54] = { trade = { 14224, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 28100 },
    [ 55] = { trade = { 14099, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.PIECE_OF_OXBLOOD           }, reward = 28233 },
    -- SAM (Wakido) - Tama-Hagane
    [ 56] = { trade = { 13868, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.LUMP_OF_TAMA_HAGANE, xi.item.PHOENIX_FEATHER         }, reward = 27674 },
    [ 57] = { trade = { 13781, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.LUMP_OF_TAMA_HAGANE, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 27818 },
    [ 58] = { trade = { 13972, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.LUMP_OF_TAMA_HAGANE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27954 },
    [ 59] = { trade = { 14225, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.LUMP_OF_TAMA_HAGANE, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 28101 },
    [ 60] = { trade = { 14100, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.LUMP_OF_TAMA_HAGANE, xi.item.PIECE_OF_OXBLOOD           }, reward = 28234 },
    -- NIN (Hachiya) - Tama-Hagane
    [ 61] = { trade = { 13869, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.LUMP_OF_TAMA_HAGANE, xi.item.PHOENIX_FEATHER         }, reward = 27675 },
    [ 62] = { trade = { 13782, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.LUMP_OF_TAMA_HAGANE, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 27819 },
    [ 63] = { trade = { 13973, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.LUMP_OF_TAMA_HAGANE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27955 },
    [ 64] = { trade = { 14226, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.LUMP_OF_TAMA_HAGANE, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 28102 },
    [ 65] = { trade = { 14101, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.LUMP_OF_TAMA_HAGANE, xi.item.PIECE_OF_OXBLOOD           }, reward = 28235 },
    -- DRG (Vishap) - Gold Sheet
    [ 66] = { trade = { 12519, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.GOLD_SHEET, xi.item.PHOENIX_FEATHER         }, reward = 27676 },
    [ 67] = { trade = { 12649, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.GOLD_SHEET, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 27820 },
    [ 68] = { trade = { 13974, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.GOLD_SHEET, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27956 },
    [ 69] = { trade = { 14227, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.GOLD_SHEET, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 28103 },
    [ 70] = { trade = { 14102, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.GOLD_SHEET, xi.item.PIECE_OF_OXBLOOD           }, reward = 28236 },
    -- SMN (Convoker's) - Scarlet Linen
    [ 71] = { trade = { 12520, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.PHOENIX_FEATHER         }, reward = 27677 },
    [ 72] = { trade = { 12650, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 27821 },
    [ 73] = { trade = { 13975, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27957 },
    [ 74] = { trade = { 14228, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 28104 },
    [ 75] = { trade = { 14103, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.PIECE_OF_OXBLOOD           }, reward = 28237 },
    -- BLU (Assimilator's) - Imp. Silk Cloth
    [ 76] = { trade = { 15265, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.PHOENIX_FEATHER         }, reward = 27678 },
    [ 77] = { trade = { 14521, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 27822 },
    [ 78] = { trade = { 14928, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27958 },
    [ 79] = { trade = { 15600, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 28105 },
    [ 80] = { trade = { 15684, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_IMPERIAL_SILK_CLOTH, xi.item.PIECE_OF_OXBLOOD           }, reward = 28238 },
    -- COR (Laksamana's) - Karakul Cloth
    [ 81] = { trade = { 15266, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.PHOENIX_FEATHER         }, reward = 27679 },
    [ 82] = { trade = { 14522, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 27823 },
    [ 83] = { trade = { 14929, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27959 },
    [ 84] = { trade = { 15601, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 28106 },
    [ 85] = { trade = { 15685, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.PIECE_OF_OXBLOOD           }, reward = 28239 },
    -- PUP (Foire) - Karakul Cloth
    [ 86] = { trade = { 15267, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.PHOENIX_FEATHER         }, reward = 27680 },
    [ 87] = { trade = { 14523, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 27824 },
    [ 88] = { trade = { 14930, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27960 },
    [ 89] = { trade = { 15602, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 28107 },
    [ 90] = { trade = { 15686, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_KARAKUL_CLOTH, xi.item.PIECE_OF_OXBLOOD           }, reward = 28240 },
    -- DNC/M (Maxixi) - Gold Thread
    [ 91] = { trade = { 16138, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.PHOENIX_FEATHER         }, reward = 27681 },
    [ 92] = { trade = { 14578, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 27825 },
    [ 93] = { trade = { 15002, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27961 },
    [ 94] = { trade = { 15659, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 28108 },
    [ 95] = { trade = { 15746, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.PIECE_OF_OXBLOOD           }, reward = 28241 },
    -- DNC/F (Maxixi) - Gold Thread
    [ 96] = { trade = { 16139, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.PHOENIX_FEATHER         }, reward = 27682 },
    [ 97] = { trade = { 14579, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 27826 },
    [ 98] = { trade = { 15003, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27962 },
    [ 99] = { trade = { 15660, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 28109 },
    [100] = { trade = { 15747, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SPOOL_OF_GOLD_THREAD, xi.item.PIECE_OF_OXBLOOD           }, reward = 28242 },
    -- SCH (Academic's) - Scarlet Linen
    [101] = { trade = { 16140, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.PHOENIX_FEATHER         }, reward = 27683 },
    [102] = { trade = { 14580, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.SPOOL_OF_MALBORO_FIBER    }, reward = 27827 },
    [103] = { trade = { 15004, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD }, reward = 27963 },
    [104] = { trade = { 16311, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.SQUARE_OF_DAMASCENE_CLOTH  }, reward = 28110 },
    [105] = { trade = { 15748, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SQUARE_OF_SCARLET_LINEN_CLOTH, xi.item.PIECE_OF_OXBLOOD           }, reward = 28243 },
    -- Path 2: AF+1 + 5x Rem's Tale -> same i109 output (no extra ingredients needed)
    -- WAR
    [106] = { trade = { 15225, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 27663 },
    [107] = { trade = { 14473, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 27807 },
    [108] = { trade = { 14890, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 27943 },
    [109] = { trade = { 15561, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 28090 },
    [110] = { trade = { 15352, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 28223 },
    -- MNK
    [111] = { trade = { 15226, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 27664 },
    [112] = { trade = { 14474, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 27808 },
    [113] = { trade = { 14891, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 27944 },
    [114] = { trade = { 15562, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 28091 },
    [115] = { trade = { 15353, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 28224 },
    -- WHM
    [116] = { trade = { 15227, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 27665 },
    [117] = { trade = { 14475, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 27809 },
    [118] = { trade = { 14892, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 27945 },
    [119] = { trade = { 15563, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 28092 },
    [120] = { trade = { 15354, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 28225 },
    -- BLM
    [121] = { trade = { 15228, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 27666 },
    [122] = { trade = { 14476, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 27810 },
    [123] = { trade = { 14893, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 27946 },
    [124] = { trade = { 15564, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 28093 },
    [125] = { trade = { 15355, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 28226 },
    -- RDM
    [126] = { trade = { 15229, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 27667 },
    [127] = { trade = { 14477, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 27811 },
    [128] = { trade = { 14894, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 27947 },
    [129] = { trade = { 15565, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 28094 },
    [130] = { trade = { 15356, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 28227 },
    -- THF
    [131] = { trade = { 15230, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 27668 },
    [132] = { trade = { 14478, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 27812 },
    [133] = { trade = { 14895, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 27948 },
    [134] = { trade = { 15566, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 28095 },
    [135] = { trade = { 15357, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 28228 },
    -- PLD
    [136] = { trade = { 15231, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 27669 },
    [137] = { trade = { 14479, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 27813 },
    [138] = { trade = { 14896, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 27949 },
    [139] = { trade = { 15567, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 28096 },
    [140] = { trade = { 15358, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 28229 },
    -- DRK
    [141] = { trade = { 15232, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 27670 },
    [142] = { trade = { 14480, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 27814 },
    [143] = { trade = { 14897, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 27950 },
    [144] = { trade = { 15568, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 28097 },
    [145] = { trade = { 15359, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 28230 },
    -- BST
    [146] = { trade = { 15233, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 27671 },
    [147] = { trade = { 14481, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 27815 },
    [148] = { trade = { 14898, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 27951 },
    [149] = { trade = { 15569, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 28098 },
    [150] = { trade = { 15360, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 28231 },
    -- BRD
    [151] = { trade = { 15234, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 27672 },
    [152] = { trade = { 14482, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 27816 },
    [153] = { trade = { 14899, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 27952 },
    [154] = { trade = { 15570, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 28099 },
    [155] = { trade = { 15361, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 28232 },
    -- RNG
    [156] = { trade = { 15235, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 27673 },
    [157] = { trade = { 14483, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 27817 },
    [158] = { trade = { 14900, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 27953 },
    [159] = { trade = { 15571, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 28100 },
    [160] = { trade = { 15362, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 28233 },
    -- SAM
    [161] = { trade = { 15236, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 27674 },
    [162] = { trade = { 14484, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 27818 },
    [163] = { trade = { 14901, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 27954 },
    [164] = { trade = { 15572, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 28101 },
    [165] = { trade = { 15363, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 28234 },
    -- NIN
    [166] = { trade = { 15237, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 27675 },
    [167] = { trade = { 14485, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 27819 },
    [168] = { trade = { 14902, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 27955 },
    [169] = { trade = { 15573, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 28102 },
    [170] = { trade = { 15364, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 28235 },
    -- DRG
    [171] = { trade = { 15238, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 27676 },
    [172] = { trade = { 14486, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 27820 },
    [173] = { trade = { 14903, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 27956 },
    [174] = { trade = { 15574, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 28103 },
    [175] = { trade = { 15365, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 28236 },
    -- SMN
    [176] = { trade = { 15239, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 27677 },
    [177] = { trade = { 14487, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 27821 },
    [178] = { trade = { 14904, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 27957 },
    [179] = { trade = { 15575, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 28104 },
    [180] = { trade = { 15366, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 28237 },
    -- BLU
    [181] = { trade = { 11464, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 27678 },
    [182] = { trade = { 11291, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 27822 },
    [183] = { trade = { 15024, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 27958 },
    [184] = { trade = { 16345, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 28105 },
    [185] = { trade = { 11381, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 28238 },
    -- COR
    [186] = { trade = { 11467, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 27679 },
    [187] = { trade = { 11294, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 27823 },
    [188] = { trade = { 15027, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 27959 },
    [189] = { trade = { 16348, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 28106 },
    [190] = { trade = { 11384, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 28239 },
    -- PUP
    [191] = { trade = { 11470, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 27680 },
    [192] = { trade = { 11297, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 27824 },
    [193] = { trade = { 15030, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 27960 },
    [194] = { trade = { 16351, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 28107 },
    [195] = { trade = { 11387, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 28240 },
    -- DNC/M
    [196] = { trade = { 11475, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 27681 },
    [197] = { trade = { 11302, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 27825 },
    [198] = { trade = { 15035, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 27961 },
    [199] = { trade = { 16357, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 28108 },
    [200] = { trade = { 11393, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 28241 },
    -- DNC/F (keys 316-320: offset to avoid collision with afReforgeI119 [201-315])
    [316] = { trade = { 11476, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 27682 },
    [317] = { trade = { 11303, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 27826 },
    [318] = { trade = { 15036, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 27962 },
    [319] = { trade = { 16358, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 28109 },
    [320] = { trade = { 11394, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 28242 },
    -- SCH (keys 321-325)
    [321] = { trade = { 11477, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 5 } }, reward = 27683 },
    [322] = { trade = { 11304, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 5 } }, reward = 27827 },
    [323] = { trade = { 15037, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 5 } }, reward = 27963 },
    [324] = { trade = { 16359, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 5 } }, reward = 28110 },
    [325] = { trade = { 11395, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 5 } }, reward = 28243 },
}

-----------------------------------
-- Artifact Armor Reforge i119
-- Trade: i109 piece + 8x Rem's Tale (Ch.6 head/Ch.7 body/Ch.8 hands/Ch.9 legs/Ch.10 feet)
--         + job ingredient + slot ingredient -> i119
-- GEO/RUN have no i109 intermediate — trade base AF piece directly for i119.
--
-- Slot ingredients: Maliyakaleya Coral(head) / Hepatizon Ore(body) / Beryllium Ore(hands)
--                   Exalted Log(legs) / Sif's Lock(feet)
--
-- Output layout (actual Monisette i119 items, job_index j):
--   WAR=0 MNK=1 WHM=2 BLM=3 RDM=4 THF=5 PLD=6 DRK=7 BST=8 BRD=9
--   RNG=10 SAM=11 NIN=12 DRG=13 SMN=14 BLU=15 COR=16 PUP=17 DNC(M)=18 DNC(F)=19 SCH=20
--   Head 27684+j  Body 27828+j  Hands 27964+j  Legs 28111+j  Feet 28244+j
--   GEO(21): Head 27705  Body 27849  Hands 27985  Legs 28132  Feet 28265
--   RUN(22): Head 27706  Body 27850  Hands 27986  Legs 28133  Feet 28266
-----------------------------------
local afReforgeI119 =
{
    -- WAR (Pummeler's) - Behemoth Leather
    [201] = { trade = { 27663, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SQUARE_OF_BEHEMOTH_LEATHER,     xi.item.MALIYAKALEYA_CORAL }, reward = 27684 }, -- head
    [202] = { trade = { 27807, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SQUARE_OF_BEHEMOTH_LEATHER,     xi.item.HEPATIZON_ORE      }, reward = 27828 }, -- body
    [203] = { trade = { 27943, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SQUARE_OF_BEHEMOTH_LEATHER,     xi.item.BERYLLIUM_ORE      }, reward = 27964 }, -- hands
    [204] = { trade = { 28090, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SQUARE_OF_BEHEMOTH_LEATHER,     xi.item.EXALTED_LOG        }, reward = 28111 }, -- legs
    [205] = { trade = { 28223, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SQUARE_OF_BEHEMOTH_LEATHER,     xi.item.SIFS_LOCK          }, reward = 28244 }, -- feet
    -- MNK (Anchorite's) - Platinum Silk Thread
    [206] = { trade = { 27664, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.MALIYAKALEYA_CORAL }, reward = 27685 },
    [207] = { trade = { 27808, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.HEPATIZON_ORE      }, reward = 27829 },
    [208] = { trade = { 27944, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.BERYLLIUM_ORE      }, reward = 27965 },
    [209] = { trade = { 28091, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.EXALTED_LOG        }, reward = 28112 },
    [210] = { trade = { 28224, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.SIFS_LOCK          }, reward = 28245 },
    -- WHM (Theophany) - Raxa
    [211] = { trade = { 27665, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.MALIYAKALEYA_CORAL }, reward = 27686 },
    [212] = { trade = { 27809, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.HEPATIZON_ORE      }, reward = 27830 },
    [213] = { trade = { 27945, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.BERYLLIUM_ORE      }, reward = 27966 },
    [214] = { trade = { 28092, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.EXALTED_LOG        }, reward = 28113 },
    [215] = { trade = { 28225, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SQUARE_OF_RAXA,                xi.item.SIFS_LOCK          }, reward = 28246 },
    -- BLM (Spaekona's) - Twill Damask
    [216] = { trade = { 27666, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.TWILL_DAMASK,                  xi.item.MALIYAKALEYA_CORAL }, reward = 27687 },
    [217] = { trade = { 27810, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.TWILL_DAMASK,                  xi.item.HEPATIZON_ORE      }, reward = 27831 },
    [218] = { trade = { 27946, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.TWILL_DAMASK,                  xi.item.BERYLLIUM_ORE      }, reward = 27967 },
    [219] = { trade = { 28093, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.TWILL_DAMASK,                  xi.item.EXALTED_LOG        }, reward = 28114 },
    [220] = { trade = { 28226, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.TWILL_DAMASK,                  xi.item.SIFS_LOCK          }, reward = 28247 },
    -- RDM (Atrophy) - Siren's Hair
    [221] = { trade = { 27667, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.MALIYAKALEYA_CORAL }, reward = 27688 },
    [222] = { trade = { 27811, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.HEPATIZON_ORE      }, reward = 27832 },
    [223] = { trade = { 27947, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.BERYLLIUM_ORE      }, reward = 27968 },
    [224] = { trade = { 28094, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.EXALTED_LOG        }, reward = 28115 },
    [225] = { trade = { 28227, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.SIFS_LOCK          }, reward = 28248 },
    -- THF (Pillager's) - Platinum Silk Thread
    [226] = { trade = { 27668, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.MALIYAKALEYA_CORAL }, reward = 27689 },
    [227] = { trade = { 27812, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.HEPATIZON_ORE      }, reward = 27833 },
    [228] = { trade = { 27948, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.BERYLLIUM_ORE      }, reward = 27969 },
    [229] = { trade = { 28095, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.EXALTED_LOG        }, reward = 28116 },
    [230] = { trade = { 28228, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.SIFS_LOCK          }, reward = 28249 },
    -- PLD (Reverence) - Orichalcum Sheet
    [231] = { trade = { 27669, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.ORICHALCUM_SHEET,              xi.item.MALIYAKALEYA_CORAL }, reward = 27690 },
    [232] = { trade = { 27813, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.ORICHALCUM_SHEET,              xi.item.HEPATIZON_ORE      }, reward = 27834 },
    [233] = { trade = { 27949, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.ORICHALCUM_SHEET,              xi.item.BERYLLIUM_ORE      }, reward = 27970 },
    [234] = { trade = { 28096, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.ORICHALCUM_SHEET,              xi.item.EXALTED_LOG        }, reward = 28117 },
    [235] = { trade = { 28229, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.ORICHALCUM_SHEET,              xi.item.SIFS_LOCK          }, reward = 28250 },
    -- DRK (Ignominy) - Durium Sheet
    [236] = { trade = { 27670, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.DURIUM_SHEET,                  xi.item.MALIYAKALEYA_CORAL }, reward = 27691 },
    [237] = { trade = { 27814, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.DURIUM_SHEET,                  xi.item.HEPATIZON_ORE      }, reward = 27835 },
    [238] = { trade = { 27950, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.DURIUM_SHEET,                  xi.item.BERYLLIUM_ORE      }, reward = 27971 },
    [239] = { trade = { 28097, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.DURIUM_SHEET,                  xi.item.EXALTED_LOG        }, reward = 28118 },
    [240] = { trade = { 28230, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.DURIUM_SHEET,                  xi.item.SIFS_LOCK          }, reward = 28251 },
    -- BST (Totemic) - Behemoth Leather
    [241] = { trade = { 27671, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SQUARE_OF_BEHEMOTH_LEATHER,     xi.item.MALIYAKALEYA_CORAL }, reward = 27692 },
    [242] = { trade = { 27815, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SQUARE_OF_BEHEMOTH_LEATHER,     xi.item.HEPATIZON_ORE      }, reward = 27836 },
    [243] = { trade = { 27951, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SQUARE_OF_BEHEMOTH_LEATHER,     xi.item.BERYLLIUM_ORE      }, reward = 27972 },
    [244] = { trade = { 28098, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SQUARE_OF_BEHEMOTH_LEATHER,     xi.item.EXALTED_LOG        }, reward = 28119 },
    [245] = { trade = { 28231, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SQUARE_OF_BEHEMOTH_LEATHER,     xi.item.SIFS_LOCK          }, reward = 28252 },
    -- BRD (Brioso) - Raxa
    [246] = { trade = { 27672, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.MALIYAKALEYA_CORAL }, reward = 27693 },
    [247] = { trade = { 27816, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.HEPATIZON_ORE      }, reward = 27837 },
    [248] = { trade = { 27952, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.BERYLLIUM_ORE      }, reward = 27973 },
    [249] = { trade = { 28099, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.EXALTED_LOG        }, reward = 28120 },
    [250] = { trade = { 28232, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SQUARE_OF_RAXA,                xi.item.SIFS_LOCK          }, reward = 28253 },
    -- RNG (Orion) - Twill Damask
    [251] = { trade = { 27673, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.TWILL_DAMASK,                  xi.item.MALIYAKALEYA_CORAL }, reward = 27694 },
    [252] = { trade = { 27817, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.TWILL_DAMASK,                  xi.item.HEPATIZON_ORE      }, reward = 27838 },
    [253] = { trade = { 27953, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.TWILL_DAMASK,                  xi.item.BERYLLIUM_ORE      }, reward = 27974 },
    [254] = { trade = { 28100, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.TWILL_DAMASK,                  xi.item.EXALTED_LOG        }, reward = 28121 },
    [255] = { trade = { 28233, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.TWILL_DAMASK,                  xi.item.SIFS_LOCK          }, reward = 28254 },
    -- SAM (Wakido) - Damascus Ingot
    [256] = { trade = { 27674, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.MALIYAKALEYA_CORAL }, reward = 27695 },
    [257] = { trade = { 27818, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.HEPATIZON_ORE      }, reward = 27839 },
    [258] = { trade = { 27954, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.BERYLLIUM_ORE      }, reward = 27975 },
    [259] = { trade = { 28101, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.EXALTED_LOG        }, reward = 28122 },
    [260] = { trade = { 28234, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.DAMASCUS_INGOT,                xi.item.SIFS_LOCK          }, reward = 28255 },
    -- NIN (Hachiya) - Damascus Ingot
    [261] = { trade = { 27675, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.MALIYAKALEYA_CORAL }, reward = 27696 },
    [262] = { trade = { 27819, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.HEPATIZON_ORE      }, reward = 27840 },
    [263] = { trade = { 27955, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.BERYLLIUM_ORE      }, reward = 27976 },
    [264] = { trade = { 28102, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.EXALTED_LOG        }, reward = 28123 },
    [265] = { trade = { 28235, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.DAMASCUS_INGOT,                xi.item.SIFS_LOCK          }, reward = 28256 },
    -- DRG (Vishap) - Orichalcum Sheet
    [266] = { trade = { 27676, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.ORICHALCUM_SHEET,              xi.item.MALIYAKALEYA_CORAL }, reward = 27697 },
    [267] = { trade = { 27820, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.ORICHALCUM_SHEET,              xi.item.HEPATIZON_ORE      }, reward = 27841 },
    [268] = { trade = { 27956, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.ORICHALCUM_SHEET,              xi.item.BERYLLIUM_ORE      }, reward = 27977 },
    [269] = { trade = { 28103, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.ORICHALCUM_SHEET,              xi.item.EXALTED_LOG        }, reward = 28124 },
    [270] = { trade = { 28236, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.ORICHALCUM_SHEET,              xi.item.SIFS_LOCK          }, reward = 28257 },
    -- SMN (Convoker's) - Siren's Hair
    [271] = { trade = { 27677, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.MALIYAKALEYA_CORAL }, reward = 27698 },
    [272] = { trade = { 27821, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.HEPATIZON_ORE      }, reward = 27842 },
    [273] = { trade = { 27957, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.BERYLLIUM_ORE      }, reward = 27978 },
    [274] = { trade = { 28104, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.EXALTED_LOG        }, reward = 28125 },
    [275] = { trade = { 28237, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.SIFS_LOCK          }, reward = 28258 },
    -- BLU (Assimilator's) - Raxa
    [276] = { trade = { 27678, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.MALIYAKALEYA_CORAL }, reward = 27699 },
    [277] = { trade = { 27822, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.HEPATIZON_ORE      }, reward = 27843 },
    [278] = { trade = { 27958, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.BERYLLIUM_ORE      }, reward = 27979 },
    [279] = { trade = { 28105, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.EXALTED_LOG        }, reward = 28126 },
    [280] = { trade = { 28238, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SQUARE_OF_RAXA,                xi.item.SIFS_LOCK          }, reward = 28259 },
    -- COR (Laksamana's) - Twill Damask
    [281] = { trade = { 27679, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.TWILL_DAMASK,                  xi.item.MALIYAKALEYA_CORAL }, reward = 27700 },
    [282] = { trade = { 27823, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.TWILL_DAMASK,                  xi.item.HEPATIZON_ORE      }, reward = 27844 },
    [283] = { trade = { 27959, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.TWILL_DAMASK,                  xi.item.BERYLLIUM_ORE      }, reward = 27980 },
    [284] = { trade = { 28106, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.TWILL_DAMASK,                  xi.item.EXALTED_LOG        }, reward = 28127 },
    [285] = { trade = { 28239, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.TWILL_DAMASK,                  xi.item.SIFS_LOCK          }, reward = 28260 },
    -- PUP (Foire) - Twill Damask
    [286] = { trade = { 27680, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.TWILL_DAMASK,                  xi.item.MALIYAKALEYA_CORAL }, reward = 27701 },
    [287] = { trade = { 27824, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.TWILL_DAMASK,                  xi.item.HEPATIZON_ORE      }, reward = 27845 },
    [288] = { trade = { 27960, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.TWILL_DAMASK,                  xi.item.BERYLLIUM_ORE      }, reward = 27981 },
    [289] = { trade = { 28107, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.TWILL_DAMASK,                  xi.item.EXALTED_LOG        }, reward = 28128 },
    [290] = { trade = { 28240, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.TWILL_DAMASK,                  xi.item.SIFS_LOCK          }, reward = 28261 },
    -- DNC/M (Maxixi) - Platinum Silk Thread
    [291] = { trade = { 27681, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.MALIYAKALEYA_CORAL }, reward = 27702 },
    [292] = { trade = { 27825, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.HEPATIZON_ORE      }, reward = 27846 },
    [293] = { trade = { 27961, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.BERYLLIUM_ORE      }, reward = 27982 },
    [294] = { trade = { 28108, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.EXALTED_LOG        }, reward = 28129 },
    [295] = { trade = { 28241, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.SIFS_LOCK          }, reward = 28262 },
    -- DNC/F (Maxixi) - Platinum Silk Thread
    [296] = { trade = { 27682, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.MALIYAKALEYA_CORAL }, reward = 27703 },
    [297] = { trade = { 27826, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.HEPATIZON_ORE      }, reward = 27847 },
    [298] = { trade = { 27962, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.BERYLLIUM_ORE      }, reward = 27983 },
    [299] = { trade = { 28109, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.EXALTED_LOG        }, reward = 28130 },
    [300] = { trade = { 28242, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SPOOL_OF_PLATINUM_SILK_THREAD, xi.item.SIFS_LOCK          }, reward = 28263 },
    -- SCH (Academic's) - Siren's Hair
    [301] = { trade = { 27683, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.MALIYAKALEYA_CORAL }, reward = 27704 },
    [302] = { trade = { 27827, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.HEPATIZON_ORE      }, reward = 27848 },
    [303] = { trade = { 27963, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.BERYLLIUM_ORE      }, reward = 27984 },
    [304] = { trade = { 28110, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.EXALTED_LOG        }, reward = 28131 },
    [305] = { trade = { 28243, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.LOCK_OF_SIRENS_HAIR,           xi.item.SIFS_LOCK          }, reward = 28264 },
    -- GEO (Geomancy) - Raxa
    [306] = { trade = { 27786, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.MALIYAKALEYA_CORAL }, reward = 27705 },
    [307] = { trade = { 27926, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.HEPATIZON_ORE      }, reward = 27849 },
    [308] = { trade = { 28066, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.BERYLLIUM_ORE      }, reward = 27985 },
    [309] = { trade = { 28206, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SQUARE_OF_RAXA,                xi.item.EXALTED_LOG        }, reward = 28132 },
    [310] = { trade = { 28346, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SQUARE_OF_RAXA,                xi.item.SIFS_LOCK          }, reward = 28265 },
    -- RUN (Runeist) - Damascus Ingot
    [311] = { trade = { 27787, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.MALIYAKALEYA_CORAL }, reward = 27706 },
    [312] = { trade = { 27927, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.HEPATIZON_ORE      }, reward = 27850 },
    [313] = { trade = { 28067, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.BERYLLIUM_ORE      }, reward = 27986 },
    [314] = { trade = { 28207, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.DAMASCUS_INGOT,                xi.item.EXALTED_LOG        }, reward = 28133 },
    [315] = { trade = { 28347, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.DAMASCUS_INGOT,                xi.item.SIFS_LOCK          }, reward = 28266 },
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
--
-- Output layout (actual Monisette i109 relic items, job_index j):
--   WAR=0 MNK=1 WHM=2 BLM=3 RDM=4 THF=5 PLD=6 DRK=7 BST=8 BRD=9
--   RNG=10 SAM=11 NIN=12 DRG=13 SMN=14 BLU=15 COR=16 PUP=17 DNC=18 SCH=19 GEO=20 RUN=21
--   Head 26624+j*2  Body 26800+j*2  Hands 26976+j*2  Legs 27152+j*2  Feet 27328+j*2
-----------------------------------
local relicReforgeI109 =
{
    -- WAR (Agoge) - Wootz Ore
    [401] = { trade = { xi.item.WARRIORS_MASK_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.PHOENIX_FEATHER            }, reward = 26624 },
    [402] = { trade = { xi.item.WARRIORS_LORICA_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 26800 },
    [403] = { trade = { xi.item.WARRIORS_MUFFLERS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 26976 },
    [404] = { trade = { xi.item.WARRIORS_CUISSES_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 27152 },
    [405] = { trade = { xi.item.WARRIORS_CALLIGAE_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.PIECE_OF_OXBLOOD            }, reward = 27328 },
    -- MNK (Hesychast's) - Griffon Hide
    [406] = { trade = { xi.item.MELEE_CROWN_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.GRIFFON_HIDE, xi.item.PHOENIX_FEATHER            }, reward = 26626 },
    [407] = { trade = { xi.item.MELEE_CYCLAS_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.GRIFFON_HIDE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 26802 },
    [408] = { trade = { xi.item.MELEE_GLOVES_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.GRIFFON_HIDE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 26978 },
    [409] = { trade = { xi.item.MELEE_HOSE_P2,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.GRIFFON_HIDE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 27154 },
    [410] = { trade = { xi.item.MELEE_GAITERS_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.GRIFFON_HIDE, xi.item.PIECE_OF_OXBLOOD            }, reward = 27330 },
    -- WHM (Piety) - Sparkling Stone
    [411] = { trade = { xi.item.CLERICS_CAP_P2,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SPARKLING_STONE, xi.item.PHOENIX_FEATHER            }, reward = 26628 },
    [412] = { trade = { xi.item.CLERICS_BLIAUT_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SPARKLING_STONE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 26804 },
    [413] = { trade = { xi.item.CLERICS_MITTS_P2,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SPARKLING_STONE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 26980 },
    [414] = { trade = { xi.item.CLERICS_PANTALOONS_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SPARKLING_STONE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 27156 },
    [415] = { trade = { xi.item.CLERICS_DUCKBILLS_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SPARKLING_STONE, xi.item.PIECE_OF_OXBLOOD            }, reward = 27332 },
    -- BLM (Archmage's) - Sparkling Stone
    [416] = { trade = { xi.item.SORCERERS_PETASOS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SPARKLING_STONE, xi.item.PHOENIX_FEATHER            }, reward = 26630 },
    [417] = { trade = { xi.item.SORCERERS_COAT_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SPARKLING_STONE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 26806 },
    [418] = { trade = { xi.item.SORCERERS_GLOVES_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SPARKLING_STONE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 26982 },
    [419] = { trade = { xi.item.SORCERERS_TONBAN_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SPARKLING_STONE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 27158 },
    [420] = { trade = { xi.item.SORCERERS_SABOTS_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SPARKLING_STONE, xi.item.PIECE_OF_OXBLOOD            }, reward = 27334 },
    -- RDM (Vitiation) - Griffon Hide
    [421] = { trade = { xi.item.DUELISTS_CHAPEAU_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.GRIFFON_HIDE, xi.item.PHOENIX_FEATHER            }, reward = 26632 },
    [422] = { trade = { xi.item.DUELISTS_TABARD_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.GRIFFON_HIDE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 26808 },
    [423] = { trade = { xi.item.DUELISTS_GLOVES_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.GRIFFON_HIDE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 26984 },
    [424] = { trade = { xi.item.DUELISTS_TIGHTS_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.GRIFFON_HIDE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 27160 },
    [425] = { trade = { xi.item.DUELISTS_BOOTS_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.GRIFFON_HIDE, xi.item.PIECE_OF_OXBLOOD            }, reward = 27336 },
    -- THF (Plunderer's) - Griffon Hide
    [426] = { trade = { xi.item.ASSASSINS_BONNET_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.GRIFFON_HIDE, xi.item.PHOENIX_FEATHER            }, reward = 26634 },
    [427] = { trade = { xi.item.ASSASSINS_VEST_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.GRIFFON_HIDE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 26810 },
    [428] = { trade = { xi.item.ASSASSINS_ARMLETS_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.GRIFFON_HIDE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 26986 },
    [429] = { trade = { xi.item.ASSASSINS_CULOTTES_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.GRIFFON_HIDE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 27162 },
    [430] = { trade = { xi.item.ASSASSINS_POULAINES_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.GRIFFON_HIDE, xi.item.PIECE_OF_OXBLOOD            }, reward = 27338 },
    -- PLD (Caballarius) - Wootz Ore
    [431] = { trade = { xi.item.VALOR_CORONET_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.PHOENIX_FEATHER            }, reward = 26636 },
    [432] = { trade = { xi.item.VALOR_SURCOAT_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 26812 },
    [433] = { trade = { xi.item.VALOR_GAUNTLETS_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 26988 },
    [434] = { trade = { xi.item.VALOR_BREECHES_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 27164 },
    [435] = { trade = { xi.item.VALOR_LEGGINGS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.PIECE_OF_OXBLOOD            }, reward = 27340 },
    -- DRK (Fallen's) - Wootz Ore
    [436] = { trade = { xi.item.ABYSS_BURGEONET_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.PHOENIX_FEATHER            }, reward = 26638 },
    [437] = { trade = { xi.item.ABYSS_CUIRASS_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 26814 },
    [438] = { trade = { xi.item.ABYSS_GAUNTLETS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 26990 },
    [439] = { trade = { xi.item.ABYSS_FLANCHARD_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 27166 },
    [440] = { trade = { xi.item.ABYSS_SOLLERETS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.CHUNK_OF_WOOTZ_ORE, xi.item.PIECE_OF_OXBLOOD            }, reward = 27342 },
    -- BST (Ankusa) - Mammoth Tusk
    [441] = { trade = { xi.item.MONSTER_HELM_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.MAMMOTH_TUSK, xi.item.PHOENIX_FEATHER            }, reward = 26640 },
    [442] = { trade = { xi.item.MONSTER_JACKCOAT_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.MAMMOTH_TUSK, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 26816 },
    [443] = { trade = { xi.item.MONSTER_GLOVES_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.MAMMOTH_TUSK, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 26992 },
    [444] = { trade = { xi.item.MONSTER_TROUSERS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.MAMMOTH_TUSK, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 27168 },
    [445] = { trade = { xi.item.MONSTER_GAITERS_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.MAMMOTH_TUSK, xi.item.PIECE_OF_OXBLOOD            }, reward = 27344 },
    -- BRD (Bihu) - Griffon Hide
    [446] = { trade = { xi.item.BARDS_ROUNDLET_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.GRIFFON_HIDE, xi.item.PHOENIX_FEATHER            }, reward = 26642 },
    [447] = { trade = { xi.item.BARDS_JUSTAUCORPS_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.GRIFFON_HIDE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 26818 },
    [448] = { trade = { xi.item.BARDS_CUFFS_P2,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.GRIFFON_HIDE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 26994 },
    [449] = { trade = { xi.item.BARDS_CANNIONS_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.GRIFFON_HIDE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 27170 },
    [450] = { trade = { xi.item.BARDS_SLIPPERS_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.GRIFFON_HIDE, xi.item.PIECE_OF_OXBLOOD            }, reward = 27346 },
    -- RNG (Arcadian) - Griffon Hide
    [451] = { trade = { xi.item.SCOUTS_BERET_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.GRIFFON_HIDE, xi.item.PHOENIX_FEATHER            }, reward = 26644 },
    [452] = { trade = { xi.item.SCOUTS_JERKIN_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.GRIFFON_HIDE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 26820 },
    [453] = { trade = { xi.item.SCOUTS_BRACERS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.GRIFFON_HIDE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 26996 },
    [454] = { trade = { xi.item.SCOUTS_BRACCAE_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.GRIFFON_HIDE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 27172 },
    [455] = { trade = { xi.item.SCOUTS_SOCKS_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.GRIFFON_HIDE, xi.item.PIECE_OF_OXBLOOD            }, reward = 27348 },
    -- SAM (Sakonji) - Relic Iron
    [456] = { trade = { xi.item.SAOTOME_KABUTO_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.PILE_OF_RELIC_IRON, xi.item.PHOENIX_FEATHER            }, reward = 26646 },
    [457] = { trade = { xi.item.SAOTOME_DOMARU_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.PILE_OF_RELIC_IRON, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 26822 },
    [458] = { trade = { xi.item.SAOTOME_KOTE_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.PILE_OF_RELIC_IRON, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 26998 },
    [459] = { trade = { xi.item.SAOTOME_HAIDATE_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.PILE_OF_RELIC_IRON, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 27174 },
    [460] = { trade = { xi.item.SAOTOME_SUNE_ATE_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.PILE_OF_RELIC_IRON, xi.item.PIECE_OF_OXBLOOD            }, reward = 27350 },
    -- NIN (Mochizuki) - Relic Iron
    [461] = { trade = { xi.item.KOGA_HATSUBURI_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.PILE_OF_RELIC_IRON, xi.item.PHOENIX_FEATHER            }, reward = 26648 },
    [462] = { trade = { xi.item.KOGA_CHAINMAIL_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.PILE_OF_RELIC_IRON, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 26824 },
    [463] = { trade = { xi.item.KOGA_TEKKO_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.PILE_OF_RELIC_IRON, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 27000 },
    [464] = { trade = { xi.item.KOGA_HAKAMA_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.PILE_OF_RELIC_IRON, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 27176 },
    [465] = { trade = { xi.item.KOGA_KYAHAN_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.PILE_OF_RELIC_IRON, xi.item.PIECE_OF_OXBLOOD            }, reward = 27352 },
    -- DRG (Pteroslaver) - Griffon Hide
    [466] = { trade = { xi.item.WYRM_ARMET_P2,             { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.GRIFFON_HIDE, xi.item.PHOENIX_FEATHER            }, reward = 26650 },
    [467] = { trade = { xi.item.WYRM_MAIL_P2,              { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.GRIFFON_HIDE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 26826 },
    [468] = { trade = { xi.item.WYRM_FINGER_GAUNTLETS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.GRIFFON_HIDE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 27002 },
    [469] = { trade = { xi.item.WYRM_BRAIS_P2,             { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.GRIFFON_HIDE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 27178 },
    [470] = { trade = { xi.item.WYRM_GREAVES_P2,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.GRIFFON_HIDE, xi.item.PIECE_OF_OXBLOOD            }, reward = 27354 },
    -- SMN (Glyphic) - Lancewood Log
    [471] = { trade = { xi.item.SUMMONERS_HORN_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.LANCEWOOD_LOG, xi.item.PHOENIX_FEATHER            }, reward = 26652 },
    [472] = { trade = { xi.item.SUMMONERS_DOUBLET_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.LANCEWOOD_LOG, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 26828 },
    [473] = { trade = { xi.item.SUMMONERS_BRACERS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.LANCEWOOD_LOG, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 27004 },
    [474] = { trade = { xi.item.SUMMONERS_SPATS_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.LANCEWOOD_LOG, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 27180 },
    [475] = { trade = { xi.item.SUMMONERS_PIGACHES_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.LANCEWOOD_LOG, xi.item.PIECE_OF_OXBLOOD            }, reward = 27356 },
    -- BLU (Luhlaza) - Griffon Hide
    [476] = { trade = { xi.item.MIRAGE_KEFFIYEH_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.GRIFFON_HIDE, xi.item.PHOENIX_FEATHER            }, reward = 26654 },
    [477] = { trade = { xi.item.MIRAGE_JUBBAH_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.GRIFFON_HIDE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 26830 },
    [478] = { trade = { xi.item.MIRAGE_BAZUBANDS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.GRIFFON_HIDE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 27006 },
    [479] = { trade = { xi.item.MIRAGE_SHALWAR_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.GRIFFON_HIDE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 27182 },
    [480] = { trade = { xi.item.MIRAGE_CHARUQS_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.GRIFFON_HIDE, xi.item.PIECE_OF_OXBLOOD            }, reward = 27358 },
    -- COR (Lanun) - Sparkling Stone
    [481] = { trade = { xi.item.COMMODORES_TRICORNE_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.SPARKLING_STONE, xi.item.PHOENIX_FEATHER            }, reward = 26656 },
    [482] = { trade = { xi.item.COMMODORE_FRAC_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.SPARKLING_STONE, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 26832 },
    [483] = { trade = { xi.item.COMMODORE_GANTS_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.SPARKLING_STONE, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 27008 },
    [484] = { trade = { xi.item.COMMODORE_TREWS_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.SPARKLING_STONE, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 27184 },
    [485] = { trade = { xi.item.COMMODORE_BOTTES_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.SPARKLING_STONE, xi.item.PIECE_OF_OXBLOOD            }, reward = 27360 },
    -- PUP (Pitre) - Lancewood Log
    [486] = { trade = { xi.item.PANTIN_TAJ_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.LANCEWOOD_LOG, xi.item.PHOENIX_FEATHER            }, reward = 26658 },
    [487] = { trade = { xi.item.PANTIN_TOBE_P2,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.LANCEWOOD_LOG, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 26834 },
    [488] = { trade = { xi.item.PANTIN_DASTANAS_P2,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.LANCEWOOD_LOG, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 27010 },
    [489] = { trade = { xi.item.PANTIN_CHURIDARS_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.LANCEWOOD_LOG, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 27186 },
    [490] = { trade = { xi.item.PANTIN_BABOUCHES_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.LANCEWOOD_LOG, xi.item.PIECE_OF_OXBLOOD            }, reward = 27362 },
    -- DNC (Horos) - Mammoth Tusk
    [491] = { trade = { xi.item.ETOILE_TIARA_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.MAMMOTH_TUSK, xi.item.PHOENIX_FEATHER            }, reward = 26660 },
    [492] = { trade = { xi.item.ETOILE_CASAQUE_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.MAMMOTH_TUSK, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 26836 },
    [493] = { trade = { xi.item.ETOILE_BANGLES_P2,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.MAMMOTH_TUSK, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 27012 },
    [494] = { trade = { xi.item.ETOILE_TIGHTS_P2,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.MAMMOTH_TUSK, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 27188 },
    [495] = { trade = { xi.item.ETOILE_TOE_SHOES_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.MAMMOTH_TUSK, xi.item.PIECE_OF_OXBLOOD            }, reward = 27364 },
    -- SCH (Pedagogy) - Lancewood Log
    [496] = { trade = { xi.item.ARGUTE_MORTARBOARD_P2, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 }, xi.item.LANCEWOOD_LOG, xi.item.PHOENIX_FEATHER            }, reward = 26662 },
    [497] = { trade = { xi.item.ARGUTE_GOWN_P2,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 }, xi.item.LANCEWOOD_LOG, xi.item.SPOOL_OF_MALBORO_FIBER      }, reward = 26838 },
    [498] = { trade = { xi.item.ARGUTE_BRACERS_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 }, xi.item.LANCEWOOD_LOG, xi.item.VIAL_OF_BLACK_BEETLE_BLOOD  }, reward = 27014 },
    [499] = { trade = { xi.item.ARGUTE_PANTS_P2,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 }, xi.item.LANCEWOOD_LOG, xi.item.SQUARE_OF_DAMASCENE_CLOTH   }, reward = 27190 },
    [500] = { trade = { xi.item.ARGUTE_LOAFERS_P2,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 }, xi.item.LANCEWOOD_LOG, xi.item.PIECE_OF_OXBLOOD            }, reward = 27366 },
    -- WAR (Agoge) - Path B (+1 input)
    [501] = { trade = { xi.item.WARRIORS_MASK_P1,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26624 },
    [502] = { trade = { xi.item.WARRIORS_LORICA_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26800 },
    [503] = { trade = { xi.item.WARRIORS_MUFFLERS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26976 },
    [504] = { trade = { xi.item.WARRIORS_CUISSES_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27152 },
    [505] = { trade = { xi.item.WARRIORS_CALLIGAE_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27328 },
    -- MNK (Hesychast's) - Path B
    [506] = { trade = { xi.item.MELEE_CROWN_P1,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26626 },
    [507] = { trade = { xi.item.MELEE_CYCLAS_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26802 },
    [508] = { trade = { xi.item.MELEE_GLOVES_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26978 },
    [509] = { trade = { xi.item.MELEE_HOSE_P1,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27154 },
    [510] = { trade = { xi.item.MELEE_GAITERS_P1,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27330 },
    -- WHM (Piety) - Path B
    [511] = { trade = { xi.item.CLERICS_CAP_P1,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26628 },
    [512] = { trade = { xi.item.CLERICS_BLIAUT_P1,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26804 },
    [513] = { trade = { xi.item.CLERICS_MITTS_P1,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26980 },
    [514] = { trade = { xi.item.CLERICS_PANTALOONS_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27156 },
    [515] = { trade = { xi.item.CLERICS_DUCKBILLS_P1,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27332 },
    -- BLM (Archmage's) - Path B
    [516] = { trade = { xi.item.SORCERERS_PETASOS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26630 },
    [517] = { trade = { xi.item.SORCERERS_COAT_P1,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26806 },
    [518] = { trade = { xi.item.SORCERERS_GLOVES_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26982 },
    [519] = { trade = { xi.item.SORCERERS_TONBAN_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27158 },
    [520] = { trade = { xi.item.SORCERERS_SABOTS_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27334 },
    -- RDM (Vitiation) - Path B
    [521] = { trade = { xi.item.DUELISTS_CHAPEAU_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26632 },
    [522] = { trade = { xi.item.DUELISTS_TABARD_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26808 },
    [523] = { trade = { xi.item.DUELISTS_GLOVES_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26984 },
    [524] = { trade = { xi.item.DUELISTS_TIGHTS_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27160 },
    [525] = { trade = { xi.item.DUELISTS_BOOTS_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27336 },
    -- THF (Plunderer's) - Path B
    [526] = { trade = { xi.item.ASSASSINS_BONNET_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26634 },
    [527] = { trade = { xi.item.ASSASSINS_VEST_P1,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26810 },
    [528] = { trade = { xi.item.ASSASSINS_ARMLETS_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26986 },
    [529] = { trade = { xi.item.ASSASSINS_CULOTTES_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27162 },
    [530] = { trade = { xi.item.ASSASSINS_POULAINES_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27338 },
    -- PLD (Caballarius) - Path B
    [531] = { trade = { xi.item.VALOR_CORONET_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26636 },
    [532] = { trade = { xi.item.VALOR_SURCOAT_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26812 },
    [533] = { trade = { xi.item.VALOR_GAUNTLETS_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26988 },
    [534] = { trade = { xi.item.VALOR_BREECHES_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27164 },
    [535] = { trade = { xi.item.VALOR_LEGGINGS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27340 },
    -- DRK (Fallen's) - Path B
    [536] = { trade = { xi.item.ABYSS_BURGEONET_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26638 },
    [537] = { trade = { xi.item.ABYSS_CUIRASS_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26814 },
    [538] = { trade = { xi.item.ABYSS_GAUNTLETS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26990 },
    [539] = { trade = { xi.item.ABYSS_FLANCHARD_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27166 },
    [540] = { trade = { xi.item.ABYSS_SOLLERETS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27342 },
    -- BST (Ankusa) - Path B
    [541] = { trade = { xi.item.MONSTER_HELM_P1,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26640 },
    [542] = { trade = { xi.item.MONSTER_JACKCOAT_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26816 },
    [543] = { trade = { xi.item.MONSTER_GLOVES_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26992 },
    [544] = { trade = { xi.item.MONSTER_TROUSERS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27168 },
    [545] = { trade = { xi.item.MONSTER_GAITERS_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27344 },
    -- BRD (Bihu) - Path B
    [546] = { trade = { xi.item.BARDS_ROUNDLET_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26642 },
    [547] = { trade = { xi.item.BARDS_JUSTAUCORPS_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26818 },
    [548] = { trade = { xi.item.BARDS_CUFFS_P1,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26994 },
    [549] = { trade = { xi.item.BARDS_CANNIONS_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27170 },
    [550] = { trade = { xi.item.BARDS_SLIPPERS_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27346 },
    -- RNG (Arcadian) - Path B
    [551] = { trade = { xi.item.SCOUTS_BERET_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26644 },
    [552] = { trade = { xi.item.SCOUTS_JERKIN_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26820 },
    [553] = { trade = { xi.item.SCOUTS_BRACERS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26996 },
    [554] = { trade = { xi.item.SCOUTS_BRACCAE_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27172 },
    [555] = { trade = { xi.item.SCOUTS_SOCKS_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27348 },
    -- SAM (Sakonji) - Path B
    [556] = { trade = { xi.item.SAOTOME_KABUTO_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26646 },
    [557] = { trade = { xi.item.SAOTOME_DOMARU_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26822 },
    [558] = { trade = { xi.item.SAOTOME_KOTE_P1,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26998 },
    [559] = { trade = { xi.item.SAOTOME_HAIDATE_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27174 },
    [560] = { trade = { xi.item.SAOTOME_SUNE_ATE_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27350 },
    -- NIN (Mochizuki) - Path B
    [561] = { trade = { xi.item.KOGA_HATSUBURI_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26648 },
    [562] = { trade = { xi.item.KOGA_CHAINMAIL_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26824 },
    [563] = { trade = { xi.item.KOGA_TEKKO_P1,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27000 },
    [564] = { trade = { xi.item.KOGA_HAKAMA_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27176 },
    [565] = { trade = { xi.item.KOGA_KYAHAN_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27352 },
    -- DRG (Pteroslaver) - Path B
    [566] = { trade = { xi.item.WYRM_ARMET_P1,             { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26650 },
    [567] = { trade = { xi.item.WYRM_MAIL_P1,              { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26826 },
    [568] = { trade = { xi.item.WYRM_FINGER_GAUNTLETS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27002 },
    [569] = { trade = { xi.item.WYRM_BRAIS_P1,             { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27178 },
    [570] = { trade = { xi.item.WYRM_GREAVES_P1,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27354 },
    -- SMN (Glyphic) - Path B
    [571] = { trade = { xi.item.SUMMONERS_HORN_P1,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26652 },
    [572] = { trade = { xi.item.SUMMONERS_DOUBLET_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26828 },
    [573] = { trade = { xi.item.SUMMONERS_BRACERS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27004 },
    [574] = { trade = { xi.item.SUMMONERS_SPATS_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27180 },
    [575] = { trade = { xi.item.SUMMONERS_PIGACHES_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27356 },
    -- BLU (Luhlaza) - Path B
    [576] = { trade = { xi.item.MIRAGE_KEFFIYEH_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26654 },
    [577] = { trade = { xi.item.MIRAGE_JUBBAH_P1,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26830 },
    [578] = { trade = { xi.item.MIRAGE_BAZUBANDS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27006 },
    [579] = { trade = { xi.item.MIRAGE_SHALWAR_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27182 },
    [580] = { trade = { xi.item.MIRAGE_CHARUQS_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27358 },
    -- COR (Lanun) - Path B
    [581] = { trade = { xi.item.COMMODORE_TRICORNE_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26656 },
    [582] = { trade = { xi.item.COMMODORE_FRAC_P1,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26832 },
    [583] = { trade = { xi.item.COMMODORE_GANTS_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27008 },
    [584] = { trade = { xi.item.COMMODORE_TREWS_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27184 },
    [585] = { trade = { xi.item.COMMODORE_BOTTES_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27360 },
    -- PUP (Pitre) - Path B
    [586] = { trade = { xi.item.PANTIN_TAJ_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26658 },
    [587] = { trade = { xi.item.PANTIN_TOBE_P1,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26834 },
    [588] = { trade = { xi.item.PANTIN_DASTANAS_P1,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27010 },
    [589] = { trade = { xi.item.PANTIN_CHURIDARS_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27186 },
    [590] = { trade = { xi.item.PANTIN_BABOUCHES_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27362 },
    -- DNC (Horos) - Path B
    [591] = { trade = { xi.item.ETOILE_TIARA_P1,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26660 },
    [592] = { trade = { xi.item.ETOILE_CASAQUE_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26836 },
    [593] = { trade = { xi.item.ETOILE_BANGLES_P1,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27012 },
    [594] = { trade = { xi.item.ETOILE_TIGHTS_P1,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27188 },
    [595] = { trade = { xi.item.ETOILE_TOE_SHOES_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27364 },
    -- SCH (Pedagogy) - Path B
    [596] = { trade = { xi.item.ARGUTE_MORTARBOARD_P1, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26662 },
    [597] = { trade = { xi.item.ARGUTE_GOWN_P1,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26838 },
    [598] = { trade = { xi.item.ARGUTE_BRACERS_P1,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27014 },
    [599] = { trade = { xi.item.ARGUTE_PANTS_P1,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27190 },
    [600] = { trade = { xi.item.ARGUTE_LOAFERS_P1,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27366 },
    -- WAR (Agoge) - Path C (base input)
    [701] = { trade = { xi.item.WARRIORS_MASK,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26624 },
    [702] = { trade = { xi.item.WARRIORS_LORICA,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26800 },
    [703] = { trade = { xi.item.WARRIORS_MUFFLERS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26976 },
    [704] = { trade = { xi.item.WARRIORS_CUISSES,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27152 },
    [705] = { trade = { xi.item.WARRIORS_CALLIGAE,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27328 },
    -- MNK (Hesychast's) - Path C
    [706] = { trade = { xi.item.MELEE_CROWN,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26626 },
    [707] = { trade = { xi.item.MELEE_CYCLAS,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26802 },
    [708] = { trade = { xi.item.MELEE_GLOVES,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26978 },
    [709] = { trade = { xi.item.MELEE_HOSE,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27154 },
    [710] = { trade = { xi.item.MELEE_GAITERS,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27330 },
    -- WHM (Piety) - Path C
    [711] = { trade = { xi.item.CLERICS_CAP,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26628 },
    [712] = { trade = { xi.item.CLERICS_BLIAUT,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26804 },
    [713] = { trade = { xi.item.CLERICS_MITTS,         { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26980 },
    [714] = { trade = { xi.item.CLERICS_PANTALOONS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27156 },
    [715] = { trade = { xi.item.CLERICS_DUCKBILLS,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27332 },
    -- BLM (Archmage's) - Path C
    [716] = { trade = { xi.item.SORCERERS_PETASOS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26630 },
    [717] = { trade = { xi.item.SORCERERS_COAT,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26806 },
    [718] = { trade = { xi.item.SORCERERS_GLOVES,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26982 },
    [719] = { trade = { xi.item.SORCERERS_TONBAN,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27158 },
    [720] = { trade = { xi.item.SORCERERS_SABOTS,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27334 },
    -- RDM (Vitiation) - Path C
    [721] = { trade = { xi.item.DUELISTS_CHAPEAU,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26632 },
    [722] = { trade = { xi.item.DUELISTS_TABARD,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26808 },
    [723] = { trade = { xi.item.DUELISTS_GLOVES,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26984 },
    [724] = { trade = { xi.item.DUELISTS_TIGHTS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27160 },
    [725] = { trade = { xi.item.DUELISTS_BOOTS,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27336 },
    -- THF (Plunderer's) - Path C
    [726] = { trade = { xi.item.ASSASSINS_BONNET,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26634 },
    [727] = { trade = { xi.item.ASSASSINS_VEST,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26810 },
    [728] = { trade = { xi.item.ASSASSINS_ARMLETS,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26986 },
    [729] = { trade = { xi.item.ASSASSINS_CULOTTES,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27162 },
    [730] = { trade = { xi.item.ASSASSINS_POULAINES, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27338 },
    -- PLD (Caballarius) - Path C
    [731] = { trade = { xi.item.VALOR_CORONET,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26636 },
    [732] = { trade = { xi.item.VALOR_SURCOAT,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26812 },
    [733] = { trade = { xi.item.VALOR_GAUNTLETS, { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26988 },
    [734] = { trade = { xi.item.VALOR_BREECHES,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27164 },
    [735] = { trade = { xi.item.VALOR_LEGGINGS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27340 },
    -- DRK (Fallen's) - Path C
    [736] = { trade = { xi.item.ABYSS_BURGEONET,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26638 },
    [737] = { trade = { xi.item.ABYSS_CUIRASS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26814 },
    [738] = { trade = { xi.item.ABYSS_GAUNTLETS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26990 },
    [739] = { trade = { xi.item.ABYSS_FLANCHARD,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27166 },
    [740] = { trade = { xi.item.ABYSS_SOLLERETS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27342 },
    -- BST (Ankusa) - Path C
    [741] = { trade = { xi.item.MONSTER_HELM,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26640 },
    [742] = { trade = { xi.item.MONSTER_JACKCOAT,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26816 },
    [743] = { trade = { xi.item.MONSTER_GLOVES,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26992 },
    [744] = { trade = { xi.item.MONSTER_TROUSERS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27168 },
    [745] = { trade = { xi.item.MONSTER_GAITERS,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27344 },
    -- BRD (Bihu) - Path C
    [746] = { trade = { xi.item.BARDS_ROUNDLET,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26642 },
    [747] = { trade = { xi.item.BARDS_JUSTAUCORPS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26818 },
    [748] = { trade = { xi.item.BARDS_CUFFS,          { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26994 },
    [749] = { trade = { xi.item.BARDS_CANNIONS,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27170 },
    [750] = { trade = { xi.item.BARDS_SLIPPERS,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27346 },
    -- RNG (Arcadian) - Path C
    [751] = { trade = { xi.item.SCOUTS_BERET,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26644 },
    [752] = { trade = { xi.item.SCOUTS_JERKIN,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26820 },
    [753] = { trade = { xi.item.SCOUTS_BRACERS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26996 },
    [754] = { trade = { xi.item.SCOUTS_BRACCAE,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27172 },
    [755] = { trade = { xi.item.SCOUTS_SOCKS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27348 },
    -- SAM (Sakonji) - Path C
    [756] = { trade = { xi.item.SAOTOME_KABUTO,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26646 },
    [757] = { trade = { xi.item.SAOTOME_DOMARU,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26822 },
    [758] = { trade = { xi.item.SAOTOME_KOTE,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 26998 },
    [759] = { trade = { xi.item.SAOTOME_HAIDATE,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27174 },
    [760] = { trade = { xi.item.SAOTOME_SUNE_ATE, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27350 },
    -- NIN (Mochizuki) - Path C
    [761] = { trade = { xi.item.KOGA_HATSUBURI, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26648 },
    [762] = { trade = { xi.item.KOGA_CHAINMAIL, { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26824 },
    [763] = { trade = { xi.item.KOGA_TEKKO,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27000 },
    [764] = { trade = { xi.item.KOGA_HAKAMA,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27176 },
    [765] = { trade = { xi.item.KOGA_KYAHAN,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27352 },
    -- DRG (Pteroslaver) - Path C
    [766] = { trade = { xi.item.WYRM_ARMET,             { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26650 },
    [767] = { trade = { xi.item.WYRM_MAIL,              { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26826 },
    [768] = { trade = { xi.item.WYRM_FINGER_GAUNTLETS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27002 },
    [769] = { trade = { xi.item.WYRM_BRAIS,             { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27178 },
    [770] = { trade = { xi.item.WYRM_GREAVES,           { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27354 },
    -- SMN (Glyphic) - Path C
    [771] = { trade = { xi.item.SUMMONERS_HORN,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26652 },
    [772] = { trade = { xi.item.SUMMONERS_DOUBLET,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26828 },
    [773] = { trade = { xi.item.SUMMONERS_BRACERS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27004 },
    [774] = { trade = { xi.item.SUMMONERS_SPATS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27180 },
    [775] = { trade = { xi.item.SUMMONERS_PIGACHES, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27356 },
    -- BLU (Luhlaza) - Path C
    [776] = { trade = { xi.item.MIRAGE_KEFFIYEH,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26654 },
    [777] = { trade = { xi.item.MIRAGE_JUBBAH,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26830 },
    [778] = { trade = { xi.item.MIRAGE_BAZUBANDS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27006 },
    [779] = { trade = { xi.item.MIRAGE_SHALWAR,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27182 },
    [780] = { trade = { xi.item.MIRAGE_CHARUQS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27358 },
    -- COR (Lanun) - Path C
    [781] = { trade = { xi.item.COMMODORE_TRICORNE, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26656 },
    [782] = { trade = { xi.item.COMMODORE_FRAC,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26832 },
    [783] = { trade = { xi.item.COMMODORE_GANTS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27008 },
    [784] = { trade = { xi.item.COMMODORE_TREWS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27184 },
    [785] = { trade = { xi.item.COMMODORE_BOTTES,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27360 },
    -- PUP (Pitre) - Path C
    [786] = { trade = { xi.item.PANTIN_TAJ,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26658 },
    [787] = { trade = { xi.item.PANTIN_TOBE,      { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26834 },
    [788] = { trade = { xi.item.PANTIN_DASTANAS,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27010 },
    [789] = { trade = { xi.item.PANTIN_CHURIDARS, { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27186 },
    [790] = { trade = { xi.item.PANTIN_BABOUCHES, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27362 },
    -- DNC (Horos) - Path C
    [791] = { trade = { xi.item.ETOILE_TIARA,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26660 },
    [792] = { trade = { xi.item.ETOILE_CASAQUE,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26836 },
    [793] = { trade = { xi.item.ETOILE_BANGLES,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27012 },
    [794] = { trade = { xi.item.ETOILE_TIGHTS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27188 },
    [795] = { trade = { xi.item.ETOILE_TOE_SHOES, { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27364 },
    -- SCH (Pedagogy) - Path C
    [796] = { trade = { xi.item.ARGUTE_MORTARBOARD, { xi.item.COPY_OF_REMS_TALE_CHAPTER_1, 10 } }, reward = 26662 },
    [797] = { trade = { xi.item.ARGUTE_GOWN,        { xi.item.COPY_OF_REMS_TALE_CHAPTER_2, 10 } }, reward = 26838 },
    [798] = { trade = { xi.item.ARGUTE_BRACERS,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_3, 10 } }, reward = 27014 },
    [799] = { trade = { xi.item.ARGUTE_PANTS,       { xi.item.COPY_OF_REMS_TALE_CHAPTER_4, 10 } }, reward = 27190 },
    [800] = { trade = { xi.item.ARGUTE_LOAFERS,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_5, 10 } }, reward = 27366 },
}

-----------------------------------
-- Relic Armor Reforge i119
-- Trade: Relic i109 (P2) piece + 8x Rem's Tale (Ch.6-10 by slot) + job ingredient + slot ingredient -> i119 (P3)
--
-- Slot Rem's Tale: Head=Ch.6 / Body=Ch.7 / Hands=Ch.8 / Legs=Ch.9 / Feet=Ch.10
-- Slot ingredients: Gabbrath Horn(head) / Yggdreant Bole(body) / Bztavian Stinger(hands)
--                   Waktza Rostrum(legs) / Rockfin Tooth(feet)
--
-- i109 input:  Head 26624+j*2  Body 26800+j*2  Hands 26976+j*2  Legs 27152+j*2  Feet 27328+j*2
-- i119 output: Head 26625+j*2  Body 26801+j*2  Hands 26977+j*2  Legs 27153+j*2  Feet 27329+j*2
--   j: WAR=0 MNK=1 WHM=2 BLM=3 RDM=4 THF=5 PLD=6 DRK=7 BST=8 BRD=9
--      RNG=10 SAM=11 NIN=12 DRG=13 SMN=14 BLU=15 COR=16 PUP=17 DNC=18 SCH=19 GEO=20 RUN=21
-----------------------------------
local relicReforgeI119 =
{
    -- WAR (Agoge +1) - Voidwrought Plate
    [601] = { trade = { 26624, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.GABBRATH_HORN      }, reward = 26625 },
    [602] = { trade = { 26800, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.YGGDREANT_BOLE     }, reward = 26801 },
    [603] = { trade = { 26976, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.BZTAVIAN_STINGER   }, reward = 26977 },
    [604] = { trade = { 27152, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.WAKTZA_ROSTRUM     }, reward = 27153 },
    [605] = { trade = { 27328, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.ROCKFIN_TOOTH      }, reward = 27329 },
    -- MNK (Hesychast's +1) - Kaggen's Cuticle
    [606] = { trade = { 26626, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.GABBRATH_HORN      }, reward = 26627 },
    [607] = { trade = { 26802, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.YGGDREANT_BOLE     }, reward = 26803 },
    [608] = { trade = { 26978, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.BZTAVIAN_STINGER   }, reward = 26979 },
    [609] = { trade = { 27154, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.WAKTZA_ROSTRUM     }, reward = 27155 },
    [610] = { trade = { 27330, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.KAGGENS_CUTICLE,      xi.item.ROCKFIN_TOOTH      }, reward = 27331 },
    -- WHM (Piety +1) - Akvan's Pennon
    [611] = { trade = { 26628, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.AKVANS_PENNON,        xi.item.GABBRATH_HORN      }, reward = 26629 },
    [612] = { trade = { 26804, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.AKVANS_PENNON,        xi.item.YGGDREANT_BOLE     }, reward = 26805 },
    [613] = { trade = { 26980, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.AKVANS_PENNON,        xi.item.BZTAVIAN_STINGER   }, reward = 26981 },
    [614] = { trade = { 27156, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.AKVANS_PENNON,        xi.item.WAKTZA_ROSTRUM     }, reward = 27157 },
    [615] = { trade = { 27332, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.AKVANS_PENNON,        xi.item.ROCKFIN_TOOTH      }, reward = 27333 },
    -- BLM (Archmage's +1) - Akvan's Pennon
    [616] = { trade = { 26630, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.AKVANS_PENNON,        xi.item.GABBRATH_HORN      }, reward = 26631 },
    [617] = { trade = { 26806, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.AKVANS_PENNON,        xi.item.YGGDREANT_BOLE     }, reward = 26807 },
    [618] = { trade = { 26982, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.AKVANS_PENNON,        xi.item.BZTAVIAN_STINGER   }, reward = 26983 },
    [619] = { trade = { 27158, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.AKVANS_PENNON,        xi.item.WAKTZA_ROSTRUM     }, reward = 27159 },
    [620] = { trade = { 27334, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.AKVANS_PENNON,        xi.item.ROCKFIN_TOOTH      }, reward = 27335 },
    -- RDM (Vitiation +1) - Pil's Tuille
    [621] = { trade = { 26632, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.PILS_TUILLE,          xi.item.GABBRATH_HORN      }, reward = 26633 },
    [622] = { trade = { 26808, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.PILS_TUILLE,          xi.item.YGGDREANT_BOLE     }, reward = 26809 },
    [623] = { trade = { 26984, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.PILS_TUILLE,          xi.item.BZTAVIAN_STINGER   }, reward = 26985 },
    [624] = { trade = { 27160, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.PILS_TUILLE,          xi.item.WAKTZA_ROSTRUM     }, reward = 27161 },
    [625] = { trade = { 27336, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.PILS_TUILLE,          xi.item.ROCKFIN_TOOTH      }, reward = 27337 },
    -- THF (Plunderer's +1) - Kaggen's Cuticle
    [626] = { trade = { 26634, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.GABBRATH_HORN      }, reward = 26635 },
    [627] = { trade = { 26810, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.YGGDREANT_BOLE     }, reward = 26811 },
    [628] = { trade = { 26986, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.BZTAVIAN_STINGER   }, reward = 26987 },
    [629] = { trade = { 27162, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.WAKTZA_ROSTRUM     }, reward = 27163 },
    [630] = { trade = { 27338, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.KAGGENS_CUTICLE,      xi.item.ROCKFIN_TOOTH      }, reward = 27339 },
    -- PLD (Caballarius +1) - Pil's Tuille
    [631] = { trade = { 26636, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.PILS_TUILLE,          xi.item.GABBRATH_HORN      }, reward = 26637 },
    [632] = { trade = { 26812, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.PILS_TUILLE,          xi.item.YGGDREANT_BOLE     }, reward = 26813 },
    [633] = { trade = { 26988, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.PILS_TUILLE,          xi.item.BZTAVIAN_STINGER   }, reward = 26989 },
    [634] = { trade = { 27164, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.PILS_TUILLE,          xi.item.WAKTZA_ROSTRUM     }, reward = 27165 },
    [635] = { trade = { 27340, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.PILS_TUILLE,          xi.item.ROCKFIN_TOOTH      }, reward = 27341 },
    -- DRK (Fallen's +1) - Pil's Tuille
    [636] = { trade = { 26638, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.PILS_TUILLE,          xi.item.GABBRATH_HORN      }, reward = 26639 },
    [637] = { trade = { 26814, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.PILS_TUILLE,          xi.item.YGGDREANT_BOLE     }, reward = 26815 },
    [638] = { trade = { 26990, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.PILS_TUILLE,          xi.item.BZTAVIAN_STINGER   }, reward = 26991 },
    [639] = { trade = { 27166, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.PILS_TUILLE,          xi.item.WAKTZA_ROSTRUM     }, reward = 27167 },
    [640] = { trade = { 27342, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.PILS_TUILLE,          xi.item.ROCKFIN_TOOTH      }, reward = 27343 },
    -- BST (Ankusa +1) - Hahava's Mail
    [641] = { trade = { 26640, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.GABBRATH_HORN      }, reward = 26641 },
    [642] = { trade = { 26816, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.YGGDREANT_BOLE     }, reward = 26817 },
    [643] = { trade = { 26992, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.BZTAVIAN_STINGER   }, reward = 26993 },
    [644] = { trade = { 27168, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.WAKTZA_ROSTRUM     }, reward = 27169 },
    [645] = { trade = { 27344, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.ROCKFIN_TOOTH      }, reward = 27345 },
    -- BRD (Bihu +1) - Kaggen's Cuticle
    [646] = { trade = { 26642, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.GABBRATH_HORN      }, reward = 26643 },
    [647] = { trade = { 26818, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.YGGDREANT_BOLE     }, reward = 26819 },
    [648] = { trade = { 26994, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.BZTAVIAN_STINGER   }, reward = 26995 },
    [649] = { trade = { 27170, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.WAKTZA_ROSTRUM     }, reward = 27171 },
    [650] = { trade = { 27346, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.KAGGENS_CUTICLE,      xi.item.ROCKFIN_TOOTH      }, reward = 27347 },
    -- RNG (Arcadian +1) - Celaeno's Cloth
    [651] = { trade = { 26644, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.CELAENOS_CLOTH,       xi.item.GABBRATH_HORN      }, reward = 26645 },
    [652] = { trade = { 26820, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.CELAENOS_CLOTH,       xi.item.YGGDREANT_BOLE     }, reward = 26821 },
    [653] = { trade = { 26996, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.CELAENOS_CLOTH,       xi.item.BZTAVIAN_STINGER   }, reward = 26997 },
    [654] = { trade = { 27172, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.CELAENOS_CLOTH,       xi.item.WAKTZA_ROSTRUM     }, reward = 27173 },
    [655] = { trade = { 27348, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.CELAENOS_CLOTH,       xi.item.ROCKFIN_TOOTH      }, reward = 27349 },
    -- SAM (Sakonji +1) - Pil's Tuille
    [656] = { trade = { 26646, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.PILS_TUILLE,          xi.item.GABBRATH_HORN      }, reward = 26647 },
    [657] = { trade = { 26822, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.PILS_TUILLE,          xi.item.YGGDREANT_BOLE     }, reward = 26823 },
    [658] = { trade = { 26998, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.PILS_TUILLE,          xi.item.BZTAVIAN_STINGER   }, reward = 26999 },
    [659] = { trade = { 27174, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.PILS_TUILLE,          xi.item.WAKTZA_ROSTRUM     }, reward = 27175 },
    [660] = { trade = { 27350, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.PILS_TUILLE,          xi.item.ROCKFIN_TOOTH      }, reward = 27351 },
    -- NIN (Mochizuki +1) - Voidwrought Plate
    [661] = { trade = { 26648, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.GABBRATH_HORN      }, reward = 26649 },
    [662] = { trade = { 26824, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.YGGDREANT_BOLE     }, reward = 26825 },
    [663] = { trade = { 27000, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.BZTAVIAN_STINGER   }, reward = 27001 },
    [664] = { trade = { 27176, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.WAKTZA_ROSTRUM     }, reward = 27177 },
    [665] = { trade = { 27352, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.ROCKFIN_TOOTH      }, reward = 27353 },
    -- DRG (Pteroslaver +1) - Voidwrought Plate
    [666] = { trade = { 26650, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.GABBRATH_HORN      }, reward = 26651 },
    [667] = { trade = { 26826, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.YGGDREANT_BOLE     }, reward = 26827 },
    [668] = { trade = { 27002, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.BZTAVIAN_STINGER   }, reward = 27003 },
    [669] = { trade = { 27178, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.WAKTZA_ROSTRUM     }, reward = 27179 },
    [670] = { trade = { 27354, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.VOIDWROUGHT_PLATE,    xi.item.ROCKFIN_TOOTH      }, reward = 27355 },
    -- SMN (Glyphic +1) - Hahava's Mail
    [671] = { trade = { 26652, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.GABBRATH_HORN      }, reward = 26653 },
    [672] = { trade = { 26828, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.YGGDREANT_BOLE     }, reward = 26829 },
    [673] = { trade = { 27004, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.BZTAVIAN_STINGER   }, reward = 27005 },
    [674] = { trade = { 27180, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.WAKTZA_ROSTRUM     }, reward = 27181 },
    [675] = { trade = { 27356, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.ROCKFIN_TOOTH      }, reward = 27357 },
    -- BLU (Luhlaza +1) - Pil's Tuille
    [676] = { trade = { 26654, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.PILS_TUILLE,          xi.item.GABBRATH_HORN      }, reward = 26655 },
    [677] = { trade = { 26830, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.PILS_TUILLE,          xi.item.YGGDREANT_BOLE     }, reward = 26831 },
    [678] = { trade = { 27006, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.PILS_TUILLE,          xi.item.BZTAVIAN_STINGER   }, reward = 27007 },
    [679] = { trade = { 27182, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.PILS_TUILLE,          xi.item.WAKTZA_ROSTRUM     }, reward = 27183 },
    [680] = { trade = { 27358, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.PILS_TUILLE,          xi.item.ROCKFIN_TOOTH      }, reward = 27359 },
    -- COR (Lanun +1) - Kaggen's Cuticle
    [681] = { trade = { 26656, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.GABBRATH_HORN      }, reward = 26657 },
    [682] = { trade = { 26832, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.YGGDREANT_BOLE     }, reward = 26833 },
    [683] = { trade = { 27008, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.BZTAVIAN_STINGER   }, reward = 27009 },
    [684] = { trade = { 27184, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.KAGGENS_CUTICLE,      xi.item.WAKTZA_ROSTRUM     }, reward = 27185 },
    [685] = { trade = { 27360, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.KAGGENS_CUTICLE,      xi.item.ROCKFIN_TOOTH      }, reward = 27361 },
    -- PUP (Pitre +1) - Hahava's Mail
    [686] = { trade = { 26658, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.GABBRATH_HORN      }, reward = 26659 },
    [687] = { trade = { 26834, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.YGGDREANT_BOLE     }, reward = 26835 },
    [688] = { trade = { 27010, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.BZTAVIAN_STINGER   }, reward = 27011 },
    [689] = { trade = { 27186, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.WAKTZA_ROSTRUM     }, reward = 27187 },
    [690] = { trade = { 27362, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.SUIT_OF_HAHAVAS_MAIL, xi.item.ROCKFIN_TOOTH      }, reward = 27363 },
    -- DNC (Horos +1) - Celaeno's Cloth
    [691] = { trade = { 26660, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.CELAENOS_CLOTH,       xi.item.GABBRATH_HORN      }, reward = 26661 },
    [692] = { trade = { 26836, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.CELAENOS_CLOTH,       xi.item.YGGDREANT_BOLE     }, reward = 26837 },
    [693] = { trade = { 27012, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.CELAENOS_CLOTH,       xi.item.BZTAVIAN_STINGER   }, reward = 27013 },
    [694] = { trade = { 27188, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.CELAENOS_CLOTH,       xi.item.WAKTZA_ROSTRUM     }, reward = 27189 },
    [695] = { trade = { 27364, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.CELAENOS_CLOTH,       xi.item.ROCKFIN_TOOTH      }, reward = 27365 },
    -- SCH (Pedagogy +1) - Akvan's Pennon
    [696] = { trade = { 26662, { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.AKVANS_PENNON,        xi.item.GABBRATH_HORN      }, reward = 26663 },
    [697] = { trade = { 26838, { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.AKVANS_PENNON,        xi.item.YGGDREANT_BOLE     }, reward = 26839 },
    [698] = { trade = { 27014, { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.AKVANS_PENNON,        xi.item.BZTAVIAN_STINGER   }, reward = 27015 },
    [699] = { trade = { 27190, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.AKVANS_PENNON,        xi.item.WAKTZA_ROSTRUM     }, reward = 27191 },
    [700] = { trade = { 27366, { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.AKVANS_PENNON,        xi.item.ROCKFIN_TOOTH      }, reward = 27367 },
    -- GEO (Bagua +1) - Akvan's Pennon
    [1101] = { trade = { xi.item.BAGUA_GALERO,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.AKVANS_PENNON,  xi.item.GABBRATH_HORN    }, reward = 26665 },
    [1102] = { trade = { xi.item.BAGUA_TUNIC,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.AKVANS_PENNON,  xi.item.YGGDREANT_BOLE   }, reward = 26841 },
    [1103] = { trade = { xi.item.BAGUA_MITAINES,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.AKVANS_PENNON,  xi.item.BZTAVIAN_STINGER }, reward = 27017 },
    [1104] = { trade = { xi.item.BAGUA_PANTS,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.AKVANS_PENNON,  xi.item.WAKTZA_ROSTRUM   }, reward = 27193 },
    [1105] = { trade = { xi.item.BAGUA_SANDALS,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.AKVANS_PENNON,  xi.item.ROCKFIN_TOOTH    }, reward = 27369 },
    -- RUN (Futhark +1) - Celaeno's Cloth
    [1106] = { trade = { xi.item.FUTHARK_BANDEAU,  { xi.item.COPY_OF_REMS_TALE_CHAPTER_6,  8 }, xi.item.CELAENOS_CLOTH, xi.item.GABBRATH_HORN    }, reward = 26667 },
    [1107] = { trade = { xi.item.FUTHARK_COAT,     { xi.item.COPY_OF_REMS_TALE_CHAPTER_7,  8 }, xi.item.CELAENOS_CLOTH, xi.item.YGGDREANT_BOLE   }, reward = 26843 },
    [1108] = { trade = { xi.item.FUTHARK_MITONS,   { xi.item.COPY_OF_REMS_TALE_CHAPTER_8,  8 }, xi.item.CELAENOS_CLOTH, xi.item.BZTAVIAN_STINGER }, reward = 27019 },
    [1109] = { trade = { xi.item.FUTHARK_TROUSERS, { xi.item.COPY_OF_REMS_TALE_CHAPTER_9,  8 }, xi.item.CELAENOS_CLOTH, xi.item.WAKTZA_ROSTRUM   }, reward = 27195 },
    [1110] = { trade = { xi.item.FUTHARK_BOOTS,    { xi.item.COPY_OF_REMS_TALE_CHAPTER_10, 8 }, xi.item.CELAENOS_CLOTH, xi.item.ROCKFIN_TOOTH    }, reward = 27371 },
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
-- In-game menu system
-- Root menu → Browse Recipes (type → job → slot → chat output)
--           → Get Tales (chapter → quantity → give)
--
-- Menu window fits 3 lines: 2 selectable options + 1 nav button.
-- First display: no timer.  Page/menu transitions: player:timer(50, ...).
-----------------------------------

-- Ordered job abbreviations and per-type support lists
local menuTypeJobs =
{
    AF109  = { 'WAR','MNK','WHM','BLM','RDM','THF','PLD','DRK','BST','BRD','RNG','SAM','NIN','DRG','SMN','BLU','COR','PUP','DNC','SCH' },
    AF119  = { 'WAR','MNK','WHM','BLM','RDM','THF','PLD','DRK','BST','BRD','RNG','SAM','NIN','DRG','SMN','BLU','COR','PUP','DNC','SCH','GEO','RUN' },
    REL109 = { 'WAR','MNK','WHM','BLM','RDM','THF','PLD','DRK','BST','BRD','RNG','SAM','NIN','DRG','SMN','BLU','COR','PUP','DNC','SCH' },
    REL119 = { 'WAR','MNK','WHM','BLM','RDM','THF','PLD','DRK','BST','BRD','RNG','SAM','NIN','DRG','SMN','BLU','COR','PUP','DNC','SCH','GEO','RUN' },
    EMP109 = { 'WAR','MNK','WHM','BLM','RDM','THF','PLD','DRK','BST','BRD','RNG','SAM','NIN','DRG','SMN','BLU','COR','PUP','DNC','SCH' },
    EMP119 = { 'WAR','MNK','WHM','BLM','RDM','THF','PLD','DRK','BST','BRD','RNG','SAM','NIN','DRG','SMN','BLU','COR','PUP','DNC','SCH' },
}

-- Job-specific upgrade material per type (index = position in menuTypeJobs list above)
local menuJobMats =
{
    AF109  = { 'Black Tiger Lth.', 'Gold Thread',         'Imp. Silk Cloth',    'Karakul Cloth',
               'Scarlet Linen',    'Gold Thread',         'Gold Sheet',         'Darksteel Sheet',
               'Black Tiger Lth.', 'Imp. Silk Cloth',     'Karakul Cloth',      'Tama-Hagane',
               'Tama-Hagane',      'Gold Sheet',          'Scarlet Linen',      'Imp. Silk Cloth',
               'Karakul Cloth',    'Karakul Cloth',       'Gold Thread',        'Scarlet Linen' },

    AF119  = { 'Behemoth Leather', 'Plat. Silk Thread',   'Raxa',               'Twill Damask',
               "Siren's Hair",     'Plat. Silk Thread',   'Orichalcum Sheet',   'Durium Sheet',
               'Behemoth Leather', 'Raxa',                'Twill Damask',       'Damascus Ingot',
               'Damascus Ingot',   'Orichalcum Sheet',    "Siren's Hair",       'Raxa',
               'Twill Damask',     'Twill Damask',        'Plat. Silk Thread',  "Siren's Hair",
               'Raxa',             'Damascus Ingot' },

    REL109 = { 'Wootz Ore',        'Griffon Hide',        'Sparkling Stone',    'Sparkling Stone',
               'Griffon Hide',     'Griffon Hide',        'Wootz Ore',          'Wootz Ore',
               'Mammoth Tusk',     'Griffon Hide',        'Griffon Hide',       'Relic Iron',
               'Relic Iron',       'Griffon Hide',        'Lancewood Log',      'Griffon Hide',
               'Sparkling Stone',  'Lancewood Log',       'Mammoth Tusk',       'Lancewood Log' },

    REL119 = { 'Voidwrought Plate', "Kaggen's Cuticle",   "Akvan's Pennon",     "Akvan's Pennon",
               "Pil's Tuille",     "Kaggen's Cuticle",    "Pil's Tuille",       "Pil's Tuille",
               "Hahava's Mail",    "Kaggen's Cuticle",    "Celaeno's Cloth",    "Pil's Tuille",
               'Voidwrought Plate','Voidwrought Plate',   "Hahava's Mail",      "Pil's Tuille",
               "Kaggen's Cuticle", "Hahava's Mail",       "Celaeno's Cloth",    "Akvan's Pennon",
               "Akvan's Pennon",   "Celaeno's Cloth" },

    EMP109 = { 'Helm of Briareus',  "Itzpapalotl's Scale", "Orthrus's Claw",    'Glavoid Shell',
               "Cirein-croin's Lantern", "Alfard's Fang", "Kulkulkan's Fang",   'Helm of Briareus',
               "Carabosse's Gem",  "Dragua's Scale",      "Ulhuadshi's Fang",   "Apademak's Horn",
               "Bukhis's Wing",    "Azdaja's Horn",       "Carabosse's Gem",    "Isgebind's Heart",
               "Sobek's Skin",     "Carabosse's Gem",     'Two-Leaf Chloris Bud', "Sedna's Tusk" },
}

-- Slot-specific upgrade material per type (index 1-5 = Head/Body/Hands/Legs/Feet)
local menuSlotMats =
{
    AF109  = { 'Phoenix Feather',     'Malboro Fiber',        'Black Beetle Blood',  'Damascene Cloth',     'Oxblood'              },
    AF119  = { 'Maliyakaleya Coral',  'Hepatizon Ore',        'Beryllium Ore',       'Exalted Log',         "Sif's Lock"           },
    REL109 = { 'Phoenix Feather',     'Malboro Fiber',        'Black Beetle Blood',  'Damascene Cloth',     'Oxblood'              },
    REL119 = { 'Gabbrath Horn',       'Yggdreant Bole',       'Bztavian Stinger',    'Waktza Rostrum',      'Rockfin Tooth'        },
    EMP109 = { 'Phoenix Feather',     'Malboro Fiber',        'Black Beetle Blood',  'Damascene Cloth',     'Oxblood'              },
    EMP119 = { 'Defiant Sweat',       'Dark Matter',          'Macuil Horn',         'Tartarian Chain',     'Plovid Effluvium'     },
}

-- Etched Memory qty for Emp i119 per slot (Head/Body/Hands/Legs/Feet)
local menuEtchedQty = { 15, 25, 15, 20, 15 }

local menuSlotNames = { 'Head', 'Body', 'Hands', 'Legs', 'Feet' }

local menuTypeLabel = { AF109='AF i109', AF119='AF i119', REL109='Rel i109', REL119='Rel i119', EMP109='Emp i109', EMP119='Emp i119' }

local menuTypeList =
{
    { key = 'AF109',  label = 'AF i109'  },
    { key = 'AF119',  label = 'AF i119'  },
    { key = 'REL109', label = 'Rel i109' },
    { key = 'REL119', label = 'Rel i119' },
    { key = 'EMP109', label = 'Emp i109' },
    { key = 'EMP119', label = 'Emp i119' },
}

-- Map numeric FFXI job ID → abbreviation
local menuJobIdToAbbrev =
{
    [xi.job.WAR] = 'WAR', [xi.job.MNK] = 'MNK', [xi.job.WHM] = 'WHM', [xi.job.BLM] = 'BLM',
    [xi.job.RDM] = 'RDM', [xi.job.THF] = 'THF', [xi.job.PLD] = 'PLD', [xi.job.DRK] = 'DRK',
    [xi.job.BST] = 'BST', [xi.job.BRD] = 'BRD', [xi.job.RNG] = 'RNG', [xi.job.SAM] = 'SAM',
    [xi.job.NIN] = 'NIN', [xi.job.DRG] = 'DRG', [xi.job.SMN] = 'SMN', [xi.job.BLU] = 'BLU',
    [xi.job.COR] = 'COR', [xi.job.PUP] = 'PUP', [xi.job.DNC] = 'DNC', [xi.job.SCH] = 'SCH',
    [xi.job.GEO] = 'GEO', [xi.job.RUN] = 'RUN',
}

-----------------------------------
-- Print a recipe description to the player's chat log.
-----------------------------------
local function menuPrintRecipe(player, npc, typeKey, jobAbbrev, slotIdx)
    local typeJobs = menuTypeJobs[typeKey]
    local jobIdx   = nil
    for i, j in ipairs(typeJobs) do
        if j == jobAbbrev then jobIdx = i break end
    end
    if not jobIdx then return end

    local slot      = menuSlotNames[slotIdx]
    local typeLabel = menuTypeLabel[typeKey]
    local rtCh      = slotIdx       -- i109 types: Ch.1–5 (Head=Ch.1 … Feet=Ch.5)
    local rtCh2     = slotIdx + 5   -- i119 types: Ch.6–10
    local jobMat    = menuJobMats[typeKey] and menuJobMats[typeKey][jobIdx] or nil
    local slotMat   = menuSlotMats[typeKey] and menuSlotMats[typeKey][slotIdx] or nil

    player:printToPlayer(string.format('--- %s  %s  %s ---', typeLabel, jobAbbrev, slot), xi.msg.channel.SAY, npc:getName())

    if typeKey == 'AF109' then
        player:printToPlayer(string.format('Path A (base AF):  10x RT Ch.%d  +  %s  +  %s', rtCh, jobMat, slotMat), xi.msg.channel.SAY, npc:getName())
        player:printToPlayer(string.format('Path B (AF+1):      5x RT Ch.%d  (no extra mats needed)', rtCh), xi.msg.channel.SAY, npc:getName())

    elseif typeKey == 'AF119' then
        player:printToPlayer(string.format('i109 piece  +  8x RT Ch.%d  +  %s  +  %s', rtCh2, jobMat, slotMat), xi.msg.channel.SAY, npc:getName())

    elseif typeKey == 'REL109' then
        player:printToPlayer(string.format('Path A (Relic+2):  10x RT Ch.%d  +  %s  +  %s', rtCh, jobMat, slotMat), xi.msg.channel.SAY, npc:getName())
        player:printToPlayer(string.format('Path B (Relic+1):  10x RT Ch.%d  (no extra mats needed)', rtCh), xi.msg.channel.SAY, npc:getName())
        player:printToPlayer(string.format('Path C (Relic):    10x RT Ch.%d  (no extra mats needed)', rtCh), xi.msg.channel.SAY, npc:getName())

    elseif typeKey == 'REL119' then
        player:printToPlayer(string.format('i109 piece  +  8x RT Ch.%d  +  %s  +  %s', rtCh2, jobMat, slotMat), xi.msg.channel.SAY, npc:getName())

    elseif typeKey == 'EMP109' then
        player:printToPlayer(string.format('Path A (Emp+2):   5x RT Ch.%d  +  %s  +  %s', rtCh, jobMat, slotMat), xi.msg.channel.SAY, npc:getName())
        player:printToPlayer(string.format('Path B (Emp+1):  10x RT Ch.%d  (no extra mats needed)', rtCh), xi.msg.channel.SAY, npc:getName())

    elseif typeKey == 'EMP119' then
        local etched = menuEtchedQty[slotIdx]
        player:printToPlayer(string.format('i109 piece  +  8x RT Ch.%d  +  %dx Etched Memory  +  %s', rtCh2, etched, slotMat), xi.msg.channel.SAY, npc:getName())
    end
end

-----------------------------------
-- Menu: slot selection (Head/Body/Hands/Legs/Feet)
-- Prints recipe to chat on selection; redisplays menu for continued browsing.
-----------------------------------
local function menuShowSlots(player, npc, typeKey, jobAbbrev, pageNum, useTimer)
    local itemsPerPage = 2
    local totalPages   = math.ceil(5 / itemsPerPage)
    pageNum = math.max(1, math.min(pageNum, totalPages))

    local options  = {}
    local startIdx = (pageNum - 1) * itemsPerPage + 1
    local endIdx   = math.min(startIdx + itemsPerPage - 1, 5)

    for s = startIdx, endIdx do
        local slotCapture = s
        table.insert(options, {
            label    = menuSlotNames[s],
            callback = function(p)
                menuPrintRecipe(p, npc, typeKey, jobAbbrev, slotCapture)
                p:timer(50, function(pp)
                    menuShowSlots(pp, npc, typeKey, jobAbbrev, pageNum, false)
                end)
            end,
        })
    end

    if totalPages > 1 then
        if pageNum < totalPages then
            local next = pageNum + 1
            table.insert(options, {
                label    = string.format('Next >> %u/%u', next, totalPages),
                callback = function(p)
                    p:timer(50, function(pp) menuShowSlots(pp, npc, typeKey, jobAbbrev, next, false) end)
                end,
            })
        else
            local prev = pageNum - 1
            table.insert(options, {
                label    = string.format('<< Prev %u/%u', prev, totalPages),
                callback = function(p)
                    p:timer(50, function(pp) menuShowSlots(pp, npc, typeKey, jobAbbrev, prev, false) end)
                end,
            })
        end
    end

    local function draw(p)
        p:customMenu({
            title   = string.format('%s %s', menuTypeLabel[typeKey], jobAbbrev),
            options = options,
        })
    end

    if useTimer then
        player:timer(50, function(p) draw(p) end)
    else
        draw(player)
    end
end

-----------------------------------
-- Menu: job selection
-- Player's current main job appears first (marked with *) if supported by this type.
-----------------------------------
local function menuShowJobs(player, npc, typeKey, pageNum, useTimer)
    local rawJobs         = menuTypeJobs[typeKey]
    local playerAbbrev    = menuJobIdToAbbrev[player:getMainJob()]
    local playerSupported = false
    for _, j in ipairs(rawJobs) do
        if j == playerAbbrev then playerSupported = true break end
    end

    -- Build list: player's job first (with *), then remaining jobs in order
    local jobEntries = {}
    if playerSupported then
        table.insert(jobEntries, { abbrev = playerAbbrev, label = playerAbbrev .. '*' })
    end
    for _, j in ipairs(rawJobs) do
        if not (playerSupported and j == playerAbbrev) then
            table.insert(jobEntries, { abbrev = j, label = j })
        end
    end

    local itemsPerPage = 2
    local totalItems   = #jobEntries
    local totalPages   = math.ceil(totalItems / itemsPerPage)
    pageNum = math.max(1, math.min(pageNum, totalPages))

    local options  = {}
    local startIdx = (pageNum - 1) * itemsPerPage + 1
    local endIdx   = math.min(startIdx + itemsPerPage - 1, totalItems)

    for i = startIdx, endIdx do
        local entry        = jobEntries[i]
        local abbrevCapture = entry.abbrev
        table.insert(options, {
            label    = entry.label,
            callback = function(p)
                p:timer(50, function(pp) menuShowSlots(pp, npc, typeKey, abbrevCapture, 1, false) end)
            end,
        })
    end

    if totalPages > 1 then
        if pageNum < totalPages then
            local next = pageNum + 1
            table.insert(options, {
                label    = string.format('Next >> %u/%u', next, totalPages),
                callback = function(p)
                    p:timer(50, function(pp) menuShowJobs(pp, npc, typeKey, next, false) end)
                end,
            })
        else
            local prev = pageNum - 1
            table.insert(options, {
                label    = string.format('<< Prev %u/%u', prev, totalPages),
                callback = function(p)
                    p:timer(50, function(pp) menuShowJobs(pp, npc, typeKey, prev, false) end)
                end,
            })
        end
    end

    local function draw(p)
        p:customMenu({
            title   = string.format('%s - Job', menuTypeLabel[typeKey]),
            options = options,
        })
    end

    if useTimer then
        player:timer(50, function(p) draw(p) end)
    else
        draw(player)
    end
end

-----------------------------------
-- Menu: upgrade type selection
-----------------------------------
local function menuShowTypes(player, npc, pageNum, useTimer)
    local itemsPerPage = 2
    local totalItems   = #menuTypeList
    local totalPages   = math.ceil(totalItems / itemsPerPage)
    pageNum = math.max(1, math.min(pageNum, totalPages))

    local options  = {}
    local startIdx = (pageNum - 1) * itemsPerPage + 1
    local endIdx   = math.min(startIdx + itemsPerPage - 1, totalItems)

    for i = startIdx, endIdx do
        local entry      = menuTypeList[i]
        local keyCapture = entry.key
        table.insert(options, {
            label    = entry.label,
            callback = function(p)
                p:timer(50, function(pp) menuShowJobs(pp, npc, keyCapture, 1, false) end)
            end,
        })
    end

    if totalPages > 1 then
        if pageNum < totalPages then
            local next = pageNum + 1
            table.insert(options, {
                label    = string.format('Next >> %u/%u', next, totalPages),
                callback = function(p)
                    p:timer(50, function(pp) menuShowTypes(pp, npc, next, false) end)
                end,
            })
        else
            local prev = pageNum - 1
            table.insert(options, {
                label    = string.format('<< Prev %u/%u', prev, totalPages),
                callback = function(p)
                    p:timer(50, function(pp) menuShowTypes(pp, npc, prev, false) end)
                end,
            })
        end
    end

    local function draw(p)
        p:customMenu({
            title   = 'Browse Recipes',
            options = options,
        })
    end

    if useTimer then
        player:timer(50, function(p) draw(p) end)
    else
        draw(player)
    end
end

-----------------------------------
-- Menu: quantity selection for Rem's Tales retrieval
-----------------------------------
local function menuShowTalesQty(player, npc, chapter, stored, useTimer)
    -- Build quantity options: 1, 5, 10 (if enough stored), then "Return All"
    -- Only append stored if it is not already the last entry in the list.
    local qtyList = {}
    if stored >= 1  then table.insert(qtyList, 1)  end
    if stored >= 5  then table.insert(qtyList, 5)  end
    if stored >= 10 then table.insert(qtyList, 10) end
    if #qtyList == 0 or qtyList[#qtyList] ~= stored then
        table.insert(qtyList, stored)
    end

    local itemsPerPage = 2
    local totalItems   = #qtyList
    local totalPages   = math.ceil(totalItems / itemsPerPage)

    local function buildPage(pageNum, pgUseTimer)
        pageNum = math.max(1, math.min(pageNum, totalPages))

        local options  = {}
        local startIdx = (pageNum - 1) * itemsPerPage + 1
        local endIdx   = math.min(startIdx + itemsPerPage - 1, totalItems)

        for i = startIdx, endIdx do
            local qty = qtyList[i]
            local lbl = (qty == stored) and string.format('Return All (%d)', stored) or string.format('Return %d', qty)
            local qtyCapture = qty
            table.insert(options, {
                label    = lbl,
                callback = function(p)
                    local currentStored = getStoredTales(p, chapter)
                    local give          = math.min(qtyCapture, currentStored)
                    if give > 0 then
                        if npcUtil.giveItem(p, { { remsTaleItems[chapter], give } }) then
                            setStoredTales(p, chapter, currentStored - give)
                            p:printToPlayer(string.format('Here are %dx RT Ch.%d for you!', give, chapter), xi.msg.channel.SAY, npc:getName())
                        end
                    end
                end,
            })
        end

        if totalPages > 1 then
            if pageNum < totalPages then
                local next = pageNum + 1
                table.insert(options, {
                    label    = string.format('Next >> %u/%u', next, totalPages),
                    callback = function(p)
                        p:timer(50, function(pp) buildPage(next, false) end)
                    end,
                })
            else
                local prev = pageNum - 1
                table.insert(options, {
                    label    = string.format('<< Prev %u/%u', prev, totalPages),
                    callback = function(p)
                        p:timer(50, function(pp) buildPage(prev, false) end)
                    end,
                })
            end
        end

        local function draw(p)
            p:customMenu({
                title   = string.format('RT Ch.%d (%d stored)', chapter, stored),
                options = options,
            })
        end

        if pgUseTimer then
            player:timer(50, function(p) draw(p) end)
        else
            draw(player)
        end
    end

    buildPage(1, useTimer)
end

-----------------------------------
-- Menu: chapter selection for Rem's Tales retrieval
-----------------------------------
local function menuShowChapters(player, npc, pageNum, useTimer)
    local chapters = {}
    for ch = 1, 10 do
        local stored = getStoredTales(player, ch)
        if stored > 0 then
            table.insert(chapters, { ch = ch, stored = stored })
        end
    end

    if #chapters == 0 then
        player:printToPlayer("I don't have any Rem's Tales stored for you right now.", xi.msg.channel.SAY, npc:getName())
        return
    end

    local itemsPerPage = 2
    local totalItems   = #chapters
    local totalPages   = math.ceil(totalItems / itemsPerPage)
    pageNum = math.max(1, math.min(pageNum, totalPages))

    local options  = {}
    local startIdx = (pageNum - 1) * itemsPerPage + 1
    local endIdx   = math.min(startIdx + itemsPerPage - 1, totalItems)

    for i = startIdx, endIdx do
        local entry    = chapters[i]
        local chCap    = entry.ch
        local storeCap = entry.stored
        table.insert(options, {
            label    = string.format('Ch.%d (%d)', entry.ch, entry.stored),
            callback = function(p)
                p:timer(50, function(pp) menuShowTalesQty(pp, npc, chCap, storeCap, false) end)
            end,
        })
    end

    if totalPages > 1 then
        if pageNum < totalPages then
            local next = pageNum + 1
            table.insert(options, {
                label    = string.format('Next >> %u/%u', next, totalPages),
                callback = function(p)
                    p:timer(50, function(pp) menuShowChapters(pp, npc, next, false) end)
                end,
            })
        else
            local prev = pageNum - 1
            table.insert(options, {
                label    = string.format('<< Prev %u/%u', prev, totalPages),
                callback = function(p)
                    p:timer(50, function(pp) menuShowChapters(pp, npc, prev, false) end)
                end,
            })
        end
    end

    local function draw(p)
        p:customMenu({
            title   = "Rem's Tales",
            options = options,
        })
    end

    if useTimer then
        player:timer(50, function(p) draw(p) end)
    else
        draw(player)
    end
end

-----------------------------------
-- Root menu shown when player triggers Monisette.
-----------------------------------
local function menuShowRoot(player, npc)
    local hasTales = false
    for chapter = 1, 10 do
        if getStoredTales(player, chapter) > 0 then
            hasTales = true
            break
        end
    end

    local options =
    {
        {
            label    = 'Browse recipes',
            callback = function(p)
                p:timer(50, function(pp) menuShowTypes(pp, npc, 1, false) end)
            end,
        },
    }

    if hasTales then
        table.insert(options, {
            label    = 'Get Tales',
            callback = function(p)
                p:timer(50, function(pp) menuShowChapters(pp, npc, 1, false) end)
            end,
        })
    end

    player:customMenu({
        title   = 'Monisette',
        options = options,
    })
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
            player:printToPlayer('I will keep your Rem\'s Tales safe. Come back for them whenever you like!', xi.msg.channel.SAY, npc:getName())
        end

        return
    end

    -- Armor upgrade trades
    for _, entry in pairs(allUpgrades) do
        if npcUtil.tradeHasExactly(trade, entry.trade) then
            player:printToPlayer('Splendid! These materials are exactly what I need. Your armor has been reforged!', xi.msg.channel.SAY, npc:getName())

            if npcUtil.giveItem(player, entry.reward) then
                player:confirmTrade()
            end

            return
        end
    end

    -- No matching trade found — items are automatically returned to the player
    player:printToPlayer("Hmm... I'm afraid these materials don't match any reforge I can perform. Please check that you have all of the correct items.", xi.msg.channel.SAY, npc:getName())
end

-----------------------------------
-- Avoid event 384: it contains a hard-coded Sagheera prerequisite check in its
-- event data that cannot be bypassed from Lua.  Instead open the custom menu.
-----------------------------------
entity.onTrigger = function(player, npc)
    menuShowRoot(player, npc)
end

return entity
