-----------------------------------
-- Trust: Babban
-- MNK/MNK
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

local isWearingMandragoraGear = function(player)
    if player == nil then
        return false
    end

    local wearingHead = player:getEquipID(xi.slot.HEAD) == 26705 or player:getEquipID(xi.slot.HEAD) == 26706 -- Mandragora Masque or Masque + 1
    local wearingBody = player:getEquipID(xi.slot.BODY) == 27854 or player:getEquipID(xi.slot.BODY) == 27855 -- Mandragora Suit or Suit + 1

    return wearingHead and wearingBody
end

spellObject.onMobSpawn = function(mob)
    local master = mob:getMaster()

    if isWearingMandragoraGear(master) then
        xi.trust.message(mob, xi.trust.messageOffset.SPAWN)
    end

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MELEE)
    mob:setMobMod(xi.mobMod.SKILL_LIST, 1073)

    -- Petal Pirouette resets target TP. Check this before basic TP moves.
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1500 }, { ai.r.MS, ai.s.SPECIFIC, 3353 }, 30)

    -- Offensive mob skills.
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, 3354 }, 16) -- Head Butt
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, 3351 }, 18) -- Wild Oats
end

spellObject.onMobDespawn = function(mob)
    local master = mob:getMaster()

    if isWearingMandragoraGear(master) then
        xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
    end
end

spellObject.onMobDeath = function(mob)
    local master = mob:getMaster()

    if isWearingMandragoraGear(master) then
        xi.trust.message(mob, xi.trust.messageOffset.DEATH)
    end
end

return spellObject
