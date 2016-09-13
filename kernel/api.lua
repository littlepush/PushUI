local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local frame_metatable = {
   __index = CreateFrame('Frame')
}

function frame_metatable.__index:tostring()
   return tostring(self)
end
 
-- lib = setmetatable(lib, frame_metatable)
-- print(lib:tostring()) -- works

PushUIAPI.getObjName = function(self)
    if self.name then
        return self.name
    elseif self.GetName then
        return self:GetName()
    end

    return '<unnamed>'
end

PushUIAPI.isTable = function(obj)
    return type(obj) == 'table'
end
PushUIAPI.isUserdata = function(obj)
    return type(obj) == 'userdata'
end

PushUIAPI.dumpLevel = function(lv)
    local _ = ':'
    for i=1,lv do
        _ = _..'-'
    end
    return _
end

PushUIAPI.dumpObject = function(key, obj, lv)
    if not key then
        key = '<undefined>'
    end
    if nil == obj then
        print(key.." is nil")
        return
    end
    lv = lv or 1
    local _slv = PushUIAPI.dumpLevel(lv)
    if PushUIAPI.isTable(obj) then
        --print(_slv..key..':'..PushUIAPI.getObjName(obj)..'(table)')
        for k,v in pairs(obj) do
            PushUIAPI.dumpObject(k, v, lv + 1)
        end
    elseif PushUIAPI.isUserdata(obj) then
        print(_slv..key..':'..tostring(obj)..'('..type(obj)..')')
        print(getmetatable(obj))
    else
        print(_slv..key..':'..obj..'('..type(obj)..')')
    end
end

-- Unit Events
PushUIAPI._UnitEventList = {}
PushUIAPI._UnitEventsMap = {}
PushUIAPI._UnitFireEvent = function(e, ...)
    local _EM = PushUIAPI._UnitEventsMap
    for i = 1, #_EM[e] do
        local _f = unpack(_EM[e][i])
        _f(...)
    end
end
PushUIAPI._UnitRegisterEvent = function(e, obj, func)
    local _EM = PushUIAPI._UnitEventsMap
    if not _EM[e] then
        _EM[e] = {}
        for _, sys in pairs(PushUIAPI._UnitEventList[e]) do
            PushUIAPI.RegisterEvent(
                sys.sysevent,
                sys.target,
                sys.callback
            )
        end
    end
    _EM[e][#_EM[e] + 1] = {func, obj}
end
PushUIAPI._UnitUnRegisterEvent = function(e, obj)
    local _EM = PushUIAPI._UnitEventsMap
    if not _EM[e] then return end
    for i = 1, #_EM[e] do
        local _f, _o = unpack(_EM[e][i])
        if _o == obj then
            table.remove(_EM[e], i)
            break
        end
    end
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
    lcoal _obj = self.__storage[#self.__storage]
    table.remove(self.__storage)
    return _obj
end
function PushUIAPI.Array:erase(index)
    if #self.__storage < index then return end
    table.remove(self.__storage, index)
end
function PushUIAPI.Array:insert(index, obj)
    if obj == nil then return
    if #self.__storage < index then index = #self.__storage + 1 end
    if index <= 0 then index = 1 end
    table.insert(self.__storage, index, obj)
end
function PushUIAPI.Array:size()
    return #self.__storage end
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
function PushUIAPI.Array:for_each(enumfunc)
    if not enumfunc return end
    local _s = #self.__storage
    for i = 1, _s do
        enumfunc(i, self.__storage[i])
    end
end
function PushUIAPI.Array.new()
    return setmetatable({__storage = {}}, PushUIAPI.Array)
end
setmetatable(PushUIAPI.Array, {__call = function(_, ...) return PushUIAPI.Array.new(...) end})

-- Map
PushUIAPI.Map = {}
PushUIAPI.Map.__index = PushUIAPI.Map
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
function PushUIAPI.Map:clear()
	repeat
		table.remove(self.__storage)
	until #self.__storage == 0
    self.__storage = {}
    self.__size = 0
end
function PushUIAPI.Map:for_each(enumfunc)
    if not enumfunc then return end
	for k, v in pairs(self.__storage) do
		enumfunc(k, v)
	end
end
function PushUIAPI.Map.new()
    return setmetatable({__storage = {}, __size = 0}, PushUIAPI.Map)
end
setmetatable(PushUIAPI.Map, {__call = function(_, ...) return PushUIAPI.Map.new(...) end})

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
    if not _onNew then return _onNew() end
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
    self.__events:object(event):for_each(function(_, act)
        act(event, ...)
    end)
end
