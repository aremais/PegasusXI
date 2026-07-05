-----------------------------------
-- Trust: Excenmille S
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    local trustSpell = xi.magic.spell.EXCENMILLE_S or xi.magic.spell.EXCENMILLE
    return xi.trust.canCast(caster, spell, trustSpell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Excenmille (S) has Regain and uses unique TP moves at 1000 TP.
    mob:addMod(xi.mod.REGAIN, 50)

    -- Stag's Call is an ally-targeted AoE buff in mob_skills.sql.
    mob:addGambit(ai.t.SELF, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 3291 }, 300) -- Stag's Call

    -- Unique offensive TP moves.
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 3292 }, 10) -- Gyre Strike
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 3293 }, 10) -- Stag's Charge
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 3294 }, 10) -- Orcsbane
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 3295 }, 10) -- Songbird Swoop
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
