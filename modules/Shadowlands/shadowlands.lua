-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local C_LFGList = _G.C_LFGList
local GetBuildInfo = _G.GetBuildInfo
local ipairs = _G.ipairs
local setmetatable = _G.setmetatable

local modName = 'Shadowlands'
LazyCurve = LibStub('AceAddon-3.0'):GetAddon('LazyCurve');
LazyCurveShadowlands = LazyCurve:NewModule(modName)
LazyCurveShadowlands.TYPE = LazyCurve.TYPE_RAID

function LazyCurveShadowlands:HasLatestRaid()
    local _, _, _, gameVersion = GetBuildInfo();
    return gameVersion >= 90000 and gameVersion < 100000
end

function LazyCurveShadowlands:GetLatestRaid()
    if not self:HasLatestRaid() then return nil end

    return self:GetInfoTable()[1]
end

function LazyCurveShadowlands:GetInfoTableByActivityGroup(groupId)
    -- pvp or m+ would just return all if the category matches
    for _, activityTable in ipairs(self:GetInfoTable()) do
        if activityTable.groupId == groupId then
            return activityTable
        end
    end
    return false
end

function LazyCurveShadowlands:IsActivityActive(activityTable)
    local searchGroupId = activityTable.groupId
    for _, groupId in ipairs(C_LFGList.GetAvailableActivityGroups(LazyCurve.ACTIVITY_CATEGORY_RAID)) do
        if groupId == searchGroupId then
            return true
        end
    end

    return false
end

function LazyCurveShadowlands:GetInfoTable()
    local infoTable = {
        {
            shortName = "CN",
            alternativeKeyword = "placeholder",
            groupId = 267,
            achievements = { -- these are all placeholders for now
                normal = 12266,
                curve = 12110,
                edge = 12111,
                mythic = {
                    11992, --garothi worldbreaker
                    11993, --hounds
                    11994, --high command
                    11995, --portal keeper
                    11996, --eonar
                    11997, --imonar
                    11998, --kin'garoth
                    11999, --varimathras
                    12000, --coven
                    12001, --aggramar
                    12002, --argus
                },
            },
        },
    }
    local metatable = {
        __index = function(activityTable, key)
            if key == 'longName' then
                local name,_ = C_LFGList.GetActivityGroupInfo(activityTable.groupId)
                return name
            elseif key == 'isActive' then
                return self:IsActivityActive(activityTable)
            elseif key == 'type' then
                return self.TYPE
            elseif key == 'module' then
                return self
            elseif key == 'isLatest' then
                return self:HasLatestRaid()
                        and self:GetLatestRaid().shortName == activityTable.shortName
            end
        end
    }
    for _, activityTable in ipairs(infoTable) do
        setmetatable(activityTable, metatable)
    end
    return infoTable
end



