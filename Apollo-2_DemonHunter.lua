Apollo.DemonHunter = {}
local AD = Apollo.DemonHunter
local AH = Apollo.Healer
Apollo.Paladin.SpellHealing = {}
ADSH = Apollo.Paladin.SpellHealing

function AD.Controller()
	
	local controllerReturn, idealTarget = 0, nil

	skillFunctions = {		--Skill functions that are run to determine priority
		AD.EyeBeam,
		AD.FuryOfTheIllidari,
		AD.ChaosNova,
		AD.BladeDance,
		AD.ChaosStrike,
		AD.ThrowGlaive,
		AD.DemonsBite,
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

function AD.DemonsBite(spellTarget, rebind)
	if spellTarget == nil then spellTarget = "target"; end;
	local __func__ = "Apollo.DemonHunter.DemonsBite"
	local spellName = "Demon's Bite"
	local keybinding = 1
	
	--IF REBIND IS SET TO TRUE  THE KEYBINDING WILL BE SET AND THE FUNCTION ENDS ELSE IT WILL CONTINUE AS NORMAL
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding); return; end;
	if (not UnitExists(spellTarget)) or spellTarget ~= "target" then return false, 0, keybinding; end;
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local affectingCombat = UnitAffectingCombat(spellTarget)
	
	if (inRange == 1)
	and (canAttack)
	and (affectingCombat)
	and (not isDead)
	then spellCast = true else spellCast = false; end
	
	return spellCast, spellDPS, keybinding
end

function AD.ChaosStrike(spellTarget, rebind)
	if spellTarget == nil then spellTarget = "target"; end;
	local __func__ = "Apollo.DemonHunter.ChaosStrike"
	local spellName = "Chaos Strike"
	local keybinding = 2
	
	--IF REBIND IS SET TO TRUE  THE KEYBINDING WILL BE SET AND THE FUNCTION ENDS ELSE IT WILL CONTINUE AS NORMAL
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding); return; end;
	if (not UnitExists(spellTarget)) or spellTarget ~= "target" then return false, 0, keybinding; end;
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local affectingCombat = UnitAffectingCombat(spellTarget)
	local power = UnitPower("player")
	
	if (inRange == 1)
	and (canAttack)
	and (power >= 75)
	and (affectingCombat)
	and (not isDead)
	then spellCast = true else spellCast = false; end
	
	return spellCast, spellDPS, keybinding
end

function AD.ThrowGlaive(spellTarget, rebind)
	if spellTarget == nil then spellTarget = "target"; end;
	local __func__ = "Apollo.DemonHunter.ThrowGlaive"
	local spellName = "Throw Glaive"
	local keybinding = 3
	
	--IF REBIND IS SET TO TRUE  THE KEYBINDING WILL BE SET AND THE FUNCTION ENDS ELSE IT WILL CONTINUE AS NORMAL
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding); return; end;
	if (not UnitExists(spellTarget)) or spellTarget ~= "target" then return false, 0, keybinding; end;
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local affectingCombat = UnitAffectingCombat(spellTarget)
	local cooldown = select(2,GetSpellCooldown(spellName))
	
	if (inRange == 1)
	and (canAttack)
	and (affectingCombat)
	and (cooldown < 2)
	and (not isDead)
	then spellCast = true else spellCast = false; end
	
	return spellCast, spellDPS, keybinding
end

function AD.BladeDance(spellTarget, rebind)
	if spellTarget == nil then spellTarget = "target"; end;
	local __func__ = "Apollo.DemonHunter.BladeDance"
	local spellName = "Blade Dance"
	local keybinding = 4
	
	--IF REBIND IS SET TO TRUE  THE KEYBINDING WILL BE SET AND THE FUNCTION ENDS ELSE IT WILL CONTINUE AS NORMAL
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding); return; end;
	if (not UnitExists(spellTarget)) or spellTarget ~= "target" then return false, 0, keybinding; end;
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange( "Demon's Bite",spellTarget)
	local affectingCombat = UnitAffectingCombat(spellTarget)
	local cooldown = select(2,GetSpellCooldown(spellName))
	local power = UnitPower("player")
	
	if (inRange == 1)
	and (canAttack)
	and (affectingCombat)
	and (cooldown < 2)
	and (power >= 35)
	and (not isDead)
	then spellCast = true else spellCast = false; end
	
	return spellCast, spellDPS, keybinding
end

function AD.ChaosNova(spellTarget, rebind)
	if spellTarget == nil then spellTarget = "target"; end;
	local __func__ = "Apollo.DemonHunter.ChaosNova"
	local spellName = "Chaos Nova"
	local keybinding = 5
	
	--IF REBIND IS SET TO TRUE  THE KEYBINDING WILL BE SET AND THE FUNCTION ENDS ELSE IT WILL CONTINUE AS NORMAL
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding); return; end;
	if (not UnitExists(spellTarget)) or spellTarget ~= "target" then return false, 0, keybinding; end;
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange( "Demon's Bite",spellTarget)
	local affectingCombat = UnitAffectingCombat(spellTarget)
	local cooldown = select(2,GetSpellCooldown(spellName))
	local power = UnitPower("player")
	
	if (inRange == 1)
	and (canAttack)
	and (affectingCombat)
	and (cooldown < 2)
	and (power >= 35)
	and (not isDead)
	then spellCast = true else spellCast = false; end
	
	return spellCast, spellDPS, keybinding
end

function AD.EyeBeam(spellTarget, rebind)
	if spellTarget == nil then spellTarget = "target"; end;
	local __func__ = "Apollo.DemonHunter.EyeBeam"
	local spellName = "Eye Beam"
	local keybinding = 6
	
	--IF REBIND IS SET TO TRUE  THE KEYBINDING WILL BE SET AND THE FUNCTION ENDS ELSE IT WILL CONTINUE AS NORMAL
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding); return; end;
	if (not UnitExists(spellTarget)) or spellTarget ~= "target" then return false, 0, keybinding; end;
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange( "Demon's Bite",spellTarget)
	local affectingCombat = UnitAffectingCombat(spellTarget)
	local cooldown = select(2,GetSpellCooldown(spellName))
	local power = UnitPower("player")
	
	if (inRange == 1)
	and (canAttack)
	and (affectingCombat)
	and (cooldown < 2)
	and (power >= 50)
	and (not isDead)
	then spellCast = true else spellCast = false; end
	
	return spellCast, spellDPS, keybinding
end

function AD.FuryOfTheIllidari(spellTarget, rebind)
	if spellTarget == nil then spellTarget = "target"; end;
	local __func__ = "Apollo.DemonHunter.FuryOfTheIllidari"
	local spellName = "Fury of the Illidari"
	local keybinding = 7
	
	--IF REBIND IS SET TO TRUE  THE KEYBINDING WILL BE SET AND THE FUNCTION ENDS ELSE IT WILL CONTINUE AS NORMAL
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding); return; end;
	if (not UnitExists(spellTarget)) or spellTarget ~= "target" then return false, 0, keybinding; end;
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange( "Demon's Bite",spellTarget)
	local affectingCombat = UnitAffectingCombat(spellTarget)
	local cooldown = select(2,GetSpellCooldown(spellName))
	local power = UnitPower("player")
	
	if (inRange == 1)
	and (canAttack)
	and (affectingCombat)
	and (cooldown < 2)
	and (power >= 50)
	and (not isDead)
	then spellCast = true else spellCast = false; end
	
	return spellCast, spellDPS, keybinding
end