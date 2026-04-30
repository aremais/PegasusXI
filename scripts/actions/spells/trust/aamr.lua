-----------------------------------
-- Trust: AAMR
-----------------------------------
---@type TSpellTrust
local spellObject = {}

local wsRampage       = 3715
local wsCalamity      = 3716
local wsHavocSpiral   = 3717
local wsCloudsplitter = 3718

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobFight = function(mob, target)
    if
        mob:getLocalVar('aamrSneakAttack') < os.time() and
        mob:getTP() >= 1000
    then
        mob:useJobAbility(xi.ja.SNEAK_ATTACK, mob)
        mob:setLocalVar('aamrSneakAttack', os.time() + 60)
    end

    if
        mob:getLocalVar('aamrTrickAttack') < os.time() and
        mob:getTP() >= 1000
    then
        mob:useJobAbility(xi.ja.TRICK_ATTACK, mob)
        mob:setLocalVar('aamrTrickAttack', os.time() + 60)
    end
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    mob:addSimpleGambit(ai.t.TARGET, ai.c.TP_GTE, 3000, ai.r.WS, wsHavocSpiral, ai.s.TARGET)
    mob:addSimpleGambit(ai.t.TARGET, ai.c.TP_GTE, 2000, ai.r.WS, wsCloudsplitter, ai.s.TARGET)
    mob:addSimpleGambit(ai.t.TARGET, ai.c.TP_GTE, 1500, ai.r.WS, wsRampage, ai.s.TARGET)
    mob:addSimpleGambit(ai.t.TARGET, ai.c.TP_GTE, 1000, ai.r.WS, wsCalamity, ai.s.TARGET)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
