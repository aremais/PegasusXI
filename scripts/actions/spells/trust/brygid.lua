-----------------------------------
-- Trust: Brygid
-- Passive incorporeal Trust.
-- Grants nearby party members a Brygid-only CHR/Defense/Magic Defense aura.
-----------------------------------
---@type TSpellTrust
local spellObject = {}

local brygidAura =
{
    chr  = 5,
    mdef = 5,
    defp = 10, -- Retail value is ~9.7%; DEFP is integer-based, so +10 is the closest practical value.
}

local function removeBrygidAura(member)
    if member and member:getLocalVar('BrygidAura') == 1 then
        member:delMod(xi.mod.CHR, brygidAura.chr)
        member:delMod(xi.mod.MDEF, brygidAura.mdef)
        member:delMod(xi.mod.DEFP, brygidAura.defp)
        member:setLocalVar('BrygidAura', 0)
        member:setLocalVar('BrygidAuraExpires', 0)
    end
end

local function applyBrygidAura(mobArg)
    local master = mobArg:getMaster()

    if master == nil then
        return
    end

    local party = master:getPartyWithTrusts()

    for _, member in ipairs(party) do
        if
            member and
            member:isAlive() and
            member:checkDistance(mobArg) <= 20
        then
            if member:getLocalVar('BrygidAura') == 0 then
                member:addMod(xi.mod.CHR, brygidAura.chr)
                member:addMod(xi.mod.MDEF, brygidAura.mdef)
                member:addMod(xi.mod.DEFP, brygidAura.defp)
                member:setLocalVar('BrygidAura', 1)
            end

            member:setLocalVar('BrygidAuraExpires', GetSystemTime() + 10)
        else
            removeBrygidAura(member)
        end
    end
end

local function cleanupBrygidAura(mobArg)
    local master = mobArg:getMaster()

    if master == nil then
        return
    end

    local party = master:getPartyWithTrusts()

    for _, member in ipairs(party) do
        removeBrygidAura(member)
    end
end

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Incorporeal-style immunity.
    mob:setMod(xi.mod.UDMGPHYS, -10000)
    mob:setMod(xi.mod.UDMGRANGE, -10000)
    mob:setMod(xi.mod.UDMGBREATH, -10000)
    mob:setMod(xi.mod.UDMGMAGIC, -10000)

    -- Passive Trust behavior.
    mob:setAutoAttackEnabled(false)
    mob:setMobMod(xi.mobMod.NO_MOVE, 1)

    -- Apply once immediately so Brygid's aura is active as soon as she is summoned.
    applyBrygidAura(mob)
    mob:setLocalVar('BrygidAuraTick', GetSystemTime() + 3)
end

spellObject.onMobFight = function(mob, target)
    local master = mob:getMaster()

    if master == nil then
        return
    end

    local now = GetSystemTime()

    if now >= mob:getLocalVar('BrygidAuraTick') then
        mob:setLocalVar('BrygidAuraTick', now + 3)
        applyBrygidAura(mob)
    end

    local party = master:getPartyWithTrusts()

    for _, member in ipairs(party) do
        if
            member and
            member:getLocalVar('BrygidAura') == 1 and
            now > member:getLocalVar('BrygidAuraExpires')
        then
            removeBrygidAura(member)
        end
    end
end

spellObject.onMobDespawn = function(mob)
    cleanupBrygidAura(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    cleanupBrygidAura(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
