# Beastmaster Jug Pet & Ready Move Audit

Audit of all BST jug pets (pet IDs 21–47, 49–68, 77–127) and their Ready move sets.

Data sources:
- `sql/pet_list.sql` — pet metadata (level range, duration, pool link)
- `sql/mob_pools.sql` — mob pool → `skill_list_id` (Ready move pool)
- `sql/mob_skill_lists.sql` — skill list → mob skill IDs (`Jug_*` families)
- `sql/pet_skills.sql` — Ready move display names (authoritative for jug pets)
- `sql/mob_skills.sql` — fallback mob skill names
- `sql/item_weapon.sql` — jug reagent items (`skill=0`, `subskill=petId`)

**Total jug pets:** 98
**Data issues found:** 52

## Summary

- **Classic jug pets (21–68):** 47 — all have mob_pools entries
- **Merit jug pets (77–127):** 51 — 1 in live SQL, 50 upstream-only
- **Unique Ready move families (`Jug_*` + merit lists):** 38 referenced by jug pets

## Data Issues

- Pet **100** (AcuexFamiliar): poolid **7523** only in mob_pools_upstream.sql (not imported)
- Pet **101** (FluffyBredo): poolid **7524** only in mob_pools_upstream.sql (not imported)
- Pet **102** (WeevilFamiliar): poolid **7525** only in mob_pools_upstream.sql (not imported)
- Pet **103** (StalwartAngelina): poolid **7526** only in mob_pools_upstream.sql (not imported)
- Pet **104** (FleetReinhard): poolid **7527** only in mob_pools_upstream.sql (not imported)
- Pet **105** (SharpwitHermes): poolid **7528** only in mob_pools_upstream.sql (not imported)
- Pet **106** (P.CrabFamiliar): poolid **7529** only in mob_pools_upstream.sql (not imported)
- Pet **107** (JovialEdwin): poolid **7530** only in mob_pools_upstream.sql (not imported)
- Pet **108** (AttentiveIbuki): poolid **7531** only in mob_pools_upstream.sql (not imported)
- Pet **109** (SwoopingZhivago): poolid **7532** only in mob_pools_upstream.sql (not imported)
- Pet **110** (SunburstMalfik): poolid **7533** only in mob_pools_upstream.sql (not imported)
- Pet **111** (AgedAngus): poolid **7534** only in mob_pools_upstream.sql (not imported)
- Pet **112** (ScissorlegXerin): poolid **7535** only in mob_pools_upstream.sql (not imported)
- Pet **113** (BouncingBertha): poolid **7536** only in mob_pools_upstream.sql (not imported)
- Pet **114** (SpiderFamiliar): poolid **7537** only in mob_pools_upstream.sql (not imported)
- Pet **115** (GussyHachirobe): poolid **7538** only in mob_pools_upstream.sql (not imported)
- Pet **116** (ColibriFamiliar): poolid **7539** only in mob_pools_upstream.sql (not imported)
- Pet **117** (ChoralLeera): poolid **7540** only in mob_pools_upstream.sql (not imported)
- Pet **118** (DroopyDortwin): poolid **7541** only in mob_pools_upstream.sql (not imported)
- Pet **119** (PonderingPeter): poolid **7542** only in mob_pools_upstream.sql (not imported)
- Pet **120** (HeraldHenry): poolid **7543** only in mob_pools_upstream.sql (not imported)
- Pet **121** (Hip.Familiar): poolid **7544** only in mob_pools_upstream.sql (not imported)
- Pet **122** (DaringRoland): poolid **7545** only in mob_pools_upstream.sql (not imported)
- Pet **123** (MosquitoFamiliar): poolid **7546** only in mob_pools_upstream.sql (not imported)
- Pet **124** (Left-HandedYoko): poolid **7547** only in mob_pools_upstream.sql (not imported)
- Pet **125** (BraveHeroGlenn): poolid **7548** only in mob_pools_upstream.sql (not imported)
- Pet **125** (BraveHeroGlenn): skill_list_id is **0** (no Ready moves)
- Pet **126** (Y.BeetleFamiliar): poolid **7549** only in mob_pools_upstream.sql (not imported)
- Pet **127** (EnergizedSefina): poolid **7550** only in mob_pools_upstream.sql (not imported)
- Pet **67** (SlipperySilas): skill_list_id is **0** (no Ready moves)
- Pet **78** (AmiableRoche): poolid **7501** only in mob_pools_upstream.sql (not imported)
- Pet **79** (HeadbreakerKen): poolid **7502** only in mob_pools_upstream.sql (not imported)
- Pet **80** (AnklebiterJedd): poolid **7503** only in mob_pools_upstream.sql (not imported)
- Pet **81** (CursedAnnabelle): poolid **7504** only in mob_pools_upstream.sql (not imported)
- Pet **82** (BrainyWaluis): poolid **7505** only in mob_pools_upstream.sql (not imported)
- Pet **83** (SlimeFamiliar): poolid **7506** only in mob_pools_upstream.sql (not imported)
- Pet **84** (SultryPatrice): poolid **7507** only in mob_pools_upstream.sql (not imported)
- Pet **85** (GenerousArthur): poolid **7508** only in mob_pools_upstream.sql (not imported)
- Pet **86** (RedolentCandi): poolid **7509** only in mob_pools_upstream.sql (not imported)
- Pet **87** (AlluringHoney): poolid **7510** only in mob_pools_upstream.sql (not imported)
- Pet **88** (LynxFamiliar): poolid **7511** only in mob_pools_upstream.sql (not imported)
- Pet **89** (VivaciousGaston): poolid **7512** only in mob_pools_upstream.sql (not imported)
- Pet **90** (CaringKiyomaro): poolid **7513** only in mob_pools_upstream.sql (not imported)
- Pet **91** (VivaciousVickie): poolid **7514** only in mob_pools_upstream.sql (not imported)
- Pet **92** (SuspiciousAlice): poolid **7515** only in mob_pools_upstream.sql (not imported)
- Pet **93** (SurgingStorm): poolid **7516** only in mob_pools_upstream.sql (not imported)
- Pet **94** (SubmergedIyo): poolid **7517** only in mob_pools_upstream.sql (not imported)
- Pet **95** (WarlikePatrick): poolid **7518** only in mob_pools_upstream.sql (not imported)
- Pet **96** (RhymingShizuna): poolid **7519** only in mob_pools_upstream.sql (not imported)
- Pet **97** (BlackbeardRandy): poolid **7520** only in mob_pools_upstream.sql (not imported)
- Pet **98** (ThreestarLynn): poolid **7521** only in mob_pools_upstream.sql (not imported)
- Pet **99** (HurlerPercival): poolid **7522** only in mob_pools_upstream.sql (not imported)

## Ready Move Families

Pets sharing the same `skill_list_id` use identical Ready move sets.

| skill_list_id | List Name | # Pets | Ready Moves |
|---:|---|---:|---|
| 733 | Jug_Hare | 4 | Foot Kick (672), Dust Cloud (673), Whirl Claws (674), Wild Carrot (735) |
| 734 | Jug_Mandragora | 5 | Head Butt (675), Dream Flower (676), Wild Oats (677), Leaf Dagger (678), Scream (679) |
| 735 | Jug_Tiger | 4 | Roar (680), Razor Fang (681), Claw Cyclone (682), Crossthrash (795), Predatory Glare (796) |
| 736 | Jug_Lizard | 4 | Tail Blow (683), Fireball (684), Blockhead (685), Brain Crush (686), Infrasonics (687), Secretion (688) |
| 737 | Jug_Sheep | 4 | Lamb Chop (689), Rage (690), Sheep Charge (691), Sheep Song (692) |
| 738 | Jug_Crab | 5 | Bubble Shower (693), Bubble Curtain (694), Big Scissors (695), Scissor Guard (696), Metallic Body (697) |
| 739 | Jug_Cactuar | 1 | Needleshot (698), Random Needles (699) |
| 740 | Jug_Funguar | 3 | Frogkick (700), Spore (701), Queasyshroom (702), Numbshroom (703), Shakeshroom (704), Silence Gas (705), Dark Spore (706) |
| 741 | Jug_Beetle | 3 | Power Attack (707), Hi-freq Field (708), Rhino Attack (709), Rhino Guard (710), Spoil (711) |
| 742 | Jug_Fly | 4 | Cursed Sphere (712), Venom (713), Somersault (772) |
| 743 | Jug_Antlion | 3 | Sandblast (714), Sandpit (715), Venom Spray (716), Mandibular Bite (717) |
| 744 | Jug_Flytrap | 3 | Soporific (718), Gloeosuccus (719), Palsy Pollen (720) |
| 745 | Jug_Eft | 4 | Geist Wall (721), Numbing Noise (722), Nimble Snap (723), Cyclotail (724), Toxic Spit (725) |
| 746 | Jug_Diremite | 3 | Double Claw (726), Grapple (727), Spinning Top (728), Filamented Hold (729) |
| 747 | Jug_Coeurl | 1 | Chaotic Eye (730), Blaster (731) |
| 748 | Jug_Leech | 1 | Suction (732), Drainkiss (733), Acid Mist (740), Tp Drainkiss (741) |
| 749 | Jug_SnowHare | 1 | Foot Kick (672), Whirl Claws (674), Snow Cloud (734), Wild Carrot (735) |
| 750 | Jug_Ladybug | 2 | Sudden Lunge (736), Spiral Spin (737), Noisome Powder (738) |
| 751 | Jug_Raptor | 2 | Scythe Tail (743), Ripper Fang (744), Chomp Rush (745) |
| 752 | Jug_Slug | 2 | Purulent Ooze (747), Corrosive Ooze (748) |
| 753 | Jug_Hippogryph | 3 | Back Heel (749), Jettatura (750), Choke Breath (751), Fantod (752), Hoof Volley (797), Nihility Song (798) |
| 754 | Jug_Adamantoise | 1 | Tortoise Stomp (753), Harden Shell (754), Aqua Breath (755) |
| 755 | Jug_Apkallu | 3 | Wing Slap (756), Beak Lunge (757) |
| 756 | Jug_Pugil | 2 | Intimidate (758), Recoil Dive (759), Water Wall (760) |
| 757 | Jug_Chapuli | 2 | Sensilla Blades (761), Tegmina Buffet (762) |
| 758 | Jug_Tulfaire | 2 | Molting Plumage (763), Swooping Frenzy (764), Pentapeck (767) |
| 759 | Jug_Raaz | 2 | Sweeping Gouge (765), Zealous Snort (766) |
| 760 | Jug_Snapweed | 2 | Tickling Tendrils (768), Stink Bomb (769), Nectarous Deluge (770), Nepenthic Plunge (771) |
| 762 | Jug_Acuex | 2 | Foul Waters (774), Pestilent Plume (775) |
| 763 | Jug_Colibri | 2 | Pecking Flurry (776) |
| 764 | Jug_Spider | 2 | Sickle Slash (777), Acid Spray (778), Spider Web (779) |
| 765 | Jug_Lynx | 3 | Chaotic Eye (730), Blaster (731), Charged Whisker (746), Frenzied Rage (790) |
| 766 | Jug_Citrullus | 1 | Head Butt (675), Wild Oats (677), Leaf Dagger (678), Scream (679) |
| 2093 | Jug_Slime | 2 | Fluid Toss (792), Fluid Spread (793), Digest (794) |
| 2094 | Jug_CrabHi | 2 | Venom Shower (788), Bubble Curtain (694), Mega Scissors (789), Scissor Guard (696), Metallic Body (697) |
| 2095 | Jug_Lucani | 2 | Disembowel (786), Extirpating Salvo (787) |
| 2096 | Jug_Mosquito | 2 | Infected Leech (781), Gloom Spray (782) |
| 2097 | Jug_BeetleHi | 2 | Power Attack (707), Hi-freq Field (708), Rhino Attack (709), Rhino Guard (710), Spoil (711), Rhinowrecker (791) |

### Pets with no Ready moves (skill_list_id = 0)

SlipperySilas, BraveHeroGlenn

## Full Pet Table

| Pet ID | Name | Jug Item(s) | Lv | Duration | Pool | skill_list_id | List Name | Ready Moves | Status |
|---:|---|---|---:|---:|---:|---:|---|---|---|
| 21 | SheepFamiliar | herbal_broth [17864] | 23–35 | 60m | 4598 | 737 | Jug_Sheep | Lamb Chop (689), Rage (690), Sheep Charge (691), Sheep Song (692) | OK |
| 22 | HareFamiliar | carrot_broth [17860] | 23–35 | 90m | 4641 | 733 | Jug_Hare | Foot Kick (672), Dust Cloud (673), Whirl Claws (674), Wild Carrot (735) | OK |
| 23 | CrabFamiliar | fish_broth [17876] | 23–55 | 30m | 4610 | 738 | Jug_Crab | Bubble Shower (693), Bubble Curtain (694), Big Scissors (695), Scissor Guard (696), Metallic Body (697) | OK |
| 24 | CourierCarrie | fish_oil_broth [17877] | 23–75 | 30m | 4611 | 738 | Jug_Crab | Bubble Shower (693), Bubble Curtain (694), Big Scissors (695), Scissor Guard (696), Metallic Body (697) | OK |
| 25 | Homunculus | alchemist_water [17882] | 23–75 | 60m | 4616 | 734 | Jug_Mandragora | Head Butt (675), Dream Flower (676), Wild Oats (677), Leaf Dagger (678), Scream (679) | OK |
| 26 | FlytrapFamiliar | grass._broth [17885] | 28–40 | 60m | 4619 | 744 | Jug_Flytrap | Soporific (718), Gloeosuccus (719), Palsy Pollen (720) | OK |
| 27 | TigerFamiliar | meat_broth [17870] | 28–40 | 60m | 4604 | 735 | Jug_Tiger | Roar (680), Razor Fang (681), Claw Cyclone (682), Crossthrash (795), Predatory Glare (796) | OK |
| 28 | FlowerpotBill | humus [17868] | 28–40 | 60m | 4602 | 734 | Jug_Mandragora | Head Butt (675), Dream Flower (676), Wild Oats (677), Leaf Dagger (678), Scream (679) | OK |
| 29 | EftFamiliar | mole_broth [17887] | 33–45 | 60m | 4621 | 745 | Jug_Eft | Geist Wall (721), Numbing Noise (722), Nimble Snap (723), Cyclotail (724), Toxic Spit (725) | OK |
| 30 | LizardFamiliar | carrion_broth [17866] | 33–45 | 60m | 4600 | 736 | Jug_Lizard | Tail Blow (683), Fireball (684), Blockhead (685), Brain Crush (686), Infrasonics (687), Secretion (688) | OK |
| 31 | MayflyFamiliar | bug_broth [17862] | 33–45 | 60m | 4596 | 742 | Jug_Fly | Cursed Sphere (712), Venom (713), Somersault (772) | OK |
| 32 | FunguarFamiliar | seedbed_soil [17880] | 33–65 | 60m | 4614 | 740 | Jug_Funguar | Frogkick (700), Spore (701), Queasyshroom (702), Numbshroom (703), Shakeshroom (704), Silence Gas (705), Dark Spore (706) | OK |
| 33 | BeetleFamiliar | tree_sap [17872] | 38–45 | 60m | 4606 | 741 | Jug_Beetle | Power Attack (707), Hi-freq Field (708), Rhino Attack (709), Rhino Guard (710), Spoil (711) | OK |
| 34 | AntlionFamiliar | antica_broth [17891] | 38–50 | 60m | 4625 | 743 | Jug_Antlion | Sandblast (714), Sandpit (715), Venom Spray (716), Mandibular Bite (717) | OK |
| 35 | MiteFamiliar | blood_broth [17889] | 43–55 | 60m | 4623 | 746 | Jug_Diremite | Double Claw (726), Grapple (727), Spinning Top (728), Filamented Hold (729) | OK |
| 36 | LullabyMelodia | s._herbal_broth [17865] | 43–55 | 60m | 4599 | 737 | Jug_Sheep | Lamb Chop (689), Rage (690), Sheep Charge (691), Sheep Song (692) | OK |
| 37 | KeenearedSteffi | f._carrot_broth [17861] | 43–55 | 90m | 4595 | 733 | Jug_Hare | Foot Kick (672), Dust Cloud (673), Whirl Claws (674), Wild Carrot (735) | OK |
| 38 | FlowerpotBen | rich_humus [17869] | 51–63 | 60m | 4603 | 734 | Jug_Mandragora | Head Butt (675), Dream Flower (676), Wild Oats (677), Leaf Dagger (678), Scream (679) | OK |
| 39 | SaberSiravarde | w._meat_broth [17871] | 51–63 | 60m | 4605 | 735 | Jug_Tiger | Roar (680), Razor Fang (681), Claw Cyclone (682), Crossthrash (795), Predatory Glare (796) | OK |
| 40 | ColdbloodComo | c._carrion_broth [17867] | 53–65 | 60m | 4601 | 736 | Jug_Lizard | Tail Blow (683), Fireball (684), Blockhead (685), Brain Crush (686), Infrasonics (687), Secretion (688) | OK |
| 41 | ShellbusterOrob | qdv._bug_broth [17863] | 53–65 | 60m | 4597 | 742 | Jug_Fly | Cursed Sphere (712), Venom (713), Somersault (772) | OK |
| 42 | VoraciousAudrey | n._grass._broth [17886] | 53–75 | 60m | 4620 | 744 | Jug_Flytrap | Soporific (718), Gloeosuccus (719), Palsy Pollen (720) | OK |
| 43 | AmbusherAllie | l._mole_broth [17888] | 58–75 | 60m | 4622 | 745 | Jug_Eft | Geist Wall (721), Numbing Noise (722), Nimble Snap (723), Cyclotail (724), Toxic Spit (725) | OK |
| 44 | LifedrinkerLars | c._blood_broth [17890] | 63–75 | 60m | 4624 | 746 | Jug_Diremite | Double Claw (726), Grapple (727), Spinning Top (728), Filamented Hold (729) | OK |
| 45 | PanzerGalahad | scarlet_sap [17873] | 63–75 | 60m | 4607 | 741 | Jug_Beetle | Power Attack (707), Hi-freq Field (708), Rhino Attack (709), Rhino Guard (710), Spoil (711) | OK |
| 46 | ChopsueyChucky | f._antica_broth [17892] | 63–85 | 60m | 4626 | 743 | Jug_Antlion | Sandblast (714), Sandpit (715), Venom Spray (716), Mandibular Bite (717) | OK |
| 47 | AmigoSabotender | sun_water [17884] | 75–85 | 30m | 4618 | 739 | Jug_Cactuar | Needleshot (698), Random Needles (699) | OK |
| 49 | CraftyClyvonne | cng._brain_broth [17874] | 76–90 | 120m | 4608 | 747 | Jug_Coeurl | Chaotic Eye (730), Blaster (731) | OK |
| 50 | BloodclawShasr | rzr._brain_broth [17875] | 90–99 | 120m | 4609 | 765 | Jug_Lynx | Chaotic Eye (730), Blaster (731), Charged Whisker (746), Frenzied Rage (790) | OK |
| 51 | LuckyLulush | l._carrot_broth [17878] | 76–99 | 120m | 4612 | 749 | Jug_SnowHare | Foot Kick (672), Whirl Claws (674), Snow Cloud (734), Wild Carrot (735) | OK |
| 52 | FatsoFargann | c._plasma_broth [17879] | 81–99 | 120m | 4613 | 748 | Jug_Leech | Suction (732), Drainkiss (733), Acid Mist (740), Tp Drainkiss (741) | OK |
| 53 | DiscreetLouise | deepbed_soil [17881] | 79–99 | 120m | 4615 | 740 | Jug_Funguar | Frogkick (700), Spore (701), Queasyshroom (702), Numbshroom (703), Shakeshroom (704), Silence Gas (705), Dark Spore (706) | OK |
| 54 | SwiftSieghard | mlw._bird_broth [17883] | 86–94 | 120m | 4617 | 751 | Jug_Raptor | Scythe Tail (743), Ripper Fang (744), Chomp Rush (745) | OK |
| 55 | DipperYuly | wool_grease [17893] | 76–99 | 120m | 4627 | 750 | Jug_Ladybug | Sudden Lunge (736), Spiral Spin (737), Noisome Powder (738) | OK |
| 56 | FlowerpotMerle | vermihumus [17894] | 76–99 | 180m | 4628 | 734 | Jug_Mandragora | Head Butt (675), Dream Flower (676), Wild Oats (677), Leaf Dagger (678), Scream (679) | OK |
| 57 | NurseryNazuna | d._herbal_broth [17895] | 76–86 | 120m | 4629 | 737 | Jug_Sheep | Lamb Chop (689), Rage (690), Sheep Charge (691), Sheep Song (692) | OK |
| 58 | MailbusterCeta | gob._bug_broth [17896] | 85–95 | 120m | 4630 | 742 | Jug_Fly | Cursed Sphere (712), Venom (713), Somersault (772) | OK |
| 59 | AudaciousAnna | b._carrion_broth [17897] | 85–95 | 120m | 4631 | 736 | Jug_Lizard | Tail Blow (683), Fireball (684), Blockhead (685), Brain Crush (686), Infrasonics (687), Secretion (688) | OK |
| 60 | PrestoJulio | c._grass._broth [17898] | 83–93 | 120m | 4632 | 744 | Jug_Flytrap | Soporific (718), Gloeosuccus (719), Palsy Pollen (720) | OK |
| 61 | BugeyedBroncha | svg._mole_broth [17899] | 90–99 | 120m | 4633 | 745 | Jug_Eft | Geist Wall (721), Numbing Noise (722), Nimble Snap (723), Cyclotail (724), Toxic Spit (725) | OK |
| 62 | GooeyGerard | cl._wheat_broth [17900] | 95–99 | 90m | 4634 | 752 | Jug_Slug | Purulent Ooze (747), Corrosive Ooze (748) | OK |
| 63 | GorefangHobs | b._carrion_broth [17901] | 93–99 | 120m | 4635 | 735 | Jug_Tiger | Roar (680), Razor Fang (681), Claw Cyclone (682), Crossthrash (795), Predatory Glare (796) | OK |
| 64 | FaithfulFalcor | lucky_broth [17902] | 86–99 | 120m | 4636 | 753 | Jug_Hippogryph | Back Heel (749), Jettatura (750), Choke Breath (751), Fantod (752), Hoof Volley (797), Nihility Song (798) | OK |
| 65 | CrudeRaphie | shadowy_broth [17903] | 96–99 | 90m | 4637 | 754 | Jug_Adamantoise | Tortoise Stomp (753), Harden Shell (754), Aqua Breath (755) | OK |
| 66 | DapperMac | briny_broth [17904] | 76–99 | 120m | 4638 | 755 | Jug_Apkallu | Wing Slap (756), Beak Lunge (757) | OK |
| 67 | SlipperySilas | wormy_broth [17905] | 23–99 | 30m | 4639 | 0 | — | — | No Ready moves |
| 68 | TurbidToloi | auroral_broth [17906] | 75–99 | 120m | 4640 | 756 | Jug_Pugil | Intimidate (758), Recoil Dive (759), Water Wall (760) | OK |
| 77 | SweetCaroline | aged_humus [21490] | 99–119 | 120m | 7500 | 766 | Jug_Citrullus | Head Butt (675), Wild Oats (677), Leaf Dagger (678), Scream (679) | OK |
| 78 | AmiableRoche | airy_broth [21446] | 99–110 | 120m | 7501 | 756 | Jug_Pugil | Intimidate (758), Recoil Dive (759), Water Wall (760) | Pool missing (upstream) |
| 79 | HeadbreakerKen | blackwater_broth [17922] | 99–115 | 120m | 7502 | 742 | Jug_Fly | Cursed Sphere (712), Venom (713), Somersault (772) | Pool missing (upstream) |
| 80 | AnklebiterJedd | crackling_broth [21498] | 99–116 | 120m | 7503 | 746 | Jug_Diremite | Double Claw (726), Grapple (727), Spinning Top (728), Filamented Hold (729) | Pool missing (upstream) |
| 81 | CursedAnnabelle | creepy_broth [21499] | 99–118 | 120m | 7504 | 743 | Jug_Antlion | Sandblast (714), Sandpit (715), Venom Spray (716), Mandibular Bite (717) | Pool missing (upstream) |
| 82 | BrainyWaluis | crumbly_soil [21447] | 99–113 | 120m | 7505 | 740 | Jug_Funguar | Frogkick (700), Spore (701), Queasyshroom (702), Numbshroom (703), Shakeshroom (704), Silence Gas (705), Dark Spore (706) | Pool missing (upstream) |
| 83 | SlimeFamiliar | decaying_broth [21470] | 99–119 | 120m | 7506 | 2093 | Jug_Slime | Fluid Toss (792), Fluid Spread (793), Digest (794) | Pool missing (upstream) |
| 84 | SultryPatrice | putrescent_broth [21471] | 99–119 | 120m | 7507 | 2093 | Jug_Slime | Fluid Toss (792), Fluid Spread (793), Digest (794) | Pool missing (upstream) |
| 85 | GenerousArthur | dire_broth [21449] | 99–119 | 120m | 7508 | 752 | Jug_Slug | Purulent Ooze (747), Corrosive Ooze (748) | Pool missing (upstream) |
| 86 | RedolentCandi | electrified_broth [21450] | 99–115 | 120m | 7509 | 760 | Jug_Snapweed | Tickling Tendrils (768), Stink Bomb (769), Nectarous Deluge (770), Nepenthic Plunge (771) | Pool missing (upstream) |
| 87 | AlluringHoney | bug-ridden_broth [21451] | 99–115 | 120m | 7510 | 760 | Jug_Snapweed | Tickling Tendrils (768), Stink Bomb (769), Nectarous Deluge (770), Nepenthic Plunge (771) | Pool missing (upstream) |
| 88 | LynxFamiliar | frizzante_broth [21466] | 99–119 | 120m | 7511 | 765 | Jug_Lynx | Chaotic Eye (730), Blaster (731), Charged Whisker (746), Frenzied Rage (790) | Pool missing (upstream) |
| 89 | VivaciousGaston | spumante_broth [21467] | 99–119 | 120m | 7512 | 765 | Jug_Lynx | Chaotic Eye (730), Blaster (731), Charged Whisker (746), Frenzied Rage (790) | Pool missing (upstream) |
| 90 | CaringKiyomaro | fizzy_broth [17912] | 99–116 | 120m | 7513 | 759 | Jug_Raaz | Sweeping Gouge (765), Zealous Snort (766) | Pool missing (upstream) |
| 91 | VivaciousVickie | tant._broth [17919] | 99–116 | 120m | 7514 | 759 | Jug_Raaz | Sweeping Gouge (765), Zealous Snort (766) | Pool missing (upstream) |
| 92 | SuspiciousAlice | furious_broth [21496] | 99–113 | 120m | 7515 | 745 | Jug_Eft | Geist Wall (721), Numbing Noise (722), Nimble Snap (723), Cyclotail (724), Toxic Spit (725) | Pool missing (upstream) |
| 93 | SurgingStorm | insipid_broth [21492] | 99–118 | 120m | 7516 | 755 | Jug_Apkallu | Wing Slap (756), Beak Lunge (757) | Pool missing (upstream) |
| 94 | SubmergedIyo | deepwater_broth [21493] | 99–118 | 120m | 7517 | 755 | Jug_Apkallu | Wing Slap (756), Beak Lunge (757) | Pool missing (upstream) |
| 95 | WarlikePatrick | livid_broth [21444] | 99–104 | 120m | 7518 | 736 | Jug_Lizard | Tail Blow (683), Fireball (684), Blockhead (685), Brain Crush (686), Infrasonics (687), Secretion (688) | Pool missing (upstream) |
| 96 | RhymingShizuna | lyrical_broth [21445] | 99–107 | 120m | 7519 | 737 | Jug_Sheep | Lamb Chop (689), Rage (690), Sheep Charge (691), Sheep Song (692) | Pool missing (upstream) |
| 97 | BlackbeardRandy | meaty_broth [17920] | 99–117 | 120m | 7520 | 735 | Jug_Tiger | Roar (680), Razor Fang (681), Claw Cyclone (682), Crossthrash (795), Predatory Glare (796) | Pool missing (upstream) |
| 98 | ThreestarLynn | muddy_broth [17921] | 99–119 | 120m | 7521 | 750 | Jug_Ladybug | Sudden Lunge (736), Spiral Spin (737), Noisome Powder (738) | Pool missing (upstream) |
| 99 | HurlerPercival | pale_sap [21448] | 99–116 | 120m | 7522 | 741 | Jug_Beetle | Power Attack (707), Hi-freq Field (708), Rhino Attack (709), Rhino Guard (710), Spoil (711) | Pool missing (upstream) |
| 100 | AcuexFamiliar | poisonous_broth [21438] | 99–119 | 120m | 7523 | 762 | Jug_Acuex | Foul Waters (774), Pestilent Plume (775) | Pool missing (upstream) |
| 101 | FluffyBredo | venomous_broth [21439] | 99–119 | 120m | 7524 | 762 | Jug_Acuex | Foul Waters (774), Pestilent Plume (775) | Pool missing (upstream) |
| 102 | WeevilFamiliar | jug_of_pristine_sap [21488] | 99–119 | 120m | 7525 | 2095 | Jug_Lucani | Disembowel (786), Extirpating Salvo (787) | Pool missing (upstream) |
| 103 | StalwartAngelina | jug_of_truly_pristine_sap [21489] | 99–119 | 120m | 7526 | 2095 | Jug_Lucani | Disembowel (786), Extirpating Salvo (787) | Pool missing (upstream) |
| 104 | FleetReinhard | rapid_broth [21497] | 99–117 | 120m | 7527 | 751 | Jug_Raptor | Scythe Tail (743), Ripper Fang (744), Chomp Rush (745) | Pool missing (upstream) |
| 105 | SharpwitHermes | saline_broth [17913] | 99–119 | 120m | 7528 | 734 | Jug_Mandragora | Head Butt (675), Dream Flower (676), Wild Oats (677), Leaf Dagger (678), Scream (679) | Pool missing (upstream) |
| 106 | P.CrabFamiliar | rancid_broth [21464] | 99–119 | 120m | 7529 | 2094 | Jug_CrabHi | Venom Shower (788), Bubble Curtain (694), Mega Scissors (789), Scissor Guard (696), Metallic Body (697) | Pool missing (upstream) |
| 107 | JovialEdwin | pungent_broth [21465] | 99–119 | 120m | 7530 | 2094 | Jug_CrabHi | Venom Shower (788), Bubble Curtain (694), Mega Scissors (789), Scissor Guard (696), Metallic Body (697) | Pool missing (upstream) |
| 108 | AttentiveIbuki | salubrious_broth [17911] | 99–109 | 120m | 7531 | 758 | Jug_Tulfaire | Molting Plumage (763), Swooping Frenzy (764), Pentapeck (767) | Pool missing (upstream) |
| 109 | SwoopingZhivago | windy_greens [17918] | 99–119 | 120m | 7532 | 758 | Jug_Tulfaire | Molting Plumage (763), Swooping Frenzy (764), Pentapeck (767) | Pool missing (upstream) |
| 110 | SunburstMalfik | shimmering_broth [17908] | 99–104 | 120m | 7533 | 738 | Jug_Crab | Bubble Shower (693), Bubble Curtain (694), Big Scissors (695), Scissor Guard (696), Metallic Body (697) | Pool missing (upstream) |
| 111 | AgedAngus | ferm._broth [17916] | 99–104 | 120m | 7534 | 738 | Jug_Crab | Bubble Shower (693), Bubble Curtain (694), Big Scissors (695), Scissor Guard (696), Metallic Body (697) | Pool missing (upstream) |
| 112 | ScissorlegXerin | spicy_broth [17909] | 99–105 | 120m | 7535 | 757 | Jug_Chapuli | Sensilla Blades (761), Tegmina Buffet (762) | Pool missing (upstream) |
| 113 | BouncingBertha | bubbly_broth [17917] | 99–105 | 120m | 7536 | 757 | Jug_Chapuli | Sensilla Blades (761), Tegmina Buffet (762) | Pool missing (upstream) |
| 114 | SpiderFamiliar | sticky_webbing [21442] | 99–118 | 120m | 7537 | 764 | Jug_Spider | Sickle Slash (777), Acid Spray (778), Spider Web (779) | Pool missing (upstream) |
| 115 | GussyHachirobe | slimy_webbing [21443] | 99–118 | 120m | 7538 | 764 | Jug_Spider | Sickle Slash (777), Acid Spray (778), Spider Web (779) | Pool missing (upstream) |
| 116 | ColibriFamiliar | sugary_broth [21440] | 99–117 | 120m | 7539 | 763 | Jug_Colibri | Pecking Flurry (776) | Pool missing (upstream) |
| 117 | ChoralLeera | glazed_broth [21441] | 99–119 | 120m | 7540 | 763 | Jug_Colibri | Pecking Flurry (776) | Pool missing (upstream) |
| 118 | DroopyDortwin | swirling_broth [17907] | 99–103 | 120m | 7541 | 733 | Jug_Hare | Foot Kick (672), Dust Cloud (673), Whirl Claws (674), Wild Carrot (735) | Pool missing (upstream) |
| 119 | PonderingPeter | vis._broth [17915] | 99–103 | 120m | 7542 | 733 | Jug_Hare | Foot Kick (672), Dust Cloud (673), Whirl Claws (674), Wild Carrot (735) | Pool missing (upstream) |
| 120 | HeraldHenry | trans._broth [17910] | 99–113 | 120m | 7543 | 738 | Jug_Crab | Bubble Shower (693), Bubble Curtain (694), Big Scissors (695), Scissor Guard (696), Metallic Body (697) | Pool missing (upstream) |
| 121 | Hip.Familiar | turpid_broth [21472] | 99–119 | 120m | 7544 | 753 | Jug_Hippogryph | Back Heel (749), Jettatura (750), Choke Breath (751), Fantod (752), Hoof Volley (797), Nihility Song (798) | Pool missing (upstream) |
| 122 | DaringRoland | feculent_broth [21473] | 99–119 | 120m | 7545 | 753 | Jug_Hippogryph | Back Heel (749), Jettatura (750), Choke Breath (751), Fantod (752), Hoof Volley (797), Nihility Song (798) | Pool missing (upstream) |
| 123 | MosquitoFamiliar | wetlands_broth [21494] | 99–119 | 120m | 7546 | 2096 | Jug_Mosquito | Infected Leech (781), Gloom Spray (782) | Pool missing (upstream) |
| 124 | Left-HandedYoko | heavenly_broth [21495] | 99–119 | 120m | 7547 | 2096 | Jug_Mosquito | Infected Leech (781), Gloom Spray (782) | Pool missing (upstream) |
| 125 | BraveHeroGlenn | wispy_broth [17914] | 99–119 | 120m | 7548 | 0 | — | — | No Ready moves |
| 126 | Y.BeetleFamiliar | zestful_sap [21468] | 99–119 | 120m | 7549 | 2097 | Jug_BeetleHi | Power Attack (707), Hi-freq Field (708), Rhino Attack (709), Rhino Guard (710), Spoil (711), Rhinowrecker (791) | Pool missing (upstream) |
| 127 | EnergizedSefina | gassy_sap [21469] | 99–119 | 120m | 7550 | 2097 | Jug_BeetleHi | Power Attack (707), Hi-freq Field (708), Rhino Attack (709), Rhino Guard (710), Spoil (711), Rhinowrecker (791) | Pool missing (upstream) |

## Classic Familiar / Named Pairs

Early jug pets come in Familiar + Named pairs sharing the same Ready move family:

| Familiar | Named | skill_list_id | Ready Moves |
|---|---|---:|---|
| SheepFamiliar | LullabyMelodia | 737 | Lamb Chop (689), Rage (690), Sheep Charge (691), Sheep Song (692) |
| HareFamiliar | KeenearedSteffi | 733 | Foot Kick (672), Dust Cloud (673), Whirl Claws (674), Wild Carrot (735) |
| CrabFamiliar | CourierCarrie | 738 | Bubble Shower (693), Bubble Curtain (694), Big Scissors (695), Scissor Guard (696), Metallic Body (697) |
| Homunculus | FlowerpotBen | 734 | Head Butt (675), Dream Flower (676), Wild Oats (677), Leaf Dagger (678), Scream (679) |
| FlytrapFamiliar | VoraciousAudrey | 744 | Soporific (718), Gloeosuccus (719), Palsy Pollen (720) |
| TigerFamiliar | SaberSiravarde | 735 | Roar (680), Razor Fang (681), Claw Cyclone (682), Crossthrash (795), Predatory Glare (796) |
| FlowerpotBill | FlowerpotBen | 734 | Head Butt (675), Dream Flower (676), Wild Oats (677), Leaf Dagger (678), Scream (679) |
| EftFamiliar | AmbusherAllie | 745 | Geist Wall (721), Numbing Noise (722), Nimble Snap (723), Cyclotail (724), Toxic Spit (725) |
| LizardFamiliar | ColdbloodComo | 736 | Tail Blow (683), Fireball (684), Blockhead (685), Brain Crush (686), Infrasonics (687), Secretion (688) |
| MayflyFamiliar | ShellbusterOrob | 742 | Cursed Sphere (712), Venom (713), Somersault (772) |
| FunguarFamiliar | DiscreetLouise | 740 | Frogkick (700), Spore (701), Queasyshroom (702), Numbshroom (703), Shakeshroom (704), Silence Gas (705), Dark Spore (706) |
| BeetleFamiliar | PanzerGalahad | 741 | Power Attack (707), Hi-freq Field (708), Rhino Attack (709), Rhino Guard (710), Spoil (711) |
| AntlionFamiliar | ChopsueyChucky | 743 | Sandblast (714), Sandpit (715), Venom Spray (716), Mandibular Bite (717) |
| MiteFamiliar | LifedrinkerLars | 746 | Double Claw (726), Grapple (727), Spinning Top (728), Filamented Hold (729) |
