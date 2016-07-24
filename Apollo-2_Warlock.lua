Apollo.Warlock = {}
local AW = Apollo.Warlock
local AH = Apollo.Healer

function AW.Controller()
	
	local controllerReturn, idealTarget = 0, nil
	currentSpec = GetSpecialization()
	if currentSpec == 1 then
		skillFunctions = {		--Skill functions that are run to determine priority
			AW.SummonVoidwalker,
			AW.Haunt,
			AW.Agony,
			AW.Corruption,
			AW.UnstableAffliction,
			AW.DrainLife,
			AW.CreateHealthstone,
		}
	elseif currentSpec == 3 then
		skillFunctions = {		--Skill functions that are run to determine priority

		}
	else 
		skillFunctions = {		--Skill functions that are run to determine priority
			AW.DrainLife,
		}
	end
	
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

function AW.DrainLife(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Warlock.DrainLife"
	
	local spellCast = false
	local spellName = "Drain Life"
	local keybinding = 1
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, "target", keybinding);return; end;
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

	return spellCast, spellHeal, keybinding
end

function AW.Corruption(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Warlock.Corruption"
	
	local spellCast = false
	local spellName = "Corruption"
	local keybinding = 2
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, "target", keybinding);return; end;
	if (not UnitExists(spellTarget)) or spellTarget ~= "target" then return false, 0, keybinding; end;
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local affectingCombat = UnitAffectingCombat(spellTarget)
	local cooldown = select(2,GetSpellCooldown(spellName))
	local debuff = UnitDebuff(spellTarget,"Corruption");
	
	if (inRange == 1)
	and (canAttack)
	and (affectingCombat)
	and (cooldown < 2)
	and (not debuff)
	and (not isDead)
	then spellCast = true else spellCast = false; end

	return spellCast, spellHeal, keybinding
end

function AW.CreateHealthstone(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "player"; end;
	local __func__ = "Apollo.Warlock.CreateHealthstone"
	
	local spellCast = false
	local spellName = "Create Healthstone"
	local keybinding = 3
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, "target", keybinding);return; end;
	if (not UnitExists(spellTarget)) or spellTarget ~= "player" then return false, 0, keybinding; end;
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local affectingCombat = UnitAffectingCombat(spellTarget)
	local cooldown = select(2,GetSpellCooldown(spellName))
	local debuff = UnitDebuff(spellTarget,"Corruption");
	local inCombat = InCombatLockdown()
	local casting = UnitCastingInfo("player")
	local itemFound = false
	
	Apollo.Warlock.CreateHealthstoneCast = Apollo.Warlock.CreateHealthstoneCast or 0
	if casting then Apollo.Warlock.CreateHealthstoneCast = GetTime(); end;
	
	for i = 0,4 do
		for j = 1, GetContainerNumSlots(i) do
			if GetContainerItemID(i,j) == 5512 then 
				itemFound = true
			end
		end
		i = i + 1
	end
	
	if (cooldown < 2)
	and (Apollo.Warlock.CreateHealthstoneCast < GetTime() - 3)
	and (not casting)
	and (not itemFound)
	and (not inCombat)
	and (not isDead)
	then spellCast = true else spellCast = false; end

	return spellCast, spellHeal, keybinding
end

function AW.Agony(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Warlock.Agony"
	
	local spellCast = false
	local spellName = "Agony"
	local keybinding = 4
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, "target", keybinding);return; end;
	if (not UnitExists(spellTarget)) or spellTarget ~= "target" then return false, 0, keybinding; end;
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local affectingCombat = UnitAffectingCombat(spellTarget)
	local cooldown = select(2,GetSpellCooldown(spellName))
	local debuff,_,_,_,_,_,expirationTime = UnitDebuff(spellTarget,"Agony")
	local expirationTime = expirationTime or 0
	local timeRemaining = (expirationTime - GetTime())
	
	if (inRange == 1)
	and (canAttack)
	and (affectingCombat)
	and (cooldown < 2)
	and (timeRemaining < 6)
	and (not isDead)
	then spellCast = true else spellCast = false; end

	return spellCast, spellHeal, keybinding
end

function AW.SummonVoidwalker(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "player"; end;
	local __func__ = "Apollo.Warlock.SummonVoidwalker"
	
	local spellCast = false
	local spellName = "Summon Voidwalker"
	local keybinding = 5
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, "target", keybinding);return; end;
	if (not UnitExists(spellTarget)) or spellTarget ~= "player" then return false, 0, keybinding; end;
	
	local isDead = UnitIsDead("player")
	local cooldown = select(2,GetSpellCooldown(spellName))
	local hasPet = HasPetUI()
	local petIsDead = UnitIsDead("pet")
	local soulShards = UnitPower("player",7)
	
	Apollo.Warlock.SummonVoidwalkerCast = Apollo.Warlock.SummonVoidwalkerCast or 0
	if UnitCastingInfo("player") == spellName then Apollo.Warlock.SummonVoidwalkerCast = GetTime(); end;
	
	if (cooldown < 2)
	and (Apollo.Warlock.SummonVoidwalkerCast < GetTime() - 3)
	and (soulShards >= 1)
	and (not isDead)
	and (not hasPet or petIsDead)
	then spellCast = true else spellCast = false; end

	return spellCast, spellHeal, keybinding
end

function AW.UnstableAffliction(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Warlock.UnstableAffliction"
	
	local spellCast = false
	local spellName = "Unstable Affliction"
	local keybinding = 6
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, "target", keybinding);return; end;
	if (not UnitExists(spellTarget)) or spellTarget ~= "target" then return false, 0, keybinding; end;
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local affectingCombat = UnitAffectingCombat(spellTarget)
	local cooldown = select(2,GetSpellCooldown(spellName))
	local debuff = UnitDebuff(spellTarget,"Unstable Affliction");
	local soulShards = UnitPower("player",7)
	
	Apollo.Warlock.UnstableAfflictionCast = Apollo.Warlock.UnstableAfflictionCast or 0
	if UnitCastingInfo("player") == spellName then Apollo.Warlock.UnstableAfflictionCast = GetTime(); end;
	
	if (inRange == 1)
	and (canAttack)
	and (soulShards > 1)
	and (Apollo.Warlock.UnstableAfflictionCast < GetTime() - 3)
	and (affectingCombat)
	and (cooldown < 2)
	and (not debuff)
	and (not isDead)
	then spellCast = true else spellCast = false; end

	return spellCast, spellHeal, keybinding
end

function AW.Haunt(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Warlock.Haunt"
	
	local spellCast = false
	local spellName = "Haunt"
	local keybinding = 7
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, "target", keybinding);return; end;
	if (not UnitExists(spellTarget)) or spellTarget ~= "target" then return false, 0, keybinding; end;
	
	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local affectingCombat = UnitAffectingCombat(spellTarget)
	local cooldown = select(2,GetSpellCooldown(spellName))
	local currentSpeed = GetUnitSpeed("player")
	
	if (inRange == 1)
	and (currentSpeed == 0)
	and (canAttack)
	and (affectingCombat)
	and (cooldown < 2)
	and (not isDead)
	then spellCast = true else spellCast = false; end

	return spellCast, spellHeal, keybinding
end