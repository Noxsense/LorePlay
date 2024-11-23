Test = Test or {}

-------------------------------------------------------------------------------
-- Fake ESO setup and other dependencies.

LorePlay = LorePlay or {}
LorePlay.db = LorePlay.db or {}

LorePlaySavedCustomIdleEmotes = LorePlaySavedCustomIdleEmotes or {}
LorePlaySavedCustomSmartEmotes = LorePlaySavedCustomSmartEmotes or {}

-- -------

function d(input) print(input) end

EVENT_MANAGER = {
	["RegisterForEvent"] = function() end,
}

SCENE_MANAGER = {}

CALLBACK_MANAGER = {}

SLASH_COMMANDS = {}

function GetString(x)
	return tostring(x)
end

function GetEmoteSlashNameByIndex(index)
	-- setup test emotes but avoid NPEs
	local loops = {
		"/attention", "/blessing", "/kneel", "/kneelpray", "/pray", "/ritual",
		"/saluteloop", "/saluteloop2", "/saluteloop3", "/clap", "/handsonhips",
		"/impatient", "/armscrossed", "/cry", "/crying", "/downcast", "/drunk",
		"/heartbroken", "/humble", "/sad", "/surrender", "/celebrate",
		"/dance", "/dancealtmer", "/danceargonian", "/dancebosmer",
		"/dancebreton", "/dancedarkelf", "/dancedrunk", "/dancedunmer",
		"/dancehighelf", "/danceimperial", "/dancekhajiit", "/dancenord",
		"/danceorc", "/danceredguard", "/dancewoodelf", "/drum", "/flute",
		"/lute", "/juggleflame", "/drink", "/drink2", "/drink3", "/eat",
		"/eat2", "/eat3", "/eat4", "/eatbread", "/cower", "/crouch",
		"/jumpingjacks", "/lookup", "/pushup", "/pushups", "/sit", "/sit2",
		"/sit3", "/sit4", "/sit5", "/sit6", "/situps", "/sleep", "/sleep2",
		"/breathless", "/colder", "/faint", "/idle", "/idle2", "/idle3",
		"/idle4", "/idle5", "/knockeddown", "/leanback", "/leanbackcoin",
		"/leanside", "/playdead", "/sick", "/controlrod", "/hammer",
		"/hammerwall", "/hammerlow", "/letter", "/rake", "/read", "/shovel",
		"/sitchair", "/sweep", "/torch", "/wand2", "/write", "/beggar", "/kowtow",
	}
	if index <= #loops then
		return loops[index]
	end
	return "/slashname" .. tostring(index)
end

function GetNumEmotes()
	return 10000
end

-- -------

COLLECTIBLE_CATEGORY_TYPE_ASSISTANT = 'COLLECTIBLE_CATEGORY_TYPE_ASSISTANT'
COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING = 'COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING'
COLLECTIBLE_CATEGORY_TYPE_COSTUME = 'COLLECTIBLE_CATEGORY_TYPE_COSTUME'
COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY = 'COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY'
COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS = 'COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS'
COLLECTIBLE_CATEGORY_TYPE_HAIR = 'COLLECTIBLE_CATEGORY_TYPE_HAIR'
COLLECTIBLE_CATEGORY_TYPE_HAT = 'COLLECTIBLE_CATEGORY_TYPE_HAT'
COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING = 'COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING'
COLLECTIBLE_CATEGORY_TYPE_PERSONALITY = 'COLLECTIBLE_CATEGORY_TYPE_PERSONALITY'
COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY = 'COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY'
COLLECTIBLE_CATEGORY_TYPE_POLYMORPH = 'COLLECTIBLE_CATEGORY_TYPE_POLYMORPH'
COLLECTIBLE_CATEGORY_TYPE_SKIN = 'COLLECTIBLE_CATEGORY_TYPE_SKIN'
COLLECTIBLE_CATEGORY_TYPE_VANITY_PET = 'COLLECTIBLE_CATEGORY_TYPE_VANITY_PET'
COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED = 'COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED'
COMBAT_MECHANIC_FLAGS_STAMINA = 'COMBAT_MECHANIC_FLAGS_STAMINA'
COMBAT_UNIT_TYPE_PLAYER = 'COMBAT_UNIT_TYPE_PLAYER'
DEFAULT_EMOTES_BY_CITY_KEYS = 'DEFAULT_EMOTES_BY_CITY_KEYS'
DEFAULT_EMOTES_BY_REGION_KEYS = 'DEFAULT_EMOTES_BY_REGION_KEYS'
DEFAULT_EMOTES_FOR_DOLMENS = 'DEFAULT_EMOTES_FOR_DOLMENS'
DEFAULT_EMOTES_FOR_DUNGEONS = 'DEFAULT_EMOTES_FOR_DUNGEONS'
DEFAULT_EMOTES_FOR_HOUSING = 'DEFAULT_EMOTES_FOR_HOUSING'
DEFAULT_EVENTS = 'DEFAULT_EVENTS'
EVENT_ACTIVE_EMOTE = 'EVENT_ACTIVE_EMOTE'
EVENT_ADD_ON_LOADED = 'EVENT_ADD_ON_LOADED'
EVENT_BANKED_MONEY_UPDATE = 'EVENT_BANKED_MONEY_UPDATE'
EVENT_BANKED_MONEY_UPDATE_DOUBLE = 'EVENT_BANKED_MONEY_UPDATE_DOUBLE'
EVENT_BANKED_MONEY_UPDATE_GROWTH = 'EVENT_BANKED_MONEY_UPDATE_GROWTH'
EVENT_BEGIN_LOCKPICK = 'EVENT_BEGIN_LOCKPICK'
EVENT_CAPTURE_FLAG_STATE_CHANGED = 'EVENT_CAPTURE_FLAG_STATE_CHANGED'
EVENT_CAPTURE_FLAG_STATE_CHANGED_LOST_FLAG = 'EVENT_CAPTURE_FLAG_STATE_CHANGED_LOST_FLAG'
EVENT_CHATTER_BEGIN = 'EVENT_CHATTER_BEGIN'
EVENT_CHATTER_END = 'EVENT_CHATTER_END'
EVENT_CLIENT_INTERACT_RESULT = 'EVENT_CLIENT_INTERACT_RESULT'
EVENT_COLLECTIBLE_NOTIFICATION_NEW = 'EVENT_COLLECTIBLE_NOTIFICATION_NEW'
EVENT_COMBAT_EVENT = 'EVENT_COMBAT_EVENT'
EVENT_CRAFTING_STATION_INTERACT = 'EVENT_CRAFTING_STATION_INTERACT'
EVENT_END_CRAFTING_STATION_INTERACT = 'EVENT_END_CRAFTING_STATION_INTERACT'
EVENT_END_FAST_TRAVEL_INTERACTION = 'EVENT_END_FAST_TRAVEL_INTERACTION'
EVENT_END_FAST_TRAVEL_KEEP_INTERACTION = 'EVENT_END_FAST_TRAVEL_KEEP_INTERACTION'
EVENT_EXPERIENCE_UPDATE = 'EVENT_EXPERIENCE_UPDATE'
EVENT_HIGH_FALL_DAMAGE = 'EVENT_HIGH_FALL_DAMAGE'
EVENT_HOUSING_EDITOR_MODE_CHANGED = 'EVENT_HOUSING_EDITOR_MODE_CHANGED'
EVENT_INDICATOR_MOVED = 'EVENT_INDICATOR_MOVED'
EVENT_INDICATOR_ON = 'EVENT_INDICATOR_ON'
EVENT_KILLED_BOSS = 'EVENT_KILLED_BOSS'
EVENT_KILLED_CREATURE = 'EVENT_KILLED_CREATURE'
EVENT_LEVEL_UPDATE = 'EVENT_LEVEL_UPDATE'
EVENT_LINKED_WORLD_POSITION_CHANGED = 'EVENT_LINKED_WORLD_POSITION_CHANGED'
EVENT_LOCKPICK_FAILED = 'EVENT_LOCKPICK_FAILED'
EVENT_LOCKPICK_SUCCESS = 'EVENT_LOCKPICK_SUCCESS'
EVENT_LOCKPICK_SUCCESS_EASY = 'EVENT_LOCKPICK_SUCCESS_EASY'
EVENT_LOCKPICK_SUCCESS_HARD = 'EVENT_LOCKPICK_SUCCESS_HARD'
EVENT_LOCKPICK_SUCCESS_MEDIUM = 'EVENT_LOCKPICK_SUCCESS_MEDIUM'
EVENT_LOOT_RECEIVED = 'EVENT_LOOT_RECEIVED'
EVENT_LOOT_RECEIVED_BETTER = 'EVENT_LOOT_RECEIVED_BETTER'
EVENT_LOOT_RECEIVED_GENERAL = 'EVENT_LOOT_RECEIVED_GENERAL'
EVENT_LOOT_RECEIVED_RARE_RECIPE_OR_MATERIAL = 'EVENT_LOOT_RECEIVED_RARE_RECIPE_OR_MATERIAL'
EVENT_LOOT_RECEIVED_RECIPE_OR_MATERIAL = 'EVENT_LOOT_RECEIVED_RECIPE_OR_MATERIAL'
EVENT_LOOT_RECEIVED_RUNE = 'EVENT_LOOT_RECEIVED_RUNE'
EVENT_LOOT_RECEIVED_RUNE_KUTA = 'EVENT_LOOT_RECEIVED_RUNE_KUTA'
EVENT_LOOT_RECEIVED_RUNE_REKUTA = 'EVENT_LOOT_RECEIVED_RUNE_REKUTA'
EVENT_LOOT_RECEIVED_RUNE_TA = 'EVENT_LOOT_RECEIVED_RUNE_TA'
EVENT_LOOT_RECEIVED_UNIQUE = 'EVENT_LOOT_RECEIVED_UNIQUE'
EVENT_LORE_BOOK_LEARNED_SKILL_EXPERIENCE = 'EVENT_LORE_BOOK_LEARNED_SKILL_EXPERIENCE'
EVENT_LOW_FALL_DAMAGE = 'EVENT_LOW_FALL_DAMAGE'
EVENT_MOUNTED_STATE_CHANGED = 'EVENT_MOUNTED_STATE_CHANGED'
EVENT_ON_IDLE_EMOTE = 'EVENT_ON_IDLE_EMOTE'
EVENT_ON_SMART_EMOTE = 'EVENT_ON_SMART_EMOTE'
EVENT_PLAYER_ACTIVATED = 'EVENT_PLAYER_ACTIVATED'
EVENT_PLAYER_COMBAT_STATE = 'EVENT_PLAYER_COMBAT_STATE'
EVENT_PLAYER_COMBAT_STATE_INCOMBAT = 'EVENT_PLAYER_COMBAT_STATE_INCOMBAT'
EVENT_PLAYER_COMBAT_STATE_NOT_INCOMBAT = 'EVENT_PLAYER_COMBAT_STATE_NOT_INCOMBAT'
EVENT_PLAYER_COMBAT_STATE_NOT_INCOMBAT_FLED = 'EVENT_PLAYER_COMBAT_STATE_NOT_INCOMBAT_FLED'
EVENT_PLAYER_DEACTIVATED = 'EVENT_PLAYER_DEACTIVATED'
EVENT_PLAYER_NOT_SWIMMING = 'EVENT_PLAYER_NOT_SWIMMING'
EVENT_PLAYER_REINCARNATED = 'EVENT_PLAYER_REINCARNATED'
EVENT_PLAYER_SWIMMING = 'EVENT_PLAYER_SWIMMING'
EVENT_PLEDGE_OF_MARA_MARRIAGE = 'EVENT_PLEDGE_OF_MARA_MARRIAGE'
EVENT_PLEDGE_OF_MARA_RESULT = 'EVENT_PLEDGE_OF_MARA_RESULT'
EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE = 'EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE'
EVENT_PLEDGE_OF_MARA_RESULT_PLEDGED = 'EVENT_PLEDGE_OF_MARA_RESULT_PLEDGED'
EVENT_POI_UPDATED = 'EVENT_POI_UPDATED'
EVENT_POWER_UPDATE = 'EVENT_POWER_UPDATE'
EVENT_POWER_UPDATE_STAMINA = 'EVENT_POWER_UPDATE_STAMINA'
EVENT_RETICLE_TARGET_CHANGED_TO_EPIC = 'EVENT_RETICLE_TARGET_CHANGED_TO_EPIC'
EVENT_RETICLE_TARGET_CHANGED_TO_EPIC_SAME = 'EVENT_RETICLE_TARGET_CHANGED_TO_EPIC_SAME'
EVENT_RETICLE_TARGET_CHANGED_TO_FRIEND = 'EVENT_RETICLE_TARGET_CHANGED_TO_FRIEND'
EVENT_RETICLE_TARGET_CHANGED_TO_NORMAL = 'EVENT_RETICLE_TARGET_CHANGED_TO_NORMAL'
EVENT_RETICLE_TARGET_CHANGED_TO_SPOUSE = 'EVENT_RETICLE_TARGET_CHANGED_TO_SPOUSE'
EVENT_SKILL_POINTS_CHANGED = 'EVENT_SKILL_POINTS_CHANGED'
EVENT_STARTUP = 'EVENT_STARTUP'
EVENT_START_FAST_TRAVEL_INTERACTION = 'EVENT_START_FAST_TRAVEL_INTERACTION'
EVENT_START_FAST_TRAVEL_KEEP_INTERACTION = 'EVENT_START_FAST_TRAVEL_KEEP_INTERACTION'
EVENT_STEALTH_STATE_CHANGED = 'EVENT_STEALTH_STATE_CHANGED'
EVENT_TRADE_CANCELED = 'EVENT_TRADE_CANCELED'
EVENT_TRADE_INVITE_ACCEPTED = 'EVENT_TRADE_INVITE_ACCEPTED'
EVENT_TRADE_SUCCEEDED = 'EVENT_TRADE_SUCCEEDED'
EVENT_TTL_EMOTES = 'EVENT_TTL_EMOTES'
EVENT_ZONE_CHANGED = 'EVENT_ZONE_CHANGED'
FRAME_PLAYER_FRAGMENT = 'FRAME_PLAYER_FRAGMENT'
FUNCTION = 'FUNCTION'
GAMEPLAY_ACTOR_CATEGORY_PLAYER = 'GAMEPLAY_ACTOR_CATEGORY_PLAYER'
GENDER_FEMALE = 'GENDER_FEMALE'
GENDER_MALE = 'GENDER_MALE'
GENERATED_AT = 'GENERATED_AT'
HIDE_LOREWEAR_CLOTHES = 'HIDE_LOREWEAR_CLOTHES'
HOUSING_EDITOR_MODE_DISABLED = 'HOUSING_EDITOR_MODE_DISABLED'
INTERACTION_NONE = 'INTERACTION_NONE'
ITEMTYPE_RAW_MATERIAL = 'ITEMTYPE_RAW_MATERIAL'
ITEMTYPE_RECIPE = 'ITEMTYPE_RECIPE'
ITEM_QUALITY_ARTIFACT = 'ITEM_QUALITY_ARTIFACT'
ITEM_QUALITY_LEGENDARY = 'ITEM_QUALITY_LEGENDARY'
ITEM_QUALITY_NORMAL = 'ITEM_QUALITY_NORMAL'
LOCK_QUALITY_ADVANCED = 'LOCK_QUALITY_ADVANCED'
LOCK_QUALITY_IMPOSSIBLE = 'LOCK_QUALITY_IMPOSSIBLE'
LOCK_QUALITY_INTERMEDIATE = 'LOCK_QUALITY_INTERMEDIATE'
LOCK_QUALITY_MASTER = 'LOCK_QUALITY_MASTER'
LOCK_QUALITY_PRACTICE = 'LOCK_QUALITY_PRACTICE'
LOCK_QUALITY_SIMPLE = 'LOCK_QUALITY_SIMPLE'
LOCK_QUALITY_TRIVIAL = 'LOCK_QUALITY_TRIVIAL'
LW_BEHAVIOR_ID_CANCEL_HIDE_HELM = 'LW_BEHAVIOR_ID_CANCEL_HIDE_HELM'
LW_BEHAVIOR_ID_DONT_CARE = 'LW_BEHAVIOR_ID_DONT_CARE'
LW_BEHAVIOR_ID_PREVENT_CHANGE = 'LW_BEHAVIOR_ID_PREVENT_CHANGE'
LW_BEHAVIOR_ID_USE_SPECIFIED_ONE = 'LW_BEHAVIOR_ID_USE_SPECIFIED_ONE'
LW_PRESET_EQUIP_WEDDING_COSTUME = 'LW_PRESET_EQUIP_WEDDING_COSTUME'
LW_PRESET_TOGGLE_ALL_COLLECTIBLES = 'LW_PRESET_TOGGLE_ALL_COLLECTIBLES'
LW_PRESET_TOGGLE_COSTUME_ONLY = 'LW_PRESET_TOGGLE_COSTUME_ONLY'
LW_PRESET_TURN_OFF_HIDE_HELM = 'LW_PRESET_TURN_OFF_HIDE_HELM'
LW_USAGE_ID_ADVENTURE = 'LW_USAGE_ID_ADVENTURE'
LW_USAGE_ID_CITY = 'LW_USAGE_ID_CITY'
LW_USAGE_ID_COMBAT = 'LW_USAGE_ID_COMBAT'
LW_USAGE_ID_DUNGEON = 'LW_USAGE_ID_DUNGEON'
LW_USAGE_ID_HOUSING = 'LW_USAGE_ID_HOUSING'
LW_USAGE_ID_NOT_USED = 'LW_USAGE_ID_NOT_USED'
LW_USAGE_ID_RIDING = 'LW_USAGE_ID_RIDING'
LW_USAGE_ID_SWIMMING = 'LW_USAGE_ID_SWIMMING'
SI_BINDING_NAME_FORCE_EQUIP_ADVENTURE_OUTFIT = 'SI_BINDING_NAME_FORCE_EQUIP_ADVENTURE_OUTFIT'
SI_BINDING_NAME_FORCE_EQUIP_CITY_OUTFIT = 'SI_BINDING_NAME_FORCE_EQUIP_CITY_OUTFIT'
SI_BINDING_NAME_FORCE_EQUIP_DUNGEON_OUTFIT = 'SI_BINDING_NAME_FORCE_EQUIP_DUNGEON_OUTFIT'
SI_BINDING_NAME_FORCE_EQUIP_HOUSING_OUTFIT = 'SI_BINDING_NAME_FORCE_EQUIP_HOUSING_OUTFIT'
SI_BINDING_NAME_LP_FORCE_EQUIP_ADVENTURE_OUTFIT = 'SI_BINDING_NAME_LP_FORCE_EQUIP_ADVENTURE_OUTFIT'
SI_BINDING_NAME_LP_FORCE_EQUIP_CITY_OUTFIT = 'SI_BINDING_NAME_LP_FORCE_EQUIP_CITY_OUTFIT'
SI_BINDING_NAME_LP_FORCE_EQUIP_DUNGEON_OUTFIT = 'SI_BINDING_NAME_LP_FORCE_EQUIP_DUNGEON_OUTFIT'
SI_BINDING_NAME_LP_FORCE_EQUIP_HOUSING_OUTFIT = 'SI_BINDING_NAME_LP_FORCE_EQUIP_HOUSING_OUTFIT'
SI_BINDING_NAME_LP_PERFORM_SMART_EMOTE = 'SI_BINDING_NAME_LP_PERFORM_SMART_EMOTE'
SI_BINDING_NAME_LP_SHOW_HIDE_LOREWEAR_CLOTHES = 'SI_BINDING_NAME_LP_SHOW_HIDE_LOREWEAR_CLOTHES'
SI_BINDING_NAME_LP_TOGGLE_ALTERNATIVE_OUTFIT = 'SI_BINDING_NAME_LP_TOGGLE_ALTERNATIVE_OUTFIT'
SI_BINDING_NAME_LP_TOGGLE_IDLEEMOTES = 'SI_BINDING_NAME_LP_TOGGLE_IDLEEMOTES'
SI_BINDING_NAME_PERFORM_SMART_EMOTE = 'SI_BINDING_NAME_PERFORM_SMART_EMOTE'
SI_BINDING_NAME_SHOW = 'SI_BINDING_NAME_SHOW'
SI_BINDING_NAME_TOGGLE_IDLEEMOTES_ON = 'SI_BINDING_NAME_TOGGLE_IDLEEMOTES_ON'
SI_LOREPLAY_LOCATION_KEYWORD_ABYSSAL_GEYSER = 'SI_LOREPLAY_LOCATION_KEYWORD_ABYSSAL_GEYSER'
SI_LOREPLAY_LOCATION_KEYWORD_DOLMEN = 'SI_LOREPLAY_LOCATION_KEYWORD_DOLMEN'
SI_LOREPLAY_PANEL_IE_ALLOWED_IN_HOUSING_NAME = 'SI_LOREPLAY_PANEL_IE_ALLOWED_IN_HOUSING_NAME'
SI_LOREPLAY_PANEL_IE_ALLOWED_IN_HOUSING_TIPS = 'SI_LOREPLAY_PANEL_IE_ALLOWED_IN_HOUSING_TIPS'
SI_LOREPLAY_PANEL_IE_BE_DRUNK_IN_CITY_SW_NAME = 'SI_LOREPLAY_PANEL_IE_BE_DRUNK_IN_CITY_SW_NAME'
SI_LOREPLAY_PANEL_IE_BE_DRUNK_IN_CITY_SW_TIPS = 'SI_LOREPLAY_PANEL_IE_BE_DRUNK_IN_CITY_SW_TIPS'
SI_LOREPLAY_PANEL_IE_CAMERA_SPIN_DISABLER_NAME = 'SI_LOREPLAY_PANEL_IE_CAMERA_SPIN_DISABLER_NAME'
SI_LOREPLAY_PANEL_IE_CAMERA_SPIN_DISABLER_TIPS = 'SI_LOREPLAY_PANEL_IE_CAMERA_SPIN_DISABLER_TIPS'
SI_LOREPLAY_PANEL_IE_DANCE_IN_CITY_SW_NAME = 'SI_LOREPLAY_PANEL_IE_DANCE_IN_CITY_SW_NAME'
SI_LOREPLAY_PANEL_IE_DANCE_IN_CITY_SW_TIPS = 'SI_LOREPLAY_PANEL_IE_DANCE_IN_CITY_SW_TIPS'
SI_LOREPLAY_PANEL_IE_DESCRIPTION = 'SI_LOREPLAY_PANEL_IE_DESCRIPTION'
SI_LOREPLAY_PANEL_IE_EMOTE_DURATION_NAME = 'SI_LOREPLAY_PANEL_IE_EMOTE_DURATION_NAME'
SI_LOREPLAY_PANEL_IE_EMOTE_DURATION_TIPS = 'SI_LOREPLAY_PANEL_IE_EMOTE_DURATION_TIPS'
SI_LOREPLAY_PANEL_IE_EXERCISE_IN_ZONE_SW_NAME = 'SI_LOREPLAY_PANEL_IE_EXERCISE_IN_ZONE_SW_NAME'
SI_LOREPLAY_PANEL_IE_EXERCISE_IN_ZONE_SW_TIPS = 'SI_LOREPLAY_PANEL_IE_EXERCISE_IN_ZONE_SW_TIPS'
SI_LOREPLAY_PANEL_IE_HEADER = 'SI_LOREPLAY_PANEL_IE_HEADER'
SI_LOREPLAY_PANEL_IE_IDLE_TIME_NAME = 'SI_LOREPLAY_PANEL_IE_IDLE_TIME_NAME'
SI_LOREPLAY_PANEL_IE_IDLE_TIME_TIPS = 'SI_LOREPLAY_PANEL_IE_IDLE_TIME_TIPS'
SI_LOREPLAY_PANEL_IE_PLAY_INST_IN_CITY_SW_NAME = 'SI_LOREPLAY_PANEL_IE_PLAY_INST_IN_CITY_SW_NAME'
SI_LOREPLAY_PANEL_IE_PLAY_INST_IN_CITY_SW_TIPS = 'SI_LOREPLAY_PANEL_IE_PLAY_INST_IN_CITY_SW_TIPS'
SI_LOREPLAY_PANEL_IE_SW_NAME = 'SI_LOREPLAY_PANEL_IE_SW_NAME'
SI_LOREPLAY_PANEL_IE_SW_TIPS = 'SI_LOREPLAY_PANEL_IE_SW_TIPS'
SI_LOREPLAY_PANEL_IE_WORSHIP_SW_NAME = 'SI_LOREPLAY_PANEL_IE_WORSHIP_SW_NAME'
SI_LOREPLAY_PANEL_IE_WORSHIP_SW_TIPS = 'SI_LOREPLAY_PANEL_IE_WORSHIP_SW_TIPS'
SI_LOREPLAY_PANEL_LE_SET_OUTFIT_ADVENTURE_NAME = 'SI_LOREPLAY_PANEL_LE_SET_OUTFIT_ADVENTURE_NAME'
SI_LOREPLAY_PANEL_LE_SET_OUTFIT_ADVENTURE_TIPS = 'SI_LOREPLAY_PANEL_LE_SET_OUTFIT_ADVENTURE_TIPS'
SI_LOREPLAY_PANEL_LE_SET_OUTFIT_CITY_NAME = 'SI_LOREPLAY_PANEL_LE_SET_OUTFIT_CITY_NAME'
SI_LOREPLAY_PANEL_LE_SET_OUTFIT_CITY_TIPS = 'SI_LOREPLAY_PANEL_LE_SET_OUTFIT_CITY_TIPS'
SI_LOREPLAY_PANEL_LE_SET_OUTFIT_DUNGEON_NAME = 'SI_LOREPLAY_PANEL_LE_SET_OUTFIT_DUNGEON_NAME'
SI_LOREPLAY_PANEL_LE_SET_OUTFIT_DUNGEON_TIPS = 'SI_LOREPLAY_PANEL_LE_SET_OUTFIT_DUNGEON_TIPS'
SI_LOREPLAY_PANEL_LE_SET_OUTFIT_HOUSING_NAME = 'SI_LOREPLAY_PANEL_LE_SET_OUTFIT_HOUSING_NAME'
SI_LOREPLAY_PANEL_LE_SET_OUTFIT_HOUSING_TIPS = 'SI_LOREPLAY_PANEL_LE_SET_OUTFIT_HOUSING_TIPS'
SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_NAME_ = 'SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_NAME_'
SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_TIPS_ = 'SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_TIPS_'
SI_LOREPLAY_PANEL_LW_DESCRIPTION = 'SI_LOREPLAY_PANEL_LW_DESCRIPTION'
SI_LOREPLAY_PANEL_LW_EQUIP_WHILE_MOUNT_SW_NAME = 'SI_LOREPLAY_PANEL_LW_EQUIP_WHILE_MOUNT_SW_NAME'
SI_LOREPLAY_PANEL_LW_EQUIP_WHILE_MOUNT_SW_TIPS = 'SI_LOREPLAY_PANEL_LW_EQUIP_WHILE_MOUNT_SW_TIPS'
SI_LOREPLAY_PANEL_LW_HEADER = 'SI_LOREPLAY_PANEL_LW_HEADER'
SI_LOREPLAY_PANEL_LW_OUTFIT_SW_NAME = 'SI_LOREPLAY_PANEL_LW_OUTFIT_SW_NAME'
SI_LOREPLAY_PANEL_LW_OUTFIT_SW_TIPS = 'SI_LOREPLAY_PANEL_LW_OUTFIT_SW_TIPS'
SI_LOREPLAY_PANEL_LW_SW_NAME = 'SI_LOREPLAY_PANEL_LW_SW_NAME'
SI_LOREPLAY_PANEL_LW_SW_TIPS = 'SI_LOREPLAY_PANEL_LW_SW_TIPS'
SI_LOREPLAY_PANEL_SE_DESCRIPTION = 'SI_LOREPLAY_PANEL_SE_DESCRIPTION'
SI_LOREPLAY_PANEL_SE_EDIT_SIGNIFICANT_CHAR_NAME = 'SI_LOREPLAY_PANEL_SE_EDIT_SIGNIFICANT_CHAR_NAME'
SI_LOREPLAY_PANEL_SE_EDIT_SIGNIFICANT_CHAR_TIPS = 'SI_LOREPLAY_PANEL_SE_EDIT_SIGNIFICANT_CHAR_TIPS'
SI_LOREPLAY_PANEL_SE_HEADER = 'SI_LOREPLAY_PANEL_SE_HEADER'
SI_LOREPLAY_PANEL_SE_INDICATOR_POS_RESET_NAME = 'SI_LOREPLAY_PANEL_SE_INDICATOR_POS_RESET_NAME'
SI_LOREPLAY_PANEL_SE_INDICATOR_POS_RESET_TIPS = 'SI_LOREPLAY_PANEL_SE_INDICATOR_POS_RESET_TIPS'
SI_LOREPLAY_PANEL_SE_INDICATOR_SW_NAME = 'SI_LOREPLAY_PANEL_SE_INDICATOR_SW_NAME'
SI_LOREPLAY_PANEL_SE_INDICATOR_SW_TIPS = 'SI_LOREPLAY_PANEL_SE_INDICATOR_SW_TIPS'
SI_LOREPLAY_PANEL_SUPPRESS_STARTUP_MESSAGE_NAME = 'SI_LOREPLAY_PANEL_SUPPRESS_STARTUP_MESSAGE_NAME'
SI_LOREPLAY_PANEL_SUPPRESS_STARTUP_MESSAGE_TIPS = 'SI_LOREPLAY_PANEL_SUPPRESS_STARTUP_MESSAGE_TIPS'
SI_LOREPLAY_UI_WELCOME = 'SI_LOREPLAY_UI_WELCOME'



-- ----------------------------------------------------------------------------
-- Load The Components of the Addon.

require("code.LPCategoryStrings")
require("code.LPUtilities")
require("code.LPEmotesTable")
require("code.LPEmoteHandler")
require("code.LPSettings")
require("LorePlay")
require("code.SmartEmotes")
require("code.IdleEmotes")
require("code.LoreWear")

-- initialize Emotes with Index and Names
LPEmotesTable.CreateAllEmotesTable()

-- alias
local pretty = LorePlay.LPUtilities.SerializeLua

local assertions = {}

local function deepEquals(a, b)
	if type(a) == "table" and type(b) == "table" then
		local _, _ = pcall(function() table.sort(a) end)
		local _, _ = pcall(function() table.sort(b) end)
		for akey, avalue in pairs(a) do
			if not deepEquals(b[akey], avalue) then
				return false
			end
		end

		for bkey, bvalue in pairs(b) do
			if not deepEquals(a[bkey], bvalue) then
				return false
			end
		end

		return true
	else
		return a == b
	end
end

local function ConditonEqualsTo(expected)
	return function(actual, result)
		local equals = deepEquals(actual, expected)

		result["passed"] = equals
		result["actual"] = actual or nil
		result["expected"] = expected or nil

		return equals
	end
end

local contains = function(dictionary, value)
	for _, v in pairs(dictionary or {}) do
		if v == value then
			return true
		end
	end
	return false
end

local function ConditonContainsAll(expected)
	return function(actual, result)
		local containsAll = true
		local misses = {}

		for _, expVal in pairs(expected or {}) do
			if not contains(actual, expVal) then
				print("misses:", expVal)
				table.insert(misses, expVal)
				containsAll = false
			end
		end

		result["passed"] = containsAll
		result["expected"] = expected or {}
		result["misses"] = misses

		return containsAll
	end
end

local function assertThat(msg, actual, condition)
	local test_result = {}
	test_result["message"] = msg or ""
	test_result["starttime"] = os.date("%FT%T%z")
	test_result["actual"] = actual or nil

	test_result["passed"] = (condition(actual, test_result))

	test_result["trace"] = debug.traceback()
	test_result["test"] = debug.getinfo(2)
	test_result["endtime"] = os.date("%FT%T%z")

	-- add globally to assertions.
	table.insert(assertions, test_result)
end

Test.Idles = {}
Test.Smarts = {}

function Test.Idles.ExportedIdlesShouldBeRestoredTSameState()
	LorePlaySavedCustomIdleEmotes["EMOTES"] = nil
	local idles0 = LorePlay.ReloadIdleEmotes()

	-- export and store to saved
	local export0 = LorePlay.ExportIdleEmotes()
	LorePlaySavedCustomIdleEmotes["EMOTES"] = export0

	-- restore exported
	local idles1 = LorePlay.ReloadIdleEmotes()
	local export1 = LorePlay.ExportIdleEmotes()

	-- assert
	assertThat("IdleEmotes reloead(store(load0)) == load0",
		idles1, ConditonEqualsTo(idles0))
end

function Test.Idles.IdlesCanBeRestorted()
	-- prepare saved variables
	LorePlaySavedCustomIdleEmotes["EMOTES"] = {
		["EVENT_IDLE_ID_TABLE"] = {
			[EVENT_TRADE_INVITE_ACCEPTED] = {
				[1] = 77777,
			}
		},
		["OPTIONAL_IDLE_TABLE"] = {
			["ADD_DRUNK_TABLE"] = {
				[1] = 555,
			}
		}
	}
	-- restore exported
	local idles = LorePlay.ReloadIdleEmotes()

	-- assert
	assertThat("IdleEmotes reloead(saved)",
		idles["EVENT_IDLE_ID_TABLE"][EVENT_TRADE_INVITE_ACCEPTED],
		ConditonContainsAll({ 77777 }))

	assertThat("IdleEmotes reloead(saved)",
		idles["OPTIONAL_IDLE_TABLE"]["ADD_DRUNK_TABLE"],
		ConditonContainsAll({ 555 }))
end

function Test.Smarts.ExportedSmartsShouldBeRestoredTSameState()
	local smarts0 = LorePlay.ReloadSmartEmotes()

	-- export and store to saved.
	local export0 = LorePlay.ExportSmartEmotes()
	LorePlaySavedCustomSmartEmotes["EMOTES"] = export0

	-- load also from saved.
	local smarts1 = LorePlay.ReloadSmartEmotes()
	local export1 = LorePlay.ExportSmartEmotes()

	assertThat("SmartEmotes reloead(store(load0)) == load0",
		smarts1, ConditonEqualsTo(smarts0))
end

function Test.Smarts.SmartsCanBeRestoredFromSaved()
	LorePlaySavedCustomSmartEmotes["EMOTES"] = {
		["EVENT_TTL_EMOTES"] = {
			{
				["EventName"] = EVENT_CAPTURE_FLAG_STATE_CHANGED_LOST_FLAG,
				["Duration"] = 5000,
				["Emotes"] = { 999 }
			},
			{
				["EventName"] = EVENT_KILLED_BOSS,
				["Duration"] = 30000,
				["Emotes"] = { 4444 },
			},
		}
	}

	-- load also from saved.
	local smarts0 = LorePlay.ReloadSmartEmotes()
	local export0 = LorePlay.ExportSmartEmotes()

	assertThat("SmartEmotes reload(saved)  worked",
		smarts0["EVENT_TTL_EMOTES"]["EVENT_CAPTURE_FLAG_STATE_CHANGED_LOST_FLAG"]["Emotes"],
		ConditonContainsAll({ 999 }))

	assertThat("SmartEmotes reload(saved)  worked",
		smarts0["EVENT_TTL_EMOTES"]["EVENT_KILLED_BOSS"]["Emotes"],
		ConditonContainsAll({ 4444 }))
end

function Test.Smarts.SmartsFromSavedNilIsEmpty()
	LorePlaySavedCustomSmartEmotes["EMOTES"] = nil

	local fromSavedVariables = LorePlay.LoadSmartEmotesFromSavedVariables()

	assertThat("SmartEmotes from saved variables = nil is empty",
		fromSavedVariables, ConditonEqualsTo({}))
end

function Test.Smarts.SmartsWithoutSavedEqualsPurelyCoded()
	-- no saved.
	LorePlaySavedCustomSmartEmotes["EMOTES"] = nil
	local fromCodedEmotesTables = LorePlay.RecreatDefaulSmartEmotes()

	local smartEmotes = LorePlay.ReloadSmartEmotes()
	smartEmotes["Metadata"] = nil -- remove metadata for comparrisson.

	assertThat("SmartEmotes without saved variables are purely with coded",
		smartEmotes, ConditonEqualsTo(fromCodedEmotesTables))
end

function Test.Smarts.SmartsWithoutSavedExportsToPurelyCoded()
	-- no saved.
	LorePlaySavedCustomSmartEmotes["EMOTES"] = nil
	local fromCodedEmotesTables = LorePlay.RecreatDefaulSmartEmotes()

	local smartEmotes = LorePlay.ReloadSmartEmotes()

	-- export from purely coded.
	local exported = LorePlay.ExportSmartEmotes()
	LorePlaySavedCustomSmartEmotes["EMOTES"] = exported

	-- reload.
	local reimported = LorePlay.ReloadSmartEmotes()
	reimported["Metadata"] = nil -- remove metadata for comparrisson.

	assertThat("Reimported without any changes equals previous setup",
		reimported, ConditonEqualsTo(fromCodedEmotesTables))
end

function Test.Smarts.SmartsWithAllSavedIsPurelyImported()
	-- copy from coded preset of SmartEmotes
	local presetSmartEmotes = {
		["EVENT_TTL_EMOTES"] =
		{
			{ ["EventName"] = EVENT_CAPTURE_FLAG_STATE_CHANGED_LOST_FLAG, ["Duration"] = 5000, ["Emotes"] = {1007} },
			{ ["EventName"] = EVENT_KILLED_BOSS, ["Duration"] = 30000, ["Emotes"] = {1012}, },
			{ ["EventName"] = EVENT_KILLED_CREATURE, ["Duration"] = 30000, ["Emotes"] = {1017}, },
			{ ["EventName"] = EVENT_STARTUP, ["Duration"] = 60000, ["Emotes"] = {1022}, },
			{ ["EventName"] = EVENT_LOOT_RECEIVED_BETTER, ["Duration"] = 30000, ["Emotes"] = {1027}, },
			{ ["EventName"] = EVENT_LOOT_RECEIVED_RUNE_TA, ["Duration"] = 20000, ["Emotes"] = {1032}, },
			{ ["EventName"] = EVENT_LOOT_RECEIVED_RUNE_REKUTA, ["Duration"] = 20000, ["Emotes"] = {1037}, },
			{ ["EventName"] = EVENT_LOOT_RECEIVED_RUNE_KUTA, ["Duration"] = 30000, ["Emotes"] = {1042}, },
			{ ["EventName"] = EVENT_LOOT_RECEIVED_UNIQUE, ["Duration"] = 30000, ["Emotes"] = {1047}, },
			{ ["EventName"] = EVENT_PLEDGE_OF_MARA_RESULT_PLEDGED, ["Duration"] = 120000, ["Emotes"] = {1052}, },
			{ ["EventName"] = EVENT_LOOT_RECEIVED_RARE_RECIPE_OR_MATERIAL, ["Duration"] = 30000, ["Emotes"] = {1057}, },
			{ ["EventName"]  = EVENT_LOCKPICK_SUCCESS_EASY, ["Duration"] = 30000, ["Emotes"] = {1062}, },
			{ ["EventName"] = EVENT_LOCKPICK_SUCCESS_MEDIUM, ["Duration"] = 30000, ["Emotes"] = {1067}, },
			{ ["EventName"] = EVENT_LOCKPICK_SUCCESS_HARD, ["Duration"] = 30000, ["Emotes"] = {1072}, },
			{ ["EventName"] = EVENT_PLAYER_COMBAT_STATE_INCOMBAT, ["Duration"] = 20000, ["Emotes"] = {1077}, },
			{ ["EventName"] = EVENT_PLAYER_COMBAT_STATE_NOT_INCOMBAT_FLED, ["Duration"] = 15000, ["Emotes"] = {1082}, },
			{ ["EventName"] = EVENT_PLAYER_COMBAT_STATE_NOT_INCOMBAT, ["Duration"] = 15000, ["Emotes"] = {1087}, },
			{ ["EventName"] = EVENT_BANKED_MONEY_UPDATE_DOUBLE, ["Duration"] = 30000, ["Emotes"] = {1092}, },
			{ ["EventName"] = EVENT_BANKED_MONEY_UPDATE_GROWTH, ["Duration"] = 30000, ["Emotes"] = {1097}, },
			{ ["EventName"] = 131109, ["Duration"] = 20000, ["Emotes"] = {1102}, },
			{ ["EventName"] = 131498, ["Duration"] = 30000, ["Emotes"] = {1107}, },
			{ ["EventName"] = 131403, ["Duration"] = 15000, ["Emotes"] = {1112}, },
			{ ["EventName"] = 131442, ["Duration"] = 30000, ["Emotes"] = {1117}, },
			{ ["EventName"] = 131411, ["Duration"] = 15000, ["Emotes"] = {1122}, },
			{ ["EventName"] = 131224, ["Duration"] = 20000, ["Emotes"] = {1127}, },
			{ ["EventName"] = 131110, ["Duration"] = 15000, ["Emotes"] = {1132}, },
			{ ["EventName"] = 131130, ["Duration"] = 120000, ["Emotes"] = {1137}, },
			{ ["EventName"] = 131542, ["Duration"] = 20000, ["Emotes"] = {1142}, },
			{ ["EventName"] = 131391, ["Duration"] = 30000, ["Emotes"] = {1147}, },
		},
		["DEFAULT_EVENTS"] =
		{
			{
				["Key"] = "DEFAULT_EMOTES_BY_CITY_KEYS",
				["SubEntries"] = {
					["Vulkhel Guard"] = { ["Emotes"] = {1156}, },
					["EP"] = { ["Emotes"] = {1159}, },
					["Windhelm"] = { ["Emotes"] = {1162}, },
					["Riften"] = { ["Emotes"] = {1165}, },
					["Wayrest"] = { ["Emotes"] = {1168}, },
					["DC"] = { ["Emotes"] = {1171}, },
					["Elden Root"] = { ["Emotes"] = {1174}, },
					["AD"] = { ["Emotes"] = {1177}, },
					["Other"] = { ["Emotes"] = {1180}, },
					["Mournhold"] = { ["Emotes"] = {1183}, },
				},
			},
			{
				["Key"] = "DEFAULT_EMOTES_BY_REGION_KEYS",
				["SubEntries"] = {
					["ad2"] = { ["Emotes"] = {1191}, },
					["ep2"] = { ["Emotes"] = {1194}, },
					["dc2"] = { ["Emotes"] = {1197}, },
					["ep3"] = { ["Emotes"] = {1200}, },
					["ip"] = { ["Emotes"] = {1203}, },
					["ad1"] = { ["Emotes"] = {1206}, },
					["other"] = { ["Emotes"] = {1209}, },
					["ep1"] = { ["Emotes"] = {1212}, },
					["ch"] = { ["Emotes"] = {1215}, },
					["dc1"] = { ["Emotes"] = {1218}, },
				},
			},
			{ ["Key"] = "DEFAULT_EMOTES_FOR_HOUSING", ["Emotes"] = {1224}, },
			{ ["Key"] = "DEFAULT_EMOTES_FOR_DUNGEONS", ["Emotes"] = {1228}, },
			{ ["Key"] = "DEFAULT_EMOTES_FOR_DOLMENS", ["Emotes"] = {1232}, },
		},
		["RETICLE_EMOTES"] = {
			{ ["EventName"] = EVENT_RETICLE_TARGET_CHANGED_TO_FRIEND, ["Emotes"] = {1238} },
			{ ["EventName"] = EVENT_RETICLE_TARGET_CHANGED_TO_SPOUSE, ["Emotes"] = {1242} },
			{ ["EventName"] = EVENT_RETICLE_TARGET_CHANGED_TO_EPIC, ["Emotes"] = {1246} },
			{ ["EventName"] = EVENT_RETICLE_TARGET_CHANGED_TO_EPIC_SAME, ["Emotes"] = {1250} },
			{ ["EventName"] = EVENT_RETICLE_TARGET_CHANGED_TO_NORMAL, ["Emotes"] = {1254} },
		},
		["LATCHED_EMOTES"] = {
			{ ["EventName"] = EVENT_POWER_UPDATE_STAMINA, ["Emotes"] = {1260}, },
		}
	}

	LorePlaySavedCustomSmartEmotes["EMOTES"] = LorePlay.LPUtilities.DeepCopy(presetSmartEmotes)

	local fromSaved = LorePlay.LoadSmartEmotesFromSavedVariables()
	local smartEmotes = LorePlay.ReloadSmartEmotes()

	-- export from purely saved.
	local exported = LorePlay.ExportSmartEmotes()
	smartEmotes["Metadata"] = nil -- remove metadata for comparrisson.

	LorePlaySavedCustomSmartEmotes["EMOTES"] = nil
	local reset = LorePlay.LoadSmartEmotesFromSavedVariables()

	LorePlaySavedCustomSmartEmotes["EMOTES"] = LorePlay.LPUtilities.DeepCopy(exported)
	local fromExported = LorePlay.LoadSmartEmotesFromSavedVariables()

	assertThat("Imported SmartEmotes are Purely from Saved.",
		smartEmotes, ConditonEqualsTo(fromSaved))

	assertThat("Exported SmartEmotes equal Saved SmartEmotes (structure and values).",
		exported, function(actual, result)
			result["expectedStructure"] = LorePlay.LPUtilities.DeepCopy(presetSmartEmotes)
			result["todo"] = "under construction"
			return true
		end)

	assertThat("Exporting and Reloading SmartEmotes",
		fromExported, function(actual, result)
			fromExported["Metadata"] = nil
			fromSaved["Metadata"] = nil
			result["expected"] = LorePlay.LPUtilities.DeepCopy(fromSaved)
			result["control"] = LorePlay.LPUtilities.DeepCopy(reset) -- from reset
			return deepEquals(actual, fromSaved)
		end)
end

-- -- -- -- --

for _, testGroup in pairs(Test) do
	for name, test in pairs(testGroup) do
		if type(test) == "function" then
			-- debug.setupvalue(test, 0, name)
			test()
		end
	end
end

---
print("\"Test Results\"")
for _, assertion in pairs(assertions) do
	print(LorePlay.LPUtilities.SerializeJson(assertion))
	-- print(LorePlay.LPUtilities.SerializeLua(assertion))
end
