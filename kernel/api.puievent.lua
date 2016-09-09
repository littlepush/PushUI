local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
	PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIAPI.__dispatcherCache = {}
local _dc = PushUIAPI.__dispatcherCache

function PushUIAPI:RegisterPUIEvent(event, key, func)
	if not event or event == "" then 
		print("PUIEvent: cannot register an empty event")
		return
	end
	if not key or key == "" then
		print("PUIEvent: "..event.." cannot register with an empty key")
		return
	end
	if not func then 
		print("PUIEvent: "..event.." with key: "..key.." cannot register with empty callback function");
		return
	end
	if not _dc[event] then
		_dc[event] = {}
	end
	local _dce = _dc[event]
	if _dce[key] then print("PUIEvent: "..event.."has already been registered with key: "..key); return end
	_dce[key] = func
end

function PushUIAPI:UnRegisterPUIEvent(event, key)
	if not event or event == "" then
		print("PUIEvent: cannot unregister an empty event")
		return
	end
	if not key or key == "" then
		print("PUIEvent: "..event.." cannot unregister with empty key")
		return
	end
	if not _dc[event] then return end
	if not _dc[event][key] then return end
	_dc[event][key] = nil
end

function PushUIAPI:FirePUIEvent(event, ...)
	if not event or event == "" then
		print("PUIEvent: cannot fire an empty event")
		return
	end
	if not _dc[event] then 
		print("cannot find hook for event: "..event)
		return 
	end
	local _dce = _dc[event]
	local _dceCount = #_dce
	for k, f in pairs(_dce) do
		f(event, ...)
	end
end

-- This event will be invoke only once when the player first time to enter the world.
PushUIAPI.PUSHUIEVENT_PLAYER_FIRST_ENTERING_WORLD = "PUSHUIEVENT_PLAYER_FIRST_ENTERING_WORLD"
PushUIAPI.DefaultPlayerEnteringWorldHandler = function(...)
	PushUIAPI:FirePUIEvent(PushUIAPI.PUSHUIEVENT_PLAYER_FIRST_ENTERING_WORLD)
	PushUIAPI.UnregisterEvent("PLAYER_ENTERING_WORLD", PushUIAPI)
end

-- Default player entering world event 
PushUIAPI.RegisterEvent("PLAYER_ENTERING_WORLD", PushUIAPI, PushUIAPI.DefaultPlayerEnteringWorldHandler)


-- Push Chen
-- https://twitter.com/littlepush
--
