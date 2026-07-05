-----------------------------------
-- Trust: Robel-Akbel
-----------------------------------
require('scripts/globals/trust')
require('scripts/globals/gambits')

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

    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 45 }, { ai.c.READYING_WS, 0 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN }, 20)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 45 }, { ai.c.READYING_MS, 0 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN }, 20)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 45 }, { ai.c.READYING_JA, 0 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN }, 20)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 45 }, { ai.c.CASTING_MA, 0 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN }, 20)

    mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 }, { ai.r.MA, ai.s.MB_ELEMENT, xi.magic.spellFamily.NONE })
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_SC_AVAILABLE, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.NONE }, 60)

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.NO_MOVE)

    mob:setMobMod(xi.mobMod.SKILL_LIST, 1092)
    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
