-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local C_LFGList = _G.C_LFGList
local GetBuildInfo = _G.GetBuildInfo
local ipairs = _G.ipairs
local setmetatable = _G.setmetatable

local modName = 'Legion'
LazyCurve = LibStub('AceAddon-3.0'):GetAddon('LazyCurve');
LazyCurveLegion = LazyCurve:NewModule(modName)
LazyCurveLegion.TYPE = LazyCurve.TYPE_RAID

function LazyCurveLegion:HasLatestRaid()
    local _, _, _, gameVersion = GetBuildInfo();
    return gameVersion >= 70000 and gameVersion < 80000
end

function LazyCurveLegion:GetLatestRaid()
    if not self:HasLatestRaid() then return nil end

    return self:GetInfoTable()[1]
end

function LazyCurveLegion:GetInfoTableByActivityGroup(groupId)
    -- pvp or m+ would just return all if the category matches
    for _, activityTable in ipairs(self:GetInfoTable()) do
        if activityTable.groupId == groupId then
            return activityTable
        end
    end
    return false
end

function LazyCurveLegion:IsActivityActive(activityTable)
    local searchGroupId = activityTable.groupId
    for _, groupId in ipairs(C_LFGList.GetAvailableActivityGroups(LazyCurve.ACTIVITY_CATEGORY_RAID)) do
        if groupId == searchGroupId then
            return true
        end
    end

    return false
end

function LazyCurveLegion:GetInfoTable()
    local infoTable = {
        {
            shortName = "ABT",
            alternativeKeyword = "argus",
            groupId = 132,
            achievements = {
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
        {
            shortName = "TOS",
            alternativeKeyword = "kiljaeden",
            groupId = 131,
            achievements = {
                normal = 11790,
                curve = 11874,
                edge = 11875,
                mythic = {
                    11767, --goroth
                    11774, --demonic inq
                    11775, --harja
                    11776, --mistress
                    11777, --sisters
                    11778, --host
                    11779, --maiden
                    11780, --avatar
                    11781, --KJ
                },
            },
        },
        {
            shortName = "NH",
            alternativeKeyword = "guldan",
            groupId = 123,
            achievements = {
                normal = 10839,
                curve = 11195,
                edge = 11192,
                mythic = {
                    10840, --skorpyron
                    10842, --chronomatic anomaly
                    10843, --trilliax
                    10844, --spellblade aluriel
                    10845, --star augur
                    10846, --botanist
                    10847, --tichondrius
                    10848, --krosus
                    10849, --elisande
                    10850, --guldan
                },
            },
        },
        {
            shortName = "TOV",
            alternativeKeyword = "helya",
            groupId = 126,
            achievements = {
                normal = 11394,
                curve = 11581,
                edge = 11580,
                mythic = {
                    11396, --odin
                    11397, --guarm
                    11398, --helya
                },
            },
        },
        {
            shortName = "EN",
            alternativeKeyword = "xavius",
            groupId = 122,
            achievements = {
                normal = 10820,
                curve = 11194,
                edge = 11191,
                mythic = {
                    10821, --nythendra
                    10822, --elerethe renferal
                    10823, --il'gynoth
                    10824, --ursoc
                    10825, --dragons
                    10826, --cenarius
                    10827, --xavius
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



