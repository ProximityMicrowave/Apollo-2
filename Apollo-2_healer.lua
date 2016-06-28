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

	local castSpell, target = false, "player"

	for i = 1,Apollo.Group.GroupNum do
		if skillFunction(Apollo.Group.Names[i]) == true then 
			castSpell = true
			target = Apollo.Group.Names[i]
			break;
		end
	end
	
--	print(castSpell, target)
	return castSpell, target
	
end

function AH.TargetSorting()
	
	print(Apollo.Group.Names[1])
	
end
