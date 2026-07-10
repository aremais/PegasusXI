-----------------------------------
-- Trust: Fablinix
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

    -- Source: Fablinix has a large MP pool, Gilfinder, Treasure Hunter I, and Triple Attack from level 55.
    mob:addMod(xi.mod.MPP, 250)
    mob:addMod(xi.mod.GILFINDER, 1)
    mob:addMod(xi.mod.TREASURE_HUNTER, 1)

    if mob:getMainLvl() >= 55 then
        mob:addMod(xi.mod.TRIPLE_ATTACK, 10)
    end

    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 45 }, { ai.c.READYING_WS, 0 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN })
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 45 }, { ai.c.READYING_MS, 0 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN })
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 45 }, { ai.c.READYING_JA, 0 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN })
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 45 }, { ai.c.CASTING_MA, 0 } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN })

    mob:addGambit(ai.t.TANK, { ai.c.HPP_LT, 75 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 50 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })
    mob:addGambit(ai.t.PARTY, { { ai.c.LVL_GTE, 8 }, { ai.c.STATUS, xi.effect.SLEEP_I } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE })
    mob:addGambit(ai.t.PARTY, { { ai.c.LVL_GTE, 8 }, { ai.c.STATUS, xi.effect.SLEEP_II } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE })

    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 27 }, { ai.c.NOT_STATUS, xi.effect.ENWATER } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ENWATER })

    -- Source says Fablinix occasionally uses crossbow/ranged attacks; no separate source level gate documented.
    mob:addGambit(ai.t.TARGET, { ai.c.RANDOM, 50 }, { ai.r.RATTACK, 0, 0 }, 30)

    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.HIGHEST, 1500)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
