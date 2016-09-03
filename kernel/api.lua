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
PushUIAPI.Stack._push = function(stack, obj)
    if stack._storage == nil then return end
    if obj == nil then return end
    stack._storage[#stack._storage + 1] = obj
end
PushUIAPI.Stack._pop = function(stack)
    if stack._storage == nil then return end
    if #stack._storage == 0 then return end
    stack._storage[#stack._storage] = nil
end
PushUIAPI.Stack._top = function(stack)
    if stack._storage == nil then return nil end
    if #stack._storage == 0 then return nil end
    return stack._storage[#stack._storage]
end
PushUIAPI.Stack._size = function(stack)
    if stack._storage == nil then return 0 end
    return #stack._storage
end
PushUIAPI.Stack._clear = function(stack)
    if stack._storage == nil then return end
    local _s = #stack._storage
    for i = 1, _s do stack._storage[i] = nil end
end
PushUIAPI.Stack.New = function()
    local _stack = {}
    _stack._storage = {}
    _stack.Push = function(obj) PushUIAPI.Stack._push(_stack, obj) end
    _stack.Pop = function() PushUIAPI.Stack._pop(_stack) end
    _stack.Top = function() return PushUIAPI.Stack._top(_stack) end
    _stack.Size = function() return PushUIAPI.Stack._size(_stack) end
    _stack.Clear = function() PushUIAPI.Stack._clear(_stack) end
    return _stack
end
PushUIAPI.Stack.Delete = function(stack) _stack.Clear(); stack = nil end

