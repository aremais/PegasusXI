-- Trust: Aldo
-- THF/NIN (gambits-first)
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.ALDO_UC)
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

    -- Shadows
    safeAddGambit(mob, ai.t.SELF,
        { ai.c.NOT_STATUS, xi.effect.COPY_IMAGE },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.UTSUSEMI },
        15
    )

    -- Enfeebles
    safeAddGambit(mob, ai.t.TARGET,
        { ai.c.NOT_STATUS, xi.effect.BLINDNESS },
        { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.KURAYAMI_ICHI },
        25
    )

    safeAddGambit(mob, ai.t.TARGET,
        { ai.c.NOT_STATUS, xi.effect.SLOW },
        { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.HOJO_ICHI },
        25
    )

    safeAddGambit(mob, ai.t.TARGET,
        { ai.c.NOT_STATUS, xi.effect.PARALYSIS },
        { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.JUBAKU_ICHI },
        30
    )

    safeAddGambit(mob, ai.t.TARGET,
        { ai.c.NOT_STATUS, xi.effect.POISON },
        { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.DOKUMORI_ICHI },
        35
    )

    -- Elemental wheel
    safeAddGambit(mob, ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.KATON_ICHI }, 25)
    safeAddGambit(mob, ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.HYOTON_ICHI }, 25)
    safeAddGambit(mob, ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.HUTON_ICHI }, 25)
    safeAddGambit(mob, ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.DOTON_ICHI }, 25)
    safeAddGambit(mob, ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.RAITON_ICHI }, 25)
    safeAddGambit(mob, ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SUITON_ICHI }, 25)

    -- THF JAs
    safeAddGambit(mob, ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SNEAK_ATTACK }, 60)
    safeAddGambit(mob, ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.ASSASSINS_CHARGE }, 180)
    safeAddGambit(mob, ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.BULLY }, 180)

    -- WS
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
