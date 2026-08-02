/*
===========================================================================

  Copyright (c) 2026 LandSandBoat Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see http://www.gnu.org/licenses/

===========================================================================
*/

// Temporary compatibility aliases for the incomplete YAML enum migration.
// Prefer xi::Job / xi::SkillType / xi::Mod / xi::Weather at call sites going forward.

#pragma once

#include "data/enums/job.h"
#include "data/enums/mod.h"
#include "data/enums/skill_type.h"
#include "data/enums/weather.h"

using Mod     = xi::Mod;
using JOBTYPE = xi::Job;
using Weather = xi::Weather;

inline constexpr auto JOB_NON = xi::Job::NONE;
inline constexpr auto JOB_WAR = xi::Job::WAR;
inline constexpr auto JOB_MNK = xi::Job::MNK;
inline constexpr auto JOB_WHM = xi::Job::WHM;
inline constexpr auto JOB_BLM = xi::Job::BLM;
inline constexpr auto JOB_RDM = xi::Job::RDM;
inline constexpr auto JOB_THF = xi::Job::THF;
inline constexpr auto JOB_PLD = xi::Job::PLD;
inline constexpr auto JOB_DRK = xi::Job::DRK;
inline constexpr auto JOB_BST = xi::Job::BST;
inline constexpr auto JOB_BRD = xi::Job::BRD;
inline constexpr auto JOB_RNG = xi::Job::RNG;
inline constexpr auto JOB_SAM = xi::Job::SAM;
inline constexpr auto JOB_NIN = xi::Job::NIN;
inline constexpr auto JOB_DRG = xi::Job::DRG;
inline constexpr auto JOB_SMN = xi::Job::SMN;
inline constexpr auto JOB_BLU = xi::Job::BLU;
inline constexpr auto JOB_COR = xi::Job::COR;
inline constexpr auto JOB_PUP = xi::Job::PUP;
inline constexpr auto JOB_DNC = xi::Job::DNC;
inline constexpr auto JOB_SCH = xi::Job::SCH;
inline constexpr auto JOB_GEO = xi::Job::GEO;
inline constexpr auto JOB_RUN = xi::Job::RUN;
inline constexpr auto JOB_MON = xi::Job::MON;

inline constexpr auto SKILL_NONE              = xi::SkillType::None;
inline constexpr auto SKILL_HAND_TO_HAND      = xi::SkillType::HandToHand;
inline constexpr auto SKILL_DAGGER            = xi::SkillType::Dagger;
inline constexpr auto SKILL_SWORD             = xi::SkillType::Sword;
inline constexpr auto SKILL_GREAT_SWORD       = xi::SkillType::GreatSword;
inline constexpr auto SKILL_AXE               = xi::SkillType::Axe;
inline constexpr auto SKILL_GREAT_AXE         = xi::SkillType::GreatAxe;
inline constexpr auto SKILL_SCYTHE            = xi::SkillType::Scythe;
inline constexpr auto SKILL_POLEARM           = xi::SkillType::Polearm;
inline constexpr auto SKILL_KATANA            = xi::SkillType::Katana;
inline constexpr auto SKILL_GREAT_KATANA      = xi::SkillType::GreatKatana;
inline constexpr auto SKILL_CLUB              = xi::SkillType::Club;
inline constexpr auto SKILL_STAFF             = xi::SkillType::Staff;
inline constexpr auto SKILL_AUTOMATON_MELEE   = xi::SkillType::AutomatonMelee;
inline constexpr auto SKILL_AUTOMATON_RANGED  = xi::SkillType::AutomatonRanged;
inline constexpr auto SKILL_AUTOMATON_MAGIC   = xi::SkillType::AutomatonMagic;
inline constexpr auto SKILL_ARCHERY           = xi::SkillType::Archery;
inline constexpr auto SKILL_MARKSMANSHIP      = xi::SkillType::Marksmanship;
inline constexpr auto SKILL_THROWING          = xi::SkillType::Throwing;
inline constexpr auto SKILL_GUARD             = xi::SkillType::Guard;
inline constexpr auto SKILL_EVASION           = xi::SkillType::Evasion;
inline constexpr auto SKILL_SHIELD            = xi::SkillType::Shield;
inline constexpr auto SKILL_PARRY             = xi::SkillType::Parry;
inline constexpr auto SKILL_DIVINE_MAGIC      = xi::SkillType::DivineMagic;
inline constexpr auto SKILL_HEALING_MAGIC     = xi::SkillType::HealingMagic;
inline constexpr auto SKILL_ENHANCING_MAGIC   = xi::SkillType::EnhancingMagic;
inline constexpr auto SKILL_ENFEEBLING_MAGIC  = xi::SkillType::EnfeeblingMagic;
inline constexpr auto SKILL_ELEMENTAL_MAGIC   = xi::SkillType::ElementalMagic;
inline constexpr auto SKILL_DARK_MAGIC        = xi::SkillType::DarkMagic;
inline constexpr auto SKILL_SUMMONING_MAGIC   = xi::SkillType::SummoningMagic;
inline constexpr auto SKILL_NINJUTSU          = xi::SkillType::Ninjutsu;
inline constexpr auto SKILL_SINGING           = xi::SkillType::Singing;
inline constexpr auto SKILL_STRING_INSTRUMENT = xi::SkillType::StringInstrument;
inline constexpr auto SKILL_WIND_INSTRUMENT   = xi::SkillType::WindInstrument;
inline constexpr auto SKILL_BLUE_MAGIC        = xi::SkillType::BlueMagic;
inline constexpr auto SKILL_GEOMANCY          = xi::SkillType::Geomancy;
inline constexpr auto SKILL_HANDBELL          = xi::SkillType::Handbell;
inline constexpr auto SKILL_FISHING           = xi::SkillType::Fishing;
inline constexpr auto SKILL_WOODWORKING       = xi::SkillType::Woodworking;
inline constexpr auto SKILL_SMITHING          = xi::SkillType::Smithing;
inline constexpr auto SKILL_GOLDSMITHING      = xi::SkillType::Goldsmithing;
inline constexpr auto SKILL_CLOTHCRAFT        = xi::SkillType::Clothcraft;
inline constexpr auto SKILL_LEATHERCRAFT      = xi::SkillType::Leathercraft;
inline constexpr auto SKILL_BONECRAFT         = xi::SkillType::Bonecraft;
inline constexpr auto SKILL_ALCHEMY           = xi::SkillType::Alchemy;
inline constexpr auto SKILL_COOKING           = xi::SkillType::Cooking;
inline constexpr auto SKILL_SYNERGY           = xi::SkillType::Synergy;
inline constexpr auto SKILL_RID               = xi::SkillType::Rid;
inline constexpr auto SKILL_DIG               = xi::SkillType::Dig;
