-----------------------------------
-- Trust: Mnejing
-----------------------------------
require('scripts/globals/trust')
require('scripts/globals/ai')

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

    mob:setMobMod(xi.mobMod.CAN_SHIELD_BLOCK, 1)
    mob:setMod(xi.mod.SHIELD_MASTERY_TP, 30)
    mob:setMod(xi.mod.SHIELDBLOCKRATE, 45)
    mob:addMod(xi.mod.DMG, -37)
    mob:addMod(xi.mod.HPP, -10)
    mob:addMod(xi.mod.ENMITY, 30)

    -- Tank basics
    mob:addGambit(ai.t.TARGET,
        { ai.c.ALWAYS, 0 },
        { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE },
        30
    )

    -- Automaton tank abilities
    mob:addGambit(ai.t.SELF, { ai.c.NOT_HAS_TOP_ENMITY, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.automaton_abilities.flashbulb })
    mob:addGambit(ai.t.SELF, { ai.c.CASTING_ELE_MA_AOE, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.automaton_abilities.shield_bash })
    mob:addGambit(ai.t.TARGET, { ai.c.STATUS_FLAG, xi.effectFlag.DISPELABLE }, { ai.r.JA, ai.s.SPECIFIC, xi.automaton_abilities.disruptor })
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
