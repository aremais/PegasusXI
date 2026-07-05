-----------------------------------
-- Trust: Adelheid
-----------------------------------
require('scripts/globals/trust')
require('scripts/globals/gambits')
---@type TSpellTrust
local spellObject = {}

local ws =
{
    PARALYZING_MICROTUBE = 3466,
    SILENCING_MICROTUBE  = 3467,
    BINDING_MICROTUBE    = 3468,
    TWIRLING_DERVISH    = 3469,
}

local spell =
{
    GEOHELIX    = 278,
    HYDROHELIX  = 279,
    ANEMOHELIX  = 280,
    PYROHELIX   = 281,
    CRYOHELIX   = 282,
    IONOHELIX   = 283,
    NOCTOHELIX  = 284,
    LUMINOHELIX = 285,
}

spellObject.onMagicCastingCheck = function(caster, target, spellArg)
    return xi.trust.canCast(caster, spellArg)
end

spellObject.onSpellCast = function(caster, target, spellArg)
    -- Records of Eminence: Alter Ego: Adelheid
    if caster:getEminenceProgress(936) then
        xi.roe.onRecordTrigger(caster, 936)
    end

    return xi.trust.spawn(caster, spellArg)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Retail note: Adelheid uses Dark Arts and Addendum: Black.
    -- Keep this branch-safe and avoid unsupported Addendum/Arts helper logic.
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.ADDENDUM_BLACK }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.DARK_ARTS })
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 30 }, { ai.c.NOT_STATUS, xi.effect.ADDENDUM_BLACK } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.ADDENDUM_BLACK })

    -- Cure behavior: higher tank threshold, red HP threshold for other party members.
    mob:addGambit(ai.t.TANK,  { ai.c.HPP_LT, 50 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 33 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })

    -- Branch-safe approximation of retail interrupt Stun.
    -- This branch does not safely support newer readied-action/casting gambit conditions.
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN }, 30)

    -- Branch-safe Helix application.
    -- Retail storm/day/weakness selection and SC-element MB helix selection require newer unsupported gambit selectors.
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 32 }, { ai.c.NOT_STATUS, xi.effect.HELIX } }, { ai.r.MA, ai.s.SPECIFIC, spell.LUMINOHELIX }, 60)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 30 }, { ai.c.NOT_STATUS, xi.effect.HELIX } }, { ai.r.MA, ai.s.SPECIFIC, spell.NOCTOHELIX  }, 60)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 28 }, { ai.c.NOT_STATUS, xi.effect.HELIX } }, { ai.r.MA, ai.s.SPECIFIC, spell.IONOHELIX   }, 60)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 26 }, { ai.c.NOT_STATUS, xi.effect.HELIX } }, { ai.r.MA, ai.s.SPECIFIC, spell.CRYOHELIX   }, 60)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 24 }, { ai.c.NOT_STATUS, xi.effect.HELIX } }, { ai.r.MA, ai.s.SPECIFIC, spell.PYROHELIX   }, 60)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 22 }, { ai.c.NOT_STATUS, xi.effect.HELIX } }, { ai.r.MA, ai.s.SPECIFIC, spell.ANEMOHELIX  }, 60)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 20 }, { ai.c.NOT_STATUS, xi.effect.HELIX } }, { ai.r.MA, ai.s.SPECIFIC, spell.HYDROHELIX  }, 60)
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 18 }, { ai.c.NOT_STATUS, xi.effect.HELIX } }, { ai.r.MA, ai.s.SPECIFIC, spell.GEOHELIX    }, 60)

    -- Offensive fallback. Spell list 381 already level-gates single-target elemental nukes I-V.
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.NONE }, 75)

    -- TP usage. Twirling Dervish is level 50+, Microtubes are available before that.
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 50 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, ws.TWIRLING_DERVISH }, 120)
    mob:addGambit(ai.t.SELF, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, ws.PARALYZING_MICROTUBE }, 30)
    mob:addGambit(ai.t.SELF, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, ws.SILENCING_MICROTUBE  }, 30)
    mob:addGambit(ai.t.SELF, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, ws.BINDING_MICROTUBE    }, 30)

    mob:addListener('WEAPONSKILL_USE', 'ADELHEID_WEAPONSKILL_USE', function(mobArg, target, skillArg, tp, action, damage)
        if skillArg:getID() == ws.TWIRLING_DERVISH then
            if math.random(1, 100) <= 33 then
                xi.trust.message(mobArg, xi.trust.messageOffset.SPECIAL_MOVE_1) -- You may want to cover your ears!
            end
        end
    end)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
