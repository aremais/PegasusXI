-----------------------------------
-- Trust: Abenzio
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

    -- Abenzio is a MNK/WAR Mandragora-style melee Trust.
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MELEE)
    mob:setAutoAttackEnabled(true)

    -- Mob skills from TRUST_Abenzio skill list 1074.
    local blow      = 581
    local uppercut  = 584
    local blankGaze = 586
    local antiphase = 587

    -- Damage/stun-style attacks.
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, uppercut }, 30)
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, blow }, 30)

    -- Gaze utility. Do not spam if the target is already paralyzed.
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.PARALYSIS }, { ai.r.MS, ai.s.SPECIFIC, blankGaze }, 90)

    -- AoE silence. Do not spam if the target is already silenced.
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.SILENCE }, { ai.r.MS, ai.s.SPECIFIC, antiphase }, 120)
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
