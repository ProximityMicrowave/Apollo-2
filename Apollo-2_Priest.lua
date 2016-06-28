Apollo.Priest = {}
AP = Apollo.Priest

function AP.Controller()
	local highScore, controllerReturn = 0,0

	skillFunctions = {		--Skill functions that are run to determine priority
		AP.Shield,
		AP.FlashHeal,
		AP.Pain,
		AP.Smite,
	}
	
	--THIS SYSTEM WILL USE A NUMBERED PRIORITY SYSTEM FOR DECIDING WHICH SKILL TO CAST
--	skillList = {}
--	for i=1, table.getn(skillFunctions) do
--		skillList[i] = {skillFunctions[i]()}
--		if skillList[i][1] == true then
--			if skillList[i][2] >  highScore then
--				highScore = skillList[i][2]
--				controllerReturn = skillList[i][3]
--			end
--		end		
--	end

	--THIS SYSTEM WILL RUN DOWN THE LIST CASTING RETURNING THE FIRST SPELL TO RETURN 
	skillList = {}
	for i=1, table.getn(skillFunctions) do
		skillList[i] = {skillFunctions[i]()}
		if skillList[i][1] == true then
			return skillList[i][3]
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

function AP.Shield()
	local __func__ = "Apollo.Priest.Shield"
	
	local spellCast = false
	local spellName = "Power Word: Shield"
	local spellTarget = "focus"
	local castTime = 1.5
	local keybinding = 3
	
	local spellpower = GetSpellBonusHealing()
	local versatility = GetCombatRating(27)
	local missingHealth = UnitHealthMax(spellTarget) - UnitHealth(spellTarget)
	local spellHeal = ((((spellpower * 4.59) + 2) * 1) * (1 + versatility))
	if spellHeal >= missingHealth then spellHeal = missingHealth; end;

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inCombat = InCombatLockdown()
	local inRange = IsSpellInRange(spellName,spellTarget)
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local globalcooldown = GetSpellCooldown("Smite")
	local isUsable,noMana = IsUsableSpell(spellName)
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding)
	
	if (not isDead) 
	and (inCombat)
	and (inRange == 1) 
	and (globalcooldown == 0)
	and (UnitHealth(spellTarget) <= UnitHealthMax("player") * .3) 
	and (isUsable)
	and (not noMana)
	then spellCast = true; end;
	
	return spellCast, spellHeal, keybinding
end

function AP.FlashHeal()
	local __func__ = "Apollo.Priest.FlashHeal"
	
	local spellCast = false
	local spellName = "Flash Heal"
	local spellTarget = "focus"
	local castTime = 1.5
	local keybinding = 4
	
	local spellpower = GetSpellBonusHealing()
	local versatility = GetCombatRating(27)
	local missingHealth = UnitHealthMax(spellTarget) - UnitHealth(spellTarget)
	local spellHeal = (spellpower * 3.32657)
	if spellHeal >= missingHealth then spellHeal = missingHealth; end;

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inCombat = InCombatLockdown()
	local inRange = IsSpellInRange(spellName,spellTarget)
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local globalcooldown = GetSpellCooldown("Smite")
	local isUsable,noMana = IsUsableSpell(spellName)
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding)
	
	if (not isDead) 
	and (inRange == 1) 
	and (globalcooldown == 0)
	and (healthPct <= .9)
	and (isUsable)
	and (not noMana)
	then spellCast = true; end;
	
	return spellCast, spellHeal, keybinding
end
