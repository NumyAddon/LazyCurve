-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local GetAchievementInfo = _G.GetAchievementInfo
local ipairs = _G.ipairs
local table = _G.table
local pairs = _G.pairs
local strfind = _G.strfind
local C_LFGList = _G.C_LFGList

local name = ...
local LazyCurve = LibStub('AceAddon-3.0'):GetAddon(name)
if not LazyCurve then return end

LazyCurve.utils = LazyCurve.utils or {}
LazyCurve.utils.searchEntryMenu = LazyCurve.utils.searchEntryMenu or {}

local function tableInsertChildren(target, tableToInsert)
    for _,child in ipairs(tableToInsert) do
        table.insert(target, child)
    end
    return target
end

function LazyCurve.utils.searchEntryMenu:GetSearchEntryMenu(resultID)

    local tempResultTable = C_LFGList.GetSearchResultInfo(resultID);
    local _, _, _, groupId, _ = C_LFGList.GetActivityInfo(tempResultTable.activityID)
    local leaderName = tempResultTable.leaderName

    local popupMenu = LazyCurve.hooks.LFGListUtil_GetSearchEntryMenu(resultID)

    local found = false
    local menuIndex
    for i, item in pairs(popupMenu) do
        if(strfind(item.text, LazyCurve.PREFIX)) then
            menuIndex = i
            found = true
            break
        end
    end

    local lazyCurveMenu = self:getExtraMenuList(groupId, leaderName)

    if(not found) then
        table.insert(popupMenu, 4, lazyCurveMenu)
    else
        popupMenu[menuIndex] = lazyCurveMenu
    end

    return popupMenu
end

function LazyCurve.utils.searchEntryMenu:FormatAchievementMenuItem(achievementId, leaderName)
    local _, achievementName, _ = GetAchievementInfo(achievementId)

    return {
        text = achievementName,
        func = function(_, leaderName, id) LazyCurve:SendAchievement(leaderName, id) end,
        notCheckable = true,
        arg1 = leaderName,
        arg2 = achievementId,
        disabled = not leaderName,
    }
end

function LazyCurve.utils.searchEntryMenu:GetAchievementMenu(infoTable, leaderName)
    local mainMenuItems = {}

    for _, activityTable in ipairs(infoTable) do
        local earnedAchievements = LazyCurve.utils.achievement:GetHighestEarnedAchievement(activityTable)
        if #earnedAchievements > 0 then
            if activityTable.isLatest or (activityTable.hideRaids and #infoTable == 1) then
                for _, achievementId in ipairs(earnedAchievements) do
                    table.insert(mainMenuItems, 1, self:FormatAchievementMenuItem(achievementId, leaderName))
                end
            else
                local subMenuItems = {}
                for _, achievementId in ipairs(earnedAchievements) do
                    table.insert(subMenuItems, self:FormatAchievementMenuItem(achievementId, leaderName))
                end
                local subMenu = {
                    text = activityTable.longName,
                    hasArrow = true,
                    notCheckable = true,
                    disabled = not leaderName,
                    menuList = subMenuItems,
                }
                table.insert(mainMenuItems, subMenu)
            end
        end
    end

    if #mainMenuItems == 0 then
        return false
    end

    if #mainMenuItems == 1 then
        local mainMenu = mainMenuItems[1]
        mainMenu.text = LazyCurve.PREFIX .. 'Link to leader: ' .. mainMenu.text
        return mainMenu
    end

    local mainMenu =  {
        text = LazyCurve.PREFIX .. ' Link Achievement to Leader',
        hasArrow = true,
        notCheckable = true,
        disabled = not leaderName,
        menuList = mainMenuItems,
    }
    return mainMenu
end

function LazyCurve.utils.searchEntryMenu:getExtraMenuList(groupId, leaderName)
    local infoTable = self:GetInfoTableByActivityGroup(groupId)
    local menu = self:GetAchievementMenu(infoTable, leaderName)

    if not menu then
        --no achievements
        return {
            text = LazyCurve.PREFIX .. ' You haven not completed any relevant achievements yet :(',
            notCheckable = true,
            disabled = true,
        }
    end
    return menu
end

function LazyCurve.utils.searchEntryMenu:GetInfoTableByActivityGroup(groupId, groupResultsOnly)
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
