-----------------------------------
-- Trust: Iroha II
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.IROHA)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    local lvl = mob:getMainLvl()

    -- Iroha II: SAM/WHM melee skillchain closer with Flare II magic burst.
    -- Retail/wiki-confirmed abilities: Third Eye, Hasso, Meditate.
    if lvl >= 25 then
        mob:addGambit(ai.t.SELF, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.HASSO })
    end
    if lvl >= 15 then
        mob:addGambit(ai.t.SELF, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.THIRD_EYE })
    end
    if lvl >= 30 then
        mob:addGambit(ai.t.SELF, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.MEDITATE })
    end

    -- Retail/wiki: casts Protectra V, Shellra V, and magic bursts with Flare II.
    mob:addGambit(ai.t.PARTY,  { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PROTECTRA_V })
    mob:addGambit(ai.t.PARTY,  { ai.c.NOT_STATUS, xi.effect.SHELL },   { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SHELLRA_V })
    mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 },               { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.FLARE_II }, 60)

    -- Holds TP to close skillchains.
    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.RANDOM, 2500)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
