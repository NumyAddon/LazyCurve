-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local C_LFGList = _G.C_LFGList
local ipairs = _G.ipairs


local name = ...
--- @class LazyCurve
local LazyCurve = LibStub('AceAddon-3.0'):GetAddon(name)
if not LazyCurve then return end

local ModuleUtil = {}
LazyCurve.utils.module = ModuleUtil

ModuleUtil.moduleInfoTables = {}

--- @param module LazyCurveModule
--- @return LazyCurveActivityTable_enriched
function ModuleUtil:GetLatestModuleRaid(module)
	return self:GetModuleInfoTable(module)[1]
end

--- @param module LazyCurveModule
--- @return boolean
function ModuleUtil:ModuleHasLatestRaid(module)
	return LazyCurve.CURRENT_EXPANSION == module.EXPANSION and module.type == LazyCurve.MODULE_TYPE_RAID
end

--- @param module LazyCurveModule
--- @param groupId number
--- @return LazyCurveActivityTable_enriched|false
function ModuleUtil:GetModuleInfoTableByActivityGroup(module, groupId)
	for _, activityTable in ipairs(self:GetModuleInfoTable(module)) do
		if activityTable.groupId == groupId then
			return activityTable
		end
	end
	return false
end

--- @param module LazyCurveModule
--- @return LazyCurveActivityTable_enriched[]
function ModuleUtil:GetModuleInfoTable(module)
	local moduleName = module.moduleName
	if not self.moduleInfoTables[moduleName] then
	    --- @class LazyCurveActivityTable_enriched[]: LazyCurveActivityTable[]
		local infoTable = module:GetInfoTable()
		for _, activityTable in ipairs(infoTable) do
			local localName, _ = C_LFGList.GetActivityGroupInfo(activityTable.groupId)
			activityTable.longName = localName or activityTable.shortName
			activityTable.module = module
			activityTable.isLatest = self:ModuleHasLatestRaid(module) and infoTable[1] == activityTable
		end
		self.moduleInfoTables[moduleName] = infoTable
	end

	return self.moduleInfoTables[moduleName]
end