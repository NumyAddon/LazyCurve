-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local LE_EXPANSION_DRAGONFLIGHT = _G.LE_EXPANSION_DRAGONFLIGHT

local modName = 'Dragonflight'
local LazyCurve = LibStub('AceAddon-3.0'):GetAddon('LazyCurve')
local LazyCurveShadowlands = LazyCurve:NewModule(modName)
LazyCurveShadowlands.EXPANSION = LE_EXPANSION_DRAGONFLIGHT
LazyCurveShadowlands.type = LazyCurve.MODULE_TYPE_RAID

function LazyCurveShadowlands:GetInfoTable()
    local infoTable = {
        {
            shortName = "ASC",
            alternativeKeyword = "sarkareth",
            groupId = 313,
            achievements = {
                normal = 18160,
                curve = 18253,
                edge = 18254,
                mythic = {
                    18151, -- Kazzara, the Hellforged
                    18152, -- The Amalgamation Chamber
                    18154, -- Assault of the Zaqali
                    18153, -- The Forgotten Experiments
                    18155, -- Rashok, the Elder
                    18156, -- The Vigilant Steward, Zskarn
                    18157, -- Magmorax
                    18158, -- Echo of Neltharion
                    18159, -- Scalecommander Sarkareth
                },
            },
        },
        {
            shortName = "VOTI",
            alternativeKeyword = "raszageth",
            groupId = 310,
            achievements = {
                normal = 16343,
                curve = 17107,
                edge = 17108,
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
