-----------------------------------
-- Trust: Iron Eater
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
    xi.trust.teamworkMessage(mob, {
        [xi.magic.spell.NAJI] = xi.trust.messageOffset.TEAMWORK_1,
    })

    local lvl = mob:getMainLvl()

    if lvl >= 5 then
        mob:addGambit(ai.t.MASTER, { ai.c.HPP_LT, 50 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE })
    end
    if lvl >= 15 then
        mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 },      { ai.r.JA, ai.s.SPECIFIC, xi.ja.BERSERK })
    end
    if lvl >= 77 then
        mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 },      { ai.r.JA, ai.s.SPECIFIC, xi.ja.RESTRAINT })
    end

    -- Uses existing DB skill list 1032: Shield Break, Armor Break, Steel Cyclone.
    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.RANDOM, 1500)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
