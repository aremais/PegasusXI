-----------------------------------
-- Trust: Flaviria UC
-- Job: DRG/WAR
-- Wiki behavior:
-- Uses Jump, High Jump, Super Jump, and Berserk.
-- Uses Skewer, Impulse Drive, and Camlann/Celidon's Torment-style WS at 1000 TP.
-- Does not try to skillchain.
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

    -- Retail note: Flaviria UC is an aggressive physical DD.
    -- Keep this modest so it does not destabilize general Trust balance.
    mob:addMod(xi.mod.ACC, 25)
    mob:addMod(xi.mod.ATTP, 15)

    -- DRG/WAR abilities.
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.BERSERK }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.BERSERK })

    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.JUMP })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.HIGH_JUMP })

    -- Retail behavior says Super Jump is available. Use it conservatively,
    -- matching common DRG Trust behavior: shed hate only if she has top enmity.
    mob:addGambit(ai.t.SELF, { ai.c.HAS_TOP_ENMITY, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SUPER_JUMP })

    -- Uses WS at 1000 TP and does not try to skillchain.
    -- Actual available WS are controlled by sql/mob_skill_lists.sql list 1072.
    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.HIGHEST, 1000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
