-----------------------------------
-- Trust: Mnejing
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Tank basics
    mob:addGambit(ai.t.SELF, { ai.c.NOT_HAS_TOP_ENMITY, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE })

    -- Enmity spell
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.FLASH }, { ai.r.MA, ai.s.SPECIFIC, 112 }) -- Flash

    -- Self buffs (spell ids from spellList 1041)
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.PROTECT },   { ai.r.MA, ai.s.SPECIFIC, 46 })  -- Protect IV
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SHELL },     { ai.r.MA, ai.s.SPECIFIC, 51 })  -- Shell IV
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.STONESKIN }, { ai.r.MA, ai.s.SPECIFIC, 54 })  -- Stoneskin
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.PHALANX },   { ai.r.MA, ai.s.SPECIFIC, 106 }) -- Phalanx
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.REGEN },     { ai.r.MA, ai.s.SPECIFIC, 477 }) -- Regen IV

    -- Cures
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 50 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })

    -- Spend TP (AAEV WS set you copied into skill_list_id 1041)
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 2000 }, { ai.r.WS, ai.s.SPECIFIC, 3710 }) -- arrogance_incarnate
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 3713 }) -- chant_du_cygne
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 3712 }) -- dominion_slash
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 3711 }) -- vorpal_blade

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MELEE)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject