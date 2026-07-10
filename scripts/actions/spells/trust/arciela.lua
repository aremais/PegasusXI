-----------------------------------
-- Trust: Arciela
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.ARCIELA_II)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Retail-aligned Arciela I enhancing behavior:
    -- FFXIclopedia/Gamer Escape: Light mode casts Protect/Shell/Haste/Refresh
    -- only on Arciela herself and her summoner, not on other Trusts or party members.
    local arcielaEnhancingTargets = { ai.t.MASTER, ai.t.SELF }

    for _, targetType in pairs(arcielaEnhancingTargets) do
        mob:addGambit(targetType, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.SPECIFIC, 511 }, 180) -- Haste II
        mob:addGambit(targetType, { ai.c.NOT_STATUS, xi.effect.HASTE }, { ai.r.MA, ai.s.SPECIFIC, 57 }) -- Haste
        mob:addGambit(targetType, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.SPECIFIC, 473 }, 180) -- Refresh II
        mob:addGambit(targetType, { ai.c.NOT_STATUS, xi.effect.REFRESH }, { ai.r.MA, ai.s.SPECIFIC, 109 }) -- Refresh
        mob:addGambit(targetType, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.SPECIFIC, 47 }) -- Protect V
        mob:addGambit(targetType, { ai.c.NOT_STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.SPECIFIC, 52 }) -- Shell V
    end

    -- Retail/wiki-oriented Arciela approximation:
    -- RDM/PLD support, MP+20% from mob_pool_mods, Regain +25,
    -- self/summoner Haste/Refresh/Protect/Shell,
    -- Shadow-side enfeebles, and explicit branch-safe TP move gambits.

    mob:addMod(xi.mod.REGAIN, 25)

    -- Arciela uses Light-mode enhancing magic only on herself and her summoner.

    -- Enfeebling behavior, corresponding to Bellatrix of Shadows mode.
    -- Arciela I has Addle/Dispel on the wiki spell list, but they must not be spammed blindly.
    local dispelStatuses = {
        xi.effect.PROTECT,
        xi.effect.SHELL,
        xi.effect.HASTE,
        xi.effect.REFRESH,
        xi.effect.REGEN,
        xi.effect.PHALANX,
        xi.effect.STONESKIN,
        xi.effect.ATTACK_BOOST,
        xi.effect.DEFENSE_BOOST,
        xi.effect.MAGIC_ATK_BOOST,
        xi.effect.MAGIC_DEF_BOOST,
    }

    for _, statusEffect in pairs(dispelStatuses) do
        mob:addGambit(ai.t.TARGET, { ai.c.STATUS, statusEffect }, { ai.r.MA, ai.s.SPECIFIC, 260 }, 30) -- Dispel
    end

    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.ADDLE }, { ai.r.MA, ai.s.SPECIFIC, 286 }, 60) -- Addle
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.SLOW }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SLOW }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.PARALYSIS }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PARALYZE }, 60)

    -- Explicit TP move usage; avoids unsupported setTrustTPSkillSettings().
    -- 3452 Illustrious Aid: AoE healing when party members are in yellow HP.
    -- 3451 Dynastic Gravitas: AoE Amnesia.
    -- 3453 Guiding Light: AoE Atk/Def/M.Atk/M.Def buff.
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 75 }, { ai.r.WS, ai.s.SPECIFIC, 3452 }, 30)
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.WS, ai.s.SPECIFIC, 3451 }, 60)
    mob:addGambit(ai.t.SELF, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 3453 }, 60)

    -- Arciela is documented as mostly stationary/supportive, but MID_RANGE is
    -- the safer branch approximation because it lets her inch into cast range.
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MID_RANGE)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
