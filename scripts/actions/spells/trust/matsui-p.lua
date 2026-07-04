-----------------------------------
-- Trust: Matsui-P
-----------------------------------
require("scripts/globals/trust")
-----------------------------------
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Source target: NIN/BLM Trust that opens skillchains and magic bursts with ninjutsu/elemental magic.
    mob:addMod(xi.mod.DUAL_WIELD, 25)
    mob:addMod(xi.mod.DAKEN, 25)
    mob:addMod(xi.mod.MATT, 35)
    mob:addMod(xi.mod.STORETP, 20)
    mob:addMod(xi.mod.SUBTLE_BLOW, 15)

    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 12 }, { ai.c.NOT_STATUS, xi.effect.COPY_IMAGE } }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.UTSUSEMI }, 20)
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 88 }, { ai.c.NOT_STATUS, xi.effect.MIGAWARI } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.MIGAWARI_ICHI }, 120)
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 78 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.KAKKA_ICHI }, 120)
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 85 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.MYOSHU_ICHI }, 120)

    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 40 }, { ai.c.NOT_STATUS, xi.effect.INNIN } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.INNIN }, 300)
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 15 }, { ai.c.NOT_STATUS, xi.effect.ELEMENTAL_SEAL } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.ELEMENTAL_SEAL }, 600)
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 75 }, { ai.c.NOT_STATUS, xi.effect.SANGE } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SANGE }, 300)
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 77 }, { ai.c.NOT_STATUS, xi.effect.FUTAE } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.FUTAE }, 300)
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 76 }, { ai.c.NOT_STATUS, xi.effect.MANA_WALL } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.MANA_WALL }, 600)

    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 83 }, { ai.c.NOT_STATUS, xi.effect.MAGIC_DEF_DOWN } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.AISHA_ICHI }, 90)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 83 }, { ai.c.NOT_STATUS, xi.effect.ACCURACY_DOWN } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.YURIN_ICHI }, 90)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 30 }, { ai.c.NOT_STATUS, xi.effect.PARALYSIS } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.JUBAKU_ICHI }, 60)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 23 }, { ai.c.NOT_STATUS, xi.effect.SLOW } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.HOJO_ICHI }, 60)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 19 }, { ai.c.NOT_STATUS, xi.effect.BLINDNESS } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.KURAYAMI_ICHI }, 60)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 27 }, { ai.c.NOT_STATUS, xi.effect.POISON } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.DOKUMORI_ICHI }, 60)

    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 45 }, { ai.c.CASTING_MA, 0 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN }, 20)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 24 }, { ai.c.NOT_STATUS, xi.effect.BURN } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.BURN }, 90)
    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 25 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ASPIR }, 120)

    -- Elemental Ninjutsu San priority.
    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 73 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.RAITON_SAN }, 45)
    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 73 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.HUTON_SAN }, 45)
    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 73 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.KATON_SAN }, 45)
    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 73 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.HYOTON_SAN }, 45)
    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 73 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.DOTON_SAN }, 45)
    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 73 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SUITON_SAN }, 45)

    -- Tier-1 BLM elemental magic as secondary magic-burst flavor.
    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 1 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.THUNDER }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 1 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.AERO }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 1 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.FIRE }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 1 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.BLIZZARD }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 1 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STONE }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 1 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.WATER }, 60)

    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 1 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 128 }, 30) -- Blade: Rin
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 9 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 129 }, 30) -- Blade: Retsu
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 55 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 133 }, 30) -- Blade: Ei
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 60 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 134 }, 30) -- Blade: Jin
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 66 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 135 }, 30) -- Blade: Ten
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 72 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 136 }, 30) -- Blade: Ku
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 75 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 138 }, 30) -- Blade: Kamu
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 85 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 140 }, 30) -- Blade: Hi
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 91 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 141 }, 30) -- Blade: Shun

    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.HIGHEST, 2000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject