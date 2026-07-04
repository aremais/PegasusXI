-----------------------------------
-- Trust: Volker
-- If there is a NIN, PLD, or RUN in the party, behaves as a damage dealer:
-- uses Aggressor and Berserk.
-- If there are no other tanks in the party, behaves as a tank:
-- uses Defender and Retaliation.
-- Uses Provoke in either role to maintain enmity as a tank or off-tank.
-- Uses weapon skills at 2000 TP with Warrior's Charge if available;
-- does not try to skillchain.
-----------------------------------
---@type TSpellTrust
local spellObject = {}

local volkerSkills =
{
    RED_LOTUS_BLADE = 34,
    SPIRITS_WITHIN  = 39,
    VORPAL_BLADE    = 40,
    SAVAGE_BLADE    = 42,
}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.teamworkMessage(mob, {
        [xi.magic.spell.NAJI]  = xi.trust.messageOffset.TEAMWORK_1,
        [xi.magic.spell.CID]   = xi.trust.messageOffset.TEAMWORK_2,
        [xi.magic.spell.KLARA] = xi.trust.messageOffset.TEAMWORK_3,
    })

    -- DD / off-tank mode: another tank is already present.
    mob:addGambit(ai.t.SELF, { { ai.c.PT_HAS_TANK, 0 }, { ai.c.LVL_GTE, 15 }, { ai.c.NOT_STATUS, xi.effect.BERSERK } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.BERSERK })
    mob:addGambit(ai.t.SELF, { { ai.c.PT_HAS_TANK, 0 }, { ai.c.LVL_GTE, 45 }, { ai.c.NOT_STATUS, xi.effect.AGGRESSOR } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.AGGRESSOR })

    -- Tank mode: no NIN/PLD/RUN-style tank is present.
    mob:addGambit(ai.t.SELF, { { ai.c.NOT_PT_HAS_TANK, 0 }, { ai.c.LVL_GTE, 25 }, { ai.c.NOT_STATUS, xi.effect.DEFENDER } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.DEFENDER })
    mob:addGambit(ai.t.SELF, { { ai.c.NOT_PT_HAS_TANK, 0 }, { ai.c.LVL_GTE, 60 }, { ai.c.NOT_STATUS, xi.effect.RETALIATION } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.RETALIATION })

    -- Listed for Volker. Existing source used party targeting, so preserve that behavior with level/status gates.
    mob:addGambit(ai.t.PARTY, { { ai.c.LVL_GTE, 35 }, { ai.c.NOT_STATUS, xi.effect.WARCRY } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.WARCRY })

    -- Provoke in either role.
    mob:addGambit(ai.t.TARGET, { { ai.c.PT_HAS_TANK, 0 }, { ai.c.LVL_GTE, 5 } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE })
    mob:addGambit(ai.t.TARGET, { { ai.c.NOT_PT_HAS_TANK, 0 }, { ai.c.LVL_GTE, 5 } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE })

    -- Warrior's Charge before WS when available.
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 75 }, { ai.c.TP_GTE, 2000 }, { ai.c.NOT_STATUS, xi.effect.WARRIORS_CHARGE } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.WARRIORS_CHARGE })

    -- Retail-close TP behavior: hold to 2000 TP, then WS. No skillchain helper.
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 71 }, { ai.c.TP_GTE, 2000 } }, { ai.r.WS, ai.s.SPECIFIC, volkerSkills.SAVAGE_BLADE })
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 60 }, { ai.c.TP_GTE, 2000 } }, { ai.r.WS, ai.s.SPECIFIC, volkerSkills.VORPAL_BLADE })
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 55 }, { ai.c.TP_GTE, 2000 } }, { ai.r.WS, ai.s.SPECIFIC, volkerSkills.SPIRITS_WITHIN })
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 5 }, { ai.c.TP_GTE, 2000 } }, { ai.r.WS, ai.s.SPECIFIC, volkerSkills.RED_LOTUS_BLADE })
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
