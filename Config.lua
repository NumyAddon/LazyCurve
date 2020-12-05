-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local GetAddOnMetadata = _G.GetAddOnMetadata
local InterfaceOptionsFrame_OpenToCategory = _G.InterfaceOptionsFrame_OpenToCategory

local name = ...
local LazyCurve = LibStub("AceAddon-3.0"):GetAddon(name);
if not LazyCurve then return end

LazyCurve.Config = LazyCurve.Config or {}
local Config = LazyCurve.Config

Config.version = GetAddOnMetadata(name, "Version") or ""

function Config:GetOptions()
	return {
		type = 'group',
		get = function(info) return Config:GetConfig(info[#info]); end,
		set = function(info, value) return Config:SetConfig(info[#info], value); end,
		args = {
			version = {
				order = 0,
				type = "description",
				name = "Version: " .. self.version
			},
			advertise = {
				name = "Selfpromotion",
				desc = "Adds <LazyCurve> before each 'LazyCurve' whisper",
				descStyle = 'inline',
				width = "full",
				order = 1,
				type = "toggle",
			},
			whisperOnApply = {
				name = "Enable auto-linking on LFG application",
				desc = "Automatically whispers your best achievement(s) when applying to a raid.",
				descStyle = 'inline',
				width = "full",
				order = 2,
				type = "toggle",
			},
			disableAutolinkReminder = {
				name = "Disable the reminder when automatically whispering",
				width = "full",
				order = 3,
				type = "toggle",
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
			},
			mythicThresholdDesc = {
				type = "description",
				order = 5,
				name = "Set to 0 to disable linking mythic achievements on LFG applying (except for edge/last boss kill). Set to 1 or higher to start linking achievements from that boss.",
			},
		},
	}
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