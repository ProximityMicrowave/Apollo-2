local DT = 0
Apollo.Data = {}

local frame = CreateFrame("FRAME");
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
frame:SetScript("OnEvent", function(self, event, ...)

	--[[
		* Note, for this example, you could just use 'local type = select(2, ...)'.  The others are included so that it's clear what's available.
		* You can also lump all of the arguments into one block (or one really long line):

		local timestamp, type, hideCaster,                                                   	                -- arg1  to arg3
		sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags,		-- arg4  to arg11
		spellId, spellName, spellSchool,                                                                      	-- arg12 to arg14
		amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...             	-- arg15 to arg23
	]]
	
	DT = DT + 1
	Apollo.Data[DT] = {}
	local AD = Apollo.Data[DT]

	AD.timestamp, AD.type, AD.hideCaster, AD.sourceGUID, AD.sourceName, AD.sourceFlags, AD.sourceRaidFlags, AD.destGUID, 
	AD.destName, AD.destFlags, AD.destRaidFlags, AD.spellId, AD.spellName, AD.spellSchool, AD.amount, AD.overkill, AD.school, 
	AD.resisted, AD.blocked, AD.absorbed, AD.critical, AD.glancing, AD.crushing = ...
	
	
--	print(DT, AD.timestamp)
--	print(Apollo.Data[1].timestamp)
	
end)