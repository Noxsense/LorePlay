LorePlay = LorePlay or {}

-- === LPUtilities.lua ===
--[[
LorePlay.EVENT_ACTIVE_EMOTE = "EVENT_ACTIVE_EMOTE"
LorePlay.EVENT_ON_SMART_EMOTE = "EVENT_ON_SMART_EMOTE"
LorePlay.EVENT_ON_IDLE_EMOTE = "EVENT_ON_IDLE_EMOTE"
LorePlay.EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE = "EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE"
LorePlay.EVENT_INDICATOR_MOVED = "EVENT_INDICATOR_MOVED"
]]
-- ---


local LPUtilities = {}

function LPUtilities.DidPlayerMove(currentPlayerX, currentPlayerY)
	local newX, newY = GetMapPlayerPosition("player")
	if newX ~= currentPlayerX or newY ~= currentPlayerY then
		return newX, newY, true
	end
	return newX, newY, false
end

function LPUtilities.DeepCopy(original)
	local t = type(original)
	if t == "table" then
		local copied_table = {}
		for key, value in pairs(original) do
			copied_table[key] = LPUtilities.DeepCopy(value)
		end
		return copied_table
	elseif t == "number" or t == "string" or t == "boolean" then
		return original
	else
		return nil
	end
end

function isArray(t)
	if type(t) ~= "table" then
		return false
	end
	local count = 0
	for k,_ in pairs(t) do
		if type(k) ~= "number" then
			return false
		end
	end
	for i=1, count do
		if t[i] == nil then
			-- missing key.
			return false
		end
	end
	return true
end

function LPUtilities.DeepMergeTables(base, update)
	local merged = LPUtilities.DeepCopy(base)

	for key, value in pairs(update) do
		---@diagnostic disable-next-line: need-check-nil
		local previousValue = merged[key]
		if previousValue == nil or type(previousValue) ~= "table" then
			merged[key] = value
		elseif isArray(previousValue) then
			-- replace arrays fully.
			merged[key] = value
		else
			-- merge on top.
			merged[key] = LPUtilities.DeepMergeTables(previousValue, value)
		end
	end

	return merged
end

function LPUtilities.SerializeJson(value)
	local t = type(value)
	if value == nil or t == nil then
		return "null"
	elseif t == "number" or t == "boolean" then
		return tostring(value)
	elseif t == "string" then
		return '"' .. string.gsub(string.gsub(value, "\n", "\\n"),"\t", "\\t") .. '"'
	elseif t == "table" then
		local list = {}
		for key, val in pairs(value) do
			table.insert(list, "\"" .. key .. "\":" .. LPUtilities.SerializeJson(val))
		end
		return "{" .. table.concat(list, ", ") .. "}"
	end
	return "null"
end

function LPUtilities.SerializeLua(value)
	local vtype = type(value)
	if value == nil or vtype == "nil" or vtype == "number" or vrype == "boolean" then
		return tostring(value)
	elseif vtype == "string" then
		--return "\"" .. (value) .. "\""
		return '"' .. string.gsub(string.gsub(value, "\n", "\\n"),"\t", "\\t") .. '"'
	elseif vtype == "table" then
		local result = {}
		for key, val in pairs(value) do
			local key_string = (key ~= nil) and "[\"" .. (key) .. "\"] = "  or ""
			local val_string = LPUtilities.SerializeLua(val)
			table.insert(result, key_string .. val_string)
		end
		return "{ " .. table.concat(result, ", ") .. " }"
	end
	return "nil"
end

function LPUtilities.Map(input, mapFunction)
	if input == nil or type(input) ~= "table"
		or mapFunction == nil or type(mapFunction) ~= "function"
	then
		return input
	end

	local result = {}
	for key, value in pairs(input) do
		result[key] = mapFunction(value)
	end
	return result
end

-- ---
LorePlay.LPUtilities = LPUtilities
