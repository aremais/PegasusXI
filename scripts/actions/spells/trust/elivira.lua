-----------------------------------
-- Trust: Elivira
-- RNG/WAR
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

local function safeAddGambit(mob, t, cond, react, cooldown)
    if not (mob and t and cond and react) then
        return
    end

    local c1, c2 = cond[1], cond[2]
    local r1, r2, r3 = react[1], react[2], react[3]

    if c1 == nil or c2 == nil or r1 == nil or r2 == nil or r3 == nil then
        return
    end

    if cooldown ~= nil then
        mob:addGambit(t, cond, react, cooldown)
    else
        mob:addGambit(t, cond, react)
    end
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Retail note:
    -- Elivira holds position when engaging and does not move in or out.
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.NO_MOVE)

    -- WAR subjob: Berserk
    safeAddGambit(mob,
        ai.t.SELF,
        { ai.c.NOT_STATUS, xi.effect.BERSERK },
        { ai.r.JA, ai.s.SPECIFIC, xi.ja.BERSERK },
        180
    )

    -- RNG abilities
    safeAddGambit(mob,
        ai.t.SELF,
        { ai.c.NOT_STATUS, xi.effect.BARRAGE },
        { ai.r.JA, ai.s.SPECIFIC, xi.ja.BARRAGE },
        300
    )

    safeAddGambit(mob,
        ai.t.TARGET,
        { ai.c.ALWAYS, 0 },
        { ai.r.JA, ai.s.SPECIFIC, xi.ja.DOUBLE_SHOT },
        300
    )

    safeAddGambit(mob,
        ai.t.TARGET,
        { ai.c.ALWAYS, 0 },
        { ai.r.JA, ai.s.SPECIFIC, xi.ja.DECOY_SHOT },
        180
    )

    -- Ranged attack as much as possible while still allowing melee when already in range.
    safeAddGambit(mob,
        ai.t.TARGET,
        { ai.c.ALWAYS, 0 },
        { ai.r.RATTACK, 0, 0 },
        10
    )

    -- Retail special feature: Store TP-30.
    mob:addMod(xi.mod.STORETP, -30)

    -- Marksmanship WS priority.
    -- DB skill list 1056 must contain these WS IDs.
    safeAddGambit(mob,
        ai.t.TARGET,
        { ai.c.TP_GTE, 1000 },
        { ai.r.WS, ai.s.SPECIFIC, xi.weaponskill.CORONACH },
        6
    )

    safeAddGambit(mob,
        ai.t.TARGET,
        { ai.c.TP_GTE, 1000 },
        { ai.r.WS, ai.s.SPECIFIC, xi.weaponskill.SLUG_SHOT },
        6
    )

    safeAddGambit(mob,
        ai.t.TARGET,
        { ai.c.TP_GTE, 1000 },
        { ai.r.WS, ai.s.SPECIFIC, xi.weaponskill.HEAVY_SHOT },
        6
    )

    safeAddGambit(mob,
        ai.t.TARGET,
        { ai.c.TP_GTE, 1000 },
        { ai.r.WS, ai.s.SPECIFIC, xi.weaponskill.SPLIT_SHOT },
        6
    )
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
