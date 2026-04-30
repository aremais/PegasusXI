-----------------------------------
-- Trust: AAMR
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobFight = function(mob, target)
    if
        mob:getLocalVar('aamrSneakAttack') < GetSystemTime() and
        mob:getTP() >= 1000
    then
        mob:useJobAbility(xi.ja.SNEAK_ATTACK, mob)
        mob:setLocalVar('aamrSneakAttack', GetSystemTime() + 60)
    end

    if
        mob:getLocalVar('aamrTrickAttack') < GetSystemTime() and
        mob:getTP() >= 1000
    then
        mob:useJobAbility(xi.ja.TRICK_ATTACK, mob)
        mob:setLocalVar('aamrTrickAttack', GetSystemTime() + 60)
    end
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
