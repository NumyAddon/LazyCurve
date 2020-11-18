-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local gsub = _G.gsub
local table = _G.table
local pairs = _G.pairs
local strfind = _G.strfind
local strupper = _G.strupper
local GetAchievementLink = _G.GetAchievementLink
local GetAchievementInfo = _G.GetAchievementInfo
local C_LFGList = _G.C_LFGList
local NPG = _G.NPG
local ipairs = _G.ipairs
local LFGListApplicationDialog = _G.LFGListApplicationDialog


local LazyCurveName = ...
local LazyCurve = LibStub('AceAddon-3.0'):NewAddon(LazyCurveName, 'AceConsole-3.0', 'AceHook-3.0');
if not LazyCurve then return end

LazyCurve.TYPE_RAID = 'raid'
LazyCurve.TYPE_DUNGEON = 'dungeon'
LazyCurve.TYPE_PVP = 'pvp'

LazyCurve.ACTIVITY_CATEGORY_RAID = 3
LazyCurve.ACTIVITY_CATEGORY_DUNGEON = 2
LazyCurve.ACTIVITY_CATEGORY_PVP = {
	RankedArena = 4,
	Arena = 7,
	BG = 8,
	RankedBG = 9,
}

LazyCurve.PREFIX = '<LazyCurve>'

local function tableInsertChildren(target, tableToInsert)
	for _,child in ipairs(tableToInsert) do
		table.insert(target, child)
	end
	return target
end

function LazyCurve:OnSignUp(SignUpButton)
end

function LazyCurve:LFGListUtil_GetSearchEntryMenu(resultID)

	local tempResultTable = C_LFGList.GetSearchResultInfo(resultID);
	local _, _, categoryId, groupId, _ = C_LFGList.GetActivityInfo(tempResultTable.activityID)
	local leaderName = tempResultTable.leaderName

	local popupMenu = self.hooks.LFGListUtil_GetSearchEntryMenu(resultID)

	local found = false
	local menuIndex
	for i, item in pairs(popupMenu) do
		if(strfind(item.text, self.PREFIX)) then
			menuIndex = i
			found = true
			break
		end
	end

	local lazyCurveMenu = self:getExtraMenuList(categoryId, groupId, leaderName)

	if(not found) then
		table.insert(popupMenu, 4, lazyCurveMenu)
	else
		popupMenu[menuIndex] = lazyCurveMenu
	end

	return popupMenu
end

function LazyCurve:SendAchievement(name, achievementId)
	self:Print('requested to send chievo ' .. achievementId .. ' to ' .. name)
end

function LazyCurve:GetActivityTypeByCategoryId(categoryId)
	if categoryId == self.ACTIVITY_CATEGORY_DUNGEON then
		return self.TYPE_DUNGEON
	elseif categoryId == self.ACTIVITY_CATEGORY_RAID then
		return self.TYPE_RAID
	else
		for _, pvpCategoryId in ipairs(self.ACTIVITY_CATEGORY_PVP) do
			if categoryId == pvpCategoryId then
				return self.TYPE_PVP
			end
		end
	end
	return nil
end


function LazyCurve:IsAchievementEarned(achievementId)
	_, _, _, completed, _ = GetAchievementInfo(achievementId);
	return completed or false
end

function LazyCurve:GetHighestEarnedAchievement(activityTable)
	local ret = {}
	if activityTable.type == self.TYPE_RAID then
		local earnedMythic

		if self:IsAchievementEarned(activityTable.achievements.edge) then
			return {activityTable.achievements.edge}
		end

		if self:IsAchievementEarned(activityTable.achievements.curve) then
			table.insert(ret, activityTable.achievements.curve)
		end

		for _, achievementId in ipairs(activityTable.achievements.mythic) do
			if self:IsAchievementEarned(achievementId) then
				earnedMythic = achievementId
			end
		end
		if earnedMythic then
			table.insert(ret, earnedMythic)
		end

		if #ret == 0 then
			if self:IsAchievementEarned(activityTable.achievements.normal) then
				ret = {activityTable.achievements.normal}
			end
		end
	end

	return ret
end

function LazyCurve:FormatAchievementMenuItem(achievementId, leaderName)
	local _, achievementName, _ = GetAchievementInfo(achievementId)

	return {
		text = achievementName,
		func = function(_, name, id) self:SendAchievement(name, id) end,
		notCheckable = true,
		arg1 = leaderName,
		arg2 = achievementId,
		disabled = not leaderName,
	}
end

function LazyCurve:GetAchievementMenu(infoTable, leaderName)
	local mainMenuItems = {}

	for _, activityTable in ipairs(infoTable) do
		local earnedAchievements = self:GetHighestEarnedAchievement(activityTable)
		if #earnedAchievements > 0 then
			if activityTable.isLatest then
				for _, achievementId in ipairs(earnedAchievements) do
					table.insert(mainMenuItems, 1, self:FormatAchievementMenuItem(achievementId, leaderName))
				end
			else
				local subMenuItems = {}
				for _, achievementId in ipairs(earnedAchievements) do
					table.insert(subMenuItems, self:FormatAchievementMenuItem(achievementId, leaderName))
				end
				local subMenu = {
					text = activityTable.longName,
					hasArrow = true,
					notCheckable = true,
					disabled = not leaderName,
					menuList = subMenuItems,
				}
				table.insert(mainMenuItems, subMenu)
			end
		end
	end

	if #mainMenuItems == 0 then
		return false
	end

	local mainMenu =  {
		text = self.PREFIX .. " Link Achievement to Leader",
		hasArrow = true,
		notCheckable = true,
		disabled = not leaderName,
		menuList = mainMenuItems,
	}
	return mainMenu
end

function LazyCurve:GetInfoTableByActivityGroup(categoryId, groupId)
	local activityType = self:GetActivityTypeByCategoryId(categoryId)
	local resultTable = {}
	local allInfo = {}
	local minimumResults = 1

	for _, module in self:IterateModules() do
		local modType = module.TYPE
		local moduleInfoTable = module:GetInfoTable()
		local infoTable

		allInfo = tableInsertChildren(allInfo, moduleInfoTable)

		if activityType == nil and moduleInfoTable then
			tableInsertChildren(resultTable, moduleInfoTable)
		elseif activityType == modType then
			infoTable = module:GetInfoTableByActivityGroup(groupId)
			if infoTable then
				table.insert(resultTable, infoTable)
			end
		end

		if module:HasLatestRaid() then
			minimumResults = minimumResults + 1
			table.insert(resultTable, 1, module:GetLatestRaid())
		end
	end
	return #resultTable >= minimumResults and resultTable or allInfo
end

function LazyCurve:getExtraMenuList(activityId, groupId, leaderName)
	local infoTable = self:GetInfoTableByActivityGroup(activityId, groupId)
	local menu = self:GetAchievementMenu(infoTable, leaderName)

	NPG.browser(infoTable)

	if not menu then
		--no achievements
		return {
			text = self.PREFIX .. " You haven't completed any relevant achievements yet :(",
			notCheckable = true,
			disabled = true,
		}
	end
	return menu
end

function LazyCurve:OnInitialize()
	for moduleName, module in self:IterateModules() do
		local modType = module.TYPE
		if(modType == self.TYPE_PVP) then

		elseif(modType == self.TYPE_DUNGEON) then

		elseif(modType == self.TYPE_RAID) then

		else
			self:DisableModule(moduleName)
			error('LazyCurve does not support modules of type ' .. modType, 2)
		end
	end

	self:RawHook("LFGListUtil_GetSearchEntryMenu", true)
	LFGListApplicationDialog.CancelButton:HookScript('OnClick', self.OnSignUp)
end

