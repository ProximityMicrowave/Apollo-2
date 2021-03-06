Apollo.Priest = {}
local AP = Apollo.Priest
local AH = Apollo.Healer
Apollo.Priest.SpellHealing = {}
APSH = Apollo.Priest.SpellHealing

function AP.Controller()
	
	local spellpower = GetSpellBonusHealing()
	AP.SpellHealing["FlashHeal"] = (spellpower * 3.33)
	AP.SpellHealing["Heal"] = (spellpower * 3.33)
	AP.SpellHealing["Renew"] = (spellpower * (.22 + 1.76))
	AP.SpellHealing["PrayerOfHealing"] = (spellpower * 2.21664)
	
	local controllerReturn, idealTarget = 0, nil

	skillFunctions = {		--Skill functions that are run to determine priority
--		AP.Resurrection,
		AP.Fade,
		AP.Fortitude,
--		AP.Purify,
		AP.Shield,
		AP.FlashHeal,
		AP.Renew,
		AP.PrayerOfHealing,
		AP.Heal,
		AP.Pain,
		AP.Smite,
	}
	
	if Apollo.RebindKeys == true then
		for i=1, table.getn(skillFunctions) do
			skillFunctions[i](nil, true)
		end
		Apollo.RebindKeys = false
	end
	
	--THIS FUNCTION DETERMINES THE PLAYERS IDEAL TARGET AND SKILL

	for i in ipairs(skillFunctions) do
		local a, b, c = AH.Targeting(skillFunctions[i])
--		print(i, a, b, c)
		if a == true then 
			idealTarget = b
			controllerReturn = c
			break
		else
			idealTarget = nil
			controllerReturn = 0
		end
	end
	
	return controllerReturn, idealTarget
	
end

function AP.Smite(spellTarget, rebind)
	if spellTarget == nil then spellTarget = "target"; end;
	local __func__ = "Apollo.Priest.Smite"
	local spellName = "Smite"
	local keybinding = 1
	
	--IF REBIND IS SET TO TRUE  THE KEYBINDING WILL BE SET AND THE FUNCTION ENDS ELSE IT WILL CONTINUE AS NORMAL
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding); return; end;

	local castTime = 1.5
	local spellpower = GetSpellBonusDamage(2)
	local spellDPS = spellpower * 0.92448 * (1/castTime)

	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	
	if (inRange == 1)
	and (canAttack)
	and (not isDead)
	then spellCast = true else spellCast = false; end
	
	return spellCast, spellDPS, keybinding

end

function AP.Pain(spellTarget, rebind)
	if spellTarget == nil then spellTarget = "target"; end;
	local __func__ = "Apollo.Priest.Pain"
	local spellName = "Shadow Word: Pain"
	local keybinding = 2
	
	--IF REBIND IS SET TO TRUE  THE KEYBINDING WILL BE SET AND THE FUNCTION ENDS ELSE IT WILL CONTINUE AS NORMAL
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding); return; end;
	
	local castTime = 1.5
	local spellpower = GetSpellBonusDamage(6)
	local spellDPS = (spellpower * (0.475 + 2.85) * (1/castTime))

	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local debuff = UnitDebuff(spellTarget,spellName)
	
	if (inRange == 1) 
	and (canAttack) 
	and (not isDead) 
	and (not debuff)
	then spellCast = true else spellCast = false; end
	
	return spellCast, spellDPS, keybinding

end

function AP.Shield(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	
	local __func__ = "Apollo.Priest.Shield"
	
	local spellCast = false
	local spellName = "Power Word: Shield"
	local castTime = 1.5
	local keybinding = 3
	
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding);return; end;

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
	
	if (not isDead) 
	and (inRange == 1) 
	and (cooldown == 0)
	and (threat >= 2)
	and (isUsable)
	and (missingHealth > spellHeal * 2)
	and (not noMana)
	and (not debuff)
	then spellCast = true; end;
	
	if spellTarget == "target" then spellCast = false; end;
	return spellCast, spellHeal, keybinding
end

function AP.FlashHeal(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Priest.FlashHeal"
	
	local spellCast = false
	local spellName = "Flash Heal"
	local castTime = 1.5
	local keybinding = 4
	
	local missingHealth = Apollo.MissingHealth(spellTarget)

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inCombat = InCombatLockdown()
	local inRange = IsSpellInRange(spellName,spellTarget)
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local globalcooldown = GetSpellCooldown("Smite")
	local isUsable,noMana = IsUsableSpell(spellName)
	local threat = UnitThreatSituation(spellTarget) or 0
	
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding);return; end;
	
	if (not isDead) 
	and (inRange == 1) 
	and (UnitHealth(spellTarget) < UnitHealthMax("player"))
	and (missingHealth > APSH["FlashHeal"] + APSH["Renew"])
	and (threat >= 2)
	and (isUsable)
	and (not noMana)
	then spellCast = true; end;
	
	if spellTarget == "target" then spellCast = false; end;
	return spellCast, spellHeal, keybinding
end

function AP.Fortitude(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Priest.Fortitude"
	
	local spellCast = false
	local spellName = "Power Word: Fortitude"
	local castTime = 1.5
	local keybinding = 5
	local spellHeal = 1
	
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding);return; end;
	
	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inCombat = InCombatLockdown()
	local inRange = IsSpellInRange(spellName,spellTarget)
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local globalcooldown = GetSpellCooldown("Smite")
	local isUsable,noMana = IsUsableSpell(spellName)
	local buff = UnitBuff(spellTarget,spellName)
	
	if (not isDead) 
	and (inRange == 1) 
	and (isUsable)
	and (not noMana)
	and (not buff)
	then spellCast = true; end;
	
	if spellTarget == "target" then spellCast = false; end;
	return spellCast, spellHeal, keybinding
end

function AP.Purify(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Priest.Purify"
	
	local spellCast = false
	local spellName = "Purify"
	local castTime = 1.5
	local keybinding = 6
	
	local spellHeal = 2

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local debuffFound = AP.DebuffScan(spellTarget)
	local startTime = GetSpellCooldown(spellName)
	local _,noMana = IsUsableSpell("Purify")
	
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding); end;
	
	if (not isDead)
	and (not noMana)
	and (startTime == 0)
	and (inRange == 1)
	and (debuffFound)
	then spellCast = true; end;
	
	if spellTarget == "target" then spellCast = false; end;
	return spellCast, spellHeal, keybinding
	
end

function AP.Renew(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Priest.Renew"
	
	local spellCast = false
	local spellName = "Renew"
	local castTime = 1.5
	local keybinding = 7
	
	local missingHealth = Apollo.MissingHealth(spellTarget)
	
	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inCombat = InCombatLockdown()
	local inRange = IsSpellInRange(spellName,spellTarget)
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local globalcooldown = GetSpellCooldown("Smite")
	local isUsable,noMana = IsUsableSpell(spellName)
	local buff = UnitBuff(spellTarget,spellName)
	
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding);return; end;
	
	if (not isDead) 
	and (inCombat)
	and (inRange == 1) 
	and (isUsable)
	and (missingHealth >= APSH["Renew"])
	and (not noMana)
	and (not buff)
	then spellCast = true; end;
	
	if spellTarget == "target" then spellCast = false; end;
	return spellCast, spellHeal, keybinding
end

function AP.Heal(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Priest.Heal"
	
	local spellCast = false
	local spellName = "Heal"
	local castTime = 2.43
	local keybinding = 8
	
	local missingHealth = Apollo.MissingHealth(spellTarget)
	local spellHeal = APSH["Heal"]

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inCombat = InCombatLockdown()
	local inRange = IsSpellInRange(spellName,spellTarget)
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local globalcooldown = GetSpellCooldown("Smite")
	local isUsable,noMana = IsUsableSpell(spellName)
	
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding);return; end;
	
	if (not isDead) 
	and (inRange == 1) 
	and ((healthPct <= .8) or (missingHealth > spellHeal + APSH["Renew"]))
	and (isUsable)
	and (not noMana)
	then spellCast = true; end;
	
	if spellTarget == "target" then spellCast = false; end;
	return spellCast, spellHeal, keybinding
end

function AP.Resurrection(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Priest.Resurrection"
	
	local spellCast = false
	local spellName = "Resurrection"
	local castTime = 9.67
	local spellHeal = 0
	local keybinding = 9
	
	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inCombat = InCombatLockdown()
	local inRange = IsSpellInRange(spellName,spellTarget)
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local globalcooldown = GetSpellCooldown("Smite")
	local isUsable,noMana = IsUsableSpell(spellName)
	
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding);return; end;
	
	if (isDead)
	and (not inCombat)
	and (inRange == 1)
	and (isUsable)
	and (not noMana)
	and (UnitHasIncomingResurrection(spellTarget) == false)
	then spellCast = true; end;
	
	if spellTarget == target then spellCast = false; end;
	return spellCast, spellHeal, keybinding

end

function AP.Fade(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "player"; end;
	
	local __func__ = "Apollo.Priest.Fade"
	
	local spellCast = false
	local spellName = "Fade"
	local castTime = 1.5
	local keybinding = 10
	local spellHeal = 0
	
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding);return; end;

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inCombat = InCombatLockdown()
	local inRange = IsSpellInRange(spellName,spellTarget)
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local cooldown = GetSpellCooldown(spellName)
	local isUsable,noMana = IsUsableSpell(spellName)
	local threat = UnitThreatSituation(spellTarget) or 0
	
	if (not isDead)
	and (inCombat)
	and (cooldown == 0)
	and (threat >= 2)
	and (isUsable)
	and (not noMana)
	then spellCast = true; end;
	
	if spellTarget ~= "player" then spellCast = false; end;
	return spellCast, spellHeal, keybinding
end

function AP.PrayerOfHealing(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Priest.PrayerOfHealing"
	
	local spellCast = false
	local spellName = "Prayer of Healing"
	local castTime = 2.5
	local keybinding = 11
	
	local lowHealthCount = Apollo.LowHealthCount(APSH["PrayerOfHealing"]*-1)

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inCombat = InCombatLockdown()
	local inRange = IsSpellInRange(spellName,spellTarget)
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local isUsable,noMana = IsUsableSpell(spellName)
	
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding);return; end;
	
	if (not isDead) 
	and (inRange == 1) 
	and (lowHealthCount >= 3)
	and (isUsable)
	and (not noMana)
	then spellCast = true; end;
	
	if spellTarget == "target" then spellCast = false; end;
	return spellCast, spellHeal, keybinding
end