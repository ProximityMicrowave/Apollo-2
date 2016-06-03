Apollo = {}
Apollo.Blacklist = {}
Apollo.Blacklist.Name = {}
Apollo.Blacklist.Time = {}
Apollo.Diagnostic = {}
ApolloHealer_Below100 = 0
ApolloHealer_Below75 = 0
ApolloHealer_Below50 = 0
ApolloHealer_Below25 = 0

--== GLOBAL DECLARATIONS ==--
Apollo_Ability = {}								-- ARRAY CONTAINING ALL RELEVANT ABILITY DATA
Apollo_Ability.SpellName = {}
Apollo_Ability.Cast = {}						-- ARRAY CONTAINING WHICH ABILITIES SHOULD BE CAST
Apollo_Ability.Type = {}
Apollo_Group = {}
Apollo_DelayTime = 0							-- DO NOT CHANGE! (STORES THE TIME SINCE LAST PERIODIC UPDATE)
Apollo_UpdateSeconds = 0.1; 					-- DETERMINES HOW OFTEN PERIODIC EVENTS WILL RUN

local frame = CreateFrame("FRAME");				-- CREATES A FRAME FOR REGISTERING INGAME EVENTS
frame:RegisterEvent("ADDON_LOADED");			-- ALLOWS FILTERING FOR THE ADDON_LOADED EVENT
frame:RegisterEvent("UNIT_HEALTH");				-- ALLOWS FILTERING FOR THE UNIT_HEALTH EVENT
frame:RegisterEvent("UNIT_POWER");				-- ALLOWS FILTERING FOR THE UNIT_POWER EVENT
frame:RegisterEvent("PLAYER_TARGET_CHANGED");	-- ALLOWS FILTERING FOR THE PLAYER_TARGET_CHANGED EVENT
frame:RegisterEvent("PLAYER_ENTERING_WORLD");	-- ALLOWS FILTERING FOR THE PLAYER_ENTERING_WORLD EVENT
frame:RegisterEvent("GROUP_ROSTER_UPDATE");		-- ALLOWS FILTERING FOR WHEN THE PLAYERS PARTY CHANGES
frame:RegisterEvent("PLAYER_REGEN_ENABLED");
frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")


-- THIS FUNCTION TRIGGERS IN RESPONSE TO ANY INGAME EVENT
function frame:OnEvent(event, arg1)		-- EVENT REFERS TO THE TRIGGERING EVENT, ARG1 IS THE FIRST ASSOCIATED ARGUEMENT. (THIS CAN BE USED TO FILTER EVENTS)

	if event == "ADDON_LOADED" and arg1 == "Apollo" then	-- ADDON_LOADED EVENT FILTER, SCRIPT ONLY RUNS IF THE ADDON_LOADED EVENT OCCURES.
		
		
	end
	
	if (event == "PLAYER_ENTERING_WORLD" 
	or event == "GROUP_ROSTER_UPDATE" 
	or event == "PLAYER_REGEN_ENABLED" 
	or event == "ACTIVE_TALENT_GROUP_CHANGED")
	and (not InCombatLockdown()) then
		ApolloHealer_Keybinding()	--CREATES KEYBINDINGS FOR FOCUS TARGETS
		Apollo.RebindKeys = true;
		
	end
	
	

end

-- This function triggers every frame.
function Apollo_OnUpdate(self, elapsed)
	local r,g,b = 0,0,0			-- THESE VARIABLES CONTROL THE RGB COLOR CODE FOR THE CONTROLLER PIXEL. DEFAULT IS SET TO BLACK.
	
	-- THIS AREA OF THE FUNCTION WILL RUN PERIODICALLY BASED ON THE Apollo_UpdateSeconds variable
	if (GetTime() >= Apollo_DelayTime) then Apollo_DelayTime = (GetTime() + Apollo_UpdateSeconds)
	
		if select(3,UnitClass("player")) == 5 then i = Apollo.Priest.Controller(); end;

	end
	----
	----
	----

	-- EVERYTHING AFTER THIS POINT IN THE FUNCTION WILL RUN EVERY FRAME.
	
	
	-- THIS IF THEN STATEMENT TOGGLES THE COLOR REASIGNMENT ON OR OFF BASED ON CERTAIN CONDITIONS.
	if 
		ChatFrame1EditBox:IsVisible() == true or	--ALLOWS THE PLAYER TO TYPE IN CHAT WITHOUT INTERFERENCE FROM THE CONTROL PIXEL.
		UnitCastingInfo("player") ~= nil or			--DISABLES THE CONTROL PIXEL IF THE PLAYER IS CASTING A SPELL.
		UnitChannelInfo("player") ~= nil			--DISABLES THE CONTROL PIXEL IF THE PLAYER IS CHANNELING A SPELL.
	then
		ColorDot:SetTexture(r,g,b,1);				--IF THE ABOVE CONDITIONS ARE MET THE CONTROL PIXEL WILL BE ASSIGNED THE DEFAULT BLACK AND THE SCRIPT WILL STOP.
		return; 
	end;
		
--	r,g,b = i/255,i/255,i/255		--THIS CONVERTS THE CONTROLLER RETURN INTO AN RGB CODE TO BE DISPLAYED AND READ BY THE EXTERNAL AHK SCRIPT.
	
	
	--[[	--==THIS SECTION OF THE CODE IS GOING TO BE RECIEVING HEAVY ALTERATIONS AND I AM COMMENTING IT OUT FOR THE TIME BEING ==--
	local LowestName, LowestHealth = ApolloHealer_LowestHealth()
	local DecurseName, DebuffType = ApolloHealer_Decurse()

	if DecurseName then IdealTarget = DecurseName;
	elseif (ApolloHealer_Below75 == 0 and BuffName) then IdealTarget = BuffName;
	else IdealTarget = LowestName; end;
	
	if UnitIsUnit("focus",IdealTarget) == false and (Apollo_classIndex ~= 9)then
		for i = 1,Apollo_Group.GroupNum do
			local Offset = 0
			if Apollo_GroupType == "party" then Offset = -1; end;
			PartyMember = Apollo_GroupType..i+Offset
			if PartyMember == "party0" then PartyMember = "player"; end;
			
			if UnitIsUnit(PartyMember,IdealTarget) == true then
				r = (i)/255
				g = 0
				b = 0
			end
		end
	end
	]]--
	
	ColorDot:SetTexture(r,g,b,1);	--CHANGES THE CONTROL PIXEL TO THE CORESPONDING COLOR TO BE READ BY THE EXTERNAL AHK SCRIPT.
	return;
	
end

--PROVIDES AN EASY TO ACCESS FUNCTION TO DETERMINE A UNITS PERCENTAGE HEALTH
function Apollo.UnitHealthPct(a)

	local health = UnitHealth(a)
	local healthMax = UnitHealthMax(a)
	local incomingHealth = UnitGetIncomingHeals(a) or 0
	local healthPct = (health + incomingHealth) / healthMax
	
	return healthPct
end

--PROVIDES AN EASY TO ACCESS FUNCTION FOR CREATING BUTTONS TO CAST SPECIFIC SPELLS
function Apollo.CreateSkillButtons(a, b, c)

	local btnName, spellName, spellTarget = a .. "btn", b, c

	if not InCombatLockdown() then
		if _G[btnName] == nil then _G[btnName] = CreateFrame("Button", string.gsub(spellName,"%p",""), UIParent, "SecureActionButtonTemplate"); end;
		_G[btnName]:SetAttribute("type", "macro");
		_G[btnName]:SetAttribute("macrotext", "/use [@"..spellTarget.."] "..spellName)
	end
	
--	print(btnName,string.gsub(spellName,"%p",""))			--DEBUG CODE
--	print("/use [@"..spellTarget.."] "..spellName)			--DEBUG CODE

	return true --CONFIRMS THAT THE FUNCTION RAN SUCCESSFULLY
	
end

frame:SetScript("OnEvent", frame.OnEvent);
