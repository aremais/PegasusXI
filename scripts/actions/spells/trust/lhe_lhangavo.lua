-----------------------------------
-- Trust: Lhe Lhangavo
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

    -- Lhe Lhangavo: MNK/WAR.
    if lvl >= 15 then
        mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 },  { ai.r.JA, ai.s.SPECIFIC, xi.ja.DODGE })
    end
    if lvl >= 25 then
        mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 },  { ai.r.JA, ai.s.SPECIFIC, xi.ja.FOCUS })
    end
    if lvl >= 88 then
        mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 },  { ai.r.JA, ai.s.SPECIFIC, xi.ja.IMPETUS })
    end
    if lvl >= 75 then
        mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 },  { ai.r.JA, ai.s.SPECIFIC, xi.ja.FORMLESS_STRIKES })
    end
    if lvl >= 35 then
        mob:addGambit(ai.t.SELF,   { ai.c.HPP_LT, 50 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.CHAKRA })
    end
    if lvl >= 5 then
        mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },  { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE })
    end

    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.RANDOM, 3000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
