-----------------------------------
-- Trust: Klara
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

    local trustLevel = mob:getMainLvl()

    -- Retail/wiki-confirmed WAR behavior.
    if trustLevel >= 15 then
        mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.BERSERK }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.BERSERK })
    end

    if trustLevel >= 35 then
        mob:addGambit(ai.t.SELF, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.WARCRY })
    end

    -- Klara Provokes only when the summoner/master is orange HP.
    -- The condition is checked on MASTER; Provoke itself resolves onto Klara's battle target.
    if trustLevel >= 5 then
        mob:addGambit(ai.t.MASTER, { ai.c.HPP_LT, 51 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE })
    end

    -- Uses TP as soon as she gets it.
    mob:addGambit(ai.t.SELF, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.HIGHEST, 0 })
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
