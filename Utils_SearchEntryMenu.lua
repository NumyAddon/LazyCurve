local isDF = select(4, GetBuildInfo()) < 110000;
if isDF then return; end -- TWW+ only
--- @todo delete check in TWW

-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local GetAchievementInfo = _G.GetAchievementInfo
local ipairs = _G.ipairs
local table = _G.table
local C_LFGList = _G.C_LFGList

local name = ...
--- @class LazyCurve
local LazyCurve = LibStub('AceAddon-3.0'):GetAddon(name)
if not LazyCurve then return end

local SearchEntryMenuUtil = {}
LazyCurve.utils.searchEntryMenu = SearchEntryMenuUtil

local function tableInsertChildren(target, tableToInsert)
    for _,child in ipairs(tableToInsert) do
        table.insert(target, child)
    end
    return target
end

--- @param resultID number
function SearchEntryMenuUtil:ExtendMenu(resultID, rootDescription)
    local resultTable = C_LFGList.GetSearchResultInfo(resultID);
    local activityInfo = C_LFGList.GetActivityInfoTable(resultTable.activityID)
    local leaderName = resultTable.leaderName
    local groupID = activityInfo.groupFinderActivityGroupID
    local infoTable = self:GetInfoTableByActivityGroup(groupID)

    rootDescription:QueueDivider();
    rootDescription:QueueTitle(LazyCurve.PREFIX);
    local addedItems = self:AppendAchievements(rootDescription, infoTable, leaderName)

    if not addedItems then
        rootDescription:ClearQueuedDescriptions();
    end
end

function SearchEntryMenuUtil:AddAchievementItem(elementDescription, achievementId, leaderName, textPrefix)
    local _, achievementName, _ = GetAchievementInfo(achievementId)
    textPrefix = textPrefix or ''

    local button = elementDescription:CreateButton(textPrefix .. achievementName, function()
        LazyCurve:SendAchievement(leaderName, achievementId)
    end)
    button:SetEnabled(leaderName ~= nil)

    return button
end

--- @param infoTable LazyCurveActivityTable_enriched[]
--- @param leaderName string
--- @return boolean # true if any achievement was added, false otherwise
function SearchEntryMenuUtil:AppendAchievements(rootDescription, infoTable, leaderName)
    local mainMenuItems = {}

    for _, activityTable in ipairs(infoTable) do
        local earnedAchievements = LazyCurve.utils.achievement:GetHighestEarnedAchievement(activityTable)
        if #earnedAchievements > 0 then
            if activityTable.isLatest or (activityTable.hideRaids and #infoTable == 1) then
                for _, achievementID in ipairs(earnedAchievements) do
                    table.insert(mainMenuItems, 1, achievementID)
                end
            else
                local subMenuItems = {}
                for _, achievementID in ipairs(earnedAchievements) do
                    table.insert(subMenuItems,achievementID)
                end
                local subMenu = {
                    text = activityTable.longName,
                    items = subMenuItems,
                }
                table.insert(mainMenuItems, subMenu)
            end
        end
    end

    if #mainMenuItems == 0 then
        return false
    end

    if #mainMenuItems == 1 then
        self:AddAchievementItem(rootDescription, mainMenuItems[1], leaderName, 'Link to leader: ')

        return true
    end

    local elementDescription = rootDescription:CreateButton('Link Achievement to Leader');
    for _, item in ipairs(mainMenuItems) do
        if type(item) == 'number' then
            self:AddAchievementItem(elementDescription, item, leaderName)
        else
            local subMenu = elementDescription:CreateButton(item.text);
            for _, subItem in ipairs(item.items) do
                self:AddAchievementItem(subMenu, subItem, leaderName)
            end
        end
    end

    return true
end

--- @param groupId number
--- @param groupResultsOnly true?
--- @return LazyCurveActivityTable_enriched[]
function SearchEntryMenuUtil:GetInfoTableByActivityGroup(groupId, groupResultsOnly)
    local resultTable = {}
    local allInfo = {}
    local nonRaids = {}
    local minimumResults = 1

    for _, module in LazyCurve:IterateModules() do
        local moduleInfoTable = LazyCurve.utils.module:GetModuleInfoTable(module)

        allInfo = tableInsertChildren(allInfo, moduleInfoTable)

        local infoTable = LazyCurve.utils.module:GetModuleInfoTableByActivityGroup(module, groupId)
        if infoTable then
            if(infoTable.hideRaids) then
                table.insert(nonRaids, infoTable)
            end
            table.insert(resultTable, infoTable)
        end

        if (not groupResultsOnly and (not infoTable or not infoTable.isLatest)) and LazyCurve.utils.module:ModuleHasLatestRaid(module) then
            minimumResults = minimumResults + 1
            table.insert(resultTable, LazyCurve.utils.module:GetLatestModuleRaid(module))
        end
    end
    return #nonRaids > 0 and nonRaids or ((groupResultsOnly or #resultTable >= minimumResults) and resultTable or allInfo)
end
