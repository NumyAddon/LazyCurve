LazyCurveData = {}

LazyCurveData.defaultCurve = 14068 -- latest curve
LazyCurveData.defaultEdge = 14069 -- latest edge
LazyCurveData.arenaMaster = 1174
LazyCurveData.currentSeason = 4;

--/run LazyCurve.core.getAllCategoryInfo()
LazyCurveData.dungeonCatID = 2
LazyCurveData.raidCatID = 3
LazyCurveData.pvpCatID = {
    RankedArena = 4,
    Arena = 7,
    BG = 8,
    RankedBG = 9,
}

--/run LazyCurve.core.getAllActivityInfo(_, 0, 3)
LazyCurveData.raidActivityTable =  {
    [687] = "NYA",
    [686] = "NYA",
    [685] = "NYA", -- probably mythic

    [671] = "TEP",
    [672] = "TEP",
    [670] = "TEP",

    [668] = "COS",
    [667] = "COS",
    [666] = "COS",

    [663] = "BOD",
    [664] = "BOD",
    [665] = "BOD",

    [494] = "ULDIR",
    [495] = "ULDIR",
    [496] = "ULDIR",

    [483] = "ABT",
    [482] = "ABT",
    [493] = "ABT",
    
    [492] = "TOS",
    [478] = "TOS",
    [479] = "TOS",
    
    [481] = "NH",
    [416] = "NH",
    [415] = "NH",
    
    [457] = "TOV",
    [480] = "TOV",
    [456] = "TOV",
    
    [468] = "EN",
    [414] = "EN",
    [413] = "EN",
}

local masterTable = {}
LazyCurveData.masterTable = masterTable
local faction, _ = UnitFactionGroup('player');
--KEYSTONE chievos
masterTable.keyS0 = { -- legion/basic
    11183, --key 2
    11184, --key 5
    11185, --key 10
    11162, --key 15
}

masterTable.keyS1 = { -- bfa season 1
    13079, --key 10
    13080, --key 15
}

masterTable.keyS2 = { -- bfa season 2
    13448, --key 10
    13449, --key 15
}

masterTable.keyS3 = { --bfa season 3
    13780, --key 10
    13781, --key 15
}

masterTable.keyS4 = { --bfa season 4
    14144, --key 10
    14145, --key 15
}

masterTable.raids = {
    "NYA",
    "TEP",
    "COS",
    "BOD",
    "ULDIR",
    "ABT",
    "TOS",
    "NH",
    "TOV",
    "EN",
}

masterTable.finalBoss = {
    NYA = "nzoth",
    TEP = "azshara",
    COS = "uunat",
    BOD = "jaina",
    ULDIR = "ghuun",
    ABT = "argus",
    TOS = "kiljaeden",
    NH = "guldan",
    TOV = "helya",
    EN = "xavius",
}

masterTable.NYA = { --first 3 are nm, curve and edge; rest is mythic
    14196, --nm/lfr n'zoth
    14068, --curve
    14069, --edge
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
    14069, --edge
}

masterTable.TEP = { --first 3 are nm, curve and edge; rest is mythic
    13725, --nm/lfr queen azshara
    13784, --curve
    13785, --edge
    13726, --sivara
    13728, --behemoth
    13727, --radiance
    13730, --orgozoa
    13731, --queen's court
    13732, --za'qul
    13733, --azshara
    13785, --edge
}

masterTable.COS = { --first 3 are nm, curve and edge; rest is mythic
    13414, --nm/lfr uunat
    13418, --curve
    13419, --edge
    13416, --cabal
    13417, --uunat
    13419, --edge
}

if(faction == 'Horde') then
    masterTable.BOD = { --first 3 are nm, curve and edge; rest is mythic
        13291, --nm/lfr jaina
        13322, --curve
        13323, --edge
        13292, --champion ot light
        13293, --grong
        13295, --jadefire masters
        13299, --opulence
        13300, --conclave ot chosen
        13311, --rastakhan
        13312, --mekkatorque
        13313, --stormwall blockade
        13321, --jaina
        13323, --edge
    }
else
    masterTable.BOD = { --first 3 are nm, curve and edge; rest is mythic
        13288, --nm/lfr jaina kill
        13322, --curve
        13323, --edge
        13292, --champion ot light
        13293, --grong
        13295, --jadefire masters
        13299, --opulence
        13298, --conclave ot chosen
        13311, --rastakhan
        13312, --mekkatorque
        13313, --stormwall blockade
        13321, --jaina
        13323, --edge
    }
end

masterTable.ULDIR = { --first 3 are nm, curve and edge; rest is mythic
    12523, --nm/lfr ghuun kill
    12536, --curve
    12535, --edge
    12524, --taloc
    12526, --mother
    12530, --fetid devourer
    12527, --zek'voz
    12529, --vectis
    12531, --zul
    12532, --mythrax
    12533, --ghuun
    12535, --edge
}

masterTable.ABT = { --first 3 are nm, curve and edge; rest is mythic
    12266, --nm/lfr argus kill
    12110, --curve
    12111, --edge
    11992, --garothi worldbreaker
    11993, --hounds
    11994, --high command
    11995, --portal keeper
    11996, --eonar
    11997, --imonar
    11998, --kin'garoth
    11999, -- varimathras
    12000, --coven
    12001, --aggramar
    12002, --argus
    12111, --edge
}

masterTable.TOS = { --first 3 are nm, curve and edge; rest is mythic
    11790, --nm/lfr KJ kill
    11874, --curve
    11875, --edge
    11767, --goroth
    11774, --demonic inq
    11775, --harja
    11776, --mistress
    11777, --sisters
    11778, --host
    11779, --maiden
    11780, --avatar
    11781, --KJ
    11875, -- edge
}

masterTable.NH = { --first 3 are nm, curve and edge; rest is mythic
    10839, --nm/lfr guldan
    11195, -- curve
    11192, --edge
    10840, --skorpyron
    10842, --chronomatic anomaly
    10843, --trilliax
    10844, --spellblade aluriel
    10845, --star augur
    10846, --botanist
    10847, --tichondrius
    10848, --krosus
    10849, --elisande
    10850, --guldan
    11192, --edge
}

masterTable.TOV = { --first 3 are nm, curve and edge; rest is mythic
    11394, --nm/lfr helya
    11581, -- curve
    11580, --edge
    11396, --odin
    11397, --guarm
    11398, --helya
    11580, --edge
}

masterTable.EN = { --first 3 are nm, curve and edge; rest is mythic
    10820, --nm/lfr xavius
    11194, --curve
    11191, --edge
    10821, --nythendra
    10822, --elerethe renferal
    10823, --il'gynoth
    10824, --ursoc
    10825, --dragons
    10826, --cenarius
    10827, --xavius
    11191, --edge
}

--PVP chievos
masterTable["2V2"] = {--just the rating
    399, --1550 rating
    400, --1750 rating
    401, --2000 rating
    1159, --2200 rating
}

masterTable["3V3"] = {--just the rating
    402, --1550 rating
    403, --1750 rating
    405, --2000 rating
    1160, --2200 rating
    5266, --2400 rating
    5267, --2700 rating
}

masterTable.ArenaWins = {--just the wincount
    397, --1 win
    408, --10 in a row
    398, --100
    875, --200
    876, --300
}

masterTable.ArenaTitles = {--top x % of players
    2090, --challenger
    2093, --rival
    2092, --duelist
    2091, --gladiator
}

masterTable.AllianceRBGPercentage = {--top x % of players
    --[[9995, 10104, 10120, WOD--]]11024, 11036, 11049, 11050, 12040, 12179, 12189, --soldier of the alliance http://www.wowhead.com/title=449/soldier-of-the-alliance#reward-from-achievement
    --[[9996, 10106, 10118, WOD--]]11022, 11034, 11045, 11054, 12039, 12175, 12195, --defender of the alliance http://www.wowhead.com/title=448/defender-of-the-alliance#reward-from-achievement
    --[[9997, 10108, 10116, WOD--]]11020, 11032, 11047, 11052, 12038, 12177, 12191, --guardian of the alliance http://www.wowhead.com/title=447/guardian-of-the-alliance#reward-from-achievement
    6942, --hero of the alliance (any season)
}

masterTable.HordeRBGPercentage = {--top x % of players
    --[[9998, 10105, 10121, WOD--]]11025, 11035, 11048, 11051, 12044, 12178, 12190, --soldier of the horde http://www.wowhead.com/title=452/soldier-of-the-horde#reward-from-achievement
    --[[10001, 10107, 10119, WOD--]]11023, 11033, 11044, 11055, 12043, 12174, 12194, --defender of the horde http://www.wowhead.com/title=451/defender-of-the-horde#reward-from-achievement
    --[[10000, 10109, 10117, WOD--]]11021, 11031, 11046, 11053, 12042, 12176, 12192, --guardian of the horde http://www.wowhead.com/title=450/guardian-of-the-horde#reward-from-achievement
    6941, --hero of the alliance (any season)
}

masterTable.AllianceRBGRating = {--just the rating
    5330, --private
    5331,
    5332, --sergeant
    5333,
    5335, --knight
    5336,
    5337, --knight-captain
    5359,
    5339, --lieutenant commander
    5340,
    5341, --marshal
    5357,
    5343, --grand marshal
}

masterTable.HordeRBGRating = {--just the rating
    5345, --scout
    5346,
    5347, --sergeant
    5348,
    5349, --stone guard
    5351,
    5352, --legionnaire
    5338,
    5353, --champion
    5354,
    5355, --general
    5342,
    5356, --high warlord
}

masterTable.AllianceRBGWins = {--just the wincount
    5268, --1 win
    5322, --10
    5327, --25
    5328, --75
    5823, --150
    5329, --300
}

masterTable.HordeRBGWins = {--just the wincount
    5269, --1 win
    5323, --10
    5324, --25
    5325, --75
    5824, --150
    5326, --300
}
