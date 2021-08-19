-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local LE_EXPANSION_SHADOWLANDS = _G.LE_EXPANSION_SHADOWLANDS

local modName = 'Shadowlands'
local LazyCurve = LibStub('AceAddon-3.0'):GetAddon('LazyCurve')
local LazyCurveShadowlands = LazyCurve:NewModule(modName)
LazyCurveShadowlands.EXPANSION = LE_EXPANSION_SHADOWLANDS

function LazyCurveShadowlands:GetInfoTable()
    -- source: wowhead.com and https://wow.tools/dbc/?dbc=groupfinderactivity#page=1&colFilter[2]=heroic&colFilter[3]=3

    local infoTable = {
        {
            shortName = "SOD",
            alternativeKeyword = "sylvanas",
            groupId = 271,
            achievements = {
                normal = 15126,
                curve = 15134,
                edge = 15135,
                mythic = {
                    15112, --the-tarragrue
                    15113, --the-eye-of-the-jailor
                    15114, --the-nine
                    15115, --remnant-of-ner'zhul
                    15116, --soulrender-dormazain
                    15117, --painsmith-raznal
                    15118, --guardian-of-the-first-ones
                    15119, --fatescribe-roh-kalo
                    15120, --kel'thuzad
                    15121, --sylvanas-windrunner
                },
            }
        },
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
        {
            shortName = "TAZ",
            alternativeKeyword = "taza",
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



