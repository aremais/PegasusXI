-----------------------------------
-- Trust: Mayakov
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

    local lvl = mob:getMainLvl()

    -- Mayakov: DNC-style attacker.
    -- Retail/wiki-confirmed abilities: Saber Dance, Drain Samba, Haste Samba, Climactic Flourish, Feather Step.
    if lvl >= 75 then
        mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SABER_DANCE })
    end
    if lvl >= 5 then
        mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.DRAIN_SAMBA })
    end
    if lvl >= 45 then
        mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.HASTE_SAMBA })
    end
    if lvl >= 80 then
        mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.CLIMACTIC_FLOURISH })
    end
    if lvl >= 83 then
        mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.FEATHER_STEP })
    end

    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.RANDOM, 1500)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
