-----------------------------------
-- Trust: Prishe
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.PRISHE_II)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.teamworkMessage(mob, {
        [xi.magic.spell.ULMIA] = xi.trust.messageOffset.TEAMWORK_1,
        [xi.magic.spell.CHERUKIKI] = xi.trust.messageOffset.TEAMWORK_2,
        [xi.magic.spell.KUKKI_CHEBUKKI] = xi.trust.messageOffset.TEAMWORK_3,
        [xi.magic.spell.MAKKI_CHEBUKKI] = xi.trust.messageOffset.TEAMWORK_4,
        [xi.magic.spell.MILDAURION] = xi.trust.messageOffset.TEAMWORK_5,
    })

    -- Source notes: MNK/WHM fists. Possesses MNK traits such as Kick Attacks
    -- and Auto-Regen; exact level-scaling trait potency is approximated/held.
    if mob:getMainLvl() >= 51 then
        mob:addMod(xi.mod.KICK_ATTACK_RATE, 10)
    end

    -- Cure spell levels are gated in TRUST_Prishe spell list 325:
    -- Cure Lv2, Cure II Lv22, Cure III Lv42, Cure IV Lv82.
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 25 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })

    -- Retail behavior: Prishe uses TP as soon as available.
    -- TRUST_Prishe skill list 1028 contains Nullifying Dropkick, Auroral Uppercut, and Knuckle Sandwich.
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.HIGHEST })
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
