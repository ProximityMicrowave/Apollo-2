Apollo.Healer = {}

local AH = Apollo.Healer

function ApolloHealer_Keybinding()
	
	Apollo_Group.GroupNum = GetNumGroupMembers()
	local Offset
	
	if IsInRaid() == true then 
		Apollo_GroupType = "raid"
		Offset = 0
	else 
		Apollo_GroupType = "party"
		Offset = -1
	end
	
	if Apollo_Group.GroupNum == 0 then Apollo_Group.GroupNum = 1; end;
	
	for i=1,Apollo_Group.GroupNum do
	
		Apollo_Group[i] = Apollo_GroupType..i+Offset
		if Apollo_Group[i] == "party0" then Apollo_Group[i] = "player"; end;

		local btn = CreateFrame("Button", "Apollo_target"..i, UIParent, "SecureActionButtonTemplate")
		btn:SetAttribute("type", "macro");
		btn:SetAttribute("macrotext", "/focus "..Apollo_Group[i])
		SetBinding(Apollo_Group.Keybinding[i])
		SetBindingClick(Apollo_Group.Keybinding[i], "Apollo_target"..i)
	
	end
	
end

function AH.Targeting(skillFunction)

	local castSpell, target = false, "player"

	for i = 1,Apollo_Group.GroupNum do
		if skillFunction(Apollo_Group[i]) == true then 
			castSpell = true
			target = Apollo_Group[i]
			break;
		end
	end
	
--	print(castSpell, target)
	return castSpell, target
	
end