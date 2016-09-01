local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIAPI.PlayerAuras = {}
PushUIAPI.PlayerAuras._auras = {}
PushUIAPI.PlayerAuras._auraCount = 0
PushUIAPI.PlayerAuras._gain = function()
    local _acount = #PushUIAPI.PlayerAuras._auras

    -- Clear old auras
    for i = 1, _acount do PushUIAPI.PlayerAuras._auras[i] = nil end

    local i = 1
    repeat
        local _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11 = UnitBuff("player", i)
        if not _1 then break end
        PushUIAPI.PlayerAuras._auras[i] = {
            name = _1,
            rank = _2,
            icon = _3,
            count = _4,
            debuffType = _5,
            duration = _6,
            expirationTime = _7,
            unitCaster = _8,
            isStealable = _9,
            shouldConsolidate = _10,
            spellId = _11,
            isbuff = true
        }
        i = i + 1
    until false
    _acount = #PushUIAPI.PlayerAuras._auras
    i = 1
    repeat
        local _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11 = UnitDebuff("player", i)
        if not _1 then break end
        PushUIAPI.PlayerAuras._auras[_acount + i] = {
            name = _1,
            rank = _2,
            icon = _3,
            count = _4,
            debuffType = _5,
            duration = _6,
            expirationTime = _7,
            unitCaster = _8,
            isStealable = _9,
            shouldConsolidate = _10,
            spellId = _11,
            isbuff = false,
            pbValue = function()
                return (expirationTime - GetTime())
            end
        }
        i = i + 1
    until false
    PushUIAPI.PlayerAuras._auraCount = #PushUIAPI.PlayerAuras._auras
end

PushUIAPI.PlayerAuras._onAuraChanged = function(event, uid)
    if uid ~= "player" then return end
    PushUIAPI.PlayerAuras._gain()
    PushUIAPI._UnitFireEvent("PushUI_PlayerAuras_Event_ValueChanged")
end

PushUIAPI._UnitEventList["PushUI_PlayerAuras_Event_ValueChanged"] = {
    {
        sysevent = "UNIT_AURA",
        target = PushUIAPI.PlayerAuras,
        callback = PushUIAPI.PlayerAuras._onAuraChanged
    }
}

PushUIAPI.PlayerAuras.CanDisplay = function()
    PushUIAPI.PlayerAuras._gain()
    return true
end

PushUIAPI.PlayerAuras.RegisterForDisplayStatus = function(obj, func)
    -- Nothing
end
PushUIAPI.PlayerAuras.UnRegisterForDisplayStatus = function(obj)
    -- Nothing
end

PushUIAPI.PlayerAuras.RegisterForValueChanged = function(obj, func)
    if nil == obj or nil == func then return end
    local _e = "PushUI_PlayerAuras_Event_ValueChanged"
    PushUIAPI._UnitRegisterEvent(_e, obj, func)
end
PushUIAPI.PlayerAuras.UnRegisterForValueChanged = function(obj)
    if nil == obj or nil == func then return end
    local _e = "PushUI_PlayerAuras_Event_ValueChanged"
    PushUIAPI._UnitUnRegisterEvent(_e, obj)
end

PushUIAPI.PlayerAuras.MaxValue = function()
    return PushUIAPI.PlayerAuras._auraCount
end

PushUIAPI.PlayerAuras.Count = function()
    return PushUIAPI.PlayerAuras._auraCount
end

PushUIAPI.PlayerAuras.MinValue = function()
    return 0
end

PushUIAPI.PlayerAuras.Value = function(index)
    return PushUIAPI.PlayerAuras._auras[index]
end

---------------------------------------------------------------------------------------------

-- Target Auras
PushUIAPI.TargetAuras = {}
PushUIAPI.TargetAuras.DisplayPlayerOnly = true
PushUIAPI.TargetAuras._playerId = "player"
PushUIAPI.TargetAuras._auras = {}
PushUIAPI.TargetAuras._auraCount = 0
PushUIAPI.TargetAuras._gain = function()
    local _acount = #PushUIAPI.TargetAuras._auras

    -- Clear old auras
    for i = 1, _acount do PushUIAPI.TargetAuras._auras[i] = nil end

    local _hasTarget = UnitExists("target")
    if not _hasTarget then return end

    local i = 1
    local skipped = 0
    repeat
        local _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11 = UnitBuff("target", i)
        if not _1 then break end
        local _validate = true
        if PushUIAPI.TargetAuras.DisplayPlayerOnly then
            if _8 ~= PushUIAPI.TargetAuras._playerId then
                _validate = false
                skipped = skipped + 1
            end
        end
        if _validate then
            PushUIAPI.TargetAuras._auras[i - skipped] = {
                name = _1,
                rank = _2,
                icon = _3,
                count = _4,
                debuffType = _5,
                duration = _6,
                expirationTime = _7,
                unitCaster = _8,
                isStealable = _9,
                shouldConsolidate = _10,
                spellId = _11,
                isbuff = true
            }
        end
        i = i + 1
    until false
    _acount = #PushUIAPI.TargetAuras._auras
    i = 1
    skipped = 0
    repeat
        local _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11 = UnitDebuff("target", i)
        if not _1 then break end
        local _validate = true
        if PushUIAPI.TargetAuras.DisplayPlayerOnly then
            if _8 ~= PushUIAPI.TargetAuras._playerId then
                _validate = false
                skipped = skipped + 1
            end
        end
        if _validate then
            PushUIAPI.TargetAuras._auras[_acount + i - skipped] = {
                name = _1,
                rank = _2,
                icon = _3,
                count = _4,
                debuffType = _5,
                duration = _6,
                expirationTime = _7,
                unitCaster = _8,
                isStealable = _9,
                shouldConsolidate = _10,
                spellId = _11,
                isbuff = false,
                pbValue = function()
                    return (expirationTime - GetTime())
                end
            }
        end
        i = i + 1
    until false
    PushUIAPI.TargetAuras._auraCount = #PushUIAPI.TargetAuras._auras
end

PushUIAPI.TargetAuras._onAuraChanged = function(event, uid)
    if uid ~= "target" then return end
    PushUIAPI.TargetAuras._gain()
    PushUIAPI._UnitFireEvent("PushUI_TargetAuras_Event_ValueChanged")
end

PushUIAPI._UnitEventList["PushUI_TargetAuras_Event_ValueChanged"] = {
    {
        sysevent = "UNIT_AURA",
        target = PushUIAPI.TargetAuras,
        callback = PushUIAPI.TargetAuras._onAuraChanged
    }
}

PushUIAPI.TargetAuras.CanDisplay = function()
    PushUIAPI.TargetAuras._gain()
    return true
end

PushUIAPI.TargetAuras.RegisterForDisplayStatus = function(obj, func)
    PushUIAPI.UnitTarget.RegisterForDisplayStatus(obj, func)
end
PushUIAPI.TargetAuras.UnRegisterForDisplayStatus = function(obj)
    PushUIAPI.UnitTarget.UnRegisterForDisplayStatus(obj, func)
end

PushUIAPI.TargetAuras.RegisterForValueChanged = function(obj, func)
    if nil == obj or nil == func then return end
    local _e = "PushUI_TargetAuras_Event_ValueChanged"
    PushUIAPI._UnitRegisterEvent(_e, obj, func)
end
PushUIAPI.TargetAuras.UnRegisterForValueChanged = function(obj)
    if nil == obj or nil == func then return end
    local _e = "PushUI_TargetAuras_Event_ValueChanged"
    PushUIAPI._UnitUnRegisterEvent(_e, obj)
end

PushUIAPI.TargetAuras.MaxValue = function()
    return PushUIAPI.TargetAuras._auraCount
end

PushUIAPI.TargetAuras.Count = function()
    return PushUIAPI.TargetAuras._auraCount
end

PushUIAPI.TargetAuras.MinValue = function()
    return 0
end

PushUIAPI.TargetAuras.Value = function(index)
    return PushUIAPI.TargetAuras._auras[index]
end
