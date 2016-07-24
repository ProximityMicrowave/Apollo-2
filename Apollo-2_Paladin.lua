Apollo.Paladin = {}
local AP = Apollo.Paladin
local AH = Apollo.Healer
Apollo.Paladin.SpellHealing = {}
APSH = Apollo.Paladin.SpellHealing

function AP.Controller()
	
	local spellpower = GetSpellBonusHealing()
	AP.SpellHealing["Holy Light"] = (spellpower * 4.25)
	AP.SpellHealing["Flash of Light"] = (spellpower * 4.25)
	AP.SpellHealing["Holy Shock"] = (spellpower * 4)
	
	local controllerReturn, idealTarget = 0, nil
	currentSpec = GetSpecialization()
	if currentSpec == 1 then
		if IsInInstance() then 
			skillFunctions = {		--Skill functions that are run to determine priority
				AP.Cleanse,
				AP.BlessingOfSacrifice,
				AP.LightOfTheMartyr,
				AP.HolyShockHeal,
				AP.FlashOfLight,
				AP.HolyLight,
				AP.Judgment,
	--			AP.AttackHolyShock,
				AP.CrusaderStrike,
			}
		else
			skillFunctions = {		--Skill functions that are run to determine priority
				AP.Cleanse,
				AP.BlessingOfSacrifice,
				AP.Judgment,
				AP.AttackHolyShock,
				AP.CrusaderStrike,
				AP.Consecration,
				AP.HolyShockHeal,
				AP.LightOfTheMartyr,
				AP.FlashOfLight,
				AP.HolyLight,
			}
		end
	end
	if currentSpec == 3 then
		skillFunctions = {		--Skill functions that are run to determine priority
			AP.Judgment,
			AP.TemplarsVerdict,
			AP.BladeOfJustice,
			AP.CrusaderStrike,
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

function AP.HolyShockHeal(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Paladin.HolyShockHeal"
	
	local spellCast = false
	local spellName = "Holy Shock"
	local keybinding = 1
	if rebind == true then
		if not InCombatLockdown() and Apollo.RebindKeys then
			if Apollo.HolyShockHeal == nil then Apollo.HolyShockHeal = CreateFrame("Button", "HolyShockHeal", UIParent, "SecureActionButtonTemplate"); end;
			Apollo.HolyShockHeal:SetAttribute("type", "macro");
			Apollo.HolyShockHeal:SetAttribute("macrotext", "/use [nochanneling,@focus] Holy Shock")
			SetBinding(Apollo_Ability.KeyBinding[keybinding])
			SetBindingClick(Apollo_Ability.KeyBinding[keybinding], "HolyShockHeal")
		end
	end
	if (not UnitExists(spellTarget)) or spellTarget == "target" then return false, 0, keybinding; end;
	
	local totalMissingHealth = Apollo.totalMissingHealth
	local missingHealth = Apollo.MissingHealth(spellTarget)
	local spellHeal = AP.SpellHealing["Holy Shock"]

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local cooldown = select(2,GetSpellCooldown(spellName))
	local isUsable,noMana = IsUsableSpell(spellName)
	
	if (not isDead)
	and (inRange == 1)
	and (missingHealth > spellHeal * 2)
	and (cooldown < 2)
	and (isUsable)
	and (not noMana)
	then spellCast = true; end;

	return spellCast, spellHeal, keybinding

end

function AP.AttackHolyShock(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "target"; end;
	local __func__ = "Apollo.Paladin.AttackHolyShock"
	
	local spellCast = false
	local spellName = "Holy Shock"
	local keybinding = 2
	if rebind == true then
		if not InCombatLockdown() and Apollo.RebindKeys then
			if Apollo.HolyShockAttack == nil then Apollo.HolyShockAttack = CreateFrame("Button", "HolyShockAttack", UIParent, "SecureActionButtonTemplate"); end;
			Apollo.HolyShockAttack:SetAttribute("type", "macro");
			Apollo.HolyShockAttack:SetAttribute("macrotext", "/use [nochanneling,@target] Holy Shock")
			SetBinding(Apollo_Ability.KeyBinding[keybinding])
			SetBindingClick(Apollo_Ability.KeyBinding[keybinding], "HolyShockAttack")
		end
	end
	if (not UnitExists(spellTarget)) or spellTarget ~= "target" then return false, 0, keybinding; end;
	
	local totalMissingHealth = Apollo.totalMissingHealth
	local missingHealth = Apollo.MissingHealth(spellTarget)
	local spellHeal = AP.SpellHealing["Holy Shock"]

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

function AP.Judgment(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Paladin.Judgment"
	
	local spellCast = false
	local spellName = "Judgment"
	local keybinding = 3
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, "target", keybinding);return; end;
	if (not UnitExists(spellTarget)) or spellTarget ~= "target" then return false, 0, keybinding; end;
	
	local totalMissingHealth = Apollo.totalMissingHealth
	local missingHealth = Apollo.MissingHealth(spellTarget)
	local spellHeal = AP.SpellHealing["Holy Shock"]

	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local affectingCombat = UnitAffectingCombat(spellTarget)
	local cooldown = select(2,GetSpellCooldown(spellName))
	
	if (inRange == 1)
	and (canAttack)
--	and (affectingCombat)
	and (cooldown < 2)
	and (not isDead)
	then spellCast = true else spellCast = false; end

	return spellCast, spellHeal, keybinding

end

function AP.CrusaderStrike(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Paladin.CrusaderStrike"
	
	local spellCast = false
	local spellName = "Crusader Strike"
	local keybinding = 4
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, "target", keybinding);return; end;
	if (not UnitExists(spellTarget)) or spellTarget ~= "target" then return false, 0, keybinding; end;
	
	local totalMissingHealth = Apollo.totalMissingHealth
	local missingHealth = Apollo.MissingHealth(spellTarget)
	local spellHeal = AP.SpellHealing["Holy Shock"]

	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local affectingCombat = UnitAffectingCombat(spellTarget)
	local cooldown = select(2,GetSpellCooldown(spellName))
	
	if (inRange == 1)
	and (canAttack)
--	and (affectingCombat)
	and (cooldown < 2)
	and (not isDead)
	then spellCast = true else spellCast = false; end

	return spellCast, spellHeal, keybinding
end

function AP.HolyLight(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Paladin.HolyLight"
	
	local spellCast = false
	local spellName = "Holy Light"
	local keybinding = 5
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, "focus", keybinding);return; end;
	if (not UnitExists(spellTarget)) or spellTarget == "target" then return false, 0, keybinding; end;
	
	local missingHealth = Apollo.MissingHealth(spellTarget)
	local spellHeal = AP.SpellHealing["Holy Light"]

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local isUsable,noMana = IsUsableSpell(spellName)
	
	if (not isDead) 
	and (inRange == 1) 
	and (missingHealth > spellHeal * 2)
	and (isUsable)
	and (not noMana)
	then spellCast = true; end;

	return spellCast, spellHeal, keybinding
end

function AP.Consecration(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Paladin.Consecration"
	
	local spellCast = false
	local spellName = "Consecration"
	local keybinding = 6
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, "target", keybinding);return; end;
	if (not UnitExists(spellTarget)) or spellTarget ~= "target" then return false, 0, keybinding; end;
	
	local totalMissingHealth = Apollo.totalMissingHealth
	local missingHealth = Apollo.MissingHealth(spellTarget)
	local spellHeal = AP.SpellHealing["Holy Shock"]

	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange("Crusader Strike",spellTarget)
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

function AP.Cleanse(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Paladin.Cleanse"
	
	local spellCast = false
	local spellName = "Cleanse"
	local castTime = 2.43
	local keybinding = 7
	
	local debuff = false
	local debuffList = {"Aqua Bomb", "Shadow Word: Pain", "Corruption", "Drain Life", "Curse of Exhaustion", "Immolate", "Conflagrate", "Dancing Flames", "Withering Flames", "Salve of Toxic Fumes", "Unstable Afliction"}
	
	for i,v in ipairs(debuffList) do
		if UnitDebuff(spellTarget,v) then debuff = true; break; end;
	end
	if UnitDebuff(spellTarget,"Unstable Affliction") then debuff = false; end;
	
	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local isUsable,noMana = IsUsableSpell(spellName)
	local cooldown = select(2,GetSpellCooldown(spellName))
	
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding);return; end;
	
	if (not isDead)
	and (inRange == 1)
	and (isUsable)
	and (not noMana)
	and (debuff)
	and (cooldown < 2)
	then spellCast = true; end;
	
	if spellTarget == "target" then spellCast = false; end;
	return spellCast, spellHeal, keybinding
end

function AP.FlashOfLight(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Paladin.FlashOfLight"
	
	local spellCast = false
	local spellName = "Flash of Light"
	local keybinding = 8
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, "focus", keybinding);return; end;
	if (not UnitExists(spellTarget)) or spellTarget == "target" then return false, 0, keybinding; end;
	
	local missingHealth = Apollo.MissingHealth(spellTarget)
	local spellHeal = AP.SpellHealing["Flash of Light"]

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local isUsable,noMana = IsUsableSpell(spellName)
	
	if (not isDead) 
	and (inRange == 1) 
	and (missingHealth > spellHeal * 2)
--	and (AP.EmergencyConditions(spellTarget))
	and (isUsable)
	and (not noMana)
	then spellCast = true; end;

	return spellCast, spellHeal, keybinding
end

function AP.LightOfTheMartyr(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Paladin.LightOfTheMartyr"
	
	local spellCast = false
	local spellName = "Light of the Martyr"
	local keybinding = 9
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, "focus", keybinding);return; end;
	if (not UnitExists(spellTarget)) or spellTarget == "target" then return false, 0, keybinding; end;
	
	local missingHealth = Apollo.MissingHealth(spellTarget)
	local spellHeal = AP.SpellHealing["Flash of Light"]

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local isUsable,noMana = IsUsableSpell(spellName)
	local playerHealth = Apollo.UnitHealthPct("player")
	local targetHealth = Apollo.UnitHealthPct(spellTarget)
	
	if (not isDead) 
	and (inRange == 1) 
	and (missingHealth > spellHeal * 2)
	and (targetHealth < playerHealth)
	and (not UnitIsUnit("player",spellTarget))
--	and (AP.EmergencyConditions(spellTarget))
	and (playerHealth > .7)
	and (isUsable)
	and (not noMana)
	then spellCast = true; end;

	return spellCast, spellHeal, keybinding
end

function AP.BlessingOfSacrifice(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Paladin.BlessingOfSacrifice"
	
	local spellCast = false
	local spellName = "Blessing of Sacrifice"
	local keybinding = 10
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, "focus", keybinding);return; end;
	if (not UnitExists(spellTarget)) or spellTarget == "target" then return false, 0, keybinding; end;
	
	local missingHealth = Apollo.MissingHealth(spellTarget)
	local spellHeal = AP.SpellHealing["Flash of Light"]

	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local isUsable,noMana = IsUsableSpell(spellName)
	local playerHealth = Apollo.UnitHealthPct("player")
	local targetHealth = Apollo.UnitHealthPct(spellTarget)
	local cooldown = select(2,GetSpellCooldown(spellName))
	local lowHealthCount = Apollo.LowHealthCount(UnitHealthMax("player") * .7)
	local threat = UnitThreatSituation(spellTarget) or 0
	
	if (not isDead) 
	and (inRange == 1) 
	and (missingHealth > spellHeal * 2)
	and (targetHealth < playerHealth)
	and (not UnitIsUnit("player",spellTarget))
	and (lowHealthCount >= 1)
	and (playerHealth > .7)
	and (cooldown < 2)
	and (threat >= 2)
	and (isUsable)
	and (not noMana)
	then spellCast = true; end;

	return spellCast, spellHeal, keybinding
end

function AP.TemplarsVerdict(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Paladin.TemplarsVerdict"
	
	local spellCast = false
	local spellName = "Templar's Verdict"
	local keybinding = 11
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, "target", keybinding);return; end;
	if (not UnitExists(spellTarget)) or spellTarget ~= "target" then return false, 0, keybinding; end;
	
	local totalMissingHealth = Apollo.totalMissingHealth
	local missingHealth = Apollo.MissingHealth(spellTarget)
	local spellHeal = AP.SpellHealing["Holy Shock"]

	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local affectingCombat = UnitAffectingCombat(spellTarget)
	local cooldown = select(2,GetSpellCooldown(spellName))
	local holyPower = UnitPower("player",9)
	local unitBuff = UnitBuff("player","Divine Purpose")
	
	if (inRange == 1)
	and (canAttack)
--	and (affectingCombat)
	and ((holyPower >= 3) or (unitBuff))
	and (cooldown < 2)
	and (not isDead)
	then spellCast = true else spellCast = false; end

	return spellCast, spellHeal, keybinding
end

function AP.BladeOfJustice(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Paladin.BladeOfJustice"
	
	local spellCast = false
	local spellName = "Blade of Justice"
	local keybinding = 12
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, "target", keybinding);return; end;
	if (not UnitExists(spellTarget)) or spellTarget ~= "target" then return false, 0, keybinding; end;
	
	local totalMissingHealth = Apollo.totalMissingHealth
	local missingHealth = Apollo.MissingHealth(spellTarget)
	local spellHeal = AP.SpellHealing["Holy Shock"]

	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local affectingCombat = UnitAffectingCombat(spellTarget)
	local cooldown = select(2,GetSpellCooldown(spellName))
	
	if (inRange == 1)
	and (canAttack)
--	and (affectingCombat)
	and (cooldown < 2)
	and (not isDead)
	then spellCast = true else spellCast = false; end

	return spellCast, spellHeal, keybinding
end

function AP.EmergencyConditions(spellTarget)
	Apollo.Data.EmergencyCast = Apollo.Data.EmergencyCast or 0
	
	local remainingHealth = Apollo.UnitHealth(spellTarget)
	local affectingCombat = UnitAffectingCombat(spellTarget)
	local missingHealth = Apollo.MissingHealth(spellTarget)
	
	if (remainingHealth < (UnitHealthMax("player") * .7))
	and (affectingCombat == true)
	and (missingHealth >= AP.SpellHealing["Flash of Light"] * 2)
	and (Apollo.Data.EmergencyCast + 3 < time())
	
	then return true else return false; end;
end
