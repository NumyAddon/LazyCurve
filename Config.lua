-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local GetAddOnMetadata = _G.GetAddOnMetadata or _G.C_AddOns.GetAddOnMetadata
local InterfaceOptionsFrame_OpenToCategory = _G.InterfaceOptionsFrame_OpenToCategory
local tonumber = _G.tonumber
local GetAchievementInfo = _G.GetAchievementInfo
local pairs = _G.pairs
local coroutine = _G.coroutine

local name = ...
local LazyCurve = LibStub("AceAddon-3.0"):GetAddon(name);
if not LazyCurve then return end

LazyCurve.Config = LazyCurve.Config or {}
local Config = LazyCurve.Config

Config.version = GetAddOnMetadata(name, "Version") or ""

local function getCounter(start, increment)
	start = start or 1
	increment = increment or 1
	return coroutine.wrap(function()
		local count = start
		while true do
			count = count + increment
			coroutine.yield(count)
		end
	end)
end

function Config:GetOptions()
	local orderCount = getCounter()
	local options = {
		type = 'group',
		get = function(info) return Config:GetConfig(info[#info]); end,
		set = function(info, value) return Config:SetConfig(info[#info], value); end,
		args = {
			version = {
				order = orderCount(),
				type = "description",
				name = "Version: " .. self.version
			},
			advertise = {
				order = orderCount(),
				name = "Selfpromotion",
				desc = "Adds <LazyCurve> before each 'LazyCurve' whisper",
				descStyle = 'inline',
				width = "full",
				type = "toggle",
			},
			whisperOnApply = {
				order = orderCount(),
				name = "Enable auto-linking on LFG application",
				desc = "Automatically whispers your best achievement(s) when applying to a raid.",
				descStyle = 'inline',
				width = "full",
				type = "toggle",
			},
			disableAutolinkReminder = {
				order = orderCount(),
				name = "Disable the reminder when automatically whispering",
				width = "full",
				type = "toggle",
			},
			mythicThreshold = {
				order = orderCount(),
				name = "Which mythic boss is the first relevant boss to link together with curve.",
				width = 3,
				type = "range",
				min = 0,
				softMax = 10,
				step = 1,
				bigStep = 1,
			},
			mythicThresholdDesc = {
				order = orderCount(),
				type = "description",
				name = "Set to 0 to disable linking mythic achievements on LFG applying (except for edge/last boss kill). Set to 1 or higher to start linking achievements from that boss.",
			},
			devMode = {
				order = orderCount(),
				type = "toggle",
				name = "Enable Dev mode",
				set = function(info, value)
					Config:SetConfig(info[#info], value)
					if not value then
						LazyCurve.DB.enableSimulation = false
						LazyCurve.utils.achievement:BuildAchievementKeywordMap()
					end
					Config:RegisterOptions()
				end,
			},
		},
	}

	if self:GetConfig('devMode') then
		options.childGroups = "tab"
		options.args.devTab = {
			order = orderCount(),
			name = "Dev mode",
			type = "group",
			args = {
				enableSimulation = {
					order = orderCount(),
					width = "full",
					type = "toggle",
					get = function()
						return LazyCurve.DB.enableSimulation;
					end,
					set = function(_, value)
						LazyCurve.DB.enableSimulation = value
						LazyCurve.utils.achievement:BuildAchievementKeywordMap()
					end,
					name = "Enable simulation mode",
					desc = "Simulate earned achievements, and simulate linking of achievements. (this can't be used to trick people into thinking you've earned achievements)",
				},
				addAchievement = {
					order = orderCount(),
					type = "input",
					name = "Add simulated Achievement",
					validate = function(_, input)
						return not not GetAchievementInfo(input);
					end,
					usage = "Must be a valid achievement ID",
					set = function(_, value)
						LazyCurve.DB.simulatedAchievements[tonumber(value)] = true
						LazyCurve.utils.achievement:BuildAchievementKeywordMap()
					end,
				},
				removeAchievement = {
					order = orderCount(),
					type = "select",
					style = "dropdown",
					name = "Remove Simulated Achievement",
					desc = "Select the simulated achievement that you no longer wish to simulate",
					width = "double",
					values = function()
						local tempTable = {}
						for achievementId, _ in pairs(LazyCurve.DB.simulatedAchievements) do
							local _, achievementName, _ = GetAchievementInfo(achievementId)
							tempTable[achievementId] = achievementName
						end
						return tempTable
					end,
					get = function(_, _) return false end,
					set = function(_, index, ...)
						LazyCurve.DB.simulatedAchievements[index] = nil
						LazyCurve.utils.achievement:BuildAchievementKeywordMap()
					end,
				},
			},
		}
	end

	return options
end

function Config:Initialize()
	self:RegisterOptions()
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("LazyCurve", "LazyCurve")
end

function Config:RegisterOptions()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("LazyCurve", self:GetOptions())
end

function Config:OpenConfig()
	-- after a reload, you need to open to category twice to actually open the correct page
	InterfaceOptionsFrame_OpenToCategory('LazyCurve')
	InterfaceOptionsFrame_OpenToCategory('LazyCurve')
end

function Config:GetConfig(property)
	return LazyCurve.DB[property];
end

function Config:SetConfig(property, value)
	LazyCurve.DB[property] = value;
end