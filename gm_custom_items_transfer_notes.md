# Custom GM Scaling Item Package

Purpose:
This package adds custom GM/test-server items for PegasusXI Test using existing item IDs.
The items keep retail names, but use custom server-side stats, Level 1 / All Jobs access, and level-scaling item latents.
These are intended for GM/admin/test distribution with !additem, not normal retail progression.

Apply order:
1. Apply the custom GM/stat SQL files first.
2. Apply sql/custom/gm_restore_retail_names_only.sql last.

DAT/client note:
The database keeps retail item names, but client help text may still show original retail stats.
Caraboulou/client-side work should update DAT/help text display only.
Server-side stats and behavior are handled by the SQL files.

Main custom SQL files:
sql/custom/gm_judge_armor_scaling_item_mods.sql
sql/custom/gm_judge_accessory_scaling_item_mods.sql
sql/custom/gm_judge_weapon_scaling_item_mods.sql
sql/custom/gm_judge_weapon_damage_delay.sql
sql/custom/gm_judge_weapon_tiered_damage.sql
sql/custom/gm_judge_restore_fishing_rod.sql
sql/custom/gm_weapon_aphelion_knuckles.sql
sql/custom/gm_weapon_hedron_dagger.sql
sql/custom/gm_weapon_dullahan_axe.sql
sql/custom/gm_weapon_helgoland.sql
sql/custom/gm_weapon_lost_sickle_plus1.sql
sql/custom/gm_weapon_celestial_spear.sql
sql/custom/gm_weapon_katanas.sql
sql/custom/gm_weapon_ohakari.sql
sql/custom/gm_weapon_ranine_staff.sql
sql/custom/gm_weapon_moogle_rod.sql
sql/custom/gm_utility_ranged_batch.sql
sql/custom/gm_restore_retail_names_only.sql
