-- GM Pet Job Scaling Layer
-- Adds pet-job support to the custom GM scaling item package.
--
-- Confirmed mod IDs from modifier.h / scripts/enum/mod.lua:
-- 990  PET_ATK_DEF
-- 991  PET_ACC_EVA
-- 992  PET_MAB_MDB
-- 993  PET_MACC_MEVA
-- 994  PET_ATTR_BONUS
-- 995  PET_TP_BONUS
-- 273  CALL_BEAST_DELAY
-- 564  JUG_LEVEL_RANGE
-- 1052 SIC_READY_RECAST
-- 1155 ENHANCES_MONSTER_CORRELATION
-- 126  BP_DAMAGE
-- 346  PERPETUATION_REDUCTION
-- 357  BP_DELAY
-- 541  BP_DELAY_II
-- 913  BLOOD_BOON
-- 1040 AVATAR_LVL_BONUS
-- 1154 AVATARS_FAVOR_ENHANCE
-- 1170 HALF_PERPETUATION_DAY
-- 1171 HALF_PERPETUATION_WEATHER
-- 284  UNCAPPED_WYVERN_BREATH
-- 829  WYVERN_EFFECTIVE_BREATH
-- 986  WYVERN_BREATH_MACC
-- 1043 WYVERN_LVL_BONUS
-- 1056 WYVERN_ATTRIBUTE_DA
-- 987  AUTO_ELEM_CAPACITY
-- 1002 AUTO_RANGED_DAMAGEP
-- 1044 AUTOMATON_LVL_BONUS

-- Remove only this pet-scaling layer from the selected GM items before reapplying.
DELETE FROM item_mods
WHERE itemId IN
(
    -- Judge armor/accessories/shield/weapons
    12523, 12551, 12679, 12807, 12935,
    13074, 13215, 13358, 13505, 13606,
    12332, 16622, 17644, 17174, 17326, 17012,

    -- Custom GM scaling weapons/utility items
    20514, 20593, 21745, 21770, 21821,
    20931, 16911, 16912, 21024, 22070,
    18401, 18823, 22198, 17851, 18831,
    22154, 19232
)
AND modId IN
(
    990, 991, 992, 993, 994, 995,
    273, 564, 1052, 1155,
    126, 346, 357, 541, 913, 1040, 1154, 1170, 1171,
    284, 829, 986, 1043, 1056,
    987, 1002, 1044
);

-- ------------------------------------------------------------
-- Universal Judge armor pet support
-- Small-to-medium bonuses per armor piece.
-- Full armor set gives meaningful pet power without being absurd.
-- ------------------------------------------------------------

-- Judge's Helm 12523
INSERT INTO item_mods VALUES (12523, 990, 20); -- Pet: ATK/DEF
INSERT INTO item_mods VALUES (12523, 991, 20); -- Pet: ACC/EVA
INSERT INTO item_mods VALUES (12523, 992, 10); -- Pet: MAB/MDB
INSERT INTO item_mods VALUES (12523, 993, 10); -- Pet: MACC/MEVA
INSERT INTO item_mods VALUES (12523, 994, 5);  -- Pet: attributes

-- Judge's Cuirass 12551
INSERT INTO item_mods VALUES (12551, 990, 25);
INSERT INTO item_mods VALUES (12551, 991, 25);
INSERT INTO item_mods VALUES (12551, 992, 10);
INSERT INTO item_mods VALUES (12551, 993, 10);
INSERT INTO item_mods VALUES (12551, 994, 5);

-- Judge's Gauntlets 12679
INSERT INTO item_mods VALUES (12679, 990, 20);
INSERT INTO item_mods VALUES (12679, 991, 25);
INSERT INTO item_mods VALUES (12679, 992, 10);
INSERT INTO item_mods VALUES (12679, 993, 15);
INSERT INTO item_mods VALUES (12679, 994, 5);

-- Judge's Cuisses 12807
INSERT INTO item_mods VALUES (12807, 990, 20);
INSERT INTO item_mods VALUES (12807, 991, 20);
INSERT INTO item_mods VALUES (12807, 992, 15);
INSERT INTO item_mods VALUES (12807, 993, 15);
INSERT INTO item_mods VALUES (12807, 994, 5);

-- Judge's Greaves 12935
INSERT INTO item_mods VALUES (12935, 990, 20);
INSERT INTO item_mods VALUES (12935, 991, 20);
INSERT INTO item_mods VALUES (12935, 992, 10);
INSERT INTO item_mods VALUES (12935, 993, 10);
INSERT INTO item_mods VALUES (12935, 995, 100); -- Pet: TP Bonus

-- ------------------------------------------------------------
-- Judge accessories pet support
-- Accessories carry stronger pet utility.
-- ------------------------------------------------------------

-- Judge's Gorget 13074
INSERT INTO item_mods VALUES (13074, 990, 15);
INSERT INTO item_mods VALUES (13074, 991, 15);
INSERT INTO item_mods VALUES (13074, 992, 10);
INSERT INTO item_mods VALUES (13074, 993, 10);
INSERT INTO item_mods VALUES (13074, 995, 100);

-- Judge's Belt 13215
INSERT INTO item_mods VALUES (13215, 990, 20);
INSERT INTO item_mods VALUES (13215, 991, 20);
INSERT INTO item_mods VALUES (13215, 994, 5);
INSERT INTO item_mods VALUES (13215, 995, 150);

-- Judge's Earring 13358
INSERT INTO item_mods VALUES (13358, 992, 15);
INSERT INTO item_mods VALUES (13358, 993, 15);
INSERT INTO item_mods VALUES (13358, 346, 1); -- Avatar perp reduction
INSERT INTO item_mods VALUES (13358, 357, 2); -- Blood Pact delay reduction

-- Judge's Ring 13505
INSERT INTO item_mods VALUES (13505, 990, 15);
INSERT INTO item_mods VALUES (13505, 991, 15);
INSERT INTO item_mods VALUES (13505, 992, 15);
INSERT INTO item_mods VALUES (13505, 993, 15);
INSERT INTO item_mods VALUES (13505, 995, 150);

-- Judge's Cape 13606
INSERT INTO item_mods VALUES (13606, 990, 20);
INSERT INTO item_mods VALUES (13606, 991, 20);
INSERT INTO item_mods VALUES (13606, 992, 15);
INSERT INTO item_mods VALUES (13606, 993, 15);
INSERT INTO item_mods VALUES (13606, 994, 10);

-- Judge's Shield 12332
INSERT INTO item_mods VALUES (12332, 990, 25);
INSERT INTO item_mods VALUES (12332, 991, 25);
INSERT INTO item_mods VALUES (12332, 993, 20);
INSERT INTO item_mods VALUES (12332, 994, 10);

-- ------------------------------------------------------------
-- Job-flavored GM weapon pet support
-- ------------------------------------------------------------

-- Aphelion Knuckles 20514: PUP / Automaton focus
INSERT INTO item_mods VALUES (20514, 990, 45);
INSERT INTO item_mods VALUES (20514, 991, 45);
INSERT INTO item_mods VALUES (20514, 992, 30);
INSERT INTO item_mods VALUES (20514, 993, 30);
INSERT INTO item_mods VALUES (20514, 994, 15);
INSERT INTO item_mods VALUES (20514, 995, 250);
INSERT INTO item_mods VALUES (20514, 987, 2);   -- Automaton elemental capacity
INSERT INTO item_mods VALUES (20514, 1002, 20); -- Automaton ranged damage %
INSERT INTO item_mods VALUES (20514, 1044, 2);  -- Automaton: Lv.+

-- Dullahan Axe 21745: BST / Jug pet focus
INSERT INTO item_mods VALUES (21745, 990, 55);
INSERT INTO item_mods VALUES (21745, 991, 55);
INSERT INTO item_mods VALUES (21745, 992, 25);
INSERT INTO item_mods VALUES (21745, 993, 25);
INSERT INTO item_mods VALUES (21745, 994, 20);
INSERT INTO item_mods VALUES (21745, 995, 300);
INSERT INTO item_mods VALUES (21745, 273, 10);   -- Call Beast delay reduction
INSERT INTO item_mods VALUES (21745, 564, 2);    -- Jug level range support
INSERT INTO item_mods VALUES (21745, 1052, 10);  -- Sic/Ready recast reduction
INSERT INTO item_mods VALUES (21745, 1155, 20);  -- Monster correlation pet acc/atk bonus

-- Ranine Staff 22070: SMN / Avatar focus
INSERT INTO item_mods VALUES (22070, 990, 35);
INSERT INTO item_mods VALUES (22070, 991, 35);
INSERT INTO item_mods VALUES (22070, 992, 55);
INSERT INTO item_mods VALUES (22070, 993, 55);
INSERT INTO item_mods VALUES (22070, 994, 20);
INSERT INTO item_mods VALUES (22070, 995, 250);
INSERT INTO item_mods VALUES (22070, 126, 20);   -- Blood Pact damage
INSERT INTO item_mods VALUES (22070, 346, 5);    -- Perpetuation reduction
INSERT INTO item_mods VALUES (22070, 357, 10);   -- Blood Pact delay reduction
INSERT INTO item_mods VALUES (22070, 541, 5);    -- Blood Pact delay II
INSERT INTO item_mods VALUES (22070, 913, 10);   -- Blood Boon
INSERT INTO item_mods VALUES (22070, 1040, 2);   -- Avatar: Lv.+
INSERT INTO item_mods VALUES (22070, 1154, 3);   -- Avatar's Favor enhance
INSERT INTO item_mods VALUES (22070, 1170, 1);   -- Half perpetuation day
INSERT INTO item_mods VALUES (22070, 1171, 1);   -- Half perpetuation weather

-- Celestial Spear 20931: DRG / Wyvern focus
INSERT INTO item_mods VALUES (20931, 990, 45);
INSERT INTO item_mods VALUES (20931, 991, 45);
INSERT INTO item_mods VALUES (20931, 992, 25);
INSERT INTO item_mods VALUES (20931, 993, 35);
INSERT INTO item_mods VALUES (20931, 994, 15);
INSERT INTO item_mods VALUES (20931, 995, 250);
INSERT INTO item_mods VALUES (20931, 284, 20);   -- Uncapped wyvern breath bonus
INSERT INTO item_mods VALUES (20931, 829, 10);   -- Wyvern effective breath
INSERT INTO item_mods VALUES (20931, 986, 20);   -- Wyvern breath magic accuracy
INSERT INTO item_mods VALUES (20931, 1043, 2);   -- Wyvern: Lv.+
INSERT INTO item_mods VALUES (20931, 1056, 10);  -- Wyvern Double Attack

-- Judge's Rod 17012: light SMN/avatar support for legacy GM rod
INSERT INTO item_mods VALUES (17012, 992, 25);
INSERT INTO item_mods VALUES (17012, 993, 25);
INSERT INTO item_mods VALUES (17012, 346, 3);
INSERT INTO item_mods VALUES (17012, 357, 5);
INSERT INTO item_mods VALUES (17012, 1040, 1);

-- Judge's Bow / Arrow: light pet TP support
INSERT INTO item_mods VALUES (17174, 991, 20);
INSERT INTO item_mods VALUES (17174, 995, 150);
INSERT INTO item_mods VALUES (17326, 991, 20);
INSERT INTO item_mods VALUES (17326, 995, 150);

-- Quick verification.
SELECT
    im.itemId,
    ib.name,
    im.modId,
    im.value
FROM item_mods im
JOIN item_basic ib
    ON ib.itemid = im.itemId
WHERE im.itemId IN
(
    12523, 12551, 12679, 12807, 12935,
    13074, 13215, 13358, 13505, 13606,
    12332, 16622, 17644, 17174, 17326, 17012,
    20514, 21745, 22070, 20931
)
AND im.modId IN
(
    990, 991, 992, 993, 994, 995,
    273, 564, 1052, 1155,
    126, 346, 357, 541, 913, 1040, 1154, 1170, 1171,
    284, 829, 986, 1043, 1056,
    987, 1002, 1044
)
ORDER BY im.itemId, im.modId;
