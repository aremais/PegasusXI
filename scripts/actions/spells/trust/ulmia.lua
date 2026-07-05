-----------------------------------
-- Trust: Ulmia
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
    xi.trust.teamworkMessage(mob, {
        [xi.magic.spell.PRISHE] = xi.trust.messageOffset.TEAMWORK_1,
        [xi.magic.spell.MILDAURION] = xi.trust.messageOffset.TEAMWORK_2,
    })

    local spellFamily = xi.magic.spellFamily
    local familyMinne = spellFamily.KNIGHTS_MINNE or spellFamily.KNIGHT_MINNE or spellFamily.MINNE or 107

    -- Ulmia: non-engaging BRD/BRD support Trust.
    -- Retail intent:
    --   Ballad for casters / MP pressure.
    --   March + Madrigal as default melee support.
    --   Prelude for ranged attackers.
    --   Minuet as lower-priority offensive fallback.
    --   Minne as lowest-priority defensive fallback.
    --   Scherzo for danger/Weakness approximation.
    --
    -- Full retail MP-consumption tracking, two-song recast timing, and
    -- Pianissimo -> single-target song sequencing are not branch-safe here,
    -- so this uses conservative table-form gambits only.

    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 25 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SENTINELS_SCHERZO }, 30)
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.WEAKNESS }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SENTINELS_SCHERZO }, 30)

    mob:addGambit(ai.t.CASTER, { ai.c.NOT_STATUS, xi.effect.BALLAD }, { ai.r.MA, ai.s.HIGHEST, spellFamily.MAGES_BALLAD })
    mob:addGambit(ai.t.PARTY,  { ai.c.NOT_STATUS, xi.effect.MARCH }, { ai.r.MA, ai.s.HIGHEST, spellFamily.MARCH })
    mob:addGambit(ai.t.PARTY,  { ai.c.NOT_STATUS, xi.effect.MADRIGAL }, { ai.r.MA, ai.s.HIGHEST, spellFamily.MADRIGAL })
    mob:addGambit(ai.t.RANGED, { ai.c.NOT_STATUS, xi.effect.PRELUDE }, { ai.r.MA, ai.s.HIGHEST, spellFamily.PRELUDE })

    -- Lower-priority fallback from Ulmia's retail song set.
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.MINUET }, { ai.r.MA, ai.s.HIGHEST, spellFamily.VALOR_MINUET }, 60)
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.MINNE }, { ai.r.MA, ai.s.HIGHEST, familyMinne }, 125)

    mob:setAutoAttackEnabled(false)

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MID_RANGE)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
