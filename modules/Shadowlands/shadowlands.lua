-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local LE_EXPANSION_SHADOWLANDS = _G.LE_EXPANSION_SHADOWLANDS

local modName = 'Shadowlands'
local LazyCurve = LibStub('AceAddon-3.0'):GetAddon('LazyCurve')
local Module = LazyCurve:NewModule(modName)
Module.EXPANSION = LE_EXPANSION_SHADOWLANDS
Module.type = LazyCurve.MODULE_TYPE_RAID
Module.shortName = "SL"

function Module:GetInfoTable()
    local infoTable = {
        {
            shortName = "SFO",
            alternativeKeyword = "jailer",
            groupId = 282,
            achievements = {
                normal = 15417,
                curve = 15470,
                edge = 15471,
                mythic = {
                    15479, --vigilant-guardian
                    15480, --skolex
                    15481, --artificer-xymox
                    15482, --dausegne
                    15483, --prototype-pantheon
                    15484, --lihuvim
                    15485, --halondrus
                    15486, --anduin-wrynn
                    15487, --lords-of-dread
                    15488, --rygelon
                    15489, --the-jailer
                },
            },
        },
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
            },
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
    }
    return infoTable
end
