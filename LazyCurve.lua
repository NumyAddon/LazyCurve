-- upvalue the globals
local LibStub = _G.LibStub
local C_LFGList = _G.C_LFGList
local ipairs = _G.ipairs
local pairs = _G.pairs
local GetTime = _G.GetTime
local GetAchievementLink = _G.GetAchievementLink
local C_Timer = _G.C_Timer
local LFGListApplicationDialog = _G.LFGListApplicationDialog
local LE_EXPANSION_WAR_WITHIN = _G.LE_EXPANSION_WAR_WITHIN

local name = ...

--- @class LazyCurve: AceAddon, AceConsole-3.0, AceHook-3.0, AceEvent-3.0
local LazyCurve = LibStub('AceAddon-3.0'):NewAddon(name, 'AceConsole-3.0', 'AceHook-3.0', 'AceEvent-3.0');
if not LazyCurve then return end
_G.LazyCurve = LazyCurve

LazyCurve.PREFIX = '<LazyCurve>'
LazyCurve.CURRENT_EXPANSION = LE_EXPANSION_WAR_WITHIN
LazyCurve.MODULE_TYPE_RAID = 'raid'
LazyCurve.MODULE_TYPE_OTHER = 'other'

LazyCurve.utils = {}
--- @private
LazyCurve.lastMsgTime = 0

--- @private
function LazyCurve:OnCancel(CancelButton)
    if (self.DB.enableSimulation) then
        LazyCurve:OnSignUp(CancelButton)
    end
end

--- @private
--- @param SignUpButton LFGListApplicationDialog_SignUpButton|LFGListApplicationDialog_CancelButton
function LazyCurve:OnSignUp(SignUpButton)
    if (self.DB.whisperOnApply ~= true) then
        return
    end
    --- @type LFGListApplicationDialog
    local dialog = SignUpButton:GetParent()
    local resultID = dialog.resultID
    local resultInfo = C_LFGList.GetSearchResultInfo(resultID)

    if (resultInfo) then
        local leaderName = resultInfo.leaderName
        local activityInfo = C_LFGList.GetActivityInfoTable(resultInfo.activityID or resultInfo.activityIDs[1])
        local infoTable = activityInfo
            and activityInfo.groupFinderActivityGroupID
            and LazyCurve.utils.searchEntryMenu:GetInfoTableByActivityGroup(activityInfo.groupFinderActivityGroupID, true)

        if (infoTable) then
            local achievementList = {}

            for _, activityTable in ipairs(infoTable) do
                local earnedAchievements = LazyCurve.utils.achievement:GetHighestEarnedAchievement(activityTable, true)
                if #earnedAchievements > 0 then
                    for _, achievementId in ipairs(earnedAchievements) do
                        achievementList[achievementId] = achievementId
                    end
                end
            end

            local message = '';
            for _, achievementId in pairs(achievementList) do
                message = message .. ' ' .. GetAchievementLink(achievementId)
            end
            if message == '' then
                if (self.DB.enableSimulation) then self:SimulationPrint('no achievements found to whisper') end
                return
            end

            if (self.DB.advertise) then
                message = self.PREFIX .. message;
            end

            if (self.DB.enableSimulation) then
                self:SimulationPrint('Intent to whisper "', leaderName, '" with message:', message)
                return
            end
            self.hooks.SendChatMessage(message, 'WHISPER', nil, leaderName)

            if (GetTime() - LazyCurve.lastMsgTime) > 30000 and not self.DB.disableAutolinkReminder then -- 30 secs
                LazyCurve.lastMsgTime = GetTime()
                self:Print('To disable automatically whispering achievements, type \'/lazycurve\' and toggle off auto-linking on LFG application')
            end
        end
    end
end

--- @private
--- @param owner table
--- @param rootDescription RootMenuDescriptionProxy
function LazyCurve:OnMenuOpen(owner, rootDescription)
    local resultID = owner.resultID
    if not resultID then return end
    self.utils.searchEntryMenu:ExtendMenu(resultID, rootDescription)
end

--- @private
function LazyCurve:SimulationPrint(...)
    if (self.DB.enableSimulation) then
        self:Print('[sim active]', ...)
    end
end

--- @private
function LazyCurve:ProcessMsg(message)
    if not self.DB.replaceKeywordsInChatMessages then
        return message
    end

    local original = message

    local curve, edge;
    for keyword, achievementId in pairs(self.utils.achievement:GetAchievementKeywordMap()) do
        if keyword == 'curve' then
            curve = achievementId;
        elseif keyword == 'edge' then
            edge = achievementId;
        else
            message = self.utils.achievement.ReplaceKeywordWithAchievementLink(self, message, keyword, achievementId)
        end
    end
    if curve then
        message = self.utils.achievement.ReplaceKeywordWithAchievementLink(self, message, 'curve', curve);
    end
    if edge then
        message = self.utils.achievement.ReplaceKeywordWithAchievementLink(self, message, 'edge', edge);
    end

    if (original ~= message and self.DB.advertise) then
        message = self.PREFIX .. message
    end

    if (original ~= message and self.DB.enableSimulation) then
        self:SimulationPrint('Intent to replace message with:', message)
        return original
    end

    return message
end

--- @private
function LazyCurve:BNSendWhisper(id, msg)
    self.hooks.BNSendWhisper(id, self:ProcessMsg(msg))
end

--- @private
function LazyCurve:SendChatMessage(msg, chatType, language, channel)
    if C_ChatInfo.SendChatMessage then
        self.hooks[C_ChatInfo].SendChatMessage(self:ProcessMsg(msg), chatType, language, channel);
    else
        self.hooks.SendChatMessage(self:ProcessMsg(msg), chatType, language, channel);
    end
end

--- @private
function LazyCurve:SendAchievement(leaderName, achievementId)
    local message = GetAchievementLink(achievementId)
    if (self.DB.advertise) then
        message = self.PREFIX .. message
    end
    if (self.DB.enableSimulation) then
        self:SimulationPrint('Intent to whisper "', leaderName, '" with message:', message)
        return
    end
    self.hooks.SendChatMessage(message, 'WHISPER', nil, leaderName)
end

--- @private
function LazyCurve:OnInitialize()
    LazyCurveDB = LazyCurveDB or {}
    self.DB = LazyCurveDB --[[@as LazyCurveDB]]
    self:InitDefaults()

    self.Config:Initialize()

    if C_ChatInfo.SendChatMessage then
        self:RawHook(C_ChatInfo, 'SendChatMessage', true)
    else
        self:RawHook('SendChatMessage', true)
    end
    self:RawHook('BNSendWhisper', true)
    Menu.ModifyMenu('MENU_LFG_FRAME_SEARCH_ENTRY', function(owner, rootDescription)
        self:OnMenuOpen(owner, rootDescription)
    end)
    LFGListApplicationDialog.SignUpButton:HookScript('OnClick', function(button) self:OnSignUp(button) end)
    LFGListApplicationDialog.CancelButton:HookScript('OnClick', function(button) self:OnCancel(button) end)

    self:RegisterChatCommand('lc', self.Config.OpenConfig)
    self:RegisterChatCommand('lazycurve', self.Config.OpenConfig)

    self:RegisterEvent('ACHIEVEMENT_EARNED', function() self.utils.achievement:BuildAchievementKeywordMap() end);

    self.utils.achievement:BuildAchievementKeywordMap()
    C_Timer.NewTicker(3, function()
        -- achievements aren't loaded on login; so delay it, too lazy to find the proper event though :)
        self.utils.achievement:BuildAchievementKeywordMap()
    end, 5)
end

--- @private
function LazyCurve:InitDefaults()
    --- @type LazyCurveDB
    local defaults = {
        advertise = true,

        replaceKeywordsInChatMessages = true,
        whisperOnApply = true,
        disableAutolinkReminder = false,
        mythicThreshold = 2,

        devMode = false,
        enableSimulation = false,
        simulatedAchievements = {},
    }

    for property, value in pairs(defaults) do
        if self.DB[property] == nil then
            self.DB[property] = value
        end
    end
end
