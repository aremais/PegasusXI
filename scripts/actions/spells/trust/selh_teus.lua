-----------------------------------
-- Trust: Selh'teus
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

    -- Source notes: MP+100%, 50 Regain, Rejuvenation when a player
    -- drops to yellow HP or is asleep, and holds TP until 3000 to close SC.
    mob:addMod(xi.mod.MPP, 100)
    mob:addMod(xi.mod.REGAIN, 50)

    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 75 }, { ai.r.MS, ai.s.SPECIFIC, 1509 }, 30)
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.SLEEP_I }, { ai.r.MS, ai.s.SPECIFIC, 1509 }, 30)
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.SLEEP_II }, { ai.r.MS, ai.s.SPECIFIC, 1509 }, 30)

    -- Approximation: retail behavior specifically responds to the player/master,
    -- but party targeting is safer with current gambit helpers.
    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.HIGHEST, 3000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
