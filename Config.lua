-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local tonumber = _G.tonumber
local GetAchievementInfo = _G.GetAchievementInfo
local pairs = _G.pairs

local name = ...
--- @class LazyCurve
local LazyCurve = LibStub("AceAddon-3.0"):GetAddon(name);
if not LazyCurve then return end

local Config = {}
LazyCurve.Config = Config

Config.version = C_AddOns.GetAddOnMetadata(name, "Version") or ""

function Config:GetOptions()
	local increment = CreateCounter(1)
	local options = {
		type = 'group',
		get = function(info) return Config:GetConfig(info[#info]); end,
		set = function(info, value) return Config:SetConfig(info[#info], value); end,
		args = {
			version = {
				order = increment(),
				type = "description",
				name = "Version: " .. self.version
			},
			advertise = {
				order = increment(),
				name = "Selfpromotion",
				desc = "Adds <LazyCurve> before each 'LazyCurve' whisper",
				descStyle = 'inline',
				width = "full",
				type = "toggle",
			},
			whisperOnApply = {
				order = increment(),
				name = "Enable auto-linking on LFG application",
				desc = "Automatically whispers your best achievement(s) when applying to a raid.",
				descStyle = 'inline',
				width = "full",
				type = "toggle",
			},
			disableAutolinkReminder = {
				order = increment(),
				name = "Disable the reminder when automatically whispering",
				width = "full",
				type = "toggle",
			},
			mythicThreshold = {
				order = increment(),
				name = "Which mythic boss is the first relevant boss to link together with curve.",
				width = 3,
				type = "range",
				min = 0,
				softMax = 10,
				step = 1,
				bigStep = 1,
			},
			mythicThresholdDesc = {
				order = increment(),
				type = "description",
				name = "Set to 0 to disable linking mythic achievements on LFG applying (except for edge/last boss kill). Set to 1 or higher to start linking achievements from that boss.",
			},
			devMode = {
				order = increment(),
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
			order = increment(),
			name = "Dev mode",
			type = "group",
			args = {
				enableSimulation = {
					order = increment(),
					width = "full",
					type = "toggle",
					get = function()
						return LazyCurve.DB.enableSimulation;
					end,
					--- @param value boolean
					set = function(_, value)
						LazyCurve.DB.enableSimulation = value
						LazyCurve.utils.achievement:BuildAchievementKeywordMap()
					end,
					name = "Enable simulation mode",
					desc = "Simulate earned achievements, and simulate linking of achievements. (this can't be used to trick people into thinking you've earned achievements)",
				},
				addAchievement = {
					order = increment(),
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
					order = increment(),
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
						LazyCurve.DB.simulatedAchievements[tonumber(index)] = nil
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
	Settings.OpenToCategory('LazyCurve')
end

--- @param property LazyCurveOption
function Config:GetConfig(property)
	return LazyCurve.DB[property];
end

--- @param property LazyCurveOption
function Config:SetConfig(property, value)
	LazyCurve.DB[property] = value;
end
