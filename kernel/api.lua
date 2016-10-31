local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

-- Class
PushUIAPI._all_vtbl = {}
function PushUIAPI.__classCreate(cls_type, obj, ...)
    if cls_type.super then
        obj = PushUIAPI.__classCreate(cls_type.super, obj, ...)
    end
    if cls_type.c_str then
        cls_type.c_str(obj, ...)
    end
    return obj
end

function PushUIAPI.inhiert(super_class)
    local _inhiertCls = {}
    _inhiertCls.c_str = false
    _inhiertCls.super = super_class
    _inhiertCls.new = function(...)
        local _obj = {}
        _obj = PushUIAPI.__classCreate(_inhiertCls, _obj, ...)
        setmetatable(_obj, { __index = PushUIAPI._all_vtbl[_inhiertCls]} )
        if super_class then
            _obj.super = { child = _obj }
            setmetatable(_obj.super, {
                __index = function(t, k)
                    local _ret = PushUIAPI._all_vtbl[super_class][k]
                    if not _ret then return _ret end
                    local _f = function(t, ...)
                        return _ret(t.child, ...)
                    end
                    return _f
                end
                })
        end
        if _obj.initialize then _obj.initialize(_obj) end
        return _obj
    end

    local _vtbl = {}
    PushUIAPI._all_vtbl[_inhiertCls] = _vtbl

    setmetatable(_inhiertCls, {
        __newindex = function(t, k, v) _vtbl[k] = v end,
        __call = function(cls, ...) return cls.new(...) end
        })
    if super_class then
        setmetatable(_vtbl, {
            __index = function(t, k)
                local _ret = PushUIAPI._all_vtbl[super_class][k]
                _vtbl[k] = _ret
                return _ret
            end
            })
    end

    return _inhiertCls
end

-- Structures and Events

-- Stack
PushUIAPI.Stack = {}
PushUIAPI.Stack.__index = PushUIAPI.Stack
function PushUIAPI.Stack:push(obj)
    if obj == nil then return end
    self.__storage[#self.__storage + 1] = obj
end
function PushUIAPI.Stack:pop()
    if #self.__storage == 0 then return end
    table.remove(self.__storage)
end
function PushUIAPI.Stack:top()
    if #self.__storage == 0 then return nil end
    return self.__storage[#self.__storage]
end
function PushUIAPI.Stack:size()
    return #self.__storage
end
function PushUIAPI.Stack:clear()
    local _s = #self.__storage
    for i = 1, _s do self.__storage[i] = nil end

    -- Create a new storge is more easy
    self.__storage = {}
end
function PushUIAPI.Stack.new()
    return setmetatable({__storage = {}}, PushUIAPI.Stack)
end
setmetatable(PushUIAPI.Stack, {__call = function(_, ...) return PushUIAPI.Stack.new(...) end})

-- Array
PushUIAPI.Array = {}
PushUIAPI.Array.__index = PushUIAPI.Array
function PushUIAPI.Array:push_front(obj)
    if obj == nil then return end
    table.insert(self.__storage, 1, obj)
end
function PushUIAPI.Array:push_back(obj)
    if obj == nil then return end
    table.insert(self.__storage, obj)
end
function PushUIAPI.Array:pop_front()
    if #self.__storage == 0 then return nil end
    local _obj = self.__storage[1]
    table.remove(self.__storage, 1)
    return _obj
end
function PushUIAPI.Array:pop_back()
    if #self.__storage == 0 then return nil end
    local _obj = self.__storage[#self.__storage]
    table.remove(self.__storage)
    return _obj
end
function PushUIAPI.Array:erase(index)
    if #self.__storage < index then return end
    table.remove(self.__storage, index)
end
function PushUIAPI.Array:insert(index, obj)
    if obj == nil then return end
    if #self.__storage < index then index = #self.__storage + 1 end
    if index <= 0 then index = 1 end
    table.insert(self.__storage, index, obj)
end
function PushUIAPI.Array:size()
    return #self.__storage
end
function PushUIAPI.Array:clear()
    repeat
        table.remove(self.__storage)
    until #self.__storage == 0
end
function PushUIAPI.Array:objectAtIndex(index)
    if index > #self.__storage then return nil end
    if index <= 0 then return nil end
    return self.__storage[index]
end
function PushUIAPI.Array:find(obj)
    local _s = #self.__storage
    for i = 1, _s do
        if self.__storage[i] == obj then return i end
    end
    return 0
end
function PushUIAPI.Array:find_by(obj, cmpfunc)
    if not cmpfunc then return self:find(obj) end
    local _s = #self.__storage
    for i = 1, _s do
        if cmpfunc(self.__storage[i], obj) then return i end
    end
    return 0
end
function PushUIAPI.Array:replace(index, obj)
    if index > #self.__storage then return nil end
    if index <= 0 then return nil end
    self.__storage[index] = obj
end
function PushUIAPI.Array:for_each(enumfunc, ...)
    if not enumfunc then return end
    local _s = #self.__storage
    for i = 1, _s do
        enumfunc(i, self.__storage[i], ...)
    end
end
function PushUIAPI.Array.new()
    return setmetatable({__storage = {}}, PushUIAPI.Array)
end
setmetatable(PushUIAPI.Array, {__call = function(_, ...) return PushUIAPI.Array.new(...) end})

-- Map
PushUIAPI.Map = PushUIAPI.inhiert()
function PushUIAPI.Map:set(key, value)
    if self.__storage[key] == nil then
        self.__size = self.__size + 1
    end
    self.__storage[key] = value
end
function PushUIAPI.Map:unset(key)
	if not self.__storage[key] then return end
    local _newStorage = {}
    for k, v in pairs(self.__storage) do
        if k ~= key then
            _newStorage[k] = v
        end
    end
    self.__storage = _newStorage
    self.__size = self.__size - 1
end
function PushUIAPI.Map:contains(key)
    return self.__storage[key] ~= nil
end
function PushUIAPI.Map:object(key)
	return self.__storage[key]
end
function PushUIAPI.Map:size()
    return self.__size
end
function PushUIAPI.Map:clear()
	repeat
		table.remove(self.__storage)
	until #self.__storage == 0
    self.__storage = {}
    self.__size = 0
end
function PushUIAPI.Map:for_each(enumfunc, ...)
    if not enumfunc then return end
	for k, v in pairs(self.__storage) do
		enumfunc(k, v, ...)
	end
end
function PushUIAPI.Map:c_str()
    self.__storage = {}
    self.__size = 0
end

-- Pool
PushUIAPI.Pool = {}
PushUIAPI.Pool.__index = PushUIAPI.Pool
function PushUIAPI.Pool:release(obj)
    self.__stack:push(obj)
end
function PushUIAPI.Pool:create()
    if self.__on_new == nil then return nil end
    return self.__on_new()
end
function PushUIAPI.Pool:get(...)
    if self.__stack:size() > 0 then
        local _obj = self.__stack:top()
        self.__stack:pop()
        return _obj
    end
    local _onNew = ...
    if _onNew then return _onNew() end
    return self:create()
end
function PushUIAPI.Pool:set_new_object(newfunc)
    self.__on_new = newfunc
end
function PushUIAPI.Pool:size()
    if pool.__stack == nil then return 0 end
    return pool.__stack:size()
end
function PushUIAPI.Pool.new()
    return setmetatable({__stack = PushUIAPI.Stack(), __on_new = nil}, PushUIAPI.Pool)
end
setmetatable(PushUIAPI.Pool, {
    __call = function(_, ...)
        local _obj = PushUIAPI.Pool.new()
        local _on_new = ...
        _obj:set_new_object(_on_new)
        return _obj
    end
})

-- Dispatcher
PushUIAPI.Dispatcher = {}
PushUIAPI.Dispatcher.__index = PushUIAPI.Dispatcher
function PushUIAPI.Dispatcher:add_action(event, key, action)
    if not event or not key or not action then return end
    if not self.__events:contains(event) then
        self.__events:set(event, PushUIAPI.Map())
    end
    self.__events:object(event):set(key, action)
end
function PushUIAPI.Dispatcher:del_action(event, key)
    if not event or not key then return end
    if not self.__events:contains(event) then return end
    self.__events:object(event):unset(key)
end
function PushUIAPI.Dispatcher:fire_event(event, ...)
    if not event then return end
    if not self.__events:contains(event) then return end
    self.__events:object(event):for_each(function(_, act, ...)
        act(event, ...)
    end, ...)
end
function PushUIAPI.Dispatcher.new()
    return setmetatable({__events = PushUIAPI.Map()}, PushUIAPI.Dispatcher)
end
setmetatable(PushUIAPI.Dispatcher, {
    __call = function(_, ...)
        return PushUIAPI.Dispatcher.new(...)
    end
    })

-- Timer
PushUIAPI.Timer = {}
PushUIAPI_Timer_FireFrame = CreateFrame("Frame", "PushUIAPI_Timer_FireFrame", UIParent)
PushUIAPI_Timer_FireFrame.__timerMap = PushUIAPI.Map()
PushUIAPI_Timer_FireFrame.__updateFunc = function(...)
    local _nowtime = time()
    PushUIAPI_Timer_FireFrame.__timerMap:for_each(function(_, timer)
        if (_nowtime - timer:last_fire_time()) >= timer:interval() then
            timer:fire()
            timer.__last_fire_time = _nowtime
        end
    end)
end
PushUIAPI_Timer_FireFrame.__timerCount = 0
PushUIAPI_Timer_FireFrame.__timerNamePool = PushUIAPI.Pool(function()
    PushUIAPI_Timer_FireFrame.__timerCount = PushUIAPI_Timer_FireFrame.__timerCount + 1
    return "PushUIAPI_Timer_FireFrame_Timer"..PushUIAPI_Timer_FireFrame.__timerCount
end)
PushUIAPI_Timer_FireFrame.__registerTimer = function(name, timer)
    PushUIAPI_Timer_FireFrame.__timerMap:set(name, timer)
    -- For the first registered timer, start the update function
    if PushUIAPI_Timer_FireFrame.__timerMap:size() == 1 then 
        PushUIAPI_Timer_FireFrame:SetScript("OnUpdate", PushUIAPI_Timer_FireFrame.__updateFunc)
    end
end
PushUIAPI_Timer_FireFrame.__unregisterTimer = function(name)
    PushUIAPI_Timer_FireFrame.__timerMap:unset(name)

    -- For the last removed timer, stop the update function
    if PushUIAPI_Timer_FireFrame.__timerMap:size() == 0 then
        PushUIAPI_Timer_FireFrame:SetScript("OnUpdate", nil)
    end
end
PushUIAPI.Timer.__index = PushUIAPI.Timer
function PushUIAPI.Timer:start(...)
    local _interval, _handler = ...

    -- Update interval
    _interval = _interval or self.__savedinterval
    if not _interval then return end
    self.__savedinterval = _interval

    -- Update handler
    if _handler then self.__handler = _handler end
    if not self.__handler then return end

    self.__last_fire_time = time()

    -- Get temp name
    self.__tmp_name = PushUIAPI_Timer_FireFrame.__timerNamePool:get()
    PushUIAPI_Timer_FireFrame.__registerTimer(self.__tmp_name, self)
    self.__running = true
end
function PushUIAPI.Timer:stop()
    if not self.__running then return end

    PushUIAPI_Timer_FireFrame.__unregisterTimer(self.__tmp_name)
    PushUIAPI_Timer_FireFrame.__timerNamePool:release(self.__tmp_name)
    self.__tmp_name = ""
    self.__running = false
end
function PushUIAPI.Timer:last_fire_time()
    return self.__last_fire_time
end
function PushUIAPI.Timer:interval()
    return self.__savedinterval
end
function PushUIAPI.Timer:fire()
    if not self.__handler then return end
    self.__handler(self.__target)
end
function PushUIAPI.Timer:set_target(target)
    self.__target = target
end
function PushUIAPI.Timer:set_handler(handler)
    self.__handler = handler
    if not self.__handler then self:stop() end
end
function PushUIAPI.Timer:set_interval(interval)
    self.__savedinterval = interval
    if self.__savedinterval <= 0 then self:stop() end
end
function PushUIAPI.Timer.new(interval, target, handler)
    return setmetatable({
        __last_fire_time = 0,
        __savedinterval = interval,
        __target = target,
        __handler = handler,
        __running = false,
        __tmp_name = ""
        }, PushUIAPI.Timer)
end
setmetatable(PushUIAPI.Timer, {
    __call = function(_, ...) return PushUIAPI.Timer.new(...) end
    })
function PushUIAPI.DurationFormat(duration)
    local _fs = ""
    if duration >= 86400 then
        local _days = math.floor(duration / 86400)
        duration = duration - (_days * 86400)
        if _days == 1 then
            _fs = _fs.._days.." Day "
        else
            _fs = _fs.._days.." Days "
        end
    end

    if duration >= 3600 then
        local _hours = math.floor(duration / 3600)
        duration = duration - (_hours * 3600)
        if _hours == 1 then
            _fs = _fs.._hours.." Hour "
        else
            _fs = _fs.._hours.." Hours "
        end
    end

    if duration >= 60 then
        local _mins = math.floor(duration / 60)
        duration = duration - (_mins * 60)
        if _mins == 1 then
            _fs = _fs.."01 Minute "
        else
            _fs = _fs..("%02d"):format(_mins).." Minutes "
        end
    end

    if duration == 1 then
        _fs = _fs.."01 Second"
    else
        _fs = _fs..("%02d"):format(duration).." Seconds"
    end

    return _fs
end

-- Event Center
PushUIAPI.EventCenter = {}
PushUIAPI.EventCenter.__index = PushUIAPI.EventCenter
PushUIAPI.EventCenter.__eventDispatcher = PushUIAPI.Dispatcher()
function PushUIAPI.EventCenter:RegisterEvent(event, key, func)
    self.__eventDispatcher:add_action(event, key, func)
end
function PushUIAPI.EventCenter:UnRegisterEvent(event, key)
    self.__eventDispatcher:del_action(event, key)
end
function PushUIAPI.EventCenter:FireEvent(event, ...)
    self.__eventDispatcher:fire_event(event, ...)
end

-- This event will be invoke only once when the player first time to enter the world.
PushUIAPI.PUSHUIEVENT_PLAYER_FIRST_ENTERING_WORLD = "PUSHUIEVENT_PLAYER_FIRST_ENTERING_WORLD"
local function __firsttime_default_handler(...)
    PushUIAPI.EventCenter:FireEvent(PushUIAPI.PUSHUIEVENT_PLAYER_FIRST_ENTERING_WORLD)
    PushUIUnRegisterEvent("PLAYER_ENTERING_WORLD", "PushUIEventCenterDefaultFirstTime")
end
-- Default player entering world event 
PushUIRegisterEvent("PLAYER_ENTERING_WORLD", "PushUIEventCenterDefaultFirstTime", __firsttime_default_handler)

PushUIAPI.PUSHUIEVENT_PLAYER_BEGIN_COMBAT = "PUSHUIEVENT_PLAYER_BEGIN_COMBAT"
PushUIAPI.PUSHUIEVENT_PLAYER_END_COMBAT = "PUSHUIEVENT_PLAYER_END_COMBAT"
local function __quit_combat_handler(...)
    PushUIAPI.EventCenter:FireEvent(PushUIAPI.PUSHUIEVENT_PLAYER_END_COMBAT)
end
local function __in_combat_handler(...)
    PushUIAPI.EventCenter:FireEvent(PushUIAPI.PUSHUIEVENT_PLAYER_BEGIN_COMBAT)
end
PushUIRegisterEvent("PLAYER_REGEN_ENABLED", "PushUIEventQuitCombat", __quit_combat_handler)
PushUIRegisterEvent("PLAYER_REGEN_DISABLED", "PushUIEventInCombat", __in_combat_handler)

-- Vechicle Events
PushUIAPI.PUSHUIEVENT_PLAYER_ENTER_VECHILE = "PUSHUIEVENT_PLAYER_ENTER_VECHILE"
PushUIAPI.PUSHUIEVENT_PLAYER_EXIT_VECHILE = "PUSHUIEVENT_PLAYER_EXIT_VECHILE"
local function __enter_vechile(...)
    PushUIAPI.EventCenter:FireEvent(PushUIAPI.PUSHUIEVENT_PLAYER_ENTER_VECHILE)
end
local function __exit_vechile(...)
    PushUIAPI.EventCenter:FireEvent(PushUIAPI.PUSHUIEVENT_PLAYER_EXIT_VECHILE)
end
PushUIRegisterEvent("UNIT_ENTERED_VEHICLE", "PushUIEventVehicleEntered", __enter_vechile)
PushUIRegisterEvent("UNIT_EXITED_VEHICLE", "PushUIEventVehicleExited", __exit_vechile)

-- by Push Chen
-- twitter: @littlepush

