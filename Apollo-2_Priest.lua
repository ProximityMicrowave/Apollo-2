Apollo.Priest = {}
AP = Apollo.Priest

function AP.Controller()

	local skillList = {}
	skillList = {
		AP.Smite,
	}
	
	for i=1,table.getn(skillList) do
		if skillList[i](i) then return i; end;
	end
	
	return 0
	
end

function AP.Smite(keybinding)
--	print("AP.Smite is working!")
	local __func__ = "Apollo.Priest.Smite"

	local spellCast = false
	local spellName = "Smite"
	local spellTarget = "target"

	local canAttack = UnitCanAttack("player",spellTarget)
	local isDead = UnitIsDead(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	
	Apollo.CreateSkillButtons(__func__, spellName, spellTarget, keybinding)
	
	if (inRange == 1) 
	and (canAttack) 
	and (not isDead) 
	then return true else return false end;

end
