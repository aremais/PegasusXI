-----------------------------------
-- Trust: Darrcuiln
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

    -----------------------------------
    -- Retail-inspired passive behavior
    -- Darrcuiln is a WAR/RDM "Beast" Trust with a large HP pool.
    -- Retail notes place his HP bonus at approximately +42%.
    -----------------------------------
    mob:addMod(xi.mod.HPP, 42)

    -----------------------------------
    -- Retail-inspired TP behavior
    -- Darrcuiln uses beast TP moves and does not deliberately close SCs.
    -- His Trust pool already uses skill_list_id 1106; the DB list controls
    -- the exact available TP moves.
    -----------------------------------
    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
