-----------------------------------
-- Trust: Valaineral
-- PLD/WAR
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    -- Records of Eminence: Alter Ego: Valaineral
    if caster:getEminenceProgress(933) then
        xi.roe.onRecordTrigger(caster, 933)
    end

    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    local lvl = mob:getMainLvl()

    -- Retail special features / tank traits.
    mob:setMobMod(xi.mobMod.CAN_SHIELD_BLOCK, 1)
    mob:setMobMod(xi.mobMod.CAN_PARRY, 3)

    local shieldMasteryPower = 0

    if lvl >= 96 then
        shieldMasteryPower = 40
    elseif lvl >= 75 then
        shieldMasteryPower = 30
    elseif lvl >= 50 then
        shieldMasteryPower = 20
    elseif lvl >= 25 then
        shieldMasteryPower = 10
    end

    mob:setMod(xi.mod.SHIELD_MASTERY_TP, shieldMasteryPower)
    mob:setMod(xi.mod.SHIELDBLOCKRATE, 35)

    mob:addMod(xi.mod.SPELLINTERRUPT, 30)
    mob:addMod(xi.mod.CURE_POTENCY, 50)
    mob:addMod(xi.mod.FASTCAST, 30)
    mob:addMod(xi.mod.REFRESH, 3)
    mob:addMod(xi.mod.ENMITY, 25)
    mob:addMod(xi.mod.DMG, -800) -- Damage Taken -8%
    mob:addMod(xi.mod.HPP, 10)
    mob:addMod(xi.mod.MPP, 20)
    mob:addMod(xi.mod.UNDEAD_KILLER, 8)

    -----------------------------------
    -- Weapon skills
    --
    -- Retail: uses WS randomly around 2000 TP and does not try to close SCs.
    -- Branch-safe approximation: explicit level-gated WS gambits.
    -- Exact retail sub-1000 TP Uriel trigger is held because this branch does not
    -- safely support Valaineral's newer special Uriel helper path.
    -----------------------------------

    -- Special retail feature approximation:
    -- Valaineral may use Uriel Blade before level 50. Local gambits still require TP.
    if lvl < 50 then
        mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 238 }, 45) -- Uriel Blade
    end

    if lvl >= 49 then
        mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 2000 }, { ai.r.WS, ai.s.SPECIFIC, 38 }, 45) -- Circle Blade
    end

    if lvl >= 50 then
        mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 2000 }, { ai.r.WS, ai.s.SPECIFIC, 238 }, 45) -- Uriel Blade
    end

    if lvl >= 68 then
        mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 2000 }, { ai.r.WS, ai.s.SPECIFIC, 42 }, 45) -- Savage Blade
    end

    if lvl >= 80 then
        mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 2000 }, { ai.r.WS, ai.s.SPECIFIC, 47 }, 45) -- Sanguine Blade
    end

    -----------------------------------
    -- Job abilities
    -----------------------------------

    if lvl >= 5 then
        mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE }, 30)
    end

    if lvl >= 30 then
        mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SENTINEL }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SENTINEL }, 300)
    end

    -- /WAR Defender. Main-level 50 corresponds to WAR subjob level 25.
    if lvl >= 50 then
        mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.DEFENDER }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.DEFENDER }, 180)
    end

    if lvl >= 62 then
        -- Retail-confirmed Rampart triggers: Chainspell, Manafont, Astral Flow.
        mob:addGambit(ai.t.TARGET, { ai.c.STATUS, xi.effect.MANAFONT    }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.RAMPART }, 300)
        mob:addGambit(ai.t.TARGET, { ai.c.STATUS, xi.effect.CHAINSPELL  }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.RAMPART }, 300)
        mob:addGambit(ai.t.TARGET, { ai.c.STATUS, xi.effect.ASTRAL_FLOW }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.RAMPART }, 300)
    end

    if lvl >= 70 then
        mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.MAJESTY }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.MAJESTY }, 180)
    end

    if lvl >= 75 then
        -- Exact retail Fealty prediction logic, including Mijin Gakure anticipation, is held.
        mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.FEALTY }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.FEALTY }, 600)

        mob:addGambit(ai.t.SELF, { { ai.c.MPP_LT, 50 }, { ai.c.TP_GTE, 1000 } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.CHIVALRY }, 300)
    end

    if lvl >= 78 then
        -- Retail: Divine Emblem before Flash when available.
        mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.FLASH }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.DIVINE_EMBLEM }, 600)
    end

    if lvl >= 95 then
        mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.PALISADE }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.PALISADE }, 300)
    end

    -----------------------------------
    -- Spells
    -- Spell list 322 supplies the hard spell level gates.
    -----------------------------------

    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 50 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })
    mob:addGambit(ai.t.SELF,  { ai.c.HPP_LT, 70 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.SLEEP_I }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURE })

    if lvl >= 37 then
        mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.FLASH }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.FLASH })
    end

    if lvl >= 61 then
        mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.REPRISAL }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.REPRISAL })
    end

    -- Retail: Protect IV/V only, under Majesty. Source/live spell list is cleaned below.
    if lvl >= 70 then
        mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECT })
    end

    if lvl >= 77 then
        mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.PHALANX }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PHALANX })
    end

    if lvl >= 85 then
        mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.ENLIGHT }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ENLIGHT })
    end

    mob:addListener('WEAPONSKILL_USE', 'VALAINERAL_WEAPONSKILL_USE', function(mobArg, target, skill, tp, action, damage)
        if skill:getID() == 238 then -- Uriel Blade
            -- Let the Blade of the Conqueror once again bring glory to the Kingdom!
            if math.random(1, 100) <= 33 then
                xi.trust.message(mobArg, xi.trust.messageOffset.SPECIAL_MOVE_1)
            end
        end
    end)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
