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

function AH.GetTank()
	AH.Tank = nil
	for i = 1, table.getn(Apollo_Group) do
		if UnitGroupRolesAssigned(Apollo_Group[i]) == "TANK" or UnitName(Apollo_Group[i]) == "Oto the Protector" then
			AH.Tank = Apollo_Group[i]
		end
	end
	
	return AH.Tank
	
end

function ApolloHealer_LowestHealth()
--	for i = 1, table.getn(Apollo.Blacklist.Name) do
--		if Apollo.Blacklist.Time[i] <= time() then
--			table.remove(Apollo.Blacklist.Name, i)
--			table.remove(Apollo.Blacklist.Time, i)
--		end
--	end

	for i,v in ipairs(Apollo.Blacklist.Time) do
		if v <= time() then
			print(i,v)
			table.remove(Apollo.Blacklist.Name, i)
			table.remove(Apollo.Blacklist.Time, i)
		end
	end
	
	if ApolloHealer_TANK == nil then ApolloHealer_TANK = "player"; end;
	
--	local LowestApollo_Group = Apollo_Group[1]
	local LowestHealth = 2
	local inRange
	local inRangeSpell = ""

	local PctHealth = {}

	for i = 1,Apollo_Group.GroupNum do
		if select(3,UnitClass("player")) == 2 then inRangeSpell = "Flash of Light"; end;
		if select(3,UnitClass("player")) == 7 then inRangeSpell = "Healing Surge"; end;
		if select(3,UnitClass("player")) == 11 then inRangeSpell = "Rejuvenation"; end;
		if select(3,UnitClass("player")) == 5 then inRangeSpell = "Power Word: Shield"; end;
		inRange = IsSpellInRange(inRangeSpell,Apollo_Group[i])
		
		for _,v in pairs(Apollo.Blacklist.Name) do
			if v == UnitName(Apollo_Group[i]) then
				inRange = 0
--				print("Found blacklist target")
			end
		end
		
		local IncomingHeal = UnitGetIncomingHeals(Apollo_Group[i]) or 0;
		local CurHealth = UnitHealth(Apollo_Group[i])
		local MaxHealth = UnitHealthMax(Apollo_Group[i])
		
		PctHealth[i] = ( CurHealth + IncomingHeal ) / MaxHealth
		
		if PctHealth[i] < LowestHealth and UnitIsDeadOrGhost(Apollo_Group[i]) == false and inRange == 1 then 
			LowestApollo_Group = Apollo_Group[i]
			LowestHealth = PctHealth[i]
--			print(LowestApollo_Group)
--			print(PctHealth[i])
		end;
	end
	
	if LowestApollo_Group == nil then LowestApollo_Group = "Apollo_Group[1]"; end;
	return LowestApollo_Group, LowestHealth
	
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
	
	return castSpell, target
	
end

function ApolloHealer_Decurse()

	local CleanseSpell = "Auto Attack"
	local debuffType
	local name = false
	local level = UnitLevel("player")
	
	if select(3,UnitClass("player")) == 11 then CleanseSpell = "Nature's Cure"; end;
	if select(3,UnitClass("player")) == 2 then CleanseSpell = "Cleanse"; end;
	if select(3,UnitClass("player")) == 5 then CleanseSpell = "Purify"; end;
	
	if GetSpellCooldown(CleanseSpell) ~= 0 then return name; end;

	for i = 1,Apollo_Group.GroupNum do
		local inRange = IsSpellInRange(CleanseSpell,Apollo_Group[i])
		for _,v in pairs(Apollo.Blacklist.Name) do
			if v == UnitName(Apollo_Group[i]) then
				inRange = 0
--				print("Found blacklist target")
			end
		end
	
		if inRange == 1 then for j = 1,40 do
			
			local debuffName,_,_,_,debuffType,_,_,_,_,_,_,_,_,_,_,_ = UnitDebuff(Apollo_Group[i],j)
			
--			if debuffName == nil then break; end;
		
			if Apollo_classIndex == 11  and level >= 22 then 
				if debuffType == "Magic" then name = Apollo_Group[i]; end;
				if debuffType == "Curse" then name = Apollo_Group[i]; end;
				if debuffType == "Poison" then name = Apollo_Group[i]; end;
			end
			
			if Apollo_classIndex == 2 then
				if debuffType == "Magic" then name = Apollo_Group[i]; end;
				if debuffType == "Disease" then name = Apollo_Group[i]; end;
				if debuffType == "Poison" then name = Apollo_Group[i]; end;
			end
			
			if CleanseSpell == "Purify" then
				if debuffType == "Magic" then name = Apollo_Group[i]; end;
				if debuffType == "Disease" then name = Apollo_Group[i]; end;
			end
			
			if debuffName == "Unstable Affliction" then
				name = false
				j = 40
			end
			
		end; end;
		
	end
	
	return name

end

function ApolloHealer_BuffScan(a)

	local searchBuff = a
	local targetBuff, needBuff

	for i=1,table.getn(Apollo_Group) do
	
		local needBuff = UnitBuff(Apollo_Group[i], searchBuff)
		local health = UnitHealth(Apollo_Group[i]) / UnitHealthMax(Apollo_Group[i])
		local inRange = IsSpellInRange(searchBuff,Apollo_Group[i])
		
		for _,v in pairs(Apollo.Blacklist.Name) do
			if v == UnitName(Apollo_Group[i]) then
				inRange = 0
--				print("Found blacklist target")
			end
		end
	
		if (not needBuff) and (health < 1 and inRange == 1) then
			return Apollo_Group[i]
		end
		
	end
	
end

function ApolloHealer_Decurse2(a)

	local DecurseSpell = a
	local DebuffTypes = {}
	
	if DecurseSpell == "Nature's Cure" then DebuffTypes = {"Magic", "Curse", "Poison"}; end;
	
	local debuff, i = {}, 1
	while debuff[i] do
		debuff[i] = UnitDebuff("player",i)
		i = i + 1
	end
	
	print("The player has "..#debuff.." debuffs.")

end
