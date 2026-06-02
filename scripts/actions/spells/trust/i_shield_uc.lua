-----------------------------------
-- Trust: Invincible Shield UC
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

    -- Invincible Shield (UC): WAR/COR melee attacker.
    -- Retail/wiki-confirmed abilities include Provoke, Warcry, Retaliation,
    -- Tomahawk, Restraint, and Blood Rage.
    if lvl >= 5 then
        mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE })
    end
    if lvl >= 77 then
        mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.RESTRAINT })
    end
    if lvl >= 60 then
        mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.RETALIATION })
    end
    if lvl >= 35 then
        mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.WARCRY })
    end
    if lvl >= 87 then
        mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.BLOOD_RAGE })
    end

    -- Tomahawk is retail-used conditionally on certain monster types.
    -- Do not add a generic always-use gambit until family/type targeting is verified.

    -- Holds TP above 1000 to close skillchains; BG notes up to 1500 TP.
    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.RANDOM, 1500)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
