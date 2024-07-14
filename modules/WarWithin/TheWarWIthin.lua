-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local LE_EXPANSION_WAR_WITHIN = _G.LE_EXPANSION_WAR_WITHIN

local modName = 'TheWarWithin'
--- @type LazyCurve
local LazyCurve = LibStub('AceAddon-3.0'):GetAddon('LazyCurve')
--- @class LazyCurveWarWithin: LazyCurveModule
local Module = LazyCurve:NewModule(modName)
Module.EXPANSION = LE_EXPANSION_WAR_WITHIN
Module.type = LazyCurve.MODULE_TYPE_RAID

function Module:GetInfoTable()
    --- @type LazyCurveActivityTable[]
    local infoTable = {
        --{
        --    shortName = "ATDH",
        --    alternativeKeyword = "fyrakk",
        --    groupId = 319,
        --    achievements = {
        --        normal = 19331,
        --        curve = 19350,
        --        edge = 19351,
        --        mythic = {
        --            19335, -- Gnarlroot
        --            19336, -- Igira the Cruel
        --            19337, -- Volcoross
        --            19338, -- Council of Dreams
        --            19339, -- Larodar, Keeper of the Flame
        --            19340, -- Nymue, Weaver of the Cycle
        --            19341, -- Smolderon
        --            19342, -- Tindral Sageswift, Seer of the Flame
        --            19343, -- Fyrakk the Blazing
        --        },
        --    },
        --},
    }
    return infoTable
end
