-----------------------------------
-- Trust: Arciela
-----------------------------------
---@type TSpellTrust
local spellObject = {}

local bellatrixOfLight   = 3115
local bellatrixOfShadows = 3116
local dynasticGravitas   = 3451
local guidingLight       = 3453

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.ARCIELA_II)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MELEE)

    mob:addMod(xi.mod.REGAIN, 25)

    -- Enhancing magic
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.REFRESH }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.REFRESH_II })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.REFRESH }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.REFRESH })

    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.HASTE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.HASTE_II })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.HASTE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.HASTE })

    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PROTECT_V })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PROTECT_IV })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PROTECT_III })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PROTECT_II })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PROTECT })

    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SHELL_V })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SHELL_IV })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SHELL_III })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SHELL_II })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SHELL })

    -- Enfeebling magic
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.SLOW }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SLOW_II })
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.SLOW }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SLOW })

    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.PARALYSIS }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PARALYZE_II })
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.PARALYSIS }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PARALYZE })

    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.ADDLE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ADDLE })

    -- Unique Arciela mob skills
    mob:addGambit(ai.t.SELF, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, bellatrixOfLight })
    mob:addGambit(ai.t.SELF, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, bellatrixOfShadows })
    mob:addGambit(ai.t.SELF, { ai.c.TP_GTE, 1000 }, { ai.r.MS, ai.s.SPECIFIC, guidingLight })
    mob:addGambit(ai.t.SELF, { ai.c.TP_GTE, 2000 }, { ai.r.MS, ai.s.SPECIFIC, dynasticGravitas })
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
