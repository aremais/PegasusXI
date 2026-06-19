-- GM Judge Weapon Tiered Damage Scaling
-- Uses DMG_RATING modId 287 as hidden effective weapon damage bonus.
-- item_weapon.dmg is the Lv.1 base damage.
-- Final effective damage = item_weapon.dmg + active DMG_RATING latents.
-- 17012 judges_rod is intentionally excluded because it is a fishing rod.

UPDATE item_weapon SET dmg = 20 WHERE itemId = 16622; -- judges_sword physical Lv.1 base damage
UPDATE item_weapon SET dmg = 16 WHERE itemId = 17644; -- judges_sword magic/utility Lv.1 base damage
UPDATE item_weapon SET dmg = 24 WHERE itemId = 17174; -- judges_bow Lv.1 base damage
UPDATE item_weapon SET dmg = 8  WHERE itemId = 17326; -- judges_arrow Lv.1 base damage

DELETE FROM item_latents
WHERE itemId IN (16622, 17644, 17174, 17326)
  AND modId = 287
  AND latentId = 51;

INSERT INTO item_latents (itemId, modId, value, latentId, latentParam) VALUES
    -- 16622 judges_sword physical: 20 -> 260
    (16622, 287, 15, 51, 10),
    (16622, 287, 25, 51, 20),
    (16622, 287, 25, 51, 30),
    (16622, 287, 25, 51, 40),
    (16622, 287, 25, 51, 50),
    (16622, 287, 30, 51, 60),
    (16622, 287, 30, 51, 70),
    (16622, 287, 25, 51, 80),
    (16622, 287, 25, 51, 90),
    (16622, 287, 15, 51, 99),

    -- 17644 judges_sword magic/utility: 16 -> 210
    (17644, 287, 14, 51, 10),
    (17644, 287, 20, 51, 20),
    (17644, 287, 20, 51, 30),
    (17644, 287, 20, 51, 40),
    (17644, 287, 20, 51, 50),
    (17644, 287, 25, 51, 60),
    (17644, 287, 25, 51, 70),
    (17644, 287, 20, 51, 80),
    (17644, 287, 20, 51, 90),
    (17644, 287, 10, 51, 99),

    -- 17174 judges_bow: 24 -> 300
    (17174, 287, 21, 51, 10),
    (17174, 287, 30, 51, 20),
    (17174, 287, 30, 51, 30),
    (17174, 287, 30, 51, 40),
    (17174, 287, 30, 51, 50),
    (17174, 287, 30, 51, 60),
    (17174, 287, 30, 51, 70),
    (17174, 287, 30, 51, 80),
    (17174, 287, 30, 51, 90),
    (17174, 287, 15, 51, 99),

    -- 17326 judges_arrow: 8 -> 120
    (17326, 287, 7, 51, 10),
    (17326, 287, 13, 51, 20),
    (17326, 287, 14, 51, 30),
    (17326, 287, 14, 51, 40),
    (17326, 287, 14, 51, 50),
    (17326, 287, 15, 51, 60),
    (17326, 287, 13, 51, 70),
    (17326, 287, 10, 51, 80),
    (17326, 287, 8, 51, 90),
    (17326, 287, 4, 51, 99);
