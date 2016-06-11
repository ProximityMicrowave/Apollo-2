Apollo.Priest = {}
AP = Apollo.Priest

function AP.Controller()
	local highScore, controllerReturn = 0,0

	skillFunctions = {		--Skill functions that are run to determine priority
		AP.Smite,
		AP.Pain,
	}
	
	skillList = {}
	for i=1, table.getn(skillFunctions) do
		skillList[i] = {skillFunctions[i]()}
		if skillList[i][1] == true then
			if skillList[i][2] >  highScore then
				highScore = skillList[i][2]
				controllerReturn = skillList[i][3]
			end
		end		
	end
	
	Apollo.RebindKeys = false
	
-- Debug Code --
--	if controllerReturnDisplay ~= controllerReturn then
--		controllerReturnDisplay = controllerReturn
--		print(controllerReturnDisplay)
--	end
----------------

	return controllerReturn
	
end

function AP.Smite()
--	print("AP.Smite is working!")
	local __func__ = "Apollo.Priest.Smite"

	local spellCast = false
	local spellName = "Smite"
	local spellTarget = "target"
	local castTime = 1.5
	local keybinding = 1
	
	local spellpower = GetSpellBonusDamage(2)
	local spellDPS = spellpower * 0.92448 * (1/castTime)

	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding)
	
	if (inRange == 1) 
	and (canAttack) 
	and (not isDead) 
	then spellCast = true; end
	
	return spellCast, spellDPS, keybinding

end

function AP.Pain()
--	print("AP.Pain is working!")
	local __func__ = "Apollo.Priest.Pain"

	local spellCast = false
	local spellName = "Shadow Word: Pain"
	local spellTarget = "target"
	local castTime = 1.5
	local keybinding = 2
	
	local spellpower = GetSpellBonusDamage(6)
	local spellDPS = (spellpower * (0.475 + 2.85) * (1/castTime))

	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local debuff = UnitDebuff(spellTarget,spellName)
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding)
	
	if (inRange == 1) 
	and (canAttack) 
	and (not isDead) 
	and (not debuff)
	then spellCast = true; end
	
	return spellCast, spellDPS, keybinding

end