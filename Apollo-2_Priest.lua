Apollo.Priest = {}
AP = Apollo.Priest

function AP.Controller()
	local highScore, controllerReturn = 0,0

	skillFunctions = {		--Skill functions that are run to determine priority
		AP.Fortitude,
--		AP.Purify,
		AP.Shield,
		AP.FlashHeal,
		AP.Heal,
		AP.Renew,
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
	
	--THIS FUNCTION DETERMINES THE PLAYERS IDEAL TARGET
	for i=1, table.getn(skillFunctions) do
		castSpell, idealTarget = Apollo.Healer.Targeting(skillFunctions[i])
		if castSpell == true then break; end;
	end
	
	--THIS SYSTEM WILL RUN DOWN THE LIST CASTING RETURNING THE FIRST SPELL TO RETURN 
	for i=1, table.getn(skillFunctions) do
		local spellCast, spellDPS, keybinding = skillFunctions[i]()
		if spellCast == true then
			controllerReturn = keybinding
			break;
		end
	end
	
	Apollo.RebindKeys = false
	
-- Debug Code --
--	if controllerReturnDisplay ~= controllerReturn then
--		controllerReturnDisplay = controllerReturn
--		print(controllerReturnDisplay)
--	end
----------------

	return controllerReturn, idealTarget
	
end

function AP.Smite(spellTarget)
--	print("AP.Smite is working!")
	local __func__ = "Apollo.Priest.Smite"

	local spellCast = false
	local spellName = "Smite"
	if spellTarget == nil then spellTarget = "target"; end;
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

function AP.Pain(spellTarget)
--	print("AP.Pain is working!")
	local __func__ = "Apollo.Priest.Pain"

	local spellCast = false
	local spellName = "Shadow Word: Pain"
	if spellTarget == nil then spellTarget = "target"; end;
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

function AP.Shield(spellTarget)
	local __func__ = "Apollo.Priest.Shield"
	
	local spellCast = false
	local spellName = "Power Word: Shield"
	if spellTarget == nil then spellTarget = "focus"; end;
	local castTime = 1.5
	local keybinding = 3

	local spellpower = GetSpellBonusHealing()
	local missingHealth = UnitHealthMax(spellTarget) - UnitHealth(spellTarget)
	local spellHeal = (spellpower * 3.326)			--the healing done by Flash Heal and Heal
	
	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inCombat = InCombatLockdown()
	local inRange = IsSpellInRange(spellName,spellTarget)
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local cooldown = GetSpellCooldown(spellName)
	local isUsable,noMana = IsUsableSpell(spellName)
	local threat = UnitThreatSituation(spellTarget) or 0
	local debuff = UnitDebuff(spellTarget,"Weakened Soul")
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding)
	
	if (not isDead) 
	and (inCombat)
	and (inRange == 1) 
	and (cooldown == 0)
	and (threat >= 2)
	and (isUsable)
	and (missingHealth > spellHeal * 2)
	and (not noMana)
	and (not debuff)
	then spellCast = true; end;
	
	return spellCast, spellHeal, keybinding
end

function AP.FlashHeal(spellTarget)
	local __func__ = "Apollo.Priest.FlashHeal"
	
	local spellCast = false
	local spellName = "Flash Heal"
	if spellTarget == nil then spellTarget = "focus"; end;
	local castTime = 1.5
	local keybinding = 4
	
	local spellpower = GetSpellBonusHealing()
	local missingHealth = UnitHealthMax(spellTarget) - UnitHealth(spellTarget)
	local spellHeal = (spellpower * 3.32657)

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
	and ((healthPct <= .6) or (missingHealth > spellHeal * 4))
	and (isUsable)
	and (not noMana)
	then spellCast = true; end;
	
	return spellCast, spellHeal, keybinding
end

function AP.Fortitude(spellTarget)
	local __func__ = "Apollo.Priest.Fortitude"
	
	local spellCast = false
	local spellName = "Power Word: Fortitude"
	if spellTarget == nil then spellTarget = "focus"; end;
	local castTime = 1.5
	local keybinding = 5
	
	local spellHeal = 1
	
	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inCombat = InCombatLockdown()
	local inRange = IsSpellInRange(spellName,spellTarget)
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local globalcooldown = GetSpellCooldown("Smite")
	local isUsable,noMana = IsUsableSpell(spellName)
	local buff = UnitBuff(spellTarget,spellName)
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding)
	
	if (not isDead) 
	and (inRange == 1) 
	and (globalcooldown == 0)
	and (isUsable)
	and (not noMana)
	and (not buff)
	then spellCast = true; end;
	
	return spellCast, spellHeal, keybinding
end

function AP.Purify(spellTarget)
	local __func__ = "Apollo.Priest.Purify"
	
	local spellCast = false
	local spellName = "Purify"
	if spellTarget == nil then spellTarget = "focus"; end;
	local castTime = 1.5
	local keybinding = 6
	
	local spellHeal = 2

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local debuffFound = AP.DebuffScan(spellTarget)
	local startTime = GetSpellCooldown(spellName)
	local _,noMana = IsUsableSpell("Purify")
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding)
	
	if (not isDead)
	and (not noMana)
	and (startTime == 0)
	and (inRange == 1)
	and (debuffFound)
	then spellCast = true; end;
	
	return spellCast, spellHeal, keybinding
	
end

function AP.Renew(spellTarget)
	local __func__ = "Apollo.Priest.Renew"
	
	local spellCast = false
	local spellName = "Renew"
	if spellTarget == nil then spellTarget = "focus"; end;
	local castTime = 1.5
	local keybinding = 7
	
	local missingHealth = UnitHealthMax(spellTarget) - UnitHealth(spellTarget)
	local spellpower = GetSpellBonusHealing()
	local spellHeal = (spellpower * (.22 + 1.76))
	
	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inCombat = InCombatLockdown()
	local inRange = IsSpellInRange(spellName,spellTarget)
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local globalcooldown = GetSpellCooldown("Smite")
	local isUsable,noMana = IsUsableSpell(spellName)
	local buff = UnitBuff(spellTarget,spellName)
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding)
	
	if (not isDead) 
	and (inRange == 1) 
	and (globalcooldown == 0)
	and (isUsable)
	and (missingHealth >= spellHeal)
	and (not noMana)
	and (not buff)
	then spellCast = true; end;
	
	return spellCast, spellHeal, keybinding
end

function AP.Heal(spellTarget)
	local __func__ = "Apollo.Priest.Heal"
	
	local spellCast = false
	local spellName = "Heal"
	if spellTarget == nil then spellTarget = "focus"; end;
	local castTime = 2.43
	local keybinding = 8
	
	local spellpower = GetSpellBonusHealing()
	local versatility = GetCombatRating(27)
	local missingHealth = UnitHealthMax(spellTarget) - UnitHealth(spellTarget)
	local spellHeal = (spellpower * 3.3264)
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
	and ((healthPct <= .8) or (missingHealth > spellHeal))
	and (isUsable)
	and (not noMana)
	then spellCast = true; end;
	
	return spellCast, spellHeal, keybinding
end