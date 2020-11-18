local title = "LazyCurve"

local coreFrame = CreateFrame("Frame");
local core = LibStub("AceAddon-3.0"):NewAddon(coreFrame, title, "AceHook-3.0")
local masterTable,raidActivityTable = {}
LazyCurve = {}
LazyCurve.core = core
LazyCurve.optionsTable = {
	type = 'group',
	args = {
		selfpromotion = {
			name = "Selfpromotion",
			desc = "Adds <LazyCurve> before each 'LazyCurve' whisper",
			descStyle = 'inline',
			width = "full",
			order = 1,
			type = "toggle",
			set = function(info, val) LazyCurveDB.advertise = val end,
			get = function(info) return LazyCurveDB.advertise end,
		},
		enableAutolink = {
			name = "Enable auto-linking on LFG application",
			desc = "Automatically whispers your best achievement(s) when applying to a raid.",
			descStyle = 'inline',
			width = "full",
			order = 2,
			type = "toggle",
			set = function(info, val) LazyCurveDB.whisperOnApply = val end,
			get = function(info) return LazyCurveDB.whisperOnApply end,
		},
		enableReminder = {
			name = "Disable the reminder when automatically whispering",
			width = "full",
			order = 3,
			type = "toggle",
			set = function(info, val) LazyCurveDB.disableAutolinkReminder = val end,
			get = function(info) return LazyCurveDB.disableAutolinkReminder end,
		},
		mythicThreshold = {
			name = "Which mythic boss is the first relevant boss to link together with curve.",
			width = 3,
			order = 4,
			type = "range",
			min = 0,
			softMax = 10,
			step = 1,
			bigStep = 1,
			set = function(info, val) LazyCurveDB.mythicThreshold = val end,
			get = function(info) return LazyCurveDB.mythicThreshold end,
		},
		mythicThresholdDesc = {
			type = "description",
			order = 5,
			name = "Set to 0 to disable linking mythic achievements on LFG applying (except for edge/last boss kill). Set to 1 or higher to start linking achievements from that boss.",
		},
	},
}

LibStub('AceConfig-3.0'):RegisterOptionsTable('LazyCurve', LazyCurve.optionsTable)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions('LazyCurve')

local gsub = gsub
local table = table
local pairs = pairs
local string_find = string.find
local strupper = strupper
local GetAchievementLink = GetAchievementLink
local GetAchievementInfo = GetAchievementInfo

local prefix = "<LazyCurve> "
LazyCurveDB = LazyCurveDB or {
	advertise = true,
	whisperOnApply = true,
	mythicThreshold = 2
}
local downloadlink = "https://www.curseforge.com/wow/addons/lazycurve"

local curveTable = {}
local PvPTable = {}

LazyCurve.promote = LazyCurveDB.advertise
LazyCurve.curveTable = curveTable
LazyCurve.PvPTable = PvPTable

-- data management/lookup functions
function core:getHighestRaidFinalBossAchievement(raidname)
	local raidTable = masterTable[raidname];
	local retID = nil;
	local tests = {raidTable[1], raidTable[2], raidTable[(#raidTable - 1)], raidTable[3]};
	for i, chievoID in pairs(tests) do
			local _, _, _, completed, _ = GetAchievementInfo(chievoID);
			if(completed) then
				retID = chievoID;
			end
	end
	return retID;
end

function core:getHighestMythicAchievement(raidname, minimumBoss)
	if(not minimumBoss or minimumBoss < 1) then
		minimumBoss = 1
	end
	local minIndex = 3 + minimumBoss; -- 3 = edge; 4 = first boss etc
	local retID = masterTable[raidname][3]
	if(masterTable[raidname] ~= nil) then
		for k, chievoID in pairs(masterTable[raidname]) do
			local _, _, _, completed, _ = GetAchievementInfo(chievoID)
			if(completed and k >= minIndex) then
				retID = chievoID
			end
		end
	end
	return retID
end

function core:getHighestKeystoneAchievement(season)
	local retID
	local i = 0
	retID = masterTable["keyS" .. LazyCurveData.currentSeason][#masterTable["keyS" .. LazyCurveData.currentSeason]]
	while(masterTable["keyS" .. i]) do
		if(season == nil or season == i) then
			 for k, chievoID in pairs(masterTable["keyS" .. i]) do
				local _, _, _, completed, _ = GetAchievementInfo(chievoID)
				if(completed) then
					retID = chievoID
				end
			end
		end
		i = i + 1
	end
	return retID
end

function core:getCurveTable(filter, noDuplicates)
	t = ordered_table.new{}
	if(filter == "nofilter" or filter == "raids" or filter == "all") then
		for k,raidname in pairs(masterTable.raids) do
			local _, chievoName, _, completed, _ = GetAchievementInfo(masterTable[raidname][2])
			if(not completed or filter == "nofilter") then -- don't show nm/lfr chievo unless using a KEYWORD or you don't have curve
				t[raidname.."normal"] = masterTable[raidname][1]
			end
			t[raidname.."curve"] = masterTable[raidname][2]
			t[raidname.."edge"] = masterTable[raidname][3]
			t[raidname.."mythic"] = core:getHighestMythicAchievement(raidname)
			
			if(noDuplicates and t[raidname.."edge"] == t[raidname.."mythic"]) then
				t[raidname.."mythic"] = nil
			end
			
			--nickname
			if(filter == "nofilter") then
				t[masterTable.finalBoss[raidname].."normal"] = masterTable[raidname][1]
				t[masterTable.finalBoss[raidname].."curve"] = masterTable[raidname][2]
				t[masterTable.finalBoss[raidname].."edge"] = masterTable[raidname][3]
				t[masterTable.finalBoss[raidname].."mythic"] = core:getHighestMythicAchievement(raidname)
				
				if(noDuplicates and t[masterTable.finalBoss[raidname].."edge"] == t[masterTable.finalBoss[raidname].."mythic"]) then
					t[masterTable.finalBoss[raidname].."mythic"] = nil
				end
			end
		end
		if(filter == "nofilter") then
			t["curve"] = LazyCurveData.defaultCurve
			t["edge"] = LazyCurveData.defaultEdge
		end
	end
	
	if(filter == "nofilter" or filter == "dungeons" or filter == "all") then
		if(filter == "nofilter") then 
			t["KEY2"] = masterTable.keyS0[1]
			t["KEY5"] = masterTable.keyS0[2]
			t["KEY10"] = masterTable.keyS0[3]
			t["KEY15"] = masterTable.keyS0[4]
			local i = 0
			while(masterTable['keyS' .. i]) do
			   t["KEYS" .. i] = core:getHighestKeystoneAchievement(i)
				i = i + 1
			end
		end
		t["KEY"] = core:getHighestKeystoneAchievement(nil)
	end
	return t
end

function  core:getHighestPvPAchievement(category)
	local t
	local faction, _ = UnitFactionGroup("player") -- options: Horde, Alliance, nil
	if faction == nil then
		--neutral panda or major error
		print("There has been a major error; or you're playing a neutral panda. Go get yourself a faction and /reloadui! :)")
		return
	end
	if(category == "2V2") then
		t = masterTable["2V2"]
	elseif(category == "3V3") then
		t = masterTable["3V3"]
	elseif(category == "Arena%") then
		t = masterTable.ArenaTitles
	elseif(category == "ArenaWins") then
		t = masterTable.ArenaWins
	elseif(category == "RBGRating") then
		t = masterTable[faction.."RBGRating"]
	elseif(category == "RBGWins") then
		t = masterTable[faction.."RBGWins"]
	elseif(category == "RBG%") then
		t = masterTable[faction.."RBGPercentage"]
	end
	local retID = t[#t]
	--tprint(t)
	for k, chievoID in pairs(t) do
			local _, _, _, completed, _ = GetAchievementInfo(chievoID)
			if(completed) then
				retID = chievoID
			end
		end
		
		return retID
end

function core:getPvPTable(filter)
	t = ordered_table.new{}
	if(filter == "nofilter" or filter == "arena") then 
		t["Arena2V2"] = core.getHighestPvPAchievement(self, "2V2")
		t["Arena3V3"] = core.getHighestPvPAchievement(self, "3V3")
		t["ArenaTop"] = core.getHighestPvPAchievement(self, "Arena%")
		t["ArenaWins"] = core.getHighestPvPAchievement(self, "ArenaWins")
		t["ArenaMaster"] = LazyCurveData.defaultEdge
	end
	if(filter == "nofilter" or filter == "bg") then
		t["RBGRating"] = core.getHighestPvPAchievement(self, "RBGRating")
		t["RBGTop"] = core.getHighestPvPAchievement(self, "RBG%")
		t["RBGWins"] = core.getHighestPvPAchievement(self, "RBGWins")
	end
	return t
end
-- end data functions

-- Ace3 Functions
function core:OnInitialize()
	masterTable = LazyCurveData.masterTable
	raidActivityTable = LazyCurveData.raidActivityTable
	LazyCurve.data = LazyCurveData
	LazyCurve.lastMsgTime = 0
	
	self:RawHook("SendChatMessage", true)
	self:RawHook("LFGListUtil_GetSearchEntryMenu", true)
	_G.LFGListApplicationDialog.SignUpButton:HookScript('OnClick', core.onSignup)

	self:RawHook("BNSendWhisper", true)
	curveTable = core:getCurveTable("nofilter")
	PvPTable = core:getPvPTable("nofilter")
	LazyCurve.curveTable = curveTable
	LazyCurve.PvPTable = PvPTable
	C_Timer.After(15, function()
		--for some reason, some achievements don't properly load the first time you log in; so maybe delaying it helps
		LazyCurve.curveTable = core:getCurveTable("nofilter")
		PvPTable = core:getPvPTable("nofilter")
	end
	)
	
	local configChanged = false;
	if(LazyCurveDB == nil) then
		configChanged = true;
		LazyCurveDB = {
			advertise = true,
			whisperOnApply = true,
			mythicThreshold = 2
		}
	end
	if LazyCurveDB.advertise == nil then
		configChanged = true;
		LazyCurveDB.advertise = true
	end
	if LazyCurveDB.whisperOnApply == nil then
		configChanged = true;
		LazyCurveDB.whisperOnApply = true
	end
	if LazyCurveDB.mythicThreshold == nil then
		configChanged = true;
		LazyCurveDB.mythicThreshold = 2
	end
	if LazyCurveDB.disableAutolinkReminder == nil then
		LazyCurveDB.disableAutolinkReminder = false
	end
	
	if configChanged then
		C_Timer.After(4, function() LazyCurve.core.openConfig() end)
	end
	print("LazyCurve: loaded")
end

function core:openConfig()
	LibStub("AceConfigDialog-3.0"):Open('LazyCurve')
end

-- update tools
local function tprint( data, level )
	level = level or 0
	local ident=strrep('	', level)
	if level>5 then return end

	if type(data)~='table' then print(tostring(data)) return end;

	for index,value in pairs(data) do repeat
		if type(value)~='table' then
			print( ident .. '['..index..'] = ' .. tostring(value) .. ' (' .. type(value) .. ')' );
			break;
		end
		print( ident .. '['..index..'] = {')
		tprint(value, level+1)
		print( ident .. '}' );
	until true end
end

local function dump(data)
	_G['LazyCurveDebuggingTempData'] = data
	UIParentLoadAddOn("Blizzard_DebugTools")
	DevTools_DumpCommand('LazyCurveDebuggingTempData')
end

function core:getAllCategoryInfo() --/run LazyCurve.core.getAllCategoryInfo()
	local tempTable ={}; 
	for i=1,10 do 
		tempTable[i] = C_LFGList.GetCategoryInfo(i) 
	end;
	tprint(tempTable)
end

function core:getAllActivityInfo(dungeonCatID, raidCatID) --/run LazyCurve.core.getAllActivityInfo(_, dungeonCatID, raidCatID)
	if(dungeonCatID ~= nil and dungeonCatID > 0) then
		local dungeonActivities = C_LFGList.GetAvailableActivities(dungeonCatID)
		for key, val in pairs(dungeonActivities) do
			fullName, shortName, catID, _, _, _, minLevel, _, displayType, _ = C_LFGList.GetActivityInfo(val)
			if minLevel >= 110 then
				print("activityID " .. val .. ":" .. fullName .. "(" .. shortName .. ") minlvl:" .. minLevel .. "; displaytype:" .. displayType)
			end
		end
		print("-------------")
	end
	local raidActivities = C_LFGList.GetAvailableActivities(raidCatID)
	for key, val in pairs(raidActivities) do
		fullName, shortName, catID, _, _, _, minLevel, _, displayType, _ = C_LFGList.GetActivityInfo(val)
		if (minLevel >= 120 or minLevel == nil) then 
			print("activityID " .. val .. ":" .. fullName .. "(" .. shortName .. ") minlvl:" .. minLevel .. "; displaytype:" .. displayType)
		end
	end
end

LazyCurve.debugging = {}
LazyCurve.debugging.tprint = tprint
LazyCurve.debugging.dump = dump

-- end update tools

------------------------------------------------------------------
function core:onSignup()
	if(LazyCurveDB.whisperOnApply ~= true) then
		return;
	end
	local dialog = self:GetParent();
	local resultID = dialog.resultID;
	local resultInfo = C_LFGList.GetSearchResultInfo(resultID);
	if(resultInfo) then
		local leaderName = resultInfo.leaderName;
		local activityID = resultInfo.activityID;
		local raidname = LazyCurveData.raidActivityTable[activityID];
		if(raidname) then
			local chievo1 = LazyCurve.core.getHighestRaidFinalBossAchievement(LazyCurve.core, raidname);
			local completed1 = false;
			if(chievo1) then
				_, _, _, completed1, _ = GetAchievementInfo(chievo1);
			end
			local chievo2 = nil;
			local completed2 = false;
			if(LazyCurveDB.mythicThreshold ~= nil and LazyCurveDB.mythicThreshold > 0) then
				chievo2 = LazyCurve.core.getHighestMythicAchievement(LazyCurve.core, raidname, LazyCurveDB.mythicThreshold);
				_, _, _, completed2, _ = GetAchievementInfo(chievo2);
			end
			
			local msg = '';
			if(LazyCurveDB.advertise) then
				msg = prefix .. msg;
			end
			if(chievo1 and completed1) then
				msg = msg .. GetAchievementLink(chievo1)
			end
			if(chievo2 and completed2 and (chievo1 ~= chievo2)) then
				msg = msg .. GetAchievementLink(chievo2)
			end
			SendChatMessage(msg, "WHISPER", nil, leaderName)
			
			if(((GetTime() - LazyCurve.lastMsgTime) > 30000) and not LazyCurveDB.disableAutolinkReminder) then -- 30 secs
				LazyCurve.lastMsgTime = GetTime()
				print(prefix..'To disable automatically whispering achievements, type "/lazycurve" and toggle off auto-linking on LFG application')
			end
		end
	end
end

function core:processMsg(msg)
	msg, _ = gsub(msg, "LAZYCURVE", downloadlink)
	local unchanged = msg
	
	for keyword, chievoID in ordered_table.pairs(curveTable) do
		msg = core.replaceKeywordWithAchievementLink(self, msg, keyword, chievoID)
	end
	for keyword, chievoID in ordered_table.pairs(PvPTable) do
		msg = core.replaceKeywordWithAchievementLink(self, msg, keyword, chievoID)
	end
	if(unchanged ~= msg and LazyCurveDB.advertise) then
		msg = prefix .. msg
	end
	return msg
end

function core:BNSendWhisper(...)
	local id, msg = ...;
	msg = core.processMsg(self, msg)
	core.hooks.BNSendWhisper(id, msg)
end

function core:SendChatMessage(...)
	-- Our hook to SendChatMessage. If msg contains a tracked keyword, we insert the achievement.
	local msg, chatType, language, channel = ...;
	msg = core.processMsg(self, msg)
	core.hooks.SendChatMessage(msg, chatType, language, channel);
end

function core:replaceKeywordWithAchievementLink(msg, keyword, chievoID)
	keyword = strupper(keyword)
	if string_find(msg, keyword) then --keyword found
		local found, _ = string_find(msg, keyword)
		while(found ~= nil) do --repeat untill all keywords are replaced
			msg, _ = gsub(msg, keyword, GetAchievementLink(chievoID))
			found, _ = string_find(msg, keyword)
		end
	end
	return msg
end

function core:SendAchievement(name, chievoID)
	local msg = GetAchievementLink(chievoID)
	if(LazyCurveDB.advertise) then
		msg = prefix .. msg
	end
	core.hooks.SendChatMessage(msg, "WHISPER", nil, name)
end

function core:getFilteredTable(activityID)
	local fullName, difficulty, catID, _, _, _, minLevel, _ = C_LFGList.GetActivityInfo(activityID)
	local supportedActivity = false
	if(catID == LazyCurveData.dungeonCatID) then --dungeon chievos
		if(minLevel >= 110) then
			supportedActivity = true
			filteredTable = core.getCurveTable(self,"dungeons")
		end
	elseif(catID == LazyCurveData.raidCatID) then --raid chievos
		supportedActivity = true
		if(raidActivityTable[activityID] ~= nil) then
			filteredTable = ordered_table.new{
				raidActivityTable[activityID].."normal", curveTable[raidActivityTable[activityID].."normal"],
				raidActivityTable[activityID].."curve", curveTable[raidActivityTable[activityID].."curve"],
				raidActivityTable[activityID].."edge", curveTable[raidActivityTable[activityID].."edge"],
				raidActivityTable[activityID].."mythic", curveTable[raidActivityTable[activityID].."mythic"]
			}
			local _, _, _, completedCurve, _ = GetAchievementInfo(curveTable[raidActivityTable[activityID].."curve"])
			local _, _, _, completedEdge, _ = GetAchievementInfo(curveTable[raidActivityTable[activityID].."curve"])
			if(completedCurve) then
				filteredTable[raidActivityTable[activityID].."normal"] = nil
			end
			if(completedEdge) then
				filteredTable[raidActivityTable[activityID].."mythic"] = nil
			end
			--if not latest raid, add latest curve and edge
			if(curveTable[raidActivityTable[activityID].."curve"] ~= curveTable.curve)then
				filteredTable.curve = curveTable.curve
			end
			if(curveTable[raidActivityTable[activityID].."edge"] ~= curveTable.edge)then
				filteredTable.edge = curveTable.edge
			end
		else
			filteredTable = core.getCurveTable(self,"raids", 'noDuplicates')
		end
	end
	
	if(not supportedActivity) then --check LazyCurveData.pvpCatID
		for catName, catNumber in pairs(LazyCurveData.pvpCatID) do
			if(catID == catNumber) then
				if(string_find(catName, "BG")) then
					filteredTable = core.getPvPTable(self, "bg")
				else
					filteredTable = core.getPvPTable(self, "arena")
				end
				return filteredTable
			end
		end
		
		filteredTable = core.getCurveTable(self,"all", 'noDuplicates')
	end
	return filteredTable
end

function core:getExtraMenuList(activityID, leaderName)
	local tempMenuList = {}
	
	filteredTable = core.getFilteredTable(self, activityID)
	for keyword, chievoID in ordered_table.pairs(filteredTable) do
		local _, chievoName, _, completed, _ = GetAchievementInfo(chievoID)
		if(completed) then
			table.insert(tempMenuList, {
				text =chievoName,
				func = function(_, name) core.SendAchievement(self, name, chievoID); end,
				notCheckable = true,
				arg1 = leaderName, --Leader name goes here
				disabled = not leaderName, --Disabled if we don't have a leader name yet or you haven't applied
			})
			if(string_find(keyword, "KEY")) then
				--break
			end
		end
	end
	if(table.getn(tempMenuList)>1) then
		return { 
				text = prefix .. "Link Achievement to Leader",
				hasArrow = true,
				notCheckable = true,
				disabled = not leaderName,
				menuList = tempMenuList,
		};
	end
	if(table.getn(tempMenuList) == 1) then
		tempMenuList[1].text = prefix .. "Link " .. tempMenuList[1].text .. "  to Leader"
		return tempMenuList[1]
	end
	if(table.getn(tempMenuList) == 0) then
		--no achievements
		return {
			text = prefix .. "You haven't completed any relevant achievements yet :(",
			notCheckable = true,
			disabled = true,
		}
	end
end

function core:LFGListUtil_GetSearchEntryMenu(resultID)
	--tprint(C_LFGList.GetSearchResultInfo(resultID))
	local tempResultTable = C_LFGList.GetSearchResultInfo(resultID);
	local activityID = tempResultTable.activityID;
	local leaderName = tempResultTable.leaderName
	local LFG_LIST_SEARCH_ENTRY_MENU = nil
	LFG_LIST_SEARCH_ENTRY_MENU = core.hooks.LFGListUtil_GetSearchEntryMenu(resultID)
	LFG_LIST_SEARCH_ENTRY_MENU[2].tooltipTitle = nil
	LFG_LIST_SEARCH_ENTRY_MENU[2].tooltipText = nil
	
	local found = false
	for i, item in pairs(LFG_LIST_SEARCH_ENTRY_MENU) do
		 if(string_find(item.text, prefix)) then
				local menuIndex = i
				found = true
				break
			end
	
	end
	if(not found) then
		menuIndex = #LFG_LIST_SEARCH_ENTRY_MENU
		table.insert(LFG_LIST_SEARCH_ENTRY_MENU, menuIndex, core.getExtraMenuList(self, activityID, leaderName))
	else
		LFG_LIST_SEARCH_ENTRY_MENU[menuIndex] = core.getExtraMenuList(self, activityID, leaderName)
	end
	
	table.insert(LFG_LIST_SEARCH_ENTRY_MENU, lastItem) -- put the cancel button back in it's place
	return LFG_LIST_SEARCH_ENTRY_MENU; --and all is well that ends well :)
end


function core:printInfo()
	print("Type \"/lazycurve togglepromote\" to start/stop self-promotion.")
	print("Please leave this on if you like my addon")
	print("Type \"/lazycurve\" to open a config window.")
end

SLASH_LAZYCURVE1="/lc"
SLASH_LAZYCURVE2="/lazycurve"
SlashCmdList["LAZYCURVE"] =
	function(msg)
		local a1, a2 = strsplit(" ", strlower(msg), 2)
		if (a1 == "") then 
			core.openConfig()
		elseif (a1 == "info")  then 
			core.printInfo()
		elseif(a1 == "togglepromote") then
			LazyCurveDB.advertise = (not LazyCurveDB.advertise)
			if(LazyCurveDB.advertise) then
				print(prefix .. "self-promotion when linking an achievement is now turned ON")
			else
				print(prefix .. "self-promotion when linking an achievement is now turned OFF")
				print("Please consider turning this back on if you like my addon :)")
			end
		end
	end   
