-----------------------------------
-- Trust: Aldo
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.ALDO_UC)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Aldo is a THF/NIN Trust. Sources note that he uses Sneak Attack
    -- regardless of positioning, does not intentionally combine it with WS,
    -- and uses Bully before Sneak Attack.
    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 93 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.BULLY })
    mob:addGambit(ai.t.SELF, { ai.c.LVL_GTE, 15 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SNEAK_ATTACK })
    mob:addGambit(ai.t.SELF, { ai.c.LVL_GTE, 75 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.ASSASSINS_CHARGE })

    mob:setTrustTPSkillSettings(ai.tp.OPENER_OR_CLOSER, ai.s.RANDOM, 1000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
