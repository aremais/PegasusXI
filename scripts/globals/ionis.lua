-----------------------------------
-- Ionis (xi.effect.IONIS)
-- Coalition edification bonuses per https://www.bg-wiki.com/ffxi/Ionis
--
-- Storage: two char vars pack six 8-bit masks (one per coalition). Bit order
-- matches coalition building tiers: 0=Coalition Flag, 1=Signboard, 2=Emblem,
-- 3=Second Floor, 4=Adoulinian Flag, 5=Main Terrace, 6=Bay Roof, 7=Main Chimney.
-- Moderate tiers supersede minor for the same bonus line (not stacked).
--
-- Ionis_EdifyA: Pioneers (0-7) | Peacekeepers (8-15) | Couriers (16-23)
-- Ionis_EdifyB: Scouts (0-7) | Mummers (8-15) | Inventors (16-23)
--
-- Snapshot at grant time is stored on the status effect (power / subPower /
-- subType are uint16; subType holds Mummers|Inventors) so mid-effect char_var
-- changes do not alter active mods.
--
-- TODO: Gathering fatigue (+attempts) needs core support if not present.
-- TODO: Inventors crystal drop rate beyond base Ionis crystal roll (mobentity).
-----------------------------------

xi = xi or {}
xi.ionis = xi.ionis or {}

xi.ionis.CHAR_VAR_EDIFY_A = 'Ionis_EdifyA' -- Pioneers, Peacekeepers, Couriers
xi.ionis.CHAR_VAR_EDIFY_B = 'Ionis_EdifyB' -- Scouts, Mummers, Inventors

-- Coalition ids for setCoalitionMask / GM tools
xi.ionis.coalition =
{
    PIONEERS     = 1,
    PEACEKEEPERS = 2,
    COURIERS     = 3,
    SCOUTS       = 4,
    MUMMERS      = 5,
    INVENTORS    = 6,
}

local function has(c, bit)
    return utils.mask.getBit(c, bit)
end

---@param target CBaseEntity
---@param add boolean
---@param modId integer
---@param amount integer
local function modAmount(target, add, modId, amount)
    if amount == 0 then
        return
    end

    if add then
        target:addMod(modId, amount)
    else
        target:delMod(modId, amount)
    end
end

local statusResMods =
{
    xi.mod.PARALYZE_RES_RANK,
    xi.mod.BIND_RES_RANK,
    xi.mod.SILENCE_RES_RANK,
    xi.mod.SLOW_RES_RANK,
    xi.mod.POISON_RES_RANK,
    xi.mod.LIGHT_SLEEP_RES_RANK,
    xi.mod.DARK_SLEEP_RES_RANK,
    xi.mod.BLIND_RES_RANK,
    xi.mod.STUN_RES_RANK,
}

local function modAllRes(target, add, amount)
    for _, m in ipairs(statusResMods) do
        modAmount(target, add, m, amount)
    end
end

local function modGatheringEfficacy(target, add, amount)
    if amount == 0 then
        return
    end

    modAmount(target, add, xi.mod.MINING_RESULT, amount)
    modAmount(target, add, xi.mod.LOGGING_RESULT, amount)
    modAmount(target, add, xi.mod.HARVESTING_RESULT, amount)
end

---@param target CBaseEntity
---@param c integer
---@param add boolean
local function applyPioneers(target, c, add)
    if has(c, 4) then
        modAmount(target, add, xi.mod.ATT, 20)
    elseif has(c, 0) then
        modAmount(target, add, xi.mod.ATT, 10)
    end

    if has(c, 5) then
        modAmount(target, add, xi.mod.MATT, 5)
    elseif has(c, 1) then
        modAmount(target, add, xi.mod.MATT, 3)
    end

    -- Gathering fatigue (+5 / +10 attempts): not modeled in core.

    if has(c, 7) then
        modGatheringEfficacy(target, add, 6)
    elseif has(c, 3) then
        modGatheringEfficacy(target, add, 3)
    end
end

---@param target CBaseEntity
---@param c integer
---@param add boolean
local function applyPeacekeepers(target, c, add)
    if has(c, 4) then
        modAmount(target, add, xi.mod.DEF, 20)
    elseif has(c, 0) then
        modAmount(target, add, xi.mod.DEF, 10)
    end

    if has(c, 5) then
        modAmount(target, add, xi.mod.MDEF, 4)
    elseif has(c, 1) then
        modAmount(target, add, xi.mod.MDEF, 3)
    end

    if has(c, 6) then
        modAmount(target, add, xi.mod.HPHEAL, 10)
        modAmount(target, add, xi.mod.MPHEAL, 10)
    elseif has(c, 2) then
        modAmount(target, add, xi.mod.HPHEAL, 5)
        modAmount(target, add, xi.mod.MPHEAL, 5)
    end

    if has(c, 7) then
        modAmount(target, add, xi.mod.HP, 100)
        modAmount(target, add, xi.mod.MP, 100)
    elseif has(c, 3) then
        modAmount(target, add, xi.mod.HP, 50)
        modAmount(target, add, xi.mod.MP, 50)
    end
end

---@param target CBaseEntity
---@param c integer
---@param add boolean
local function applyCouriers(target, c, add)
    if has(c, 4) then
        modAmount(target, add, xi.mod.ACC, 20)
        modAmount(target, add, xi.mod.MACC, 20)
    elseif has(c, 0) then
        modAmount(target, add, xi.mod.ACC, 5)
        modAmount(target, add, xi.mod.MACC, 5)
    end

    if has(c, 5) then
        modAmount(target, add, xi.mod.EVA, 20)
        modAmount(target, add, xi.mod.MEVA, 20)
    elseif has(c, 1) then
        modAmount(target, add, xi.mod.EVA, 5)
        modAmount(target, add, xi.mod.MEVA, 5)
    end

    -- Moderate crit: magnitude unspecified on wiki; scaled above minor.
    if has(c, 6) then
        modAmount(target, add, xi.mod.CRITHITRATE, 10)
    elseif has(c, 2) then
        modAmount(target, add, xi.mod.CRITHITRATE, 5)
    end

    if has(c, 7) then
        modAmount(target, add, xi.mod.HASTE_GEAR, 25)
    elseif has(c, 3) then
        modAmount(target, add, xi.mod.HASTE_GEAR, 12)
    end
end

---@param target CBaseEntity
---@param c integer
---@param add boolean
local function applyScouts(target, c, add)
    if has(c, 4) then
        modAmount(target, add, xi.mod.STORETP, 100)
    elseif has(c, 0) then
        modAmount(target, add, xi.mod.STORETP, 5)
    end

    if has(c, 5) then
        modAmount(target, add, xi.mod.CONSERVE_MP, 25)
    elseif has(c, 1) then
        modAmount(target, add, xi.mod.CONSERVE_MP, 10)
    end

    if has(c, 6) then
        modAmount(target, add, xi.mod.FASTCAST, 3)
    elseif has(c, 2) then
        modAmount(target, add, xi.mod.FASTCAST, 1)
    end

    if has(c, 7) then
        modAllRes(target, add, 5)
    elseif has(c, 3) then
        modAllRes(target, add, 2)
    end
end

---@param target CBaseEntity
---@param c integer
---@param add boolean
local function applyMummers(target, c, add)
    if has(c, 4) then
        modAmount(target, add, xi.mod.COMBAT_SKILLUP_RATE, 20)
    elseif has(c, 0) then
        modAmount(target, add, xi.mod.COMBAT_SKILLUP_RATE, 10)
    end

    if has(c, 5) then
        modAmount(target, add, xi.mod.MAGIC_SKILLUP_RATE, 20)
    elseif has(c, 1) then
        modAmount(target, add, xi.mod.MAGIC_SKILLUP_RATE, 10)
    end

    if has(c, 6) then
        modAmount(target, add, xi.mod.EXP_BONUS, 10)
    elseif has(c, 2) then
        modAmount(target, add, xi.mod.EXP_BONUS, 5)
    end

    -- Reward obtainment: approximate with Treasure Hunter tier.
    if has(c, 7) then
        modAmount(target, add, xi.mod.TREASURE_HUNTER, 2)
    elseif has(c, 3) then
        modAmount(target, add, xi.mod.TREASURE_HUNTER, 1)
    end
end

---@param target CBaseEntity
---@param c integer
---@param add boolean
local function applyInventors(target, c, add)
    -- Crystal obtainment: extra rolls not hooked; see mobentity Ionis check.

    if has(c, 5) then
        modAmount(target, add, xi.mod.SYNTH_MATERIAL_LOSS, 10)
    elseif has(c, 1) then
        modAmount(target, add, xi.mod.SYNTH_MATERIAL_LOSS, 5)
    end

    if has(c, 6) then
        modAmount(target, add, xi.mod.SYNTH_SKILL_GAIN, 20)
    elseif has(c, 2) then
        modAmount(target, add, xi.mod.SYNTH_SKILL_GAIN, 10)
    end

    if has(c, 7) then
        modAmount(target, add, xi.mod.SYNTH_SUCCESS_RATE, 10)
    elseif has(c, 3) then
        modAmount(target, add, xi.mod.SYNTH_SUCCESS_RATE, 5)
    end
end

local appliers =
{
    applyPioneers,
    applyPeacekeepers,
    applyCouriers,
    applyScouts,
    applyMummers,
    applyInventors,
}

--- Read packed char vars (24 bits used each).
---@param player CBaseEntity
---@return integer edifyA
---@return integer edifyB
function xi.ionis.getPackedCharVars(player)
    local a = player:getCharVar(xi.ionis.CHAR_VAR_EDIFY_A)
    local b = player:getCharVar(xi.ionis.CHAR_VAR_EDIFY_B)
    return bit.band(a, 0xFFFFFF), bit.band(b, 0xFFFFFF)
end

--- Params for addStatusEffect (uint16-safe).
---@param player CBaseEntity
---@return { power: integer, subPower: integer, subType: integer }
function xi.ionis.encodeEffectParams(player)
    local edifyA, edifyB = xi.ionis.getPackedCharVars(player)
    local pioneer     = bit.band(edifyA, 0xFF)
    local peacekeeper = bit.band(bit.rshift(edifyA, 8), 0xFF)
    local courier     = bit.band(bit.rshift(edifyA, 16), 0xFF)
    local scout       = bit.band(edifyB, 0xFF)
    local mummer      = bit.band(bit.rshift(edifyB, 8), 0xFF)
    local inventor    = bit.band(bit.rshift(edifyB, 16), 0xFF)

    return {
        power    = bit.bor(pioneer, bit.lshift(peacekeeper, 8)),
        subPower = bit.bor(courier, bit.lshift(scout, 8)),
        subType  = bit.bor(mummer, bit.lshift(inventor, 8)),
    }
end

---@param effect CStatusEffect
---@return integer[] six coalition bytes
function xi.ionis.decodeEdification(effect)
    local p  = effect:getPower()
    local sp = effect:getSubPower()
    local st = effect:getSubType()

    return
    {
        bit.band(p, 0xFF),
        bit.band(bit.rshift(p, 8), 0xFF),
        bit.band(sp, 0xFF),
        bit.band(bit.rshift(sp, 8), 0xFF),
        bit.band(st, 0xFF),
        bit.band(bit.rshift(st, 8), 0xFF),
    }
end

---@param target CBaseEntity
---@param effect CStatusEffect
function xi.ionis.applyBonuses(target, effect)
    local bytes = xi.ionis.decodeEdification(effect)
    for i = 1, 6 do
        appliers[i](target, bytes[i], true)
    end
end

---@param target CBaseEntity
---@param effect CStatusEffect
function xi.ionis.removeBonuses(target, effect)
    local bytes = xi.ionis.decodeEdification(effect)
    for i = 1, 6 do
        appliers[i](target, bytes[i], false)
    end
end

--- Set one coalition's 8-bit edification mask (0-255). Use from coalition scripts.
---@param player CBaseEntity
---@param coalitionId integer 1-6 (xi.ionis.coalition.*)
---@param mask integer
function xi.ionis.setCoalitionMask(player, coalitionId, mask)
    mask = bit.band(mask, 0xFF)
    local varName = nil
    local shift   = nil

    if coalitionId == 1 then
        varName = xi.ionis.CHAR_VAR_EDIFY_A
        shift   = 0
    elseif coalitionId == 2 then
        varName = xi.ionis.CHAR_VAR_EDIFY_A
        shift   = 8
    elseif coalitionId == 3 then
        varName = xi.ionis.CHAR_VAR_EDIFY_A
        shift   = 16
    elseif coalitionId == 4 then
        varName = xi.ionis.CHAR_VAR_EDIFY_B
        shift   = 0
    elseif coalitionId == 5 then
        varName = xi.ionis.CHAR_VAR_EDIFY_B
        shift   = 8
    elseif coalitionId == 6 then
        varName = xi.ionis.CHAR_VAR_EDIFY_B
        shift   = 16
    else
        return
    end

    local current = bit.band(player:getCharVar(varName), 0xFFFFFF)
    local byteMask = bit.lshift(0xFF, shift)
    local cleared  = bit.band(current, bit.bxor(0xFFFFFF, byteMask))
    player:setCharVar(varName, bit.band(bit.bor(cleared, bit.lshift(mask, shift)), 0xFFFFFF))
end

return xi.ionis
