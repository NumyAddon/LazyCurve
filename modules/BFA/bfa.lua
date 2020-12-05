-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local UnitFactionGroup = _G.UnitFactionGroup
local LE_EXPANSION_BATTLE_FOR_AZEROTH = _G.LE_EXPANSION_BATTLE_FOR_AZEROTH

local modName = 'BattleForAzeroth'
LazyCurve = LibStub('AceAddon-3.0'):GetAddon('LazyCurve')
LazyCurveBFA = LazyCurve:NewModule(modName)
LazyCurveBFA.EXPANSION = LE_EXPANSION_BATTLE_FOR_AZEROTH

function LazyCurveBFA:GetInfoTable()
    local faction, _ = UnitFactionGroup('player');
    local BODConclave = faction == 'Horde' and 13300 or 13298
    local BODNm = faction == 'Horde' and 13291 or 13288

    local infoTable = {
        {
            shortName = "NYA",
            alternativeKeyword = "nzoth",
            groupId = 258,
            achievements = {
                normal = 14196,
                curve = 14068,
                edge = 14069,
                mythic = {
                    14041, --wrathion
                    14043, --maut
                    14044, --prophet skitra
                    14045, --dark inquisitor xanesh
                    14046, --hivemind
                    14048, --shad'har
                    14049, --drest'agath
                    14050, --vexiona
                    14051, --ra=den
                    14052, --il'gynoth
                    14054, --carapace of n'zoth
                    14055, --n'zoth
                },
            },
        },
        {
            shortName = "TEP",
            alternativeKeyword = "azshara",
            groupId = 254,
            achievements = {
                normal = 13725,
                curve = 13784,
                edge = 13785,
                mythic = {
                    13726, --sivara
                    13728, --behemoth
                    13727, --radiance
                    13730, --orgozoa
                    13731, --queen's court
                    13732, --za'qul
                    13733, --azshara
                },
            },
        },
        {
            shortName = "COS",
            alternativeKeyword = "uunat",
            groupId = 252,
            achievements = {
                normal = 13414,
                curve = 13418,
                edge = 13419,
                mythic = {
                    13416, --cabal
                    13417, --uunat
                },
            },
        },
        {
            shortName = "BOD",
            alternativeKeyword = "jaina",
            groupId = 251,
            achievements = {
                normal = BODNm,
                curve = 13322,
                edge = 13323,
                mythic = {
                    13292, --champion ot light
                    13293, --grong
                    13295, --jadefire masters
                    13299, --opulence
                    BODConclave, --conclave ot chosen
                    13311, --rastakhan
                    13312, --mekkatorque
                    13313, --stormwall blockade
                    13321, --jaina
                },
            },
        },
        {
            shortName = "ULDIR",
            alternativeKeyword = "ghuun",
            groupId = 135,
            achievements = {
                normal = 12523,
                curve = 12536,
                edge = 12535,
                mythic = {
                    12524, --taloc
                    12526, --mother
                    12530, --fetid devourer
                    12527, --zek'voz
                    12529, --vectis
                    12531, --zul
                    12532, --mythrax
                    12533, --ghuun
                },
            },
        },
    }
    return infoTable
end
