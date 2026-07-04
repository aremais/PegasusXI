-----------------------------------
-- Trust: Darrcuiln
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

    -- Darrcuiln is a beast melee Trust with a large HP pool, Lizard Killer,
    -- low evasion, and strong auto-regen noted by retail/wiki sources.
    mob:addMod(xi.mod.HPP, 42)
    mob:addMod(xi.mod.LIZARD_KILLER, 8)
    mob:addMod(xi.mod.REGEN, 15)
    mob:addMod(xi.mod.EVA, -50)

    -- Darrcuiln uses five Trust-specific TP moves. Source does not document
    -- individual level unlocks, so keep them available as part of the Trust kit.
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, 3684 }, 30) -- Aurous Charge
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, 3685 }, 30) -- Howling Gust
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, 3686 }, 30) -- Righteous Rasp
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, 3687 }, 30) -- Starward Yowl
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, 3688 }, 30) -- Stalking Prey

    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM, 1000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
