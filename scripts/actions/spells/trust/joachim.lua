-----------------------------------
-- Trust: Joachim
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    -- Records of Eminence: Alter Ego: Joachim
    if caster:getEminenceProgress(937) then
        xi.roe.onRecordTrigger(caster, 937)
    end

    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Joachim: BRD/WHM support Trust.
    -- Retail-safe approximation for this branch:
    -- * no melee / no WS
    -- * no unsupported ranged-attack gambit
    -- * -na / Erase / Cure support before songs
    -- * party song support should not depend on possibly-missing song effect enums
    -- * at Lv68+, healthy/default support should include Victory March + Blade Madrigal
    -- * Elegy is enemy support and should not starve party songs

    local spellIds    = xi.magic.spell or {}
    local spellFamily = xi.magic.spellFamily or {}

    -- Numeric spell-family fallbacks are from spell_list.sql family IDs.
    local familyCure     = spellFamily.CURE or 1
    local familyPaeon    = spellFamily.ARMYS_PAEON or spellFamily.ARMY_PAEON or spellFamily.PAEON or 105
    local familyBallad   = spellFamily.MAGES_BALLAD or spellFamily.MAGE_BALLAD or spellFamily.BALLAD or 106
    local familyMinne    = spellFamily.KNIGHTS_MINNE or spellFamily.KNIGHT_MINNE or spellFamily.MINNE or 107
    local familyMinuet   = spellFamily.VALOR_MINUET or spellFamily.MINUET or 108
    local familyMadrigal = spellFamily.MADRIGAL or 109
    local familyMarch    = spellFamily.MARCH or 113
    local familyElegy    = spellFamily.ELEGY or 114

    local erase = spellIds.ERASE or 143

    local function addStatusRemoval(targetType, statusEffect, spellId)
        if statusEffect ~= nil and spellId ~= nil then
            mob:addGambit(targetType, { ai.c.STATUS, statusEffect }, { ai.r.MA, ai.s.SPECIFIC, spellId })
        end
    end

    -- Prefer NOT_STATUS when this branch exposes the song effect enum.
    -- If the enum is missing, still add the song with a long cooldown instead of skipping it entirely.
    local function addSongWithOptionalStatus(targetType, statusEffect, familyId, cooldown)
        if familyId == nil then
            return
        end

        if statusEffect ~= nil then
            mob:addGambit(targetType, { ai.c.NOT_STATUS, statusEffect }, { ai.r.MA, ai.s.HIGHEST, familyId }, cooldown)
        else
            mob:addGambit(targetType, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.HIGHEST, familyId }, cooldown)
        end
    end

    -- Status removal first.
    addStatusRemoval(ai.t.PARTY, xi.effect.POISON,        spellIds.POISONA or 14)
    addStatusRemoval(ai.t.PARTY, xi.effect.PARALYSIS,     spellIds.PARALYNA or 15)
    addStatusRemoval(ai.t.PARTY, xi.effect.BLINDNESS,     spellIds.BLINDNA or 16)
    addStatusRemoval(ai.t.PARTY, xi.effect.SILENCE,       spellIds.SILENA or 17)
    addStatusRemoval(ai.t.PARTY, xi.effect.PETRIFICATION, spellIds.STONA or 18)
    addStatusRemoval(ai.t.PARTY, xi.effect.DISEASE,       spellIds.VIRUNA or 19)
    addStatusRemoval(ai.t.PARTY, xi.effect.CURSE_I or xi.effect.CURSE, spellIds.CURSNA or 20)

    -- Erase-supported debuffs. Missing effect constants are skipped safely.
    addStatusRemoval(ai.t.PARTY, xi.effect.SLOW,               erase)
    addStatusRemoval(ai.t.PARTY, xi.effect.BIND,               erase)
    addStatusRemoval(ai.t.PARTY, xi.effect.WEIGHT,             erase)
    addStatusRemoval(ai.t.PARTY, xi.effect.ATTACK_DOWN,        erase)
    addStatusRemoval(ai.t.PARTY, xi.effect.DEFENSE_DOWN,       erase)
    addStatusRemoval(ai.t.PARTY, xi.effect.EVASION_DOWN,       erase)
    addStatusRemoval(ai.t.PARTY, xi.effect.MAGIC_ATK_DOWN,     erase)
    addStatusRemoval(ai.t.PARTY, xi.effect.MAGIC_DEF_DOWN,     erase)
    addStatusRemoval(ai.t.PARTY, xi.effect.MAGIC_ACC_DOWN,     erase)
    addStatusRemoval(ai.t.PARTY, xi.effect.MAGIC_EVASION_DOWN, erase)

    -- Cure support before songs.
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 75 }, { ai.r.MA, ai.s.HIGHEST, familyCure })

    -- Emergency/self-sustain songs.
    -- Paeon remains highest conditional song priority when Joachim is hurt.
    mob:addGambit(ai.t.SELF, { ai.c.HPP_LT, 90 }, { ai.r.MA, ai.s.HIGHEST, familyPaeon }, 125)

    -- Core default support. These must be added even if xi.effect.MARCH/MADRIGAL are nil.
    -- At Lv68 this should select Victory March and Blade Madrigal from spell list 323.
    addSongWithOptionalStatus(ai.t.SELF, xi.effect.MARCH,    familyMarch,    125)
    addSongWithOptionalStatus(ai.t.SELF, xi.effect.MADRIGAL, familyMadrigal, 125)

    -- Ballad is valid when Joachim is very low on MP, but should not be the only maintained party song.
    mob:addGambit(ai.t.SELF, { ai.c.MPP_LT, 40 }, { ai.r.MA, ai.s.HIGHEST, familyBallad }, 125)

    -- Fallbacks for when other Bard support already covers March/Madrigal or when song slots allow.
    addSongWithOptionalStatus(ai.t.SELF, xi.effect.MINUET, familyMinuet, 125)
    addSongWithOptionalStatus(ai.t.SELF, xi.effect.MINNE,  familyMinne,  125)

    -- Enemy support last so it does not compete ahead of party song setup.
    addSongWithOptionalStatus(ai.t.TARGET, xi.effect.ELEGY, familyElegy, 60)

    -- Joachim should not melee or weapon skill. His weak throwing attack is intentionally
    -- omitted because this branch does not expose a verified safe ranged-attack gambit action.
    mob:setAutoAttackEnabled(false)
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MID_RANGE)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
