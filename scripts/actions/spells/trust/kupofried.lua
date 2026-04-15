-- Trust: Kupofried
-- Passive geo-style aura: applies EXP/CP bonus to nearby party members
-- Mirrors retail geo_dedication behavior using xi.effect.DEDICATION
-----------------------------------

---@type TSpellTrust
local spellObject = {}

local auraRange = 10 -- yalms, matches retail Indi-spell range
local expBonus  = 20 -- retail Kupofried gives ~20% bonus
local tickRate  = 3  -- seconds between proximity checks

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)

    local owner = mob:getMaster()

    if not owner then
        return
    end

    local members = owner:getParty()

    if members then
        for _, member in pairs(members) do
            if member and member:isPC() then
                if member:hasStatusEffect(xi.effect.DEDICATION) then
                    local effect = member:getStatusEffect(xi.effect.DEDICATION)

                    if effect and effect:getSubType() == 1 then
                        member:delStatusEffect(xi.effect.DEDICATION)
                    end
                end
            end
        end
    end
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

spellObject.onMobFight = function(mob, target)
end

spellObject.onMobRoam = function(mob)
    local owner = mob:getMaster()

    if not owner then
        return
    end

    local members = owner:getParty()

    if not members then
        members = { owner }
    end

    for _, member in pairs(members) do
        if member and member:isPC() then
            if mob:checkDistance(member) <= auraRange then
                if not member:hasStatusEffect(xi.effect.DEDICATION) then
                    local effect = member:addStatusEffect(xi.effect.DEDICATION, expBonus, tickRate, 0)

                    if effect then
                        effect:setSubType(1)
                    end
                end
            else
                if member:hasStatusEffect(xi.effect.DEDICATION) then
                    local effect = member:getStatusEffect(xi.effect.DEDICATION)

                    if effect and effect:getSubType() == 1 then
                        member:delStatusEffect(xi.effect.DEDICATION)
                    end
                end
            end
        end
    end
end

return spellObject
