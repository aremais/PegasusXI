-----------------------------------
-- Stink Bomb
-- Family: Snapweed
-- Description: Releases a noxious cloud around the caster. Additional Effect: Poison.
-- Type: Status
-- Utsusemi/Blink absorb: Unblockable
-- Range: Self-centered AoE
-- TODO: Verify Poison potency, duration, and whether this deals direct damage from retail captures.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    -- Poison: 15 damage/tick, every 3 seconds, 60 second duration
    skill:setMsg(xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.POISON, 15, 3, 60))

    return xi.effect.POISON
end

return mobskillObject
