-----------------------------------
-- Trust: Shantotto
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.SHANTOTTO_II)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.teamworkMessage(mob, {
        [xi.magic.spell.AJIDO_MARUJIDO] = xi.trust.messageOffset.TEAMWORK_1,
        [xi.magic.spell.STAR_SIBYL] = xi.trust.messageOffset.TEAMWORK_2,
        [xi.magic.spell.KORU_MORU] = xi.trust.messageOffset.TEAMWORK_3,
        [xi.magic.spell.KING_OF_HEARTS] = xi.trust.messageOffset.TEAMWORK_4
    })

    -- Retail behavior: Shantotto stops casting while she has hate.
    -- Spell list 308 handles normal BLM level gates for elemental nukes I-V.
    mob:addGambit(ai.t.TARGET, { { ai.c.NOT_HAS_TOP_ENMITY, 0 }, { ai.c.MB_AVAILABLE, 0 } }, { ai.r.MA, ai.s.MB_ELEMENT, xi.magic.spellFamily.NONE })

    -- Default to the highest available spell, with a faster caster cadence than the old 60s fallback.
    mob:addGambit(ai.t.TARGET, { { ai.c.NOT_HAS_TOP_ENMITY, 0 }, { ai.c.NOT_SC_AVAILABLE, 0 } }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.NONE }, 10)

    local power = mob:getMainLvl() / 10
    mob:addMod(xi.mod.MATT, power)
    mob:addMod(xi.mod.MACC, power)
    mob:addMod(xi.mod.HASTE_MAGIC, 1000) -- 10% Haste (Magic)

    mob:setAutoAttackEnabled(false)

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.NO_MOVE)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
