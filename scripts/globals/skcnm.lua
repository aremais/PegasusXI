-----------------------------------
-- SKCNM Reward Handler
-----------------------------------
-- Sacred Kindred Crest NM (Macrocosmic Orb) reward system.
-- Mirrors the HTBF two-layer reward system but for orb-based entry.
--
-- DIRECT DROPS (personal, every player):
--   Rem's Tale chapters and R/E/M upgrade materials scaled by difficulty.
--
-- TREASURE POOL DROPS (shared):
--   Gil, crafting materials, scrolls, and rocks enter the treasure pool.
--
-- DIFFICULTY (stored in battlefield localVar 'SKCNM_Difficulty'):
--   0 = Very Easy | 1 = Easy | 2 = Normal | 3 = Difficult | 4 = Very Difficult
--   Defaults to Normal (2) if unset.
--
-- FLOW:
--   Trade orb → difficulty menu → fight-selection CS (event 32000)
--   → pick fight → warp into arena → battle begins.
--   Difficulty is chosen BEFORE the fight-selection cutscene so the warp
--   cannot race ahead of the selection.  The chosen index is stashed in
--   the player localVar '[SKCNM]Difficulty' and read in battlefieldEntry.
-----------------------------------

xi       = xi or {}
xi.skcnm = xi.skcnm or {}

xi.skcnm.difficulty =
{
    VERY_EASY      = 0,
    EASY           = 1,
    NORMAL         = 2,
    DIFFICULT      = 3,
    VERY_DIFFICULT = 4,
}

-- [diffIndex + 1] = { chapters, upgrades }
local diffRewards =
{
    { chapters = 1, upgrades = 0 }, -- Very Easy
    { chapters = 1, upgrades = 1 }, -- Easy
    { chapters = 2, upgrades = 1 }, -- Normal
    { chapters = 3, upgrades = 2 }, -- Difficult
    { chapters = 4, upgrades = 2 }, -- Very Difficult
}

local upgradePool =
{
    xi.item.PLUTON,
    xi.item.RIFTBORN_BOULDER,
    xi.item.BEITETSU,
}

-----------------------------------
-- Internal helpers
-----------------------------------

local function giveDirectDrops(battlefield, chapterItemId)
    local diffIndex = battlefield:getLocalVar('SKCNM_Difficulty')
    local rewards   = diffRewards[diffIndex + 1] or diffRewards[3] -- default Normal
    local players   = battlefield:getPlayers()

    for _, player in ipairs(players) do
        for _ = 1, rewards.chapters do
            npcUtil.giveItem(player, chapterItemId)
        end

        for _ = 1, rewards.upgrades do
            npcUtil.giveItem(player, upgradePool[math.random(#upgradePool)])
        end
    end
end

local function rollTreasurePool(battlefield, lootTable, mob)
    if not lootTable or not mob then
        return
    end

    local players = battlefield:getPlayers()

    if not players or #players == 0 then
        return
    end

    local firstPlayer = players[1]
    local selected    = utils.selectFromLootGroups(firstPlayer, lootTable)

    for _, entry in ipairs(selected) do
        firstPlayer:addTreasure(entry.itemId, mob)
    end
end

-----------------------------------
-- Public API
-----------------------------------

-- Called from allDeath in each fight script.
--
-- params = {
--   chapterItemId : xi.item.COPY_OF_REMS_TALE_CHAPTER_X for this fight
--   mob           : the mob reference passed into allDeath (loot anchor)
--   lootTable     : content.loot table (treasure pool items)
-- }
function xi.skcnm.onWin(battlefield, params)
    giveDirectDrops(battlefield, params.chapterItemId)
    rollTreasurePool(battlefield, params.lootTable, params.mob)
    battlefield:setStatus(xi.battlefield.status.WON)
end

-----------------------------------
-- Difficulty scaling
-----------------------------------

-- hp   : percent modifier applied to base MaxHP  (e.g. -45 → 55 % of base)
-- att/def/eva : flat mod values added to the mob stat
local diffScaling =
{
    [0] = { hp = -45, att = -100, def = -100, eva =  -50 }, -- Very Easy
    [1] = { hp = -20, att =  -50, def =  -50, eva =  -25 }, -- Easy
    [2] = { hp =   0, att =    0, def =    0, eva =    0 }, -- Normal (base)
    [3] = { hp =  25, att =   50, def =   50, eva =   25 }, -- Difficult
    [4] = { hp =  55, att =  100, def =  100, eva =   50 }, -- Very Difficult
}

local function applyDiffScaling(battlefield, diffIndex)
    local scaling = diffScaling[diffIndex]

    if not scaling then
        return
    end

    local mobs = battlefield:getMobs(true, true)

    if not mobs then
        return
    end

    for _, mob in ipairs(mobs) do
        if mob and mob:isAlive() then
            -- HP scaling: adjust MaxHP by percentage from base
            if scaling.hp ~= 0 then
                local baseHP = mob:getMaxHP()
                local newHP  = math.max(1, math.floor(baseHP * (100 + scaling.hp) / 100))
                mob:setMaxHP(newHP)
                mob:setHP(newHP)
            end

            -- Stat mods: only apply if non-zero to avoid dirty Normal state
            if scaling.att ~= 0 then
                mob:addMod(xi.mod.ATT, scaling.att)
            end

            if scaling.def ~= 0 then
                mob:addMod(xi.mod.DEF, scaling.def)
            end

            if scaling.eva ~= 0 then
                mob:addMod(xi.mod.EVA, scaling.eva)
            end
        end
    end
end

-----------------------------------
-- Difficulty menu labels (Shift-JIS safe ASCII)
-----------------------------------

local difficultyLabels =
{
    [0] = 'Very Easy',
    [1] = 'Easy',
    [2] = 'Normal',
    [3] = 'Difficult',
    [4] = 'Very Difficult',
}

-----------------------------------
-- SKCNMBattlefield class
-----------------------------------
-- Extends Battlefield directly (orb-based entry, not quest/KI gated).
-- All SKCNM fight scripts use SKCNMBattlefield:new() instead of
-- Battlefield:new() so the difficulty menu is wired in automatically.

SKCNMBattlefield         = setmetatable({}, { __index = Battlefield })
SKCNMBattlefield.__index = SKCNMBattlefield

function SKCNMBattlefield:new(data)
    local obj = Battlefield:new(data)
    setmetatable(obj, self)
    return obj
end

-----------------------------------
-- Trade handler (registered via Battlefield.register)
-----------------------------------
-- battlefield.lua line 546 uses self.onEntryTrade so that subclasses can
-- override the trade handler.  This static function replaces the default
-- Battlefield.onEntryTrade for all SKCNM fights:
--
--   FLOW: orb trade → difficulty menu (GMPROMPT) → fight-selection CS.
--
-- Difficulty is stored in the player localVar '[SKCNM]Difficulty' and read
-- back in battlefieldEntry() once the battlefield exists and mobs are spawned.
-----------------------------------

function SKCNMBattlefield.onEntryTrade(player, npc, trade, onUpdate)
    -- ---- shared validation (mirrors Battlefield.onEntryTrade) ---------------

    if xi.battlefield.rejectLevelSyncedParty(player, npc) then
        return
    end

    if not trade then
        return
    end

    if player:hasStatusEffect(xi.effect.BATTLEFIELD) and not onUpdate then
        player:messageBasic(xi.msg.basic.WAIT_LONGER, 0, 0)
        return
    end

    local alliance = player:getAlliance()
    for _, member in pairs(alliance) do
        if member:hasStatusEffect(xi.effect.BATTLEFIELD) then
            player:messageBasic(xi.msg.basic.WAIT_LONGER, 0, 0)
            return
        end
    end

    local zoneId   = player:getZoneID()
    local contents = xi.battlefield.contentsByZone[zoneId]

    -- Check whether the traded Macrocosmic Orb has already been cracked.
    -- We use printToPlayer instead of messageSpecial(ORB_IS_CRACKED, itemId)
    -- because item 4063 resolves to "bureau" in vanilla client DATs.
    for _, content in ipairs(contents) do
        if
            #content.requiredItems > 0 and
            npcUtil.tradeHas(trade, content.tradeItems)
        then
            local itemId    = content.requiredItems[1]
            local totalUses = xi.battlefield.itemUses[itemId] or 1

            if player:getWornUses(itemId) >= totalUses then
                player:printToPlayer('The Macrocosmic Orb no longer contains a monster.', xi.msg.channel.NS_SAY)
                return
            end
        end
    end

    -- If called from onEntryEventUpdate (onUpdate=true) let base class handle.
    if onUpdate then
        return Battlefield.onEntryTrade(player, npc, trade, onUpdate)
    end

    -- ---- SKCNM-specific: difficulty menu BEFORE fight selection CS ----------

    local options = xi.battlefield.getBattlefieldOptions(player, npc, trade)

    if options == 0 then
        local noEntryMsg = zones[zoneId].text.NO_BATTLEFIELD_ENTRY
        if noEntryMsg then
            player:messageSpecial(noEntryMsg)
        end

        return
    end

    -- Build and show the difficulty menu.  The callback stores the selection
    -- in a player localVar, then starts the fight-selection cutscene (event 32000).
    local function onChosen(p, diffIndex)
        p:setLocalVar('[SKCNM]Difficulty', diffIndex)
        p:startEvent(32000, 0, 0, 0, options, 0, 0, 0, 0)
    end

    local menu =
    {
        title   = 'Select Battle Difficulty',
        options = {},
        onCancelled = function(p)
            onChosen(p, xi.skcnm.difficulty.NORMAL)
        end,
    }

    for value = 0, 4 do
        table.insert(menu.options, {
            difficultyLabels[value],
            function(p)
                onChosen(p, value)
            end,
        })
    end

    player:customMenu(menu)
    -- Return nil — do NOT start event 32000 here; the callback above does it.
end

-----------------------------------
-- battlefieldEntry: apply difficulty once mobs exist
-----------------------------------
-- Fires at the end of onBattlefieldEnter (base class calls self:battlefieldEntry).
-- By this point registerBattlefield has run, mobs are spawned, and the
-- '[SKCNM]Difficulty' localVar set in onEntryTrade is readable.

function SKCNMBattlefield:battlefieldEntry(player, battlefield)
    local initiatorId = select(1, battlefield:getInitiator())

    if player:getID() ~= initiatorId then
        return
    end

    local diffIndex = player:getLocalVar('[SKCNM]Difficulty')
    player:setLocalVar('[SKCNM]Difficulty', 0)               -- consume

    battlefield:setLocalVar('SKCNM_Difficulty', diffIndex)
    applyDiffScaling(battlefield, diffIndex)

    local label   = difficultyLabels[diffIndex] or 'Normal'
    local players = battlefield:getPlayers()

    -- Custom wear message shown to the initiator.
    -- Replaces messageSpecial(A_CRACK_HAS_FORMED, 0, 0, 0, 4063) which renders
    -- "bureau" in the client because item 4063 conflicts with a vanilla furniture ID.
    player:printToPlayer('A crack forms on the Macrocosmic Orb. The beast within has been unleashed!', xi.msg.channel.NS_SAY)

    for _, member in ipairs(players) do
        member:printToPlayer('Difficulty: ' .. label .. '.', xi.msg.channel.NS_SAY)
    end
end
