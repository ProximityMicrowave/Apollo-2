Apollo.Mage = {}
local AM = Apollo.Mage
local AH = Apollo.Healer

function AM.Controller()
	
	local controllerReturn, idealTarget = 0, nil

	skillFunctions = {		--Skill functions that are run to determine priority
		AM.Counterspell,
		AM.FireBlast,
		AM.FrostfireBolt,
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

function AM.FrostfireBolt(spellTarget, rebind)
	if spellTarget == nil then spellTarget = "target"; end;
	local __func__ = "Apollo.Mage.FrostfireBolt"
	local spellName = "Frostfire Bolt"
	local keybinding = 1
	
	--IF REBIND IS SET TO TRUE  THE KEYBINDING WILL BE SET AND THE FUNCTION ENDS ELSE IT WILL CONTINUE AS NORMAL
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding); return; end;

	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local affectingCombat = UnitAffectingCombat(spellTarget);

	
	if (inRange == 1)
	and (canAttack)
	and (affectingCombat)
	and (not isDead)
	then spellCast = true else spellCast = false; end
	
	if spellTarget ~= "target" then spellCast = false; end;
	return spellCast, spellDPS, keybinding
end

function AM.FireBlast(spellTarget, rebind)
	if spellTarget == nil then spellTarget = "target"; end;
	local __func__ = "Apollo.Mage.FireBlast"
	local spellName = "Fire Blast"
	local keybinding = 2
	
	--IF REBIND IS SET TO TRUE  THE KEYBINDING WILL BE SET AND THE FUNCTION ENDS ELSE IT WILL CONTINUE AS NORMAL
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding); return; end;

	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local affectingCombat = UnitAffectingCombat(spellTarget);
	local cooldown = select(2,GetSpellCooldown(spellName))

	
	if (inRange == 1)
	and (canAttack)
	and (affectingCombat)
	and (cooldown < 2)
	and (not isDead)
	then spellCast = true else spellCast = false; end
	
	if spellTarget ~= "target" then spellCast = false; end;
	return spellCast, spellDPS, keybinding
end

function AM.Counterspell(spellTarget, rebind)
	if spellTarget == nil then spellTarget = "target"; end;
	local __func__ = "Apollo.Mage.Counterspell"
	local spellName = "Counterspell"
	local keybinding = 3
	
	--IF REBIND IS SET TO TRUE  THE KEYBINDING WILL BE SET AND THE FUNCTION ENDS ELSE IT WILL CONTINUE AS NORMAL
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding); return; end;

	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local affectingCombat = UnitAffectingCombat(spellTarget);
	local cooldown = select(2,GetSpellCooldown(spellName))
	local isCasting = UnitCastingInfo(spellTarget)

	
	if (inRange == 1)
	and (canAttack)
	and (affectingCombat)
	and (cooldown < 2)
	and (isCasting)
	and (not isDead)
	then spellCast = true else spellCast = false; end
	
	if spellTarget ~= "target" then spellCast = false; end;
	return spellCast, spellDPS, keybinding
end