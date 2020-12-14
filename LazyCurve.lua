-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local C_LFGList = _G.C_LFGList
local ipairs = _G.ipairs
local pairs = _G.pairs
local GetTime = _G.GetTime
local GetAchievementLink = _G.GetAchievementLink
local LFGListApplicationDialog = _G.LFGListApplicationDialog
local LE_EXPANSION_LEVEL_CURRENT = _G.LE_EXPANSION_LEVEL_CURRENT

local name = ...

LazyCurveDB = LazyCurveDB or {}

local LazyCurve = LibStub('AceAddon-3.0'):NewAddon(name, 'AceConsole-3.0', 'AceHook-3.0', 'AceEvent-3.0');
if not LazyCurve then return end

LazyCurve.PREFIX = '<LazyCurve>'
LazyCurve.ACTIVITY_CATEGORY_RAID = 3
LazyCurve.CURRENT_EXPANSION = LE_EXPANSION_LEVEL_CURRENT

LazyCurve.utils = {}
LazyCurve.lastMsgTime = 0

function LazyCurve:IsActivityActive(activityTable)
	local searchGroupId = activityTable.groupId
	for _, groupId in ipairs(C_LFGList.GetAvailableActivityGroups(self.ACTIVITY_CATEGORY_RAID)) do
		if groupId == searchGroupId then
			return true
		end
	end

	return false
end

function LazyCurve:OnSignUp(SignUpButton)
	if(self.DB.whisperOnApply ~= true) then
		return
	end
	local dialog = SignUpButton:GetParent()
	local resultID = dialog.resultID
	local resultInfo = C_LFGList.GetSearchResultInfo(resultID)


	if(resultInfo) then
		local leaderName = resultInfo.leaderName
		local _, _, _, groupId, _ = C_LFGList.GetActivityInfo(resultInfo.activityID)
		local infoTable = LazyCurve.utils.searchEntryMenu:GetInfoTableByActivityGroup(groupId, true)

		if(infoTable) then
			local achievementList = {}

			for _, activityTable in ipairs(infoTable) do
				local earnedAchievements = LazyCurve.utils.achievement:GetHighestEarnedAchievement(activityTable)
				if #earnedAchievements > 0 then
					for _, achievementId in ipairs(earnedAchievements) do
						achievementList[achievementId] = achievementId
					end
				end
			end

			local msg = '';
			for _, achievementId in pairs(achievementList) do
				msg = msg .. ' ' .. GetAchievementLink(achievementId)
			end
			if msg == '' then return end

			if(self.DB.advertise) then
				msg = self.PREFIX .. msg;
			end
			self.hooks.SendChatMessage(msg, 'WHISPER', nil, leaderName)

			if (GetTime() - LazyCurve.lastMsgTime) > 30000 and not self.DB.disableAutolinkReminder then -- 30 secs
				LazyCurve.lastMsgTime = GetTime()
				self:Print('To disable automatically whispering achievements, type \'/lazycurve\' and toggle off auto-linking on LFG application')
			end
		end
	end
end

function LazyCurve:LFGListUtil_GetSearchEntryMenu(resultID)
	return self.utils.searchEntryMenu:GetSearchEntryMenu(resultID)
end

function LazyCurve:processMsg(message)
	local original = message

	for keyword, achievementId in pairs(self.utils.achievement:GetAchievementKeywordMap()) do
		message = self.utils.achievement.ReplaceKeywordWithAchievementLink(self, message, keyword, achievementId)
	end

	if(original ~= message and self.DB.advertise) then
		message = self.PREFIX .. message
	end
	return message
end

function LazyCurve:BNSendWhisper(id, msg)
	self.hooks.BNSendWhisper(id, self:processMsg(msg))
end

function LazyCurve:SendChatMessage(msg, chatType, language, channel)
	self.hooks.SendChatMessage(self:processMsg(msg), chatType, language, channel);
end

function LazyCurve:SendAchievement(leaderName, achievementId)
	local message = GetAchievementLink(achievementId)
	if(self.DB.advertise) then
		message = self.PREFIX .. message
	end
	self.hooks.SendChatMessage(message, 'WHISPER', nil, leaderName)
end

function LazyCurve:ACHIEVEMENT_EARNED()
	self.utils.achievement:BuildAchievementKeywordMap()
end

function LazyCurve:OnInitialize()
	self.DB = LazyCurveDB
	self:InitDefaults()

	self.Config:Initialize()

	self:RawHook('SendChatMessage', true)
	self:RawHook('BNSendWhisper', true)
	self:RawHook('LFGListUtil_GetSearchEntryMenu', true)
	LFGListApplicationDialog.SignUpButton:HookScript('OnClick', function(button) self:OnSignUp(button) end)

	self:RegisterChatCommand('lc', self.Config.OpenConfig)
	self:RegisterChatCommand('lazycurve', self.Config.OpenConfig)

	self:RegisterEvent('ACHIEVEMENT_EARNED');

	C_Timer.After(15, function()
		--for some reason, some achievements don't properly load the first time you log in; so maybe delaying it helps
		self.utils.achievement:BuildAchievementKeywordMap()
	end)
end

function LazyCurve:InitDefaults()
	local defaults = {
		advertise = true,

		whisperOnApply = true,
		disableAutolinkReminder = false,
		mythicThreshold = 2,
	}
	local configChanged = false

	for property, value in pairs(defaults) do
		if self.DB[property] == nil then
			self.DB[property] = value
			configChanged = true
		end
	end

	if configChanged then
		C_Timer.After(4, function() self.Config:OpenConfig() end)
	end
	self:Print('loaded version', self.Config.version)

end
