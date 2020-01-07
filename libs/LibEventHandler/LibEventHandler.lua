--local MAJOR, MINOR = "LibEventHandler-1.2", "LibEventHandler-1.1"
--local LEH, LEHminor = LibStub:NewLibrary(MAJOR, MINOR)
--if not LEH then return end
if LibEventHandler then d("Warning : 'LibEventHandler' has always been loaded.") return end
local LEH = {}

LEH.eventToFunctionTable = {}
local eventToFunctionTable = LEH.eventToFunctionTable


local function CallEventFunctions(eventCode, ...)
	if #eventToFunctionTable[eventCode] == 0 then return end
	local numOfFuncs = #eventToFunctionTable[eventCode]
	for i = 1, numOfFuncs, 1 do
		eventToFunctionTable[eventCode][i](eventCode, ...)
	end
end


function LEH:FireEvent(eventCode, async, ...)
	if not eventCode then return end
	if not eventToFunctionTable[eventCode] or #eventToFunctionTable[eventCode] == 0 then
		return
	end
	local arg = {...}
	if not async or async == 0 then
		CallEventFunctions(eventCode, unpack(arg))
		return
	elseif type(async) == number then
		if async < 0 then
			d("Can't delay by a negative time!")
			return
		end
		zo_callLater(function() CallEventFunctions(eventCode, unpack(arg)) end, async)
		return
	else
		zo_callLater(function() CallEventFunctions(eventCode, unpack(arg)) end, 1)
	end
end


function LEH:UnregisterForLocalEvent(eventCode, functionName)
	if eventCode == nil or functionName == nil then return end
	if #eventToFunctionTable[eventCode] ~= 0 then
		local numOfFuncs = #eventToFunctionTable[eventCode]
		local didUnregister = false
		for i = 1, numOfFuncs, 1 do
			if eventToFunctionTable[eventCode][i] == functionName then
				eventToFunctionTable[eventCode][i] = eventToFunctionTable[eventCode][numOfFuncs]
				eventToFunctionTable[eventCode][numOfFuncs] = nil
				didUnregister = true
				numOfFuncs = numOfFuncs - 1
				if numOfFuncs == 0 then
					return true
				end
				return false
			end
		end
		if not didUnregister then d("Function trying to be removed isn't registered with event "..eventCode) end
		return false
	else
		d("No function registered yet for "..eventCode)
		return false
	end
end


function LEH:UnregisterForEvent(namespace, eventCode, functionName)
	local needsUnregistration = LEH:UnregisterForLocalEvent(eventCode, functionName)
	if needsUnregistration then
		EVENT_MANAGER:UnregisterForEvent(namespace, eventCode)
	end
end


function LEH:RegisterForLocalEvent(eventCode, functionName)
	if eventCode == nil or functionName == nil then return end
	if not eventToFunctionTable[eventCode] then
		eventToFunctionTable[eventCode] = {}
	end
	if #eventToFunctionTable[eventCode] ~= 0 then
		local numOfFuncs = #eventToFunctionTable[eventCode]
		for i = 1, numOfFuncs, 1 do
			if eventToFunctionTable[eventCode][i] == functionName then
				d("Function already registered for event "..eventCode)
				return false
			end
		end
		eventToFunctionTable[eventCode][numOfFuncs + 1] = functionName
		return false
	else
		eventToFunctionTable[eventCode][1] = functionName
		return true
	end
end


function LEH:RegisterForEvent(namespace, eventCode, functionName)
	local needsRegistration = LEH:RegisterForLocalEvent(eventCode, functionName)
	if needsRegistration then
		EVENT_MANAGER:RegisterForEvent(namespace, eventCode, CallEventFunctions)
	end
end


LibEventHandler = LEH	-- global variable for accessing library API.
