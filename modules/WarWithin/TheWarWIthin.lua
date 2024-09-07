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
Module.shortName = "TWW"

function Module:GetInfoTable()
    --- @type LazyCurveActivityTable[]
    local infoTable = {
        {
            shortName = "NEPAL",
            alternativeKeyword = "ansurek",
            groupId = 362,
            achievements = {
                normal = 40244,
                curve = 40253,
                edge = 40254,
                mythic = {
                    40236, -- Ulgrax the Devourer
                    40237, -- The Bloodbound Horror
                    40238, -- Sikran, Captain of the Sureki
                    40239, -- Rasha'nan
                    40240, -- Broodtwister Ovi'nax
                    40241, -- Nexus-Princess Ky'veza
                    40242, -- The Silken Court
                    40243, -- Queen Ansurek
                },
            },
        },
    }
    return infoTable
end
