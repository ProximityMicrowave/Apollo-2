Apollo.Healer = {}

local AH = Apollo.Healer

function ApolloHealer_Keybinding()
	
	Apollo.Group.GroupNum = GetNumGroupMembers()
	local Offset
	
	if IsInRaid() == true then 
		Apollo.Group.Type = "raid"
		Offset = 0
	else 
		Apollo.Group.Type = "party"
		Offset = -1
	end
	
	if Apollo.Group.GroupNum == 0 then Apollo.Group.GroupNum = 1; end;
	
	for i=1,Apollo.Group.GroupNum do
	
		Apollo.Group.Names[i] = Apollo.Group.Type..i+Offset
		if Apollo.Group.Names[i] == "party0" then Apollo.Group.Names[i] = "player"; end;

		local btn = CreateFrame("Button", "Apollo_target"..i, UIParent, "SecureActionButtonTemplate")
		btn:SetAttribute("type", "macro");
		btn:SetAttribute("macrotext", "/focus "..Apollo.Group.Names[i])
		SetBinding(Apollo.Group.Keybinding[i])
		SetBindingClick(Apollo.Group.Keybinding[i], "Apollo_target"..i)
	
	end
	
end

function AH.Targeting(skillFunction)

	local castSpell = false
	local spellEffect
	local keybinding = 0
	local priority = Apollo.Healer.TargetSorting()
	
	for i,v in ipairs(priority) do
		local a, b, c = skillFunction(v)
		if a == true then 
			castSpell = a
			AH.Target = v
			keybinding = c
			break
		end
	end
	
	return castSpell, AH.Target, keybinding
	
end

function Apollo.Healer.TargetSorting()
	local priority = {}
	local z = {}
	
	for i, v in ipairs(Apollo.Group.Names) do
		z[Apollo.Group.Names[i]] = Apollo.UnitHealthPct(Apollo.Group.Names[i])
	end;
	
	i=1
	for k,v in spairs(z, function(t,a,b) return t[b] > t[a] end) do
		priority[i] = k
		i=i+1
	end;
	
	table.insert(priority, "target")
	
--	for i,v in ipairs(priority) do
--		print(i,v)
--	end
	
	return priority
	
end
