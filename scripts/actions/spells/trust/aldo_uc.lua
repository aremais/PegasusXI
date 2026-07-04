-----------------------------------
-- Trust: Aldo UC
-- Custom Lax server version:
-- Upgraded THF/NIN dagger-focused Unity Aldo.
-----------------------------------
---@type TSpellTrust
local spellObject = {}

local sarvasStorm = 3497

spellObject.onMagicCastingCheck = function(caster, target, spell)
    local trustSpell = xi.magic.spell.ALDO_UC or xi.magic.spell.ALDO
    return xi.trust.canCast(caster, spell, trustSpell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Custom UC upgrade: Aldo UC is a stronger dagger-focused THF/NIN
    -- variant for Lax's solo server. Ninjutsu is intentional custom utility.
    mob:addMod(xi.mod.TREASURE_HUNTER, 1)
    mob:addMod(xi.mod.GILFINDER, 1)

    -- Retail note: Aldo UC has 5/5 Triple Attack merits at Lv75.
    if mob:getMainLvl() >= 75 and xi.mod.TRIPLE_ATTACK ~= nil then
        mob:addMod(xi.mod.TRIPLE_ATTACK, 5)
    end

    -- THF job abilities.
    -- Guarded so missing JA enums cannot crash older/custom branches.
    if xi.ja ~= nil and xi.ja.BULLY ~= nil then
        mob:addGambit(ai.t.TARGET, { ai.c.LVL_GTE, 93 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.BULLY })
    end

    if xi.ja ~= nil and xi.ja.SNEAK_ATTACK ~= nil then
        mob:addGambit(ai.t.SELF, { ai.c.LVL_GTE, 15 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SNEAK_ATTACK })
    end

    -- NIN subjob utility. Spell level gates use subjob-equivalent
    -- main levels: NIN spell level * 2.
    mob:addGambit(ai.t.SELF,   { { ai.c.LVL_GTE, 74 }, { ai.c.NOT_STATUS, xi.effect.COPY_IMAGE } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.UTSUSEMI_NI })
    mob:addGambit(ai.t.SELF,   { { ai.c.LVL_GTE, 24 }, { ai.c.NOT_STATUS, xi.effect.COPY_IMAGE } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.UTSUSEMI_ICHI })
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 96 }, { ai.c.NOT_STATUS, xi.effect.SLOW } },      { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.HOJO_NI })
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 46 }, { ai.c.NOT_STATUS, xi.effect.SLOW } },      { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.HOJO_ICHI })
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 88 }, { ai.c.NOT_STATUS, xi.effect.BLINDNESS } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.KURAYAMI_NI })
    mob:addGambit(ai.t.TARGET, { { ai.c.LVL_GTE, 38 }, { ai.c.NOT_STATUS, xi.effect.BLINDNESS } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.KURAYAMI_ICHI })

    -- Branch-safe approximation of retail Aldo UC behavior:
    -- retail uses Sarva's Storm to open skillchains when another party member
    -- has TP, but this branch has no proven safe PARTY TP trigger for self WS.
    -- Therefore Aldo UC holds TP and uses Sarva's Storm at 3000 TP.
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 3000 }, { ai.r.WS, ai.s.SPECIFIC, sarvasStorm })
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject