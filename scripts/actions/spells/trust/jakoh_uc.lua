-----------------------------------
-- Trust: Jakoh Wahcondalo (UC)
-----------------------------------
require('scripts/globals/trust')
-----------------------------------
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.JAKOH_UC)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Jakoh Wahcondalo UC: THF/WAR dagger Unity Trust.
    -- Retail behavior target:
    -- * Opens with Feint and reuses it on cooldown.
    -- * Uses Sneak Attack, Trick Attack, Feint, and Conspirator.
    -- * Uses Dancing Edge, Evisceration, and a Rudra's Storm substitute randomly.
    -- * Uses weapon skills above 2000 TP and may hold TP while trying to position.
    --
    -- The live DB skill list already contains exactly:
    -- Dancing Edge 23, Evisceration 25, Rudra's Storm 31.
    -- Use the DB skill list with RANDOM selection instead of explicit WS gambits. Rudra's Storm is used as the branch-safe substitute for broken Sarva's Storm dispatch.

    mob:addMod(xi.mod.TRIPLE_ATTACK, 5)
    mob:addMod(xi.mod.TREASURE_HUNTER, 1)

    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.FEINT }, 120)
    mob:addGambit(ai.t.SELF, { ai.c.LVL_GTE, 15 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SNEAK_ATTACK }, 60)
    mob:addGambit(ai.t.SELF, { ai.c.LVL_GTE, 30 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.TRICK_ATTACK }, 60)
    mob:addGambit(ai.t.SELF, { ai.c.LVL_GTE, 87 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.CONSPIRATOR }, 300)

    local tpMode = ai.tp.ASAP
    if type(ai.tp.CLOSER_UNTIL_TP) == 'number' then
        tpMode = ai.tp.CLOSER_UNTIL_TP
    end

    mob:setTrustTPSkillSettings(tpMode, ai.s.RANDOM, 2000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
