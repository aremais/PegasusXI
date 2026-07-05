-----------------------------------
-- Trust: Gadalar
-----------------------------------
require('scripts/globals/trust')
require('scripts/globals/gambits')

---@type TSpellTrust
local spellObject = {}

local function hasRughadjeen(mob)
    local master = mob:getMaster()
    if master == nil then
        return false
    end

    local ok, party = pcall(function()
        return master:getPartyWithTrusts()
    end)

    if not ok or party == nil then
        return false
    end

    for _, member in pairs(party) do
        if
            member ~= nil and
            member:getName() ~= nil and
            string.lower(member:getName()) == 'rughadjeen'
        then
            return true
        end
    end

    return false
end

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Retail-style native traits:
    -- MP +25%, Magic Attack Bonus +25.
    mob:addMod(xi.mod.MPP, 25)
    mob:addMod(xi.mod.MATT, 25)

    -- Official synergy hint: Rughadjeen empowers Gadalar.
    -- Retail target: additional Magic Attack Bonus +25.
    if hasRughadjeen(mob) then
        mob:addMod(xi.mod.MATT, 25)

        if xi.trust.messageOffset.TEAMWORK_1 ~= nil then
            xi.trust.message(mob, xi.trust.messageOffset.TEAMWORK_1)
        end
    end

    -- Gadalar recovers MP when hit by physical attacks.
    mob:addListener('TAKE_DAMAGE', 'GADALAR_MP_RECOVERY', function(gadalar, amount, attacker, attackType, damageType)
        if
            amount ~= nil and
            amount > 0 and
            attackType == xi.attackType.PHYSICAL
        then
            local missingMP = gadalar:getMaxMP() - gadalar:getMP()
            if missingMP > 0 then
                local mpRecovered = math.max(1, math.floor(amount * 0.25))
                gadalar:setMP(gadalar:getMP() + math.min(mpRecovered, missingMP))
            end
        end
    end)

    -- Blaze Spikes from Lv10+.
    mob:addGambit(ai.t.SELF, { { ai.c.LVL_GTE, 10 }, { ai.c.NOT_STATUS, xi.effect.BLAZE_SPIKES } }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.BLAZE_SPIKES }, 60)

    -- Fire-only nuking: MB when possible, otherwise use highest available fire spell.
    mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 }, { ai.r.MA, ai.s.MB_ELEMENT, xi.magic.spellFamily.NONE })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.NONE }, 15)

    -- Uses TP as soon as he gets it; Salamander Flame is favored, with scythe WS fallback.
    mob:addGambit(ai.t.SELF, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 2089 }, 15) -- Salamander Flame
    mob:addGambit(ai.t.SELF, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 104 }, 10)  -- Spiral Hell
    mob:addGambit(ai.t.SELF, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 101 }, 10)  -- Vorpal Scythe
    mob:addGambit(ai.t.SELF, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 944 }, 10)  -- Spinning Scythe
end

spellObject.onMobDespawn = function(mob)
    mob:removeListener('GADALAR_MP_RECOVERY')
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    mob:removeListener('GADALAR_MP_RECOVERY')
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
