---@class LazyCurveModule: AceModule
---@field EXPANSION number
---@field type string
---@field GetInfoTable fun():LazyCurveActivityTable[] # ordered list of activities, most recent first

---@class LazyCurveActivityTable
---@field shortName string
---@field alternativeKeyword string
---@field groupId number # Activity Group ID
---@field achievements LazyCurveAchievementTable
---@field hideRaids true|nil

---@class LazyCurveActivityTable_enriched: LazyCurveActivityTable
---@field longName string # Localized name of the activity if available
---@field module LazyCurveModule # Reference to the module that provided this activity table
---@field isLatest boolean # True if this activity refers to the latest raid

---@class LazyCurveAchievementTable
---@field normal number
---@field curve number
---@field edge number
---@field mythic table<number, number> # ordered list of mythic achievementIDs

---@class LazyCurveDB
---@field advertise boolean
---@field whisperOnApply boolean
---@field replaceKeywordsInChatMessages boolean
---@field disableAutolinkReminder boolean
---@field mythicThreshold number
---@field devMode boolean
---@field enableSimulation boolean
---@field simulatedAchievements table<number, true>

---@alias LazyCurveOption
---|"advertise" # boolean
---|"whisperOnApply" # boolean
---|"disableAutolinkReminder" # boolean
---|"mythicThreshold" # number
---|"devMode" # boolean
---|"enableSimulation" # boolean
---|"simulatedAchievements" # table<number, true>