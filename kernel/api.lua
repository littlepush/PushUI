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

-- Get target info
PushUIAPI.UnitTarget = {}
PushUIAPI.UnitTarget.hasTarget = false
PushUIAPI.UnitTarget._onTargetChanged = function(...)
    local _hasTarget = UnitExists("target")
    if _hasTarget == PushUIAPI.UnitTarget.hasTarget then return end
    PushUIAPI.UnitTarget.hasTarget = _hasTarget
    PushUIAPI._UnitFireEvent("PushUI_UnitTarget_Event_HasTarget", _hasTarget)
end

PushUIAPI.UnitTarget._onHealthChanged = function(event, uid)
    if uid ~= "target" then return end
    PushUIAPI._UnitFireEvent("PushUI_UnitTarget_Event_ValueChanged")
end

PushUIAPI._UnitEventList["PushUI_UnitTarget_Event_HasTarget"] = {
    {
        sysevent = "PLAYER_TARGET_CHANGED",
        target = PushUIAPI.UnitTarget,
        callback = PushUIAPI.UnitTarget._onTargetChanged
    }
}
PushUIAPI._UnitEventList["PushUI_UnitTarget_Event_ValueChanged"] = {
    {
        sysevent = "UNIT_HEALTH",
        target = PushUIAPI.UnitTarget,
        callback = PushUIAPI.UnitTarget._onHealthChanged
    }
}
PushUIAPI.UnitTarget.CanDisplay = function()
    return UnitExists("target")
end
PushUIAPI.UnitTarget.RegisterForDisplayStatus = function(obj, func)
    local _e = "PushUI_UnitTarget_Event_HasTarget"
    PushUIAPI._UnitRegisterEvent(_e, obj, func)
end
PushUIAPI.UnitTarget.UnRegisterForDisplayStatus = function(obj)
    local _e = "PushUI_UnitTarget_Event_HasTarget"
    PushUIAPI._UnitUnRegisterEvent(_e, obj)
end

PushUIAPI.UnitTarget.RegisterForValueChanged = function(obj, func)
    local _e = "PushUI_UnitTarget_Event_ValueChanged"
    PushUIAPI._UnitRegisterEvent(_e, obj, func)
end
PushUIAPI.UnitTarget.UnRegisterForValueChanged = function(obj)
    local _e = "PushUI_UnitTarget_Event_ValueChanged"
    PushUIAPI._UnitUnRegisterEvent(_e, obj)
end

PushUIAPI.UnitTarget.MaxValue = function()
    return UnitHealthMax("target")
end

PushUIAPI.UnitTarget.MinValue = function()
    return 0
end

PushUIAPI.UnitTarget.Value = function()
    return UnitHealth("target")
end

-- Exp & Faction
PushUIAPI.UnitExp = {}
PushUIAPI.UnitExp._onLevelUp = function(...)
    if UnitLevel("player") == MAX_PLAYER_LEVEL then
        PushUIAPI._UnitFireEvent("PushUI_UnitExp_Event_ReachMaxLevel", false)
    else
        PushUIAPI._UnitFireEvent("PushUI_UnitExp_Event_ReachMaxLevel", true)
    end
end
PushUIAPI.UnitExp._onXPUpdate = function(...)
    PushUIAPI._UnitFireEvent("PushUI_UnitExp_Event_ExpChanged")
end
PushUIAPI.UnitExp._onExhaustionUpdate = function(...)
    PushUIAPI._UnitFireEvent("PushUI_UnitExp_Event_ExpChanged")
end

PushUIAPI._UnitEventList["PushUI_UnitExp_Event_ReachMaxLevel"] = {
    {
        sysevent = "PLAYER_LEVEL_UP",
        target = PushUIAPI.UnitExp,
        callback = PushUIAPI.UnitExp._onLevelUp
    }
}
PushUIAPI._UnitEventList["PushUI_UnitExp_Event_ExpChanged"] = {
    {
        sysevent = "PLAYER_XP_UPDATE",
        target = PushUIAPI.UnitExp,
        callback = PushUIAPI.UnitExp._onXPUpdate
    },
    {
        sysevent = "UPDATE_EXHAUSTION",
        target = PushUIAPI.UnitExp,
        callback = PushUIAPI.UnitExp._onExhaustionUpdate
    }
}

PushUIAPI.UnitExp.CanDisplay = function()
    return UnitLevel("player") ~= MAX_PLAYER_LEVEL
end
PushUIAPI.UnitExp.RegisterForDisplayStatus = function(obj, func)
    local _e = "PushUI_UnitExp_Event_ReachMaxLevel"
    PushUIAPI._UnitRegisterEvent(_e, obj, func)
end
PushUIAPI.UnitExp.UnRegisterForDisplayStatus = function(obj)
    local _e = "PushUI_UnitExp_Event_ReachMaxLevel"
    PushUIAPI._UnitUnRegisterEvent(_e, obj)
end
PushUIAPI.UnitExp.RegisterForValueChanged = function(obj, func)
    local _e = "PushUI_UnitExp_Event_ExpChanged"
    PushUIAPI._UnitRegisterEvent(_e, obj, func)
end
PushUIAPI.UnitExp.UnRegisterForValueChanged = function(obj)
    local _e = "PushUI_UnitExp_Event_ExpChanged"
    PushUIAPI._UnitUnRegisterEvent(_e, obj)
end
PushUIAPI.UnitExp.MaxValue = function()
    return UnitXPMax("player")
end
PushUIAPI.UnitExp.MinValue = function()
    return 0
end
PushUIAPI.UnitExp.Value = function()
    return UnitXP("player")
end

-- Faction Info
PushUIAPI.WatchedFactionInfo = {}
PushUIAPI.WatchedFactionInfo.name = nil
PushUIAPI.WatchedFactionInfo.rank = nil
PushUIAPI.WatchedFactionInfo.minRep = nil
PushUIAPI.WatchedFactionInfo.maxRep = nil
PushUIAPI.WatchedFactionInfo.value = nil

PushUIAPI.WatchedFactionInfo._onFactionChange = function(...)
    if GetWatchedFactionInfo() then
        local wfi = PushUIAPI.WatchedFactionInfo
        wfi.name, wfi.rank, wfi.minRep, wfi.maxRep, wfi.value = GetWatchedFactionInfo()
        PushUIAPI._UnitFireEvent("PushUI_WatchedFactionInfo_FactionChange", true)
    else
        PushUIAPI._UnitFireEvent("PushUI_WatchedFactionInfo_FactionChange", false)
    end
end

PushUIAPI.WatchedFactionInfo._onFactionUpdated = function(...)
    local wfi = PushUIAPI.WatchedFactionInfo
    wfi.name, wfi.rank, wfi.minRep, wfi.maxRep, wfi.value = GetWatchedFactionInfo()
    PushUIAPI._UnitFireEvent("PushUI_WatchedFactionInfo_FactionUpdated")
end

PushUIAPI._UnitEventList["PushUI_WatchedFactionInfo_FactionChange"] = {
    {
        sysevent = "UPDATE_FACTION",
        target = PushUIAPI.WatchedFactionInfo,
        callback = PushUIAPI.WatchedFactionInfo._onFactionChange
    }
}
PushUIAPI._UnitEventList["PushUI_WatchedFactionInfo_FactionUpdated"] = {
    {
        sysevent = "CHAT_MSG_COMBAT_FACTION_CHANGE",
        target = PushUIAPI.WatchedFactionInfo,
        callback = PushUIAPI.WatchedFactionInfo._onFactionUpdated
    }
}

PushUIAPI.WatchedFactionInfo.CanDisplay = function()
    local wfi = PushUIAPI.WatchedFactionInfo
    if GetWatchedFactionInfo() then
        wfi.name, wfi.rank, wfi.minRep, wfi.maxRep, wfi.value = GetWatchedFactionInfo()
        return true
    end
    return false
end
PushUIAPI.WatchedFactionInfo.RegisterForDisplayStatus = function(obj, func)
    local _e = "PushUI_WatchedFactionInfo_FactionChange"
    PushUIAPI._UnitRegisterEvent(_e, obj, func)
end
PushUIAPI.WatchedFactionInfo.UnRegisterForDisplayStatus = function(obj)
    local _e = "PushUI_WatchedFactionInfo_FactionChange"
    PushUIAPI._UnitUnRegisterEvent(_e, obj)
end
PushUIAPI.WatchedFactionInfo.RegisterForValueChanged = function(obj, func)
    local _e = "PushUI_WatchedFactionInfo_FactionUpdated"
    PushUIAPI._UnitRegisterEvent(_e, obj, func)
end
PushUIAPI.WatchedFactionInfo.UnRegisterForValueChanged = function(obj)
    local _e = "PushUI_WatchedFactionInfo_FactionUpdated"
    PushUIAPI._UnitUnRegisterEvent(_e, obj)
end
PushUIAPI.WatchedFactionInfo.MaxValue = function()
    return PushUIAPI.WatchedFactionInfo.maxRep
end
PushUIAPI.WatchedFactionInfo.MinValue = function()
    return PushUIAPI.WatchedFactionInfo.minRep
end
PushUIAPI.WatchedFactionInfo.Value = function()
    return PushUIAPI.WatchedFactionInfo.value
end
