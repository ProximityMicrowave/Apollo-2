Apollo.Paladin = {}
local AP = Apollo.Paladin
local AH = Apollo.Healer
Apollo.Paladin.SpellHealing = {}
APSH = Apollo.Paladin.SpellHealing

function AP.Controller()
	
	local spellpower = GetSpellBonusHealing()
	AP.SpellHealing["Holy Light"] = (spellpower * 3)
	AP.SpellHealing["Flash of Light"] = (spellpower * 2.4)
	AP.SpellHealing["Holy Shock"] = (spellpower * 1.4)

	
	local controllerReturn, idealTarget = 0, nil

	skillFunctions = {		--Skill functions that are run to determine priority
		AP.HolyShock,
		AP.FlashOfLight,
		AP.HolyLight,
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

function AP.HolyLight(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Paladin.HolyLight"
	
	local spellCast = false
	local spellName = "Holy Light"
	local castTime = 2.43
	local keybinding = 1
	
	local missingHealth = Apollo.MissingHealth(spellTarget)
	local spellHeal = APSH["Holy Light"]

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inCombat = InCombatLockdown()
	local inRange = IsSpellInRange(spellName,spellTarget)
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local isUsable,noMana = IsUsableSpell(spellName)
	
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding);return; end;
	
	if (not isDead) 
	and (inRange == 1) 
	and (missingHealth > spellHeal)
	and (isUsable)
	and (not noMana)
	then spellCast = true; end;
	
	if spellTarget == "target" then spellCast = false; end;
	return spellCast, spellHeal, keybinding
end

function AP.FlashOfLight(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Paladin.FlashOfLight"
	
	local spellCast = false
	local spellName = "Flash of Light"
	local castTime = 2.43
	local keybinding = 2
	
	local totalMissingHealth = Apollo.totalMissingHealth
	local missingHealth = Apollo.MissingHealth(spellTarget)
	local spellHeal = APSH["Flash of Light"]

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inCombat = InCombatLockdown()
	local inRange = IsSpellInRange(spellName,spellTarget)
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local isUsable,noMana = IsUsableSpell(spellName)
	
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding);return; end;
	
	if (not isDead) 
	and (inRange == 1) 
	and (missingHealth > UnitHealthMax("player") * .6)
	and (missingHealth > spellHeal)
	and (isUsable)
	and (not noMana)
	then spellCast = true; end;
	
	if spellTarget == "target" then spellCast = false; end;
	return spellCast, spellHeal, keybinding
end

function AP.HolyShock(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Paladin.HolyShock"
	
	local spellCast = false
	local spellName = "Holy Shock"
	local castTime = 2.43
	local keybinding = 3
	
	local totalMissingHealth = Apollo.totalMissingHealth
	local missingHealth = Apollo.MissingHealth(spellTarget)
	local spellHeal = APSH["Holy Shock"]

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inCombat = InCombatLockdown()
	local inRange = IsSpellInRange(spellName,spellTarget)
	local healthPct = Apollo.UnitHealthPct(spellTarget)
	local cooldown = GetSpellCooldown(spellName)
	local isUsable,noMana = IsUsableSpell(spellName)
	
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding);return; end;
	
	if (not isDead)
	and (inRange == 1)
	and (missingHealth > spellHeal)
	and (cooldown == 0)
	and (isUsable)
	and (not noMana)
	then spellCast = true; end;
	
	if spellTarget == "target" then spellCast = false; end;
	return spellCast, spellHeal, keybinding
end
