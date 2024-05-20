LorePlay = LorePlay or {}
-- --- definitions : local event codes for LibEventHandler
local EVENT_ACTIVE_EMOTE = "EVENT_ACTIVE_EMOTE"
local EVENT_ON_IDLE_EMOTE = "EVENT_ON_IDLE_EMOTE"
-- --- definitions : LPUtilities.lua
local LPUtilities = LorePlay.LPUtilities

-- ------------------------------------------------------------

-- === IdleEmotes.lua ===

local IdleEmotes = LorePlay

local isPlayerStealthed
local currentPlayerX, currentPlayerY
local emoteFromEvent
local defaultIdleTable
local eventIdleTable
local didIdleEmote = false
local isActiveEmoting = false
local isFastTraveling = false



function IdleEmotes.CreateEventIdleEmotesTable()
	eventIdleTable = {
		["isEnabled"] = false,
		[EVENT_TRADE_INVITE_ACCEPTED] = {
			[1] = 76,
			[2] = 35,
			[3] = 19,
			[4] = 36,
			[5] = 50,
			[6] = 41,
			[7] = 152,
			[8] = 15,
			[9] = 153,
		}
	}
end


local function AddDrunkToCities()
	local numOfEmotes = #defaultIdleTable["City"]
	local drunkTable = {
		[1] = 8,
		[2] = 8,
		[3] = 139,
		[4] = 139,
		[5] = 162,
		[6] = 162,
		[7] = 79,
		[8] = 79,
		[9] = 115,
		[10] = 90,
	}
	local numOfDrunks = #drunkTable
	for i = 1, numOfDrunks, 1 do
		defaultIdleTable["City"][numOfEmotes + i] = drunkTable[i]
	end
end


local function AddWorshipToDungeons()
	local numOfEmotes = #defaultIdleTable["Dungeon"]
	local worshipTable = {
		[1] = 104,
		[2] = 52,
		[3] = 171,
	}
	local numOfWorships = #worshipTable
	for i = 1, numOfWorships, 1 do
		defaultIdleTable["Dungeon"][numOfEmotes + i] = worshipTable[i]
	end
end


local function AddWorshipToCities()
	local numOfEmotes = #defaultIdleTable["City"]
	local worshipTable = {
		[1] = 104,
		[2] = 52,
		[3] = 171,
	}
	local numOfWorships = #worshipTable
	for i = 1, numOfWorships, 1 do
		defaultIdleTable["City"][numOfEmotes + i] = worshipTable[i]
	end
end


local function AddWorshipToZone()
	local numOfEmotes = #defaultIdleTable["Zone"]
	local worshipTable = {
		[1] = 104,
		[2] = 52,
		[3] = 171,
	}
	local numOfWorships = #worshipTable
	for i = 1, numOfWorships, 1 do
		defaultIdleTable["Zone"][numOfEmotes + i] = worshipTable[i]
	end
end


local function AddExercisesToZone()
	local numOfEmotes = #defaultIdleTable["Zone"]
	local exerciseTable = {
		[1] = 84,
		[2] = 85,
		[3] = 113,
	}
	local numOfExercises = #exerciseTable
	for i = 1, numOfExercises, 1 do
		defaultIdleTable["Zone"][numOfEmotes + i] = exerciseTable[i]
	end
end


local function AddDancesToCities()
	local numOfEmotes = #defaultIdleTable["City"]
	local danceTable = {
		[1] = 72,
		[2] = 189,
		[3] = 181,
		[4] = 182,
		[5] = 183,
		[6] = 180,
		[7] = 206,
		[8] = 185,
		[9] = 186,
		[10] = 187,
		[11] = 188,
	}
	local numOfDances = #danceTable
	for i = 1, numOfDances, 1 do
		defaultIdleTable["City"][numOfEmotes + i] = danceTable[i]
	end
end


local function AddInstrumentsToCities()
	local numOfEmotes = #defaultIdleTable["City"]
	local instrumentsTable = {
		[1] = 5,
		[2] = 6,
		[3] = 7,
	}
	local numOfInstruments = #instrumentsTable
	for i = 1, numOfInstruments, 1 do
		defaultIdleTable["City"][numOfEmotes + i] = instrumentsTable[i]
	end
end


function IdleEmotes.CreateDefaultIdleEmotesTable()
	defaultIdleTable = {
		["Zone"] = {
			[1] = 99,
			[2] = 119,
			[3] = 120,
			[4] = 121,
			[5] = 123,
			[6] = 102,
			[7] = 200,
			[8] = 15,
			[9] = 10,
			[10] = 38,
			[11] = 190,
		},
		["City"] = {
			[1] = 201,
			[2] = 107,
			[3] = 194,
			[4] = 8,
			[5] = 173,
			[6] = 100,
			[7] = 38,
			[8] = 168,
			[9] = 9,
			[10] = 190,
			[11] = 198,
		},
		["Dungeon"] = {
			[1] = 194,
			[2] = 1,
			[3] = 153,
			[4] = 1,
			[5] = 1,
			[6] = 122,
			[7] = 101,
		},
		["Housing"] = {
			[1] = 10,
			[2] = 10,
			[3] = 99,
			[4] = 119,
			[5] = 191,
			[6] = 191,
			[7] = 192,
			[8] = 192,
			[9] = 9,
			[10] = 177,
			[11] = 207,
			[12] = 208,
			[13] = 125,
			[14] = 125,
			[15] = 118,
			[16] = 116,
		}
	}

	if LorePlay.db.canPlayInstrumentsInCities then
		AddInstrumentsToCities()
	end
	if LorePlay.db.canDanceInCities then
		AddDancesToCities()
	end
	if LorePlay.db.canExerciseInZone then
		AddExercisesToZone()
	end
	if LorePlay.db.canWorship then
		AddWorshipToZone()
		AddWorshipToCities()
		AddWorshipToDungeons()
	end
	if LorePlay.db.canBeDrunkInCities then
		AddDrunkToCities()
	end
end


function IdleEmotes.GetLocation()
	if LorePlay.IsPlayerInHouse() then
		return "Housing"
	elseif LorePlay.IsPlayerInDungeon() then
		return "Dungeon"
	elseif LorePlay.IsPlayerInDolmen() then
		return "Dungeon"		-- use dungeon table for dolmen
	elseif LorePlay.IsPlayerInAbyssalGeyser() then
		return "Dungeon"		-- use dungeon table for AbyssalGeyser
	elseif LorePlay.IsPlayerInHarrowstormRitualSite() then
		return "Dungeon"		-- use dungeon table for HarrowstormRitualSite
	elseif LorePlay.IsPlayerInMirrormoorMosaic() then
		return "Dungeon"		-- use dungeon table for MirrormoorMosaic
	elseif LorePlay.IsPlayerInCity() then
		return "City"
	elseif LorePlay.IsPlayerInParentZone() then
		return "Zone"
	else
		return "Dungeon"		-- unregistered region case
	end
end


function IdleEmotes.PerformIdleEmote()
	if IsPlayerMoving() then return end
	local randomEmote
	local currIdleEmote
	if eventIdleTable["isEnabled"] then
		randomEmote = math.random(#emoteFromEvent)
		currIdleEmote = emoteFromEvent[randomEmote]
	else
		local location = IdleEmotes.GetLocation()
		randomEmote = math.random(#defaultIdleTable[location])
		currIdleEmote = defaultIdleTable[location][randomEmote]
	end
	LPEventHandler:FireEvent(EVENT_ON_IDLE_EMOTE, false, true, currIdleEmote)
	PlayEmoteByIndex(currIdleEmote)
	didIdleEmote = true
	EVENT_MANAGER:UnregisterForUpdate("IdleEmotes")
	EVENT_MANAGER:RegisterForUpdate("IdleEmotes", LorePlay.db.timeBetweenIdleEmotes, IdleEmotes.CheckToPerformIdleEmote)
end


function IdleEmotes.UpdateEmoteFromEvent(eventCode)
	emoteFromEvent = eventIdleTable[eventCode]
	if not eventIdleTable["isEnabled"] then
		eventIdleTable["isEnabled"] = true
	end
end


function IdleEmotes.UpdateStealthState(eventCode, unitTag, stealthState)
	if unitTag ~= "player" then return end
	if stealthState ~= STEALTH_STATE_NONE then
		isPlayerStealthed = true
	else
		isPlayerStealthed = false
	end
end


function IdleEmotes.IsCharacterIdle()
	if IsMounted() or isFastTraveling or IsUnitSwimming("player") or IsBlockActive() or not ArePlayerWeaponsSheathed() or IsUnitDeadOrReincarnating("player") then return end
	if not isActiveEmoting then
		local didMove = IdleEmotes.UpdateIfMoved() 
		if not didMove then
			if isPlayerStealthed == nil then
				IdleEmotes.UpdateStealthState(EVENT_STEALTH_STATE_CHANGED, "player", GetUnitStealthState("player"))
			end
			if not isPlayerStealthed then
				local interactionType = GetInteractionType()
  				if interactionType == INTERACTION_NONE then
					return true
				end
			end
		end
	end
	return false
end


local housingEditorScenes = {
	housingEditorHud = true, 
	housingEditorHudUI = true, 
}
function IdleEmotes.IsBlacklistedScene()
	local currentScene = SCENE_MANAGER:GetCurrentScene()
	if currentScene == nil then
--		LorePlay.LDL:Debug("[SCENE]IdleEmoteNG : currentScene = nil (not initialized yet)"
		return true
	end
	local currentSceneName = currentScene:GetName()
	if not LorePlay.adb.ieAllowedInHousingEditor and housingEditorScenes[currentSceneName] then
--		LorePlay.LDL:Debug("[SCENE]IdleEmoteNG : currentScene = %s", currentSceneName)
		return true
	end
	if currentScene:HasFragment(FRAME_PLAYER_FRAGMENT) then
--		LorePlay.LDL:Debug("[SCENE]IdleEmoteNG : detect FRAME_PLAYER_FRAGMENT")
		return true
	end
	return false
end

function IdleEmotes.CheckToPerformIdleEmote()
	if IdleEmotes.IsCharacterIdle() and not IdleEmotes.IsBlacklistedScene() then
		IdleEmotes.PerformIdleEmote()
	end
end


-- Used to check if player has moved in between IdleEmotes to allow for faster detection
function IdleEmotes.UpdateIfMoved()
	local x, y, didMove = LPUtilities.DidPlayerMove(currentPlayerX, currentPlayerY)
	if didMove then
		currentPlayerX = x
		currentPlayerY = y
		if didIdleEmote then
			didIdleEmote = false
		end
		EVENT_MANAGER:UnregisterForUpdate("IdleEmotes")
		EVENT_MANAGER:RegisterForUpdate("IdleEmotes", LorePlay.adb.ieIdleTime , IdleEmotes.CheckToPerformIdleEmote)
	end
	return didMove
end


function IdleEmotes.OnTradeEvent_For_EVENT_TRADE_INVITE_ACCEPTED(eventCode)
	if eventCode ~= EVENT_TRADE_INVITE_ACCEPTED then return end
	IdleEmotes.UpdateEmoteFromEvent(eventCode)
end


function IdleEmotes.OnTradeEvent_For_TRADE_CESSATION(eventCode)
	if emoteFromEvent == eventIdleTable[EVENT_TRADE_INVITE_ACCEPTED] then
		eventIdleTable["isEnabled"] = false
	end
end


function IdleEmotes.OnPlayerCombatStateEvent(eventCode, inCombat)
	if not inCombat then
		if LorePlay.db.isIdleEmotesOn then
			EVENT_MANAGER:RegisterForUpdate("IdleEmotes", LorePlay.adb.ieIdleTime, IdleEmotes.CheckToPerformIdleEmote)
		end
	else
		if LorePlay.db.isIdleEmotesOn then
			EVENT_MANAGER:UnregisterForUpdate("IdleEmotes")
		end
	end
end


function IdleEmotes.OnMountedEvent(eventCode, mounted)
	if not mounted then
		if LorePlay.db.isIdleEmotesOn then
			EVENT_MANAGER:RegisterForUpdate("IdleEmotes", LorePlay.adb.ieIdleTime, IdleEmotes.CheckToPerformIdleEmote)
		end
	else
		if LorePlay.db.isIdleEmotesOn then
			EVENT_MANAGER:UnregisterForUpdate("IdleEmotes")
		end
	end
end


function IdleEmotes.OnChatterEvent(eventCode)
	if eventCode == EVENT_CHATTER_BEGIN then
		EVENT_MANAGER:UnregisterForUpdate("IdleEmotes")
	else
		EVENT_MANAGER:UnregisterForUpdate("IdleEmotes")
		EVENT_MANAGER:RegisterForUpdate("IdleEmotes", LorePlay.adb.ieIdleTime, IdleEmotes.CheckToPerformIdleEmote)
	end
end


local function OnActiveEmote(eventCode, isEmotingNow)
	if eventCode ~= EVENT_ACTIVE_EMOTE then return end
	if isEmotingNow then
		isActiveEmoting = true
		EVENT_MANAGER:UnregisterForUpdate("IdleEmotes")
	else
		isActiveEmoting = false
		if not IsMounted() then
			EVENT_MANAGER:RegisterForUpdate("IdleEmotes", LorePlay.adb.ieIdleTime, IdleEmotes.CheckToPerformIdleEmote)
		end
	end
end


local function OnFastTravelInteraction(eventCode)
	if eventCode == EVENT_START_FAST_TRAVEL_INTERACTION then
		isFastTraveling = true
	else
		isFastTraveling = false
	end
end


function IdleEmotes.OnCraftingStationInteract(eventCode)
	if eventCode == EVENT_CRAFTING_STATION_INTERACT then
		EVENT_MANAGER:UnregisterForUpdate("IdleEmotes")
	elseif eventCode == EVENT_END_CRAFTING_STATION_INTERACT then
		EVENT_MANAGER:RegisterForUpdate("IdleEmotes", LorePlay.adb.ieIdleTime, IdleEmotes.CheckToPerformIdleEmote)
	end
end


local function OnHousingEditorModeChanged(eventCode, oldMode, newMode)
	if oldMode == HOUSING_EDITOR_MODE_DISABLED then
		if not LorePlay.adb.ieAllowedInHousingEditor then
			if didIdleEmote then
				-- Stop performing the IdleEmotes.
				PlayEmoteByIndex(GetEmoteIndex(267))	-- "/idle"
			end
		end
	end
end


function IdleEmotes.UnregisterIdleEvents()
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_MOUNTED_STATE_CHANGED, IdleEmotes.OnMountedEvent)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_PLAYER_COMBAT_STATE, IdleEmotes.OnPlayerCombatStateEvent)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_STEALTH_STATE_CHANGED, IdleEmotes.UpdateStealthState)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_CHATTER_BEGIN, IdleEmotes.OnChatterEvent)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_CHATTER_END, IdleEmotes.OnChatterEvent)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_TRADE_INVITE_ACCEPTED, IdleEmotes.OnTradeEvent_For_EVENT_TRADE_INVITE_ACCEPTED)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_TRADE_SUCCEEDED, IdleEmotes.OnTradeEvent_For_TRADE_CESSATION)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_TRADE_CANCELED, IdleEmotes.OnTradeEvent_For_TRADE_CESSATION)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_CRAFTING_STATION_INTERACT, IdleEmotes.OnCraftingStationInteract)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_END_CRAFTING_STATION_INTERACT, IdleEmotes.OnCraftingStationInteract)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_END_FAST_TRAVEL_INTERACTION, OnFastTravelInteraction)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_START_FAST_TRAVEL_INTERACTION, OnFastTravelInteraction)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_HOUSING_EDITOR_MODE_CHANGED, OnHousingEditorModeChanged)
	LPEventHandler:UnregisterForLocalEvent(EVENT_ACTIVE_EMOTE, OnActiveEmote)
	EVENT_MANAGER:UnregisterForUpdate("IdleEmotes")
	EVENT_MANAGER:UnregisterForUpdate("IdleEmotesMoveTimer")
end


function IdleEmotes.RegisterIdleEvents()
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_MOUNTED_STATE_CHANGED, IdleEmotes.OnMountedEvent)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_PLAYER_COMBAT_STATE, IdleEmotes.OnPlayerCombatStateEvent)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_STEALTH_STATE_CHANGED, IdleEmotes.UpdateStealthState)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_CHATTER_BEGIN, IdleEmotes.OnChatterEvent)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_CHATTER_END, IdleEmotes.OnChatterEvent)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_TRADE_INVITE_ACCEPTED, IdleEmotes.OnTradeEvent_For_EVENT_TRADE_INVITE_ACCEPTED)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_TRADE_SUCCEEDED, IdleEmotes.OnTradeEvent_For_TRADE_CESSATION)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_TRADE_CANCELED, IdleEmotes.OnTradeEvent_For_TRADE_CESSATION)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_CRAFTING_STATION_INTERACT, IdleEmotes.OnCraftingStationInteract)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_END_CRAFTING_STATION_INTERACT, IdleEmotes.OnCraftingStationInteract)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_END_FAST_TRAVEL_INTERACTION, OnFastTravelInteraction)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_START_FAST_TRAVEL_INTERACTION, OnFastTravelInteraction)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_HOUSING_EDITOR_MODE_CHANGED, OnHousingEditorModeChanged)
	LPEventHandler:RegisterForLocalEvent(EVENT_ACTIVE_EMOTE, OnActiveEmote)
	EVENT_MANAGER:RegisterForUpdate("IdleEmotes", LorePlay.adb.ieIdleTime, IdleEmotes.CheckToPerformIdleEmote)
	EVENT_MANAGER:RegisterForUpdate("IdleEmotesMoveTimer", 10000, IdleEmotes.UpdateIfMoved)
end


function IdleEmotes.InitializeIdle()
	if not LorePlay.db.isIdleEmotesOn then return end
	IdleEmotes.CreateDefaultIdleEmotesTable()
	IdleEmotes.CreateEventIdleEmotesTable()
	currentPlayerX, currentPlayerY = GetMapPlayerPosition("player")
	IdleEmotes.RegisterIdleEvents()
end

LorePlay = IdleEmotes
