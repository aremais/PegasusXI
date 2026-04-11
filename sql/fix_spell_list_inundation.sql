-- BUG-0039: Inundation (spell 879) had no spell_list row (commented in dump).
-- content_tag is NULL so charutils::LoadSpells always JOINs this row (SOA-disabled servers
-- otherwise omit SOA-tagged spells and the character never reloads 879 from char_spells).
-- BG Wiki: RDM 64, White / Enfeebling, 48 MP, 3s cast, 20s recast, ~21' range.
-- https://www.bg-wiki.com/ffxi/Inundation

REPLACE INTO `spell_list` VALUES (
  879,
  'inundation',
  X'00000000400000000000000000000000000000000000',
  6,
  157,
  7,
  0,
  4,
  35,
  48,
  3000,
  20000,
  0,
  0,
  937,
  4000,
  0,
  0,
  1.00,
  1,
  320,
  0,
  210,
  0,
  NULL
);

-- If you already inserted this row with content_tag 'SOA', run:
-- UPDATE `spell_list` SET `content_tag` = NULL WHERE `spellid` = 879 LIMIT 1;
