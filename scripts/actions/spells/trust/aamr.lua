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

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MELEE)

    -- THF JAs
    safeAddGambit(mob, ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SNEAK_ATTACK }, 60)
    safeAddGambit(mob, ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.TRICK_ATTACK }, 60)

    -- WS are DB-driven through mob_skill_lists skill_list_id 1109.
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
