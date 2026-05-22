-----------------------------------
-- Trust: D. Shantotto / Domina Shantotto
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

    -- Retail target:
    -- BLM/DRK scythe attacker.
    -- Starts fights with high-tier nukes, then melees and casts occasionally.
    -- Does not try to magic burst.
    -- Only casts single-target elemental nukes I-V.

    local trustLevel  = mob:getMainLvl()
    local power       = math.floor(trustLevel / 4)
    local spellDamage = trustLevel * math.floor((trustLevel + 1) / 12)

    mob:addMod(xi.mod.MATT, power)
    mob:addMod(xi.mod.MACC, power)
    mob:addMod(xi.mod.MAGIC_DAMAGE, spellDamage)

    -- Highest available single-target elemental nuke from her DB spell list.
    -- Her DB list contains elemental nukes I-V only, with no -ga or Ancient Magic.
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_SC_AVAILABLE, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.NONE }, 30)

    -- Retail note: uses weapon skills at 1000 TP.
    -- DB skill list 1049 contains Shadow of Death, Guillotine, Cross Reaper, Salvation Scythe.
    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.HIGHEST, 1000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
