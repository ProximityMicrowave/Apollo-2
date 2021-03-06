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
Apollo.Group = {}
Apollo.Group.Names = {}
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
	local idealTarget
	
	-- THIS AREA OF THE FUNCTION WILL RUN PERIODICALLY BASED ON THE Apollo_UpdateSeconds variable
	if (GetTime() >= Apollo_DelayTime) then Apollo_DelayTime = (GetTime() + Apollo_UpdateSeconds)

	end
	----
	----
	----

	-- EVERYTHING AFTER THIS POINT IN THE FUNCTION WILL RUN EVERY FRAME.
	Apollo.totalMissingHealth = Apollo.TotalMissingHealth()

	-- THIS IF THEN STATEMENT TOGGLES THE COLOR REASIGNMENT ON OR OFF BASED ON CERTAIN CONDITIONS.
	if 
		ChatFrame1EditBoxFocusMid:IsVisible() == true --or	--ALLOWS THE PLAYER TO TYPE IN CHAT WITHOUT INTERFERENCE FROM THE CONTROL PIXEL.
--		UnitCastingInfo("player") ~= nil or			--DISABLES THE CONTROL PIXEL IF THE PLAYER IS CASTING A SPELL.
--		UnitChannelInfo("player") ~= nil			--DISABLES THE CONTROL PIXEL IF THE PLAYER IS CHANNELING A SPELL.
	then
		ColorDot:SetColorTexture(r,g,b,1);				--IF THE ABOVE CONDITIONS ARE MET THE CONTROL PIXEL WILL BE ASSIGNED THE DEFAULT BLACK AND THE SCRIPT WILL STOP.
		return; 
	end;
	
	--THIS AREA DETERMINES WHICH CLASS THE PLAYER IS AND RUNS THE CORESPONDING CONTROLLER RETURNING WHICH SKILL SHOULD BE USED.
	i = 0
	local playerClass = select(3,UnitClass("player"))
	if playerClass == 5 then i, idealTarget = Apollo.Priest.Controller(); end;
	if playerClass == 2 then i, idealTarget = Apollo.Paladin.Controller(); end;
	if playerClass == 8 then i, idealTarget = Apollo.Mage.Controller(); end;
	if playerClass == 9 then i, idealTarget = Apollo.Warlock.Controller(); end;
	if playerClass == 12 then i, idealTarget = Apollo.DemonHunter.Controller(); end;

	
--	print(idealTarget)
	r,g,b = i/255,i/255,i/255		--THIS CONVERTS THE CONTROLLER RETURN INTO AN RGB CODE TO BE DISPLAYED AND READ BY THE EXTERNAL AHK SCRIPT.

	--==THIS SECTION OF THE CODE IS GOING TO BE RECIEVING HEAVY ALTERATIONS AND I AM COMMENTING IT OUT FOR THE TIME BEING ==--
	idealTarget = idealTarget or "focus"
	if UnitIsUnit("focus",idealTarget) == false then

		for i = 1,Apollo.Group.GroupNum do
			local Offset = 0
			if Apollo.Group.Type == "party" then Offset = -1; end;
			PartyMember = Apollo.Group.Type..i+Offset
			if PartyMember == "party0" then PartyMember = "player"; end;
			
			if UnitIsUnit(PartyMember,idealTarget) then
				r = (i)/255
				g = 0
				b = 0
			end
		end
	end
	
	ColorDot:SetColorTexture(r,g,b,1);	--CHANGES THE CONTROL PIXEL TO THE CORESPONDING COLOR TO BE READ BY THE EXTERNAL AHK SCRIPT.
	return;
	
end

--PROVIDES AN EASY TO ACCESS FUNCTION TO DETERMINE A UNITS PERCENTAGE HEALTH
function Apollo.UnitHealthPct(a)

	local health = UnitHealth(a)
	local healthMax = UnitHealthMax(a)
	local incomingHealth = UnitGetIncomingHeals(a) or 0
	if IsInRaid() then incomingHealth = 0; end;
	
	local healthPct = (health + incomingHealth) / healthMax
	
	return healthPct
end

function Apollo.UnitHealth(a)

	local health = UnitHealth(a)
	local incomingHealth = UnitGetIncomingHeals(a) or 0
	
	if IsInRaid() then
		health = health
	else
		health = health + incomingHealth
	end
	
	return health

end

function Apollo.MissingHealth(a)

	local health = UnitHealth(a)
	local healthMax = UnitHealthMax(a)
	local incomingHealth = UnitGetIncomingHeals(a) or 0
	if IsInRaid() then incomingHealth = 0; end;
	
	local missingHealth = healthMax - (health + incomingHealth)
	
	if missingHealth < 0 then missingHealth = 0; end;
	
	return missingHealth;
	
end

function Apollo.TotalMissingHealth()
	
	local TotalMissingHealth = 0
	for i,v in ipairs(Apollo.Group.Names) do
		TotalMissingHealth = TotalMissingHealth + Apollo.MissingHealth(v)
	end
	
	return TotalMissingHealth
	
end

function Apollo.LowHealthCount(a)
	--if the input is between 0 and 1 the function will read it as a percentage, and check how many in the group have less than the input in percentage health.
	--if the input is greater than 1 the function will read it as a raw value and return how many in the group have less than the input value in raw health.
	--if the input is less than zero (a negative number) then it will check how many group members are missing more than that amount of health
	
	local count = 0
	
	if a < 0 then
		a = a * -1
		for i,v in ipairs(Apollo.Group.Names) do
			if Apollo.MissingHealth(v) >= a then count = count + 1; end;
		end
	elseif a <= 1 then
		for i,v in ipairs(Apollo.Group.Names) do
			if Apollo.UnitHealthPct(v) <= a then count = count + 1; end;
		end
	elseif a > 1 then
		for i,v in ipairs(Apollo.Group.Names) do
			if UnitHealth(v) <= a then count = count + 1; end;
		end
	end
		
	return count
end

--PROVIDES AN EASY TO ACCESS FUNCTION FOR CREATING BUTTONS TO CAST SPECIFIC SPELLS
function Apollo.CreateSkillButtons(a, b, c, d)

	local btnName, spellName, spellTarget = a .. "btn", b, c
	
	if not InCombatLockdown() and Apollo.RebindKeys then
		if _G[btnName] == nil then _G[btnName] = CreateFrame("Button", string.gsub(spellName,"%p",""), UIParent, "SecureActionButtonTemplate"); end;
		_G[btnName]:SetAttribute("type", "macro");
		_G[btnName]:SetAttribute("macrotext", "/use [nochanneling,@"..spellTarget.."] "..spellName)
		
		SetBinding(Apollo_Ability.KeyBinding[d])
		SetBindingClick(Apollo_Ability.KeyBinding[d], string.gsub(spellName,"%p",""))
	end
	
	return true						--CONFIRMS THAT THE FUNCTION RAN SUCCESSFULLY

end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

frame:SetScript("OnEvent", frame.OnEvent);