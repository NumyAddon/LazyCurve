-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local LE_EXPANSION_DRAGONFLIGHT = _G.LE_EXPANSION_DRAGONFLIGHT or 9

local modName = 'Dragonflight'
local LazyCurve = LibStub('AceAddon-3.0'):GetAddon('LazyCurve')
local LazyCurveShadowlands = LazyCurve:NewModule(modName)
LazyCurveShadowlands.EXPANSION = LE_EXPANSION_DRAGONFLIGHT
LazyCurveShadowlands.type = LazyCurve.MODULE_TYPE_RAID

function LazyCurveShadowlands:GetInfoTable()
    local infoTable = {
        {
            shortName = "VOTI",
            alternativeKeyword = "raszageth",
            groupId = 310,
            achievements = {
                normal = 16343,
                curve = 999999, -- achievement isn't on the beta yet
                edge = 999999, -- achievement isn't on the beta yet
                mythic = {
                    16346, -- Eranog
                    16347, -- Terros
                    16348, -- The Primal Council
                    16349, -- Sennarth, The Cold Breath
                    16350, -- Dathea, Ascended
                    16351, -- Kurog Grimtotem
                    16352, -- Broodkeeper Diurna
                    16353, -- Raszageth the Storm-Eater
                },
            },
        },
    }
    return infoTable
end
