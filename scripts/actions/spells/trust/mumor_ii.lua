-----------------------------------
-- Trust: Mumor II
-----------------------------------
require('scripts/globals/trust')
require('scripts/globals/gambits')

---@type TSpellTrust
local spellObject = {}

local ws =
{
    SHINING_SUMMER_SAMBA  = 3637,
    LOVELY_MIRACLE_WALTZ  = 3638,
    NEO_CRYSTAL_JIG       = 3639,
    SUPER_CRUSHER_JIG     = 3640,
    ETERNAL_VANA_ILLUSION = 3641,
    FINAL_ETERNAL_HEART   = 3642,
    FIRESDAY_NIGHT_FEVER  = 3643,
}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.MUMOR)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Retail note: Mumor II has HP+15%.
    mob:addMod(xi.mod.HPP, 15)

    -- Retail note: Mumor II fights in melee range with her wands.

    -- Stun interrupt behavior. This branch already uses these readying/casting
    -- conditions in Trust scripts, so keep the retail Stun role.
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 45 }, { ai.c.READYING_WS, 0 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN }, 20)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 45 }, { ai.c.READYING_MS, 0 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN }, 20)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 45 }, { ai.c.READYING_JA, 0 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN }, 20)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 45 }, { ai.c.CASTING_MA, 0 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN }, 20)

    -- Firesday Night Fever: low-HP recovery/aura trigger.
    mob:addGambit(ai.t.SELF, { { ai.c.HPP_LT, 50 }, { ai.c.TP_GTE, 1000 }, { ai.c.NOT_STATUS, xi.effect.MUMORS_RADIANCE } }, { ai.r.WS, ai.s.SPECIFIC, ws.FIRESDAY_NIGHT_FEVER }, 300)

    -- Retail note: Mumor II should only cast -ja spells during magic bursts while
    -- Firesday aura is active. This branch does not have a proven mixed SELF aura
    -- + TARGET magic-burst gambit, so free nuking is disabled and aura-only MB is
    -- held as a known approximation.

    -- Firesday aura WS chain:
    -- Neo Crystal Jig -> Super Crusher Jig -> Eternal Vana Illusion -> Final Eternal Heart.
    -- The order is enforced inside each mobskill with MUMOR_II_FEVER_STEP local vars.
    mob:addGambit(ai.t.SELF, { { ai.c.STATUS, xi.effect.MUMORS_RADIANCE }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, ws.NEO_CRYSTAL_JIG })
    mob:addGambit(ai.t.SELF, { { ai.c.STATUS, xi.effect.MUMORS_RADIANCE }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, ws.SUPER_CRUSHER_JIG })
    mob:addGambit(ai.t.SELF, { { ai.c.STATUS, xi.effect.MUMORS_RADIANCE }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, ws.ETERNAL_VANA_ILLUSION })
    mob:addGambit(ai.t.SELF, { { ai.c.STATUS, xi.effect.MUMORS_RADIANCE }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, ws.FINAL_ETERNAL_HEART })

    mob:setMobMod(xi.mobMod.SKILL_LIST, 1130)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
