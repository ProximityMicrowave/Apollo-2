local DT = 0
Apollo.Data = {}

local frame = CreateFrame("FRAME");
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
frame:SetScript("OnEvent", function(self, event, ...)

	local timestamp, type, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
	--[[
		* Note, for this example, you could just use 'local type = select(2, ...)'.  The others are included so that it's clear what's available.
		* You can also lump all of the arguments into one block (or one really long line):

		local timestamp, type, hideCaster,                                                   	                -- arg1  to arg3
		sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags,		-- arg4  to arg11
		spellId, spellName, spellSchool,                                                                      	-- arg12 to arg14
		amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...             	-- arg15 to arg23
	]]
	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		if (type == "SPELL_CAST_SUCCESS") then
		
		local spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(12, ...)
		
			if (sourceName == GetUnitName("player")) then
				local emergencySpells = {"Execution Sentence", "Avenging Wrath", "Hand of Sacrifice", "Divine Shield", "Lay on Hands"}
				
				for i,v in ipairs(emergencySpells) do
					if (spellName == v) then
						Apollo.Data.EmergencyCast = time()
					end
				end
			end
		end
	end
	
--	print(DT, AD.timestamp)
--	print(Apollo.Data[1].timestamp)
	
end)

