-----------------------------------
-- Trust: Aldo UC
-- THF/NIN
-- Uses: Sneak Attack
-- WS: Evisceration, Mercy Stroke
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.ALDO)
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

    -- Make Aldo (UC) more offense-focused
    mob:addMod(xi.mod.DOUBLE_ATTACK, 20)
    mob:addMod(xi.mod.TRIPLE_ATTACK, 10)

    -- THF JA
    -- THF JAs
    safeAddGambit(mob,
        ai.t.TARGET,
        { ai.c.ALWAYS, 0 },
        { ai.r.JA, ai.s.SPECIFIC, xi.ja.SNEAK_ATTACK },
        60
    )

    -- WS usage from DB skill_list_id 1122
    safeAddGambit(mob,
        ai.t.TARGET,
        { ai.c.TP_GTE, 1000 },
        { ai.r.WS, ai.s.HIGHEST, 0 },
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

