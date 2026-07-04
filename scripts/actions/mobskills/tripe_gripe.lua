-----------------------------------
-- Tripe Gripe
-- Trust: Chacharoon
-- Description: Inflicts Amnesia. BG/source notes Attack Boost on the enemy.
-----------------------------------
require('scripts/globals/mobskills')
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    -- Short Amnesia. Power matters for effects that attempt to remove Amnesia.
    local msg = xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.AMNESIA, 1, 0, 30)

    -- Source-confirmed oddity: Tripe Gripe also grants Attack Boost to the enemy.
    -- Kept conservative so it is short-lived and only attempted after the Amnesia call.
    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.ATTACK_BOOST, 25, 0, 30)

    skill:setMsg(msg)
    return xi.effect.AMNESIA
end

return mobskillObject