-----------------------------------
-- Trust: AAMR
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Ark Angel MR is a BST/THF melee Trust with HP+20% and TH I.
    mob:addMod(xi.mod.HPP, 20)
    mob:addMod(xi.mod.TREASURE_HUNTER, 1)

    -- THF subjob tools. Retail behavior attempts positional Sneak/Trick
    -- Attack WS usage, but this is approximated with safe gambits because
    -- Trust Lua does not have a clean behind-target/behind-master selector.
    mob:addGambit(ai.t.SELF, { ai.c.LVL_GTE, 30 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SNEAK_ATTACK })
    mob:addGambit(ai.t.SELF, { ai.c.LVL_GTE, 60 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.TRICK_ATTACK })

    -- AAMR holds TP for WS opportunities and does not intentionally skillchain.
    -- Prefer higher TP/highest WS selection rather than closer logic.
    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.HIGHEST, 3000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject