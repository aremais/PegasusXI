-----------------------------------
-- Trust: Maximilian
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

    -- Retail/source notes: THF/NIN sword dual-wielder with Treasure Hunter I,
    -- Dual Wield, Triple Attack, and Fast/Vorpal/Swift Blade.
    mob:addMod(xi.mod.TREASURE_HUNTER, 1)
    mob:addMod(xi.mod.DUAL_WIELD, 10)
    mob:addMod(xi.mod.TRIPLE_ATTACK, 5)

    -- Approximation: opens player skillchains with a random WS.
    -- Retail also closes if possible; current Trust TP settings do not provide
    -- a clean opener+closer combination.
    mob:setTrustTPSkillSettings(ai.tp.OPENER, ai.s.RANDOM)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
