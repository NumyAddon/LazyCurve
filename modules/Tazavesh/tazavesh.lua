-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local LE_EXPANSION_SHADOWLANDS = _G.LE_EXPANSION_SHADOWLANDS

local modName = 'Tazavesh'
local LazyCurve = LibStub('AceAddon-3.0'):GetAddon('LazyCurve')
local LazyCurveTazavesh = LazyCurve:NewModule(modName)
LazyCurveTazavesh.EXPANSION = LE_EXPANSION_SHADOWLANDS
LazyCurveTazavesh.type = LazyCurve.MODULE_TYPE_OTHER

function LazyCurveTazavesh:GetInfoTable()
    local infoTable = {
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
