-----------------------------------
-- Trust: Flaviria UC
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

    if mob:getMainLvl() >= 50 then
        mob:addMod(xi.mod.DOUBLE_ATTACK, 10)
    end
    -- LAX_FLAVIRIA_UC_RETAIL_BLOCK_START
    -- Retail target: DRG/WAR melee Trust. No spells. Uses WS at 1000 TP and does not try to skillchain.
    -- Super Jump is only used when Flaviria has top enmity.

    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 30 }, { ai.c.NOT_STATUS, xi.effect.BERSERK } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.BERSERK })

    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 10 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.JUMP })
    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 35 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.HIGH_JUMP })
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 50 }, { ai.c.HAS_TOP_ENMITY, 0 } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SUPER_JUMP })
    mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 75 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.ANGON })

    -- Highest-level WS first so Flaviria upgrades cleanly as she levels.
    -- Celidon's Torment 3500 currently displays but does not dispatch Lua on this branch, so use Camlann's Torment as the working retail approximation.
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 50 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 124 }) -- Celidon's Torment fallback
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 25 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 120 }) -- Impulse Drive
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 5 }, { ai.c.TP_GTE, 1000 } }, { ai.r.WS, ai.s.SPECIFIC, 118 }) -- Skewer
    -- LAX_FLAVIRIA_UC_RETAIL_BLOCK_END
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
