LorePlay = LorePlay or {}
LorePlay.majorVersion = 1
LorePlay.minorVersion = 6
LorePlay.bugVersion = 94
LorePlay.version = LorePlay.majorVersion.."."..LorePlay.minorVersion.."."..LorePlay.bugVersion
LorePlay.name = "LorePlay"
LorePlay.savedVars = "LorePlaySavedVars"
LorePlay.savedVarsVersion = 1
LorePlay.authority = {2973583419,210970542}

local L = GetString

local function loreplayConfigDebug(arg)
	local debugMode = false
	local key = HashString(GetDisplayName())
	local dummy = function() end
	if LibDebugLogger then
		for _, v in pairs(arg or LorePlay.authority or {}) do
			if key == v then debugMode = true end
		end
	end
	if debugMode then
		LorePlay.LDL = LibDebugLogger(LorePlay.name)
	else
		LorePlay.LDL = { Verbose = dummy, Debug = dummy, Info = dummy, Warn = dummy, Error = dummy, }
	end
end


function LorePlay.OnAddOnLoaded(event, addonName)
	if addonName ~= LorePlay.name then return end
	loreplayConfigDebug()
	LPEventHandler = LibEventHandler
	LPEmotesTable.CreateAllEmotesTable()
	LPEmoteHandler.InitializeEmoteHandler()
	LorePlay.InitializeSettings()
	LorePlay.InitializeEmotes()
	LorePlay.InitializeIdle()
	LorePlay.InitializeLoreWear()
	EVENT_MANAGER:UnregisterForEvent(LorePlay.name, event)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_PLAYER_ACTIVATED, LorePlay.OnPlayerActivated)
end


function LorePlay.OnPlayerActivated(event)
	if not LorePlay.adb.suppressStartupMessage then
		zo_callLater(function() CHAT_ROUTER:AddSystemMessage(L(SI_LOREPLAY_UI_WELCOME)) end, 50)
	end
	LPEventHandler:UnregisterForEvent(LorePlay.name, event, LorePlay.OnPlayerActivated)
end

local function convertToHumanReadbleStoredSequences(arg)
	-- evaluate arg.
	if arg == "preset" then
		CHAT_ROUTER:AddSystemMessage("Unset all Saved Configuration and Stores only Preset.")
		-- TODO (2024-11-24)
	end

	local time = os.date("%FT%T%z")

	LorePlaySavedCustomSmartEmotes = {
		["GENERATED_AT"] = time,
		["EMOTES"] = LorePlay.ExportSmartEmotes(),
	}

	LorePlaySavedCustomIdleEmotes =  {
		["generatedAt"] = time,
		["EMOTES"] = LorePlay.ExportIdleEmotes(),
	}
end

function LorePlay.RestoreEmotesToSavedVariables(arg)
	zo_callLater(function()
		CHAT_ROUTER:AddSystemMessage("Restoring current settings (args: " ..  tostring(arg) .. ") from SavedVariables/LorePlay.lua[ LorePlaySavedCustomSmartEmotes, LorePlaySavedCustomIdleEmotes]")
		-- LorePlay.StoreCurrentEmotes()
		d(LorePlay.LPUtilities.Serialize(LorePlaySavedCustomSmartEmotes["EMOTES"] or {}))
		d("vvvv")
		LorePlay.InitializeEmotes()
		LorePlay.InitializeIdle()
	end, 50)
end

function LorePlay.StoreEmotesToSavedVariables(arg)
	zo_callLater(function()
		CHAT_ROUTER:AddSystemMessage("Storing current settings (args: " ..  tostring(arg) .. ") into Human Readable Table, see SavedVariables/LorePlay.lua[ LorePlaySavedCustomSmartEmotes, LorePlaySavedCustomIdleEmotes]")
		-- LorePlay.StoreCurrentEmotes()
		convertToHumanReadbleStoredSequences(arg)
		ReloadUI()
	end, 50)
end

EVENT_MANAGER:RegisterForEvent(LorePlay.name, EVENT_ADD_ON_LOADED, LorePlay.OnAddOnLoaded)

SLASH_COMMANDS["/loreplay.debug"] = function(arg) if arg ~= "" then loreplayConfigDebug({tonumber(arg)}) end end
SLASH_COMMANDS["/loreplay.reload"] = function(arg) LorePlay.ReconvertLorePlaySavedata() end
SLASH_COMMANDS["/loreplay.emotes"] = function(arg)

	local splitArgs = {}
	for word in string.gmatch(arg, "%S+") do
		table.insert(splitArgs, word)
	end

	if arg == nil or arg == "" or splitArgs[1] == "help" then
		zo_callLater(function()
			CHAT_ROUTER:AddSystemMessage("Store (/loreplay.emotes export) or Reload (/loreplay.emotes import) SmartEmotes and Idle Emotes to/from SavedVariables/LorePlay.lua[ LorePlaySavedCustomSmartEmotes, LorePlaySavedCustomIdleEmotes ]")
		end, 50)
	elseif splitArgs[1] == "export" then
		table.remove(splitArgs, 1)
		LorePlay.StoreEmotesToSavedVariables(table.concat(splitArgs, " "))
	elseif splitArgs[1] == "import" then
		table.remove(splitArgs, 1)
		LorePlay.RestoreEmotesToSavedVariables(table.concat(splitArgs, " "))
	end
end
--SLASH_COMMANDS["/loreplay.fixdata1670"] = function(arg) LorePlay.FixSavedata1670() end
