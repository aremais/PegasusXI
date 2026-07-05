-----------------------------------
-- Trust: Romaa Mihgo
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
    -- Source notes: THF/WAR. No spells.
    -- JA: Steal/Aura Steal behavior, Sneak Attack, Trick Attack, Feint.
    -- WS: Fast Blade, Vorpal Blade, Savage Blade, Cobra Clamp.
    -- Retail note: uses TP as soon as it is available.
    -- Held note: this branch does not have a safe Trust positional gambit for SA/TA.

    xi.trust.teamworkMessage(mob, {
        [xi.magic.spell.NANAA_MIHGO] = xi.trust.messageOffset.TEAMWORK_1,
        [xi.magic.spell.LEHKO_HABHOKA] = xi.trust.messageOffset.TEAMWORK_2,
    })

    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.STEAL }, 300)
    mob:addGambit(ai.t.SELF, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SNEAK_ATTACK }, 60)
    mob:addGambit(ai.t.SELF, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.TRICK_ATTACK }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.FEINT }, 120)

    mob:addGambit(ai.t.SELF, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.HIGHEST, 0 })
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
