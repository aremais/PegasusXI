-----------------------------------
-- Trust: Zazarg
-----------------------------------
require('scripts/globals/trust')
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

    -- Retail: Focuses when needed against high-evasion enemies.
    -- Branch-safe approximation: use Focus whenever available and not already active.
    -- Confirmed branch IDs: Focus JA 36, Focus effect 59.
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, 59 }, { ai.r.JA, ai.s.SPECIFIC, 36 })

    -- Retail: uses TP as soon as he gets it.
    -- Trust skill list 1039 carries Zazarg's documented WS:
    -- Howling Fist, Dragon Kick, Asuran Fists, Meteoric Impact.
    mob:addGambit(ai.t.SELF, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.HIGHEST, 0 })
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
