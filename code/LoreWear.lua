LorePlay = LorePlay or {}
-- --- definitions : LPCategoryStrings.lua
local Appearance = LorePlay.Appearance
local Hats = LorePlay.Hats
local Costumes = LorePlay.Costumes
local Skins = LorePlay.Skins
local Polymorphs = LorePlay.Polymorphs
local Hair = LorePlay.Hair
local FacialAcc = LorePlay.FacialAcc
local FacialHair = LorePlay.FacialHair
local BodyMarkings = LorePlay.BodyMarkings
local HeadMarkings = LorePlay.HeadMarkings
local Jewelry = LorePlay.Jewelry
local Personalities = LorePlay.Personalities
local VanityPets = LorePlay.VanityPets
local City = LorePlay.City
local Housing = LorePlay.Housing
local Dungeon = LorePlay.Dungeon
local Adventure = LorePlay.Adventure
local Total = LorePlay.Total
local player = LorePlay.player
local stringToColTypeTable = LorePlay.stringToColTypeTable
-- ---
-- --- definitions : LPUtilities.lua
local EVENT_ACTIVE_EMOTE = LorePlay.EVENT_ACTIVE_EMOTE
local EVENT_ON_SMART_EMOTE = LorePlay.EVENT_ON_SMART_EMOTE
local EVENT_ON_IDLE_EMOTE = LorePlay.EVENT_ON_IDLE_EMOTE
local EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE = LorePlay.EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE
local EVENT_INDICATOR_MOVED = LorePlay.EVENT_INDICATOR_MOVED
local LPUtilities = LorePlay.LPUtilities

-- ------------------------------------------------------------

-- === LoreWear.lua ===

local LW_BEHAVIOR_ID_DONT_CARE			= LorePlay.const.LW_BEHAVIOR_ID_DONT_CARE
local LW_BEHAVIOR_ID_PREVENT_CHANGE		= LorePlay.const.LW_BEHAVIOR_ID_PREVENT_CHANGE
local LW_BEHAVIOR_ID_USE_SPECIFIED_ONE	= LorePlay.const.LW_BEHAVIOR_ID_USE_SPECIFIED_ONE
local LW_BEHAVIOR_ID_CANCEL_HIDE_HELM	= LorePlay.const.LW_BEHAVIOR_ID_CANCEL_HIDE_HELM
local LW_USAGE_ID_NOT_USED				= LorePlay.const.LW_USAGE_ID_NOT_USED
local LW_USAGE_ID_CITY					= LorePlay.const.LW_USAGE_ID_CITY
local LW_USAGE_ID_HOUSING				= LorePlay.const.LW_USAGE_ID_HOUSING
local LW_USAGE_ID_DUNGEON				= LorePlay.const.LW_USAGE_ID_DUNGEON
local LW_USAGE_ID_ADVENTURE				= LorePlay.const.LW_USAGE_ID_ADVENTURE
local LW_USAGE_ID_RIDING				= LorePlay.const.LW_USAGE_ID_RIDING
local LW_USAGE_ID_COMBAT				= LorePlay.const.LW_USAGE_ID_COMBAT
local LW_USAGE_ID_SWIMMING				= LorePlay.const.LW_USAGE_ID_SWIMMING
local LW_PRESET_TURN_OFF_HIDE_HELM		= LorePlay.const.LW_PRESET_TURN_OFF_HIDE_HELM
local LW_PRESET_EQUIP_WEDDING_COSTUME	= LorePlay.const.LW_PRESET_EQUIP_WEDDING_COSTUME
local LW_PRESET_TOGGLE_ALL_COLLECTIBLES = LorePlay.const.LW_PRESET_TOGGLE_ALL_COLLECTIBLES
local LW_PRESET_TOGGLE_COSTUME_ONLY		= LorePlay.const.LW_PRESET_TOGGLE_COSTUME_ONLY

-- variables for location recognize engine -----
local isFirstTimePlayerActivated = true
local isLoadingProcess = true
local isDelayProcess = false
local zoneIndexBeforeLoading
local mapNameBeforeLoading
local specificPOINameNearbyBeforeLoading
local zoneIndexAfterLoading
local mapNameAfterLoading
local countEventZoneChangedDuringLoading = 0
local countEventPOIUpdateDuringLoading = 0
local countEventLWPChangedDuringLoading = 0
local countEventLWPChangedDuringDelayTime = 0
-- ---------------------------------------------

-- variables for LoreWear
local isFastTraveling = false
local toggleTable = {}
local isCooldown = false
local pendingPresetIndex
local currentOutfitUsageCategory = LW_USAGE_ID_NOT_USED


local function BuildToggleTable()
	for _, v in pairs(LorePlay.collectibleType) do
		toggleTable[v] = 0
	end
end


local function FindNextPresetIndex(usageId, currentPresetIndex)
	local tmpTbl = {}
	local maxn = 0
	local ptr = 0
	for k, v in pairs(LorePlay.db.stylePreset) do
		if v.usage == usageId then
			maxn = maxn + 1
			tmpTbl[maxn] = k
			if k == currentPresetIndex then
				ptr = maxn
			end
		end
	end
	if maxn > 0 then
		ptr = ptr + 1
		if ptr > maxn then
			ptr = ptr - maxn
		end
		return tmpTbl[ptr]
	end
end
LorePlay.FindNextPresetIndex = FindNextPresetIndex


local function debugShowCollectibleCooldown()
	local cooldownRemaining, cooldownDuration
	local collectibleTestCase = {
		[3] = 1155,
		[4] = 97,
		[8] = 301,
		[9] = 378,
		[10] = 399,
		[11] = 1317,
		[12] = 776,
		[13] = 537,
		[14] = 729,
		[15] = 414,
		[16] = 724,
		[17] = 1007,
		[18] = 860,
	}
	for k, v in pairs(collectibleTestCase) do
		cooldownRemaining, cooldownDuration = GetCollectibleCooldownAndDuration(v)
		LorePlay.LDL:Debug("type=%d, id=%d, cdRemain=%d, cdDuration=%d", k, v, cooldownRemaining, cooldownDuration)
	end
end

local function IsCollectibleCooldown(collectibleTypes)
	-- [collectibleTypes] nilable lua table of CollectibleCategoryTypes
	-- 		nilable   : Normally, no arguments are required.
	-- 					In that case, all collectible types handled by LoreWear will be checked.
	--
	collectibleTypes = collectibleTypes or LorePlay.collectibleType
	for k, v in pairs(collectibleTypes) do
		if LorePlay.db.isUsingCollectible[v] then
			if select(2, GetCollectibleCooldownAndDuration(GetCollectibleIdFromType(v, 1))) > 0 then return true end
		end
	end
	return false
end

local function IsPresetIndexEmbedded(presetIndex)
	if presetIndex > 10000 then return true else return false end
end

local function SafeUseCollectible(collectibleId)
	-- [returns:] unnecessity of retry
	--		true      : no error
	--		false     : error     (operation failure due to collectible cooldown)
	--
	local cooldownDuration = select(2, GetCollectibleCooldownAndDuration(collectibleId))
	if cooldownDuration == 0 then
		UseCollectible(collectibleId)
		return true
	else
		LorePlay.LDL:Warn("collectible cooldown remain : type=%d, id=%d, cdDuration=%d, name=%s", GetCollectibleCategoryType(collectibleId), collectibleId, cooldownDuration, GetCollectibleName(collectibleId))
		return false
	end
end


local function TurnOffHideHelm()
	local noErr = true
	local hideYourHelmId = 5002
	local currentCollectibleId
	if LorePlay.db.isUsingCollectible[COLLECTIBLE_CATEGORY_TYPE_HAT] then
		currentCollectibleId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HAT)
		if currentCollectibleId == hideYourHelmId and GetCollectibleBlockReason(hideYourHelmId) == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then
			noErr = SafeUseCollectible(hideYourHelmId) and noErr
		end
	end
	if noErr then
		LorePlay.db.equippedPresetIndex = 0	-- unknownId
	end
	return noErr
end

local function EquipWeddingClothes()
	local noErr = true
	local maleWeddingCostumes = {
		95, 	-- weddingSuit
	}
	local femaleWeddingCostumes = {
		79, 	-- weddingGown
		76, 	-- eveningDress
	}
	local currCostume = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COSTUME)
	local desiredCollectibleId
	local gender = GetUnitGender(player)
	if LorePlay.db.isUsingCollectible[COLLECTIBLE_CATEGORY_TYPE_COSTUME] then
		if gender == GENDER_MALE then
			for _, v in pairs(maleWeddingCostumes) do
				if  IsCollectibleUnlocked(v) then
					desiredCollectibleId = v
					break
				end
			end
		elseif gender == GENDER_FEMALE then
			for _, v in pairs(femaleWeddingCostumes) do
				if  IsCollectibleUnlocked(v) then
					desiredCollectibleId = v
					break
				end
			end
		end
		if desiredCollectibleId then
			if currCostume ~= desiredCollectibleId and GetCollectibleBlockReason(desiredCollectibleId) == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then
				noErr = SafeUseCollectible(desiredCollectibleId) and noErr
			end
		end
	end
	if noErr then
		LorePlay.db.equippedPresetIndex = 0	-- unknownId
		BuildToggleTable()
	end
	return noErr
end

local function ForceShowOrHideClothes()
	local noErr = true
	local currentCollectibleId
	if IsUnitDeadOrReincarnating("player") then return true end
	if IsCollectibleCooldown() then return false end
	for k, desiredCollectibleId in pairs(toggleTable) do
		if LorePlay.db.isUsingCollectible[k] then
			currentCollectibleId = GetActiveCollectibleByType(k)
			if desiredCollectibleId ~= 0 and GetCollectibleBlockReason(desiredCollectibleId) == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then
				noErr = SafeUseCollectible(desiredCollectibleId) and noErr
			elseif currentCollectibleId ~= 0 and GetCollectibleBlockReason(currentCollectibleId) == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then
				noErr = SafeUseCollectible(currentCollectibleId) and noErr
			end
			-- Store previous collectibleId into table to be used again
			toggleTable[k] = currentCollectibleId
		end
	end
	if noErr then
		LorePlay.db.equippedPresetIndex = 0	-- unknownId
	end
	return noErr
end

local function ToggleTakeOffCostumeOnly()
	local noErr = true
	local hideYourHelmId = 5002
	local currentCollectibleId
	local desiredCollectibleId
	local costumeCollectibleType = {
		COLLECTIBLE_CATEGORY_TYPE_COSTUME, 
		COLLECTIBLE_CATEGORY_TYPE_HAT, 
		COLLECTIBLE_CATEGORY_TYPE_POLYMORPH, 
		COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY, 
	}
	if IsUnitDeadOrReincarnating("player") then return true end
	if IsCollectibleCooldown(costumeCollectibleType) then return false end
	for k, v in pairs(costumeCollectibleType) do
		if LorePlay.db.isUsingCollectible[v] then
			currentCollectibleId = GetActiveCollectibleByType(v)
			desiredCollectibleId = toggleTable[v]
			if desiredCollectibleId ~= 0 and desiredCollectibleId ~= hideYourHelmId and GetCollectibleBlockReason(desiredCollectibleId) == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then
				noErr = SafeUseCollectible(desiredCollectibleId) and noErr
			elseif currentCollectibleId ~= 0 and currentCollectibleId ~= hideYourHelmId and GetCollectibleBlockReason(currentCollectibleId) == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then
				noErr = SafeUseCollectible(currentCollectibleId) and noErr
			end
			-- Store previous collectibleId into table to be used again
			toggleTable[v] = currentCollectibleId
		end
	end
	if noErr then
		LorePlay.db.equippedPresetIndex = 0	-- unknownId
	end
	return noErr
end



-- -------------------------------------------------------------------------------------
local EquipBuiltInFunctionTable = {
	-- special equip function table for certain embedded presetIndex
	[LW_PRESET_TURN_OFF_HIDE_HELM]		= TurnOffHideHelm, 
	[LW_PRESET_EQUIP_WEDDING_COSTUME]	= EquipWeddingClothes, 
	[LW_PRESET_TOGGLE_ALL_COLLECTIBLES] = ForceShowOrHideClothes, 
	[LW_PRESET_TOGGLE_COSTUME_ONLY]		= ToggleTakeOffCostumeOnly, 
}
-- -------------------------------------------------------------------------------------
local function EquipBuiltInStylePreset(presetIndex)
	-- [returns:] unnecessity of retry
	--		true      : no error
	--		false     : error     (operation failure due to collectible cooldown)
	--
	local noErr = true
	if not presetIndex then return noErr end

	local SpecialOperation = EquipBuiltInFunctionTable[presetIndex]
	if SpecialOperation then return SpecialOperation(presetIndex) end

	-- [in development]
	-- routine using built-in style preset table and/or account-wide preset table is a future development task
	-- 

	return noErr
end


local function EquipUserStylePreset(presetIndex)
	local noErr = true
	local outfitIndex
	local currentCollectibleId
	local desiredCollectibleId
	if not presetIndex then return noErr end
	if LorePlay.db.isUsingOutfit then
		outfitIndex = LorePlay.db.stylePreset[presetIndex].outfitIndex
		if outfixIndex == -1 then
			-- [-1 : don't care]
		elseif outfitIndex == 0 or outfitIndex == nil then
			UnequipOutfit()
		else
			EquipOutfit(outfitIndex)
		end
	end
	for k, v in pairs(LorePlay.collectibleType) do
		if LorePlay.db.isUsingCollectible[v] then
			currentCollectibleId = GetActiveCollectibleByType(v)
			desiredCollectibleId = LorePlay.db.stylePreset[presetIndex].collectible[v]
			if desiredCollectibleId == -1 then
				-- [-1 : don't care]
			elseif desiredCollectibleId ~= 0 and currentCollectibleId ~= desiredCollectibleId and GetCollectibleBlockReason(desiredCollectibleId) == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then
				noErr = SafeUseCollectible(desiredCollectibleId) and noErr
			elseif desiredCollectibleId == 0 and currentCollectibleId ~= 0 and GetCollectibleBlockReason(currentCollectibleId) == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then
				noErr = SafeUseCollectible(currentCollectibleId) and noErr
			end
		end
	end
	if noErr then
--		LorePlay.LDL:Debug("EquipStylePreset : successful (%d)", presetIndex)
		LorePlay.db.equippedPresetIndex = presetIndex
		--Reset the toggle table for correct keypress toggling
		BuildToggleTable()
	else
--		LorePlay.LDL:Debug("EquipStylePreset : failed (%d)", presetIndex)
	end
	return noErr
end


local function EquipStylePreset(presetIndex)
	-- [presetIndex] an index of the costume setting table
	-- 		nilable
	-- 		0         : unknown preset
	-- 		1...10000 : user defined style preset (savedata)
	-- 		10001 ... : special style preset (built-in)
	--
	-- [returns:] unnecessity of re-equip
	--		true      : no error  (including no operation)
	--		false     : error     (operation failure due to collectible cooldown)
	--
	if presetIndex > 10000 then return EquipBuiltInStylePreset(presetIndex) end
	return EquipUserStylePreset(presetIndex)
end
LorePlay.EquipStylePreset = EquipStylePreset


local function OnCollectibleCooldownOver()
	local noErr = true
--	LorePlay.LDL:Debug("OnCollectibleCooldownOver : ")
	if pendingPresetIndex then
		noErr = EquipStylePreset(pendingPresetIndex)
		if noErr then
			pendingPresetIndex = nil
		end
	else
		EVENT_MANAGER:UnregisterForUpdate("LorePlayCollectibleCooldown")
		isCooldown = false
--		LorePlay.LDL:Debug("Collectible cooldown is over right now.")
	end
end
local function RegisterChangeStylePreset(presetIndex)
	local noErr = true
	local duration = 1000	-- each collectible type has a 1000msec cooldown.

	presetIndex = presetIndex or pendingPresetIndex
	if presetIndex == nil then return end

	if isCooldown then
		pendingPresetIndex = presetIndex
	else
		noErr = EquipStylePreset(presetIndex)
		if noErr then
			pendingPresetIndex = nil
		else
			pendingPresetIndex = presetIndex
		end
		isCooldown = true
		EVENT_MANAGER:RegisterForUpdate("LorePlayCollectibleCooldown", duration, OnCollectibleCooldownOver)
--		LorePlay.LDL:Debug("RegisterForUpdate : OnCollectibleCooldownOver")
	end
end


-- ---------------------------------------------------------------------------------------------------------------------------------------------------

local function KeypressToggleLoreWearClothes()
	if not LorePlay.db.isLoreWearOn then return end
	if IsUnitDeadOrReincarnating("player") then return end
	RegisterChangeStylePreset(LW_PRESET_TOGGLE_ALL_COLLECTIBLES)
end
LorePlay.KeypressToggleLoreWearClothes = KeypressToggleLoreWearClothes


local function KeypressToggleTakeOffCostumeOnly()
	if IsUnitDeadOrReincarnating("player") then return end
	RegisterChangeStylePreset(LW_PRESET_TOGGLE_COSTUME_ONLY)
end
LorePlay.KeypressToggleTakeOffCostumeOnly = KeypressToggleTakeOffCostumeOnly


local function KeypressEquipPreferedStylePreset(usageId)
	local selectUsage
	local stylePresetIndex
	if not usageId then return end
	if IsUnitDeadOrReincarnating("player") then return end
	stylePresetIndex = LorePlay.db.preferedStylePresetByUsage[usageId] or 0
	if stylePresetIndex == 0 then return end
	RegisterChangeStylePreset(stylePresetIndex)
end
LorePlay.KeypressEquipPreferedStylePreset = KeypressEquipPreferedStylePreset


local function KeypressTogglePreferedStylePreset()
	if IsUnitDeadOrReincarnating("player") then return end
	local currentEquipped = LorePlay.db.equippedPresetIndex or 0
	if currentEquipped == 0 then return end
	local usage = LorePlay.db.stylePreset[currentEquipped].usage or 0
--	LorePlay.LDL:Debug("current StylePresetIndex=", currentEquipped, "  usage=", usage)
	if usage == 0 then return end
	local newStylePresetIndex = FindNextPresetIndex(usage, currentEquipped)
--	LorePlay.LDL:Debug("next StylePresetIndex=", newStylePresetIndex)
	if newStylePresetIndex then
		LorePlay.db.preferedStylePresetByUsage[usage] = newStylePresetIndex
		RegisterChangeStylePreset(newStylePresetIndex)
	end
end
LorePlay.KeypressTogglePreferedStylePreset = KeypressTogglePreferedStylePreset


-- ---------------------------------------------------------------------------------------------------------------------------------------------------

local function CorrectMapMismatch()
	if not DoesCurrentMapMatchMapForPlayerLocation() then
		local setMapResult = SetMapToPlayerLocation()		-- my special thanks to both votan and Garkin!
		if setMapResult == SET_MAP_RESULT_MAP_CHANGED then
            CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
			LorePlay.LDL:Debug("FireCallbacks : OnWorldMapChanged")
		end
	end
end


local function RequestChangeOutfits(eventCode)
	local selectUsage
	local stylePresetIndex
	local isPlayerDead
	local isPlayerMounted
	local isPlayerSwimming
	local isPlayerInCombat
	local IsUnitInAir = IsUnitInAir or function() return false end

--	LorePlay.LDL:Debug("[RequestChangeOutfits] : eventCode=", eventCode)

	if not LorePlay.db.isLoreWearOn then return end
	
	isPlayerDead = IsUnitDeadOrReincarnating("player")
	isPlayerMounted = IsMounted()
	isPlayerSwimming = IsUnitSwimming("player")
	isPlayerInCombat = IsUnitInCombat("player")
	local controlTable = LorePlay.db.lwControlTable

	-- check if request should be rejected or not
	if isPlayerDead then
--		LorePlay.LDL:Debug("Outfit change request canceled : player is dead")	-- Do not change outfit when character is dead (mismatch occurs)
		return
	end
	if isPlayerMounted then
		if controlTable.whileMounted == LW_BEHAVIOR_ID_PREVENT_CHANGE then return end
	end
	if isPlayerSwimming then
		if controlTable.duringSwimming == LW_BEHAVIOR_ID_PREVENT_CHANGE then return end
	end
	if isPlayerInCombat then
		if controlTable.inCombat == LW_BEHAVIOR_ID_PREVENT_CHANGE then return end
	end
	if isFastTraveling then
		if controlTable.inFastTraveling == LW_BEHAVIOR_ID_PREVENT_CHANGE then return end
	end
	if IsUnitInAir("player") then
--		LorePlay.LDL:Debug("Outfit change request postponed : player is in air")	-- Do not change outfit when character is in air (countermeasure for water jump)
		zo_callLater(function() RequestChangeOutfits(nil) end, 2000)	-- for fail safe
		return
	end

--	LorePlay.LDL:Debug("[RequestChangeOutfits] : reject check passed")

	-- determine outfit category based on higher priority events
	if eventCode == EVENT_MOUNTED_STATE_CHANGED and isPlayerMounted then	-- ------- start riding
		if controlTable.whileMounted == LW_BEHAVIOR_ID_USE_SPECIFIED_ONE then
--			LorePlay.LDL:Debug("[RequestChangeOutfits] : EVENT_MOUNTED_STATE_CHANGED")
			selectUsage = LW_USAGE_ID_RIDING	-- riding clothes
		end
	elseif eventCode == EVENT_PLAYER_SWIMMING then
		if controlTable.duringSwimming == LW_BEHAVIOR_ID_USE_SPECIFIED_ONE then
			if isPlayerInCombat == false then									-- --- start swimming in non-combat
--				LorePlay.LDL:Debug("[RequestChangeOutfits] : EVENT_PLAYER_SWIMMING")
				selectUsage = LW_USAGE_ID_SWIMMING	-- wet suit
			end
		end
	elseif eventCode == EVENT_PLAYER_COMBAT_STATE and isPlayerInCombat then	-- ------- just after the battle started
		if isPlayerSwimming == false then
--			LorePlay.LDL:Debug("[RequestChangeOutfits] : EVENT_PLAYER_COMBAT_STATE")
			if controlTable.inCombat == LW_BEHAVIOR_ID_CANCEL_HIDE_HELM then
				if currentOutfitUsageCategory ~= LW_USAGE_ID_COMBAT then		-- allow turning off hide helm
					currentOutfitUsageCategory = LW_USAGE_ID_COMBAT				-- as same as combat uniform
					RegisterChangeStylePreset(LW_PRESET_TURN_OFF_HIDE_HELM)
				else
--					LorePlay.LDL:Debug("Outfit change request canceled : same outfit usage category")
				end
				return
			elseif controlTable.inCombat == LW_BEHAVIOR_ID_USE_SPECIFIED_ONE then 
				if isPlayerMounted == false then
					selectUsage = LW_USAGE_ID_COMBAT	-- combat uniform
				end
			end
		end
	end

	-- determine outfit category based on player situation
	if selectUsage == nil then
		if controlTable.whileMounted == LW_BEHAVIOR_ID_USE_SPECIFIED_ONE and isPlayerMounted then
			selectUsage = LW_USAGE_ID_RIDING	-- riding clothes
		elseif controlTable.duringSwimming == LW_BEHAVIOR_ID_USE_SPECIFIED_ONE and isPlayerSwimming then
			if isPlayerInCombat == false then
				selectUsage = LW_USAGE_ID_SWIMMING	-- wet suit
			end
		end
	end
	if selectUsage == nil then
		if controlTable.inCombat == LW_BEHAVIOR_ID_USE_SPECIFIED_ONE and isPlayerInCombat then
			if isPlayerMounted == false and isPlayerSwimming == false then
				selectUsage = LW_USAGE_ID_COMBAT	-- combat uniform
			else
				if currentOutfitUsageCategory == LW_USAGE_ID_COMBAT then
					selectUsage = LW_USAGE_ID_COMBAT	-- combat uniform
				end
			end
		elseif controlTable.inCombat == LW_BEHAVIOR_ID_CANCEL_HIDE_HELM and isPlayerInCombat then
			if isPlayerSwimming == false and currentOutfitUsageCategory ~= LW_USAGE_ID_COMBAT then		-- allow turning off hide helm
				currentOutfitUsageCategory = LW_USAGE_ID_COMBAT				-- as same as combat uniform
				RegisterChangeStylePreset(LW_PRESET_TURN_OFF_HIDE_HELM)
				return
			else
				selectUsage = LW_USAGE_ID_COMBAT	-- keep turning off hide helm
			end
		end
	end

	-- determine outfit category based on location
	if selectUsage == nil then
		if LorePlay.IsPlayerInHouse() then
			selectUsage = LW_USAGE_ID_HOUSING	-- housing
		elseif LorePlay.IsPlayerInDungeon() or LorePlay.IsPlayerInDolmen() or LorePlay.IsPlayerInAbyssalGeyser() or LorePlay.IsPlayerInHarrowstormRitualSite() then
			selectUsage = LW_USAGE_ID_DUNGEON	-- dungeon
		elseif LorePlay.IsPlayerInCity() then
			selectUsage = LW_USAGE_ID_CITY		-- city
		elseif LorePlay.IsPlayerInParentZone() then
			selectUsage = LW_USAGE_ID_ADVENTURE	-- adventure
		else
			selectUsage = LW_USAGE_ID_DUNGEON	-- dungeon, for unregistered region case
		end
	end
--	LorePlay.LDL:Debug("selectUsage=", selectUsage)

	-- determine style preset index
	stylePresetIndex = LorePlay.db.preferedStylePresetByUsage[selectUsage] or 0
	if stylePresetIndex == 0 then return end

	if selectUsage == currentOutfitUsageCategory then		-- cancel change request : if there is no change in the outfit usage category to protect manual appearance changes.
--		LorePlay.LDL:Debug("Outfit change request canceled : same outfit usage category")
		return
	end
	currentOutfitUsageCategory = selectUsage
	RegisterChangeStylePreset(stylePresetIndex)
end


local function OnPlayerIsDeactivated(eventCode)
	LorePlay.LDL:Debug("EVENT_PLAYER_DEACTIVATED :")

	isLoadingProcess = true
	zoneIndexBeforeLoading = GetUnitZoneIndex("player")
	mapNameBeforeLoading = GetMapName()
	specificPOINameNearbyBeforeLoading = LorePlay.db.specificPOINameNearby
	zoneIndexAfterLoading = 0
	mapNameAfterLoading = ""
	countEventZoneChangedDuringLoading = 0
	countEventPOIUpdateDuringLoading = 0
	countEventLWPChangedDuringLoading = 0
end


local function OnZoneChangedBehindSchedule(eventCode, subZoneName, subZoneId)
	LorePlay.LDL:Debug("EVENT_ZONE_CHANGED [DELAYED] : subZoneName = %s , subZoneId = %d", subZoneName, subZoneId)
	CorrectMapMismatch()

	isDelayProcess = false
--	LorePlay.LDL:Info("Update Location by EVENT_ZONE_CHANGED")
	LorePlay.db.savedSubZoneName = subZoneName
	LorePlay.db.savedSubZoneId = subZoneId
--	if countEventLWPChangedDuringDelayTime == 0 then		-- stop changing outfits when detecting the player entering or exiting the building
	if subZoneId ~= 0 or countEventLWPChangedDuringDelayTime == 0 then		-- stop changing outfits when detecting the player entering the building
		RequestChangeOutfits(eventCode)
	end
end



local function OnZoneChanged(eventCode, _, subZoneName, _, _, subZoneId)
	LorePlay.LDL:Debug("EVENT_ZONE_CHANGED : subZoneName = %s , subZoneId = %d", subZoneName, subZoneId)
	countEventLWPChangedDuringDelayTime = 0
	if isLoadingProcess then
		countEventZoneChangedDuringLoading = countEventZoneChangedDuringLoading + 1
	end
	isDelayProcess = true
	zo_callLater(function() OnZoneChangedBehindSchedule(eventCode, subZoneName, subZoneId) end, 500)		-- delay 500ms : this event handler must be executed after events EVENT_POI_UPDATED and EVENT_LINKED_WORLD_POSITION_CHANGED.
end


local function OnPoiUpdated(eventCode, zoneIndex, poiIndex)
	local poiName = GetPOIInfo(zoneIndex, poiIndex)
	local poiType = GetPOIType(zoneIndex, poiIndex)
   	local normalizedX, normalizedZ, poiPinType, iconPath, isShown, _, _, isNearby = GetPOIMapInfo(zoneIndex, poiIndex)
--	LorePlay.LDL:Debug("EVENT_POI_UPDATED : zoneIndex=%d, poiIndex=%d, poiName=%s", zoneIndex, poiIndex, poiName)
	if iconPath:find("poi_city") or iconPath:find("poi_town") then		-- my special thanks to circonian!
		LorePlay.LDL:Debug("EVENT_POI_UPDATED: zoneIndex=%d, poiIndex=%d, ", zoneIndex, poiIndex)
		LorePlay.LDL:Debug("[POI] %s : isNearby=%s, icon=%s", poiName, tostring(isNearby), iconPath)
		CorrectMapMismatch()
		if isLoadingProcess then
			countEventPOIUpdateDuringLoading = countEventPOIUpdateDuringLoading + 1
		end
		local isInSpecificPOI, _, id = LorePlay.IsPlayerInSpecificPOI(poiName)
		if isInSpecificPOI then
--			LorePlay.LDL:Info("Update Location by EVENT_POI_UPDATED")
			if isNearby then
				LorePlay.db.specificPOINameNearby = poiName
				LorePlay.db.savedSubZoneName = poiName
				LorePlay.db.savedSubZoneId = id
			else
				LorePlay.db.specificPOINameNearby = nil
				LorePlay.db.savedSubZoneName = ""
				LorePlay.db.savedSubZoneId = 0
			end
		end
		RequestChangeOutfits(eventCode)
	end
end


local function OnLinkedWorldPositionChanged(eventCode)
	LorePlay.LDL:Debug("EVENT_LINKED_WORLD_POSITION_CHANGED :")
	if isLoadingProcess then
		countEventLWPChangedDuringLoading = countEventLWPChangedDuringLoading + 1
	end
	if isDelayProcess then
		countEventLWPChangedDuringDelayTime = countEventLWPChangedDuringDelayTime + 1
	end
end

local function OnPlayerIsActivated(eventCode, initial)
	LorePlay.LDL:Debug("EVENT_PLAYER_ACTIVATED : initial =", initial, ", isFirstTime =", isFirstTimePlayerActivated)
	isLoadingProcess = false

	CorrectMapMismatch()
	if initial then
		if isFirstTimePlayerActivated == false then		-- after fast travel
			local zoneIndexAfterLoading = GetUnitZoneIndex("player")
			local mapNameAfterLoading = GetMapName()
			local isInSpecificPOI, _, id = LorePlay.IsPlayerInSpecificPOI(mapNameAfterLoading)
			local specificPOIIndex = nil

			if isInSpecificPOI then		-- search specificPOI by map name
				for i=1, GetNumPOIs(zoneIndexAfterLoading) do
					if GetPOIInfo(zoneIndexAfterLoading, i) == mapNameAfterLoading then
						specificPOIIndex = i
						break
					end
				end
				if specificPOIIndex then
					local isNearby = select(8, GetPOIMapInfo(zoneIndexAfterLoading, specificPOIIndex))
					if isNearby then
						LorePlay.db.specificPOINameNearby = mapNameAfterLoading
--						RequestChangeOutfits(eventCode) -- mapNameAfterLoading, id
--						return
					else
						LorePlay.db.specificPOINameNearby = nil
--						RequestChangeOutfits(eventCode) -- "", 0
--						return
					end
				end
			else
				LorePlay.db.specificPOINameNearby = nil
--				RequestChangeOutfits(eventCode) -- "", 0
--				return
			end

			if countEventZoneChangedDuringLoading == 0 then
				local location = GetPlayerLocationName()
				if location ~= LorePlay.db.savedSubZoneName then
					LorePlay.db.savedSubZoneId = nil
				end
				LorePlay.db.savedSubZoneName = location
				RequestChangeOutfits(eventCode)
			end
		else		-- --------------------------------- after login
--			LorePlay.LDL:Info("after login!")
			isFirstTimePlayerActivated = false
		end
	else		-- ------------------------------------- after reloadui
--		LorePlay.LDL:Info("after reloadui")
		isFirstTimePlayerActivated = false
	end
end


local function OnMountedStateChanged(eventCode, mounted)
	local behaviorId = LorePlay.db.lwControlTable.whileMounted
	if mounted then
		if behaviorId == LW_BEHAVIOR_ID_USE_SPECIFIED_ONE then
			zo_callLater(function() RequestChangeOutfits(eventCode) end, 200)
		end
	else
		if behaviorId ~= LW_BEHAVIOR_ID_DONT_CARE then		-- it means LW_BEHAVIOR_ID_PREVENT_CHANGE or LW_BEHAVIOR_ID_USE_SPECIFIED_ONE
			zo_callLater(function() RequestChangeOutfits(eventCode) end, 900)
		end
	end
end


local function OnPlayerSwimming(eventCode)
	local behaviorId = LorePlay.db.lwControlTable.duringSwimming
	if behaviorId == LW_BEHAVIOR_ID_USE_SPECIFIED_ONE then
		RequestChangeOutfits(eventCode)
	end
end


local function OnPlayerNotSwimming(eventCode)
	local behaviorId = LorePlay.db.lwControlTable.duringSwimming
	if behaviorId ~= LW_BEHAVIOR_ID_DONT_CARE then		-- it means LW_BEHAVIOR_ID_PREVENT_CHANGE or LW_BEHAVIOR_ID_USE_SPECIFIED_ONE
		zo_callLater(function() RequestChangeOutfits(eventCode) end, 2000)
	end
end


local function OnEndFastTravelInteraction(eventCode)
	local behaviorId = LorePlay.db.lwControlTable.inFastTraveling
	isFastTraveling = false
	if behaviorId == LW_BEHAVIOR_ID_PREVENT_CHANGE then
		RequestChangeOutfits(eventCode)
	end
end


local function OnStartFastTravelInteraction(eventCode)
	isFastTraveling = true
end


local function OnPlayerCombatState(eventCode, inCombat)
	local behaviorId = LorePlay.db.lwControlTable.inCombat
	if inCombat then
		if behaviorId == LW_BEHAVIOR_ID_USE_SPECIFIED_ONE or behaviorId == LW_BEHAVIOR_ID_CANCEL_HIDE_HELM then
			zo_callLater(function() RequestChangeOutfits(eventCode) end, 500)
		end
	else
		if behaviorId ~= LW_BEHAVIOR_ID_DONT_CARE then		-- it means LW_BEHAVIOR_ID_PREVENT_CHANGE or LW_BEHAVIOR_ID_USE_SPECIFIED_ONE or LW_BEHAVIOR_ID_CANCEL_HIDE_HELM
			RequestChangeOutfits(eventCode)
		end
	end
end


local function OnPlayerReincarnated(eventCode)
	local behaviorId = LorePlay.db.lwControlTable.inCombat
	if behaviorId ~= LW_BEHAVIOR_ID_DONT_CARE then		-- it means LW_BEHAVIOR_ID_PREVENT_CHANGE or LW_BEHAVIOR_ID_USE_SPECIFIED_ONE or LW_BEHAVIOR_ID_CANCEL_HIDE_HELM
		zo_callLater(function() RequestChangeOutfits(eventCode) end, 1500)
	end
end


local function OnPlayerMaraPledge(eventCode, isGettingMarried)
	if eventCode ~= EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE then return end
	if isGettingMarried then
		EquipWeddingClothes()
	end
end


--[[
local function initializeIndicator()
	if not LorePlay.db.isLoreWearIndicatorOn then 
		LoreWearIndicator:SetHidden(true)
	end
	if LorePlay.db.indicatorTop then
		LoreWearIndicator:ClearAnchors()
		LoreWearIndicator:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, LorePlay.db.indicatorLeft, LorePlay.db.indicatorTop)
	end
	local fadeTime = 1500
	indicatorFadeIn, timelineFadeIn = CreateSimpleAnimation(ANIMATION_ALPHA, LoreWearIndicator)
	indicatorFadeOut, timelineFadeOut = CreateSimpleAnimation(ANIMATION_ALPHA, LoreWearIndicator) --LoreWearIndicator defined in xml file of same name
	indicatorFadeIn:SetAlphaValues(0, EmoteImage:GetAlpha())
	indicatorFadeIn:SetDuration(fadeTime)
	indicatorFadeOut:SetAlphaValues(EmoteImage:GetAlpha(), 0)
	indicatorFadeOut:SetDuration(fadeTime)
	timelineFadeIn:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
	timelineFadeOut:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
	indicator = false
end
]]


local function UnregisterLoreWearEvents()
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_MOUNTED_STATE_CHANGED, OnMountedStateChanged)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_PLAYER_SWIMMING, OnPlayerSwimming)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_PLAYER_NOT_SWIMMING, OnPlayerNotSwimming)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_END_FAST_TRAVEL_INTERACTION, OnEndFastTravelInteraction)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_END_FAST_TRAVEL_KEEP_INTERACTION, OnEndFastTravelInteraction)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_START_FAST_TRAVEL_INTERACTION, OnStartFastTravelInteraction)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_START_FAST_TRAVEL_KEEP_INTERACTION, OnStartFastTravelInteraction)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_PLAYER_REINCARNATED, OnPlayerReincarnated)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE, OnPlayerMaraPledge)
end
LorePlay.UnregisterLoreWearEvents = UnregisterLoreWearEvents


local function RegisterLoreWearEvents()
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_MOUNTED_STATE_CHANGED, OnMountedStateChanged)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_PLAYER_SWIMMING, OnPlayerSwimming)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_PLAYER_NOT_SWIMMING, OnPlayerNotSwimming)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_END_FAST_TRAVEL_INTERACTION, OnEndFastTravelInteraction)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_END_FAST_TRAVEL_KEEP_INTERACTION, OnEndFastTravelInteraction)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_START_FAST_TRAVEL_INTERACTION, OnStartFastTravelInteraction)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_START_FAST_TRAVEL_KEEP_INTERACTION, OnStartFastTravelInteraction)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_PLAYER_REINCARNATED, OnPlayerReincarnated)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE, OnPlayerMaraPledge)
end


local function InitializeLoreWear()
	-- ------------------------------------ always active -------------------------------------------------------------
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_PLAYER_DEACTIVATED, OnPlayerIsDeactivated)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_ZONE_CHANGED, OnZoneChanged)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_POI_UPDATED, OnPoiUpdated)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_LINKED_WORLD_POSITION_CHANGED, OnLinkedWorldPositionChanged)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_PLAYER_ACTIVATED, OnPlayerIsActivated)
	-- ----------------------------------------------------------------------------------------------------------------
	if not LorePlay.db.isLoreWearOn then return end
	BuildToggleTable()
	RegisterLoreWearEvents()
--[[
	initializeIndicator()
]]
end
LorePlay.InitializeLoreWear = InitializeLoreWear


local function ReenableLoreWear()
	BuildToggleTable()
	RegisterLoreWearEvents()
--[[
	initializeIndicator()
]]
	RequestChangeOutfits(nil)
end
LorePlay.ReenableLoreWear = ReenableLoreWear

