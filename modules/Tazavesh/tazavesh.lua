-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local LE_EXPANSION_DRAGONFLIGHT = _G.LE_EXPANSION_DRAGONFLIGHT

local modName = 'Tazavesh'
local LazyCurve = LibStub('AceAddon-3.0'):GetAddon('LazyCurve')
local LazyCurveTazavesh = LazyCurve:NewModule(modName)
LazyCurveTazavesh.EXPANSION = LE_EXPANSION_DRAGONFLIGHT
LazyCurveTazavesh.type = LazyCurve.MODULE_TYPE_OTHER

function LazyCurveTazavesh:GetInfoTable()
    local infoTable = {
        {
            hideRaids = true,
            shortName = "DOTI",
            alternativeKeyword = "dawnoftheinfinite",
            groupId = 315,
            achievements = {
                normal = 18705,
                curve = 18706,
                edge = 18706,
                mythic = {
                    18705, --normal-mode
                    18706, --hard-mode
                },
            },
        },
        {
            hideRaids = true,
            shortName = "TAZ",
            alternativeKeyword = "tazavesh",
            groupId = 272,
            achievements = {
                normal = 15177,
                curve = 15178,
                edge = 15178,
                mythic = {
                    15177, --normal-mode
                    15178, --hard-mode
                },
            },
        },
    }
    return infoTable
end
