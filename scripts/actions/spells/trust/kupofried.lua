-----------------------------------
-- Trust: Kupofried
-- Passive aura: grants EXP/CP bonus to nearby party members
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
    local mlvl = mob:getMainLvl()
    local tick_amount
    if mlvl >= 99 then
    tick_amount = 600
elseif mlvl >= 87 then
    tick_amount = 500
elseif mlvl >= 73 then
    tick_amount = 400
elseif mlvl >= 51 then
    tick_amount = 300
elseif mlvl >= 25 then
    tick_amount = 200
else
    tick_amount = 100
end

    mob:addStatusEffect(xi.effect.COLURE_ACTIVE, { power = 6, origin = mob, tick = 3, subType = xi.effect.CORSAIRS_ROLL, subPower = tick_amount, tier = xi.auraTarget.ALLIES, flag = xi.effectFlag.AURA })
    mob:setAutoAttackEnabled(false)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject