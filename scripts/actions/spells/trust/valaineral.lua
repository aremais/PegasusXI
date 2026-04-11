-----------------------------------
-- Trust: Valaineral (Retail Mimic - Core Safe)
-----------------------------------
---@type TSpellTrust
local spellObject = {}

-----------------------------------
-- Casting Checks
-----------------------------------
spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

-----------------------------------
-- On Cast
-----------------------------------
spellObject.onSpellCast = function(caster, target, spell)
    -- Adjust condition if your server uses a different RoE API for record 933
    local eminenceProgress = caster:getEminenceProgress(933)
    -- Some builds return nil when the player has no ROE/Eminence state yet.
    if (eminenceProgress or 0) > 0 then
        xi.roe.onRecordTrigger(caster, 933)
    end

    return xi.trust.spawn(caster, spell)
end

-----------------------------------
-- On Spawn
-----------------------------------
spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -----------------------------------
    -- Passive mods
    -----------------------------------
    mob:addMod(xi.mod.ENMITY, 30)
    mob:addMod(xi.mod.CURE_POTENCY, 50)
    mob:addMod(xi.mod.DMG, -8)
    mob:addMod(xi.mod.REFRESH, 3)
    mob:addMod(xi.mod.MPP, 20)
    mob:addMod(xi.mod.SPELLINTERRUPT, 50)

    -----------------------------------
    -- Enmity control
    -----------------------------------
    mob:addGambit(ai.t.SELF,
        { ai.c.NOT_HAS_TOP_ENMITY, 0 },
        { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE }
    )

    mob:addGambit(ai.t.SELF,
        { ai.c.NOT_STATUS, xi.effect.DIVINE_EMBLEM },
        { ai.r.JA, ai.s.SPECIFIC, xi.ja.DIVINE_EMBLEM }
    )

    mob:addGambit(ai.t.TARGET,
        { ai.c.NOT_STATUS, xi.effect.FLASH },
        { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.FLASH }
    )

    -----------------------------------
    -- Defensive logic
    -----------------------------------
    mob:addGambit(ai.t.SELF,
        { ai.c.HPP_LT, 70 },
        { ai.r.JA, ai.s.SPECIFIC, xi.ja.SENTINEL }
    )

    mob:addGambit(ai.t.TARGET,
        { ai.c.STATUS, xi.effect.CHAINSPELL },
        { ai.r.JA, ai.s.SPECIFIC, xi.ja.RAMPART }
    )
    mob:addGambit(ai.t.TARGET,
        { ai.c.STATUS, xi.effect.MANAFONT },
        { ai.r.JA, ai.s.SPECIFIC, xi.ja.RAMPART }
    )
    mob:addGambit(ai.t.TARGET,
        { ai.c.STATUS, xi.effect.ASTRAL_FLOW },
        { ai.r.JA, ai.s.SPECIFIC, xi.ja.RAMPART }
    )

    mob:addGambit(ai.t.SELF,
        { ai.c.HPP_LT, 50 },
        { ai.r.JA, ai.s.SPECIFIC, xi.ja.FEALTY }
    )

    -----------------------------------
    -- Healing (most urgent first: gambits match first rule that applies)
    -----------------------------------
    mob:addGambit(ai.t.SELF,
        { ai.c.HPP_LT, 40 },
        { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE_V }
    )

    mob:addGambit(ai.t.SELF,
        { ai.c.HPP_LT, 60 },
        { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE_IV }
    )

    mob:addGambit(ai.t.SELF,
        { ai.c.HPP_LT, 75 },
        { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE_III }
    )

    mob:addGambit(ai.t.PARTY,
        { ai.c.HPP_LT, 50 },
        { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE_IV }
    )

    mob:addGambit(ai.t.PARTY,
        { ai.c.HPP_LT, 70 },
        { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE_III }
    )

    -----------------------------------
    -- Buffing (Majesty, then Protect)
    -----------------------------------
    mob:addGambit(ai.t.SELF,
        { ai.c.NOT_STATUS, xi.effect.PROTECT },
        { ai.r.JA, ai.s.SPECIFIC, xi.ja.MAJESTY }
    )

    mob:addGambit(ai.t.SELF,
        { ai.c.NOT_STATUS, xi.effect.PROTECT },
        { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECT }
    )

    -----------------------------------
    -- Weapon skills: Uriel Blade before random TP dump
    -----------------------------------
    mob:addGambit(ai.t.TARGET,
        {
            { ai.c.TP_GTE, 900 },
            { ai.c.NOT_HAS_TOP_ENMITY, 0 },
        },
        { ai.r.WS, ai.s.SPECIFIC, xi.ws.URIEL_BLADE }
    )

    mob:addGambit(ai.t.TARGET,
        { ai.c.TP_GTE, 1800 },
        { ai.r.WS, ai.s.RANDOM }
    )
end

-----------------------------------
-- Despawn / Death
-----------------------------------
spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
