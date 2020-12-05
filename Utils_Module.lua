-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local C_LFGList = _G.C_LFGList
local ipairs = _G.ipairs


local name = ...
local LazyCurve = LibStub('AceAddon-3.0'):GetAddon(name)
if not LazyCurve then return end

LazyCurve.utils = LazyCurve.utils or {}
LazyCurve.utils.module = LazyCurve.utils.module or {}

LazyCurve.utils.module.moduleInfoTables = {}

function LazyCurve.utils.module:GetLatestModuleRaid(module)
	return self:GetModuleInfoTable(module)[1]
end

function LazyCurve.utils.module:ModuleHasLatestRaid(module)
	return LazyCurve.CURRENT_EXPANSION == module.EXPANSION
end

function LazyCurve.utils.module:GetModuleInfoTableByActivityGroup(module, groupId)
	for _, activityTable in ipairs(self:GetModuleInfoTable(module)) do
		if activityTable.groupId == groupId then
			return activityTable
		end
	end
	return false
end

function LazyCurve.utils.module:GetModuleInfoTable(module)
	local moduleName = module.moduleName
	if not self.moduleInfoTables[moduleName] then
		local infoTable = module:GetInfoTable()
		for i, activityTable in ipairs(infoTable) do
			local name, _ = C_LFGList.GetActivityGroupInfo(activityTable.groupId)
			activityTable.longName = name
			activityTable.isActive = LazyCurve:IsActivityActive(activityTable)
			activityTable.module = module
			activityTable.isLatest = self:ModuleHasLatestRaid(module) and
					infoTable[i].shortName == activityTable.shortName
		end
		self.moduleInfoTables[moduleName] = infoTable
	end

	return self.moduleInfoTables[moduleName]
end