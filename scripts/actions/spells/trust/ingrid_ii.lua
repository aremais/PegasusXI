-----------------------------------
-- Trust: Ingrid II
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.INGRID)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    local lvl = mob:getMainLvl()

    -- Ingrid II holds TP to close skillchains, up to 2500 TP.
    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.HIGHEST, 2500)
    mob:addMod(xi.mod.UNDEAD_KILLER, 8)

    -- Wiki-confirmed: casts Cursna, but does not act as a healer.
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.DOOM }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURSNA })

    -- Wiki-confirmed: only casts spells to Magic Burst using the Banish line.
    if lvl >= 65 then
        mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.BANISH_III })
    elseif lvl >= 30 then
        mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.BANISH_II })
    elseif lvl >= 5 then
        mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.BANISH })
    end
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
