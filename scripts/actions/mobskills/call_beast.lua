-----------------------------------
-- Call Beast
-- Call my pet.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return xi.pet.onMobSkillCheck(target, mob, skill)
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    -- Anim 718 misbinds on gigas (wrong pose/VFX); 667 is their standard armed TP animation.
    if mob:getFamily() == 126 and mob:getMainJob() == xi.job.BST then
        action:setAnimation(mob:getID(), 667)
    end

    xi.pet.spawnPet(mob, nil, skill)

    return 0
end

return mobskillObject
