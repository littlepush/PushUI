local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

-- Get target info
PushUIAPI.UnitTarget = {}
PushUIAPI.UnitTarget._onTargetChanged = function(...)
    local _hasTarget = UnitExists("target")
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

-- Get TargetTarget Info
PushUIAPI.UnitTargetTarget = {}
PushUIAPI.UnitTargetTarget._onTargetChanged = function(event, uid)
    local _hasTarget = UnitExists("targettarget")
    PushUIAPI._UnitFireEvent("PushUI_UnitTargetTarget_Event_HasTarget", _hasTarget)
end

PushUIAPI.UnitTargetTarget._onHealthChanged = function(event, uid)
    if uid ~= "targettarget" then return end
    PushUIAPI._UnitFireEvent("PushUI_UnitTargetTarget_Event_ValueChanged")
end

PushUIAPI._UnitEventList["PushUI_UnitTargetTarget_Event_HasTarget"] = {
    {
        sysevent = "UNIT_TARGET",
        target = PushUIAPI.UnitTargetTarget,
        callback = PushUIAPI.UnitTargetTarget._onTargetChanged
    }
}
PushUIAPI._UnitEventList["PushUI_UnitTargetTarget_Event_ValueChanged"] = {
    {
        sysevent = "UNIT_HEALTH",
        target = PushUIAPI.UnitTargetTarget,
        callback = PushUIAPI.UnitTargetTarget._onHealthChanged
    }
}
PushUIAPI.UnitTargetTarget.CanDisplay = function()
    return UnitExists("targettarget")
end
PushUIAPI.UnitTargetTarget.RegisterForDisplayStatus = function(obj, func)
    local _e = "PushUI_UnitTargetTarget_Event_HasTarget"
    PushUIAPI._UnitRegisterEvent(_e, obj, func)
end
PushUIAPI.UnitTargetTarget.UnRegisterForDisplayStatus = function(obj)
    local _e = "PushUI_UnitTargetTarget_Event_HasTarget"
    PushUIAPI._UnitUnRegisterEvent(_e, obj)
end

PushUIAPI.UnitTargetTarget.RegisterForValueChanged = function(obj, func)
    local _e = "PushUI_UnitTargetTarget_Event_ValueChanged"
    PushUIAPI._UnitRegisterEvent(_e, obj, func)
end
PushUIAPI.UnitTargetTarget.UnRegisterForValueChanged = function(obj)
    local _e = "PushUI_UnitTargetTarget_Event_ValueChanged"
    PushUIAPI._UnitUnRegisterEvent(_e, obj)
end

PushUIAPI.UnitTargetTarget.MaxValue = function()
    return UnitHealthMax("targettarget")
end

PushUIAPI.UnitTargetTarget.MinValue = function()
    return 0
end

PushUIAPI.UnitTargetTarget.Value = function()
    return UnitHealth("targettarget")
end

-- Get Focus Info
PushUIAPI.UnitFocus = {}
PushUIAPI.UnitFocus._onTargetChanged = function(...)
    local _hasTarget = UnitExists("focus")
    PushUIAPI._UnitFireEvent("PushUI_UnitFocus_Event_HasTarget", _hasTarget)
end

PushUIAPI.UnitFocus._onHealthChanged = function(event, uid)
    if uid ~= "focus" then return end
    PushUIAPI._UnitFireEvent("PushUI_UnitFocus_Event_ValueChanged")
end

PushUIAPI._UnitEventList["PushUI_UnitFocus_Event_HasTarget"] = {
    {
        sysevent = "PLAYER_FOCUS_CHANGED",
        target = PushUIAPI.UnitFocus,
        callback = PushUIAPI.UnitFocus._onTargetChanged
    }
}
PushUIAPI._UnitEventList["PushUI_UnitFocus_Event_ValueChanged"] = {
    {
        sysevent = "UNIT_HEALTH",
        target = PushUIAPI.UnitFocus,
        callback = PushUIAPI.UnitFocus._onHealthChanged
    }
}
PushUIAPI.UnitFocus.CanDisplay = function()
    return UnitExists("focus")
end
PushUIAPI.UnitFocus.RegisterForDisplayStatus = function(obj, func)
    local _e = "PushUI_UnitFocus_Event_HasTarget"
    PushUIAPI._UnitRegisterEvent(_e, obj, func)
end
PushUIAPI.UnitFocus.UnRegisterForDisplayStatus = function(obj)
    local _e = "PushUI_UnitFocus_Event_HasTarget"
    PushUIAPI._UnitUnRegisterEvent(_e, obj)
end

PushUIAPI.UnitFocus.RegisterForValueChanged = function(obj, func)
    local _e = "PushUI_UnitFocus_Event_ValueChanged"
    PushUIAPI._UnitRegisterEvent(_e, obj, func)
end
PushUIAPI.UnitFocus.UnRegisterForValueChanged = function(obj)
    local _e = "PushUI_UnitFocus_Event_ValueChanged"
    PushUIAPI._UnitUnRegisterEvent(_e, obj)
end

PushUIAPI.UnitFocus.MaxValue = function()
    return UnitHealthMax("focus")
end

PushUIAPI.UnitFocus.MinValue = function()
    return 0
end

PushUIAPI.UnitFocus.Value = function()
    return UnitHealth("focus")
end


