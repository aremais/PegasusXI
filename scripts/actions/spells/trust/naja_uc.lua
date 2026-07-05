-----------------------------------
-- Trust: Naja Salaheem (UC)
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.NAJA_SALAHEEM)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Source notes: high TP gain, Double Attack, Triple Attack, and one WS selected at summon.
    -- HELD: Retail selects one WS on summon and uses it exclusively.
    -- Approximation: current Trust TP settings do not expose a clean per-summon random WS lock,
    -- so this uses random ASAP WS from the UC-specific list.
    mob:addMod(xi.mod.DOUBLE_ATTACK, 10)
    mob:addMod(xi.mod.TRIPLE_ATTACK, 5)
    mob:addMod(xi.mod.STORETP, 10)

    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
