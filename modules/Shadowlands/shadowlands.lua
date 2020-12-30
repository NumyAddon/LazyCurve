-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local LE_EXPANSION_SHADOWLANDS = _G.LE_EXPANSION_SHADOWLANDS

local modName = 'Shadowlands'
local LazyCurve = LibStub('AceAddon-3.0'):GetAddon('LazyCurve')
local LazyCurveShadowlands = LazyCurve:NewModule(modName)
LazyCurveShadowlands.EXPANSION = LE_EXPANSION_SHADOWLANDS

function LazyCurveShadowlands:GetInfoTable()
    -- source: wowhead.com and https://wow.tools/dbc/?dbc=groupfinderactivity&build=9.0.2.36665#page=1&colFilter[2]=heroic&colFilter[3]=3

    local infoTable = {
        {
            shortName = "CN",
            alternativeKeyword = "denathrius",
            groupId = 267,
            achievements = {
                normal = 14715,
                curve = 14460,
                edge = 14461,
                mythic = {
                    14356, --shriekwing
                    14357, --huntsman-altimor
                    14360, --sun-kings-salvation
                    14359, --artificer-xymox
                    14358, --hungering-destroyer
                    14361, --lady-inerva-darkvein
                    14362, --the-council-of-blood
                    14363, --sludgefist
                    14364, --stone-legion-generals
                    14365, --sire-denathrius
                },
            },
        },
    }
    return infoTable
end



