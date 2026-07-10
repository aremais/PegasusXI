-----------------------------------
-- Trust: Excenmille
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.EXCENMILLE_S)
end

spellObject.onSpellCast = function(caster, target, spell)
    local sandoriaFirstTrust = caster:getCharVar('SandoriaFirstTrust')
    local zone = caster:getZoneID()

    if
        sandoriaFirstTrust == 1 and
        (zone == xi.zone.WEST_RONFAURE or zone == xi.zone.EAST_RONFAURE)
    then
        caster:setCharVar('SandoriaFirstTrust', 2)
    end

    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.teamworkMessage(mob, {
        [xi.magic.spell.RAHAL] = xi.trust.messageOffset.TEAMWORK_1,
    })

    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 30 }, { ai.c.NOT_STATUS, xi.effect.SENTINEL } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SENTINEL })

    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.FLASH }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.FLASH })

    -- Retail behavior: cures orange HP normally. The special <75% threshold
    -- when no WHM is present is held because current gambits do not expose
    -- a safe party-composition condition.
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 50 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })

    mob:addMod(xi.mod.STORETP, 25)
    mob:addMod(xi.mod.UNDEAD_KILLER, 8)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
