-----------------------------------
-- Area: LaLoff Amphitheater
-- Name: Divine Might
--
-- NOTE: This file is prefixed so it loads before ark_angels_*.lua. Otherwise
-- Battlefield:register() skips entry NPC hooks when another BF already uses
-- the same qm1_* NPC, and Divine Might lists all five circles—so no hooks
-- would be registered here. Loading first attaches trade/trigger on every
-- entrance; solo Ark Angel BFs still register after and skip duplicates.
-----------------------------------
local laLoffID = zones[xi.zone.LALOFF_AMPHITHEATER]
-----------------------------------

local content = Battlefield:new({
    zoneId        = xi.zone.LALOFF_AMPHITHEATER,
    battlefieldId = xi.battlefield.id.DIVINE_MIGHT,
    canLoseExp    = false,
    allowTrusts   = true,
    maxPlayers    = 18,
    levelCap      = 99,
    timeLimit     = utils.minutes(30),
    index         = 5,
    entryNpcs     = { 'qm1_1', 'qm1_2', 'qm1_3', 'qm1_4', 'qm1_5' },

    requiredItems = { xi.item.ARK_PENTASPHERE, wearMessage = laLoffID.text.THE_SEAL_FADES, wornMessage = { laLoffID.text.INK_HAS_FADED, xi.item.ARK_PENTASPHERE } },
})

function content:entryRequirement(player, npc, isRegistrant, trade)
    if
        player:getQuestStatus(xi.questLog.OUTLANDS, xi.quest.id.outlands.DIVINE_MIGHT) == xi.questStatus.QUEST_ACCEPTED or
        player:getQuestStatus(xi.questLog.OUTLANDS, xi.quest.id.outlands.DIVINE_MIGHT_REPEAT) == xi.questStatus.QUEST_ACCEPTED
    then
        return true
    end

    if
        player:getCurrentMission(xi.mission.log_id.ZILART) == xi.mission.id.zilart.ARK_ANGELS and
        player:getMissionStatus(xi.mission.log_id.ZILART) == 1
    then
        return true
    end

    return false
end

content.groups =
{
    {
        mobIds =
        {
            {
                laLoffID.mob.ARK_ANGEL_HM + 24,
                laLoffID.mob.ARK_ANGEL_MR + 22,
                laLoffID.mob.ARK_ANGEL_EV + 16,
                laLoffID.mob.ARK_ANGEL_TT + 14,
                laLoffID.mob.ARK_ANGEL_GK + 12,
            },

            {
                laLoffID.mob.ARK_ANGEL_HM + 32,
                laLoffID.mob.ARK_ANGEL_MR + 30,
                laLoffID.mob.ARK_ANGEL_EV + 24,
                laLoffID.mob.ARK_ANGEL_TT + 22,
                laLoffID.mob.ARK_ANGEL_GK + 20,
            },

            {
                laLoffID.mob.ARK_ANGEL_HM + 40,
                laLoffID.mob.ARK_ANGEL_MR + 38,
                laLoffID.mob.ARK_ANGEL_EV + 32,
                laLoffID.mob.ARK_ANGEL_TT + 30,
                laLoffID.mob.ARK_ANGEL_GK + 28,
            },
        },

        allDeath = function(battlefield, mob)
            battlefield:setStatus(xi.battlefield.status.WON)
        end,
    },

    -- AAMR: Tiger
    {
        mobIds =
        {
            { laLoffID.mob.ARK_ANGEL_MR + 23 },
            { laLoffID.mob.ARK_ANGEL_MR + 31 },
            { laLoffID.mob.ARK_ANGEL_MR + 39 },
        },

        spawned = false,
    },

    -- AAMR: Mandragora
    {
        mobIds =
        {
            { laLoffID.mob.ARK_ANGEL_MR + 24 },
            { laLoffID.mob.ARK_ANGEL_MR + 32 },
            { laLoffID.mob.ARK_ANGEL_MR + 40 },
        },

        spawned = false,
    },

    -- AAGK: Wyvern
    {
        mobIds =
        {
            { laLoffID.mob.ARK_ANGEL_GK + 13 },
            { laLoffID.mob.ARK_ANGEL_GK + 21 },
            { laLoffID.mob.ARK_ANGEL_GK + 29 },
        },

        spawned = false,
    },
}

return content:register()
