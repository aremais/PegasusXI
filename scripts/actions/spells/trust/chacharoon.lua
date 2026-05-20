-----------------------------------
-- Trust: Chacharoon
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
    -- Chacharoon is a fast, low-damage THF/RNG-style Qiqirn.
    -----------------------------------
    mob:addMod(xi.mod.HPP, -10)
    mob:addMod(xi.mod.MPP, -10)
    mob:addMod(xi.mod.TRIPLE_ATTACK, 10)
    mob:addMod(xi.mod.ATT, -10)

    -----------------------------------
    -- Ranged attack behavior
    -- Retail notes describe occasional ranged attacks.
    -----------------------------------
    mob:addGambit(ai.t.TARGET,
        { ai.c.RANDOM, 25 },
        { ai.r.RATTACK, 0, 0 },
        30
    )

    -----------------------------------
    -- Chacharoon unique TP moves
    -----------------------------------
    local pocketSand = 3440
    local tripeGripe = 3441
    local sharpEye   = 3442

    mob:addGambit(ai.t.TARGET,
        { ai.c.TP_GTE, 1000 },
        { ai.r.MS, ai.s.SPECIFIC, pocketSand },
        30
    )

    mob:addGambit(ai.t.TARGET,
        { ai.c.TP_GTE, 1250 },
        { ai.r.MS, ai.s.SPECIFIC, tripeGripe },
        45
    )

    mob:addGambit(ai.t.TARGET,
        { ai.c.TP_GTE, 1500 },
        { ai.r.MS, ai.s.SPECIFIC, sharpEye },
        45
    )

    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
