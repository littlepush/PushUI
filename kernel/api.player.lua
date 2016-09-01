local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

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

-- Unit Info
PushUIAPI.UnitPlayer = {}

PushUIAPI.UnitPlayer._onHealthChanged = function(event, uid)
    if uid ~= "player" then return end
    PushUIAPI._UnitFireEvent("PushUI_UnitPlayer_Event_ValueChanged")
end

PushUIAPI._UnitEventList["PushUI_UnitPlayer_Event_ValueChanged"] = {
    {
        sysevent = "UNIT_HEALTH",
        target = PushUIAPI.UnitPlayer,
        callback = PushUIAPI.UnitPlayer._onHealthChanged
    }
}
PushUIAPI.UnitPlayer.CanDisplay = function()
    return true
end
PushUIAPI.UnitPlayer.RegisterForDisplayStatus = function(obj, func)
    -- Nothing
end
PushUIAPI.UnitPlayer.UnRegisterForDisplayStatus = function(obj)
    -- Nothing
end

PushUIAPI.UnitPlayer.RegisterForValueChanged = function(obj, func)
    local _e = "PushUI_UnitPlayer_Event_ValueChanged"
    PushUIAPI._UnitRegisterEvent(_e, obj, func)
end
PushUIAPI.UnitPlayer.UnRegisterForValueChanged = function(obj)
    local _e = "PushUI_UnitPlayer_Event_ValueChanged"
    PushUIAPI._UnitUnRegisterEvent(_e, obj)
end

PushUIAPI.UnitPlayer.MaxValue = function()
    return UnitHealthMax("player")
end

PushUIAPI.UnitPlayer.MinValue = function()
    return 0
end

PushUIAPI.UnitPlayer.Value = function()
    return UnitHealth("player")
end

-- Artifact 
PushUIAPI.Artifact = {}
PushUIAPI.Artifact._value = 0
PushUIAPI.Artifact._maxValue = 0
PushUIAPI.Artifact._generateArtifactInfo = function()
    local _, _, _, _, totalXP, pointsSpent, _, _, _, _, _, _ = C_ArtifactUI.GetEquippedArtifactInfo();
    local numPoints = 0;
    local xpForNextPoint = C_ArtifactUI.GetCostForPointAtRank(pointsSpent);
    while totalXP >= xpForNextPoint and xpForNextPoint > 0 do
        totalXP = totalXP - xpForNextPoint;

        pointsSpent = pointsSpent + 1;
        numPoints = numPoints + 1;

        xpForNextPoint = C_ArtifactUI.GetCostForPointAtRank(pointsSpent);
    end
    PushUIAPI.Artifact._value = totalXP
    PushUIAPI.Artifact._maxValue = xpForNextPoint
    --return numPoints, totalXP, xpForNextPoint;
end
PushUIAPI.Artifact._onArtifactUpdate = function()
    PushUIAPI.Artifact._generateArtifactInfo()
    PushUIAPI._UnitFireEvent("PushUI_Artifact_Event_AllChange")
end
PushUIAPI._UnitEventList["PushUI_Artifact_Event_AllChange"] = {
    {
        sysevent = "ARTIFACT_XP_UPDATE",
        target = PushUIAPI.Artifact,
        callback = PushUIAPI.Artifact._onArtifactUpdate
    }
}

PushUIAPI.Artifact.CanDisplay = function()
    if HasArtifactEquipped() then
        PushUIAPI.Artifact._generateArtifactInfo()
        return true
    else
        return false
    end
end
PushUIAPI.Artifact.RegisterForDisplayStatus = function(obj, func)
    local _e = "PushUI_Artifact_Event_AllChange"
    PushUIAPI._UnitRegisterEvent(_e, obj, func)
end
PushUIAPI.Artifact.UnRegisterForDisplayStatus = function(obj)
    local _e = "PushUI_Artifact_Event_AllChange"
    PushUIAPI._UnitUnRegisterEvent(_e, obj)
end
PushUIAPI.Artifact.RegisterForValueChanged = function(obj, func)
    local _e = "PushUI_Artifact_Event_AllChange"
    PushUIAPI._UnitRegisterEvent(_e, obj, func)
end
PushUIAPI.Artifact.UnRegisterForValueChanged = function(obj)
    local _e = "PushUI_Artifact_Event_AllChange"
    PushUIAPI._UnitUnRegisterEvent(_e, obj)
end
PushUIAPI.Artifact.MaxValue = function()
    return PushUIAPI.Artifact._maxValue
end
PushUIAPI.Artifact.MinValue = function()
    return 0
end
PushUIAPI.Artifact.Value = function()
    return PushUIAPI.Artifact._value
end

-- Get Pet Info
PushUIAPI.UnitPet = {}
PushUIAPI.UnitPet._onTargetChanged = function(event, unitid)
    if unitid ~= "player" then return end
    local _hasTarget = UnitExists("pet")
    PushUIAPI._UnitFireEvent("PushUI_UnitPet_Event_HasTarget", _hasTarget)
end

PushUIAPI.UnitPet._onHealthChanged = function(event, uid)
    if uid ~= "pet" then return end
    PushUIAPI._UnitFireEvent("PushUI_UnitPet_Event_ValueChanged")
end

PushUIAPI._UnitEventList["PushUI_UnitPet_Event_HasTarget"] = {
    {
        sysevent = "UNIT_PET",
        target = PushUIAPI.UnitPet,
        callback = PushUIAPI.UnitPet._onTargetChanged
    }
}
PushUIAPI._UnitEventList["PushUI_UnitPet_Event_ValueChanged"] = {
    {
        sysevent = "UNIT_HEALTH",
        target = PushUIAPI.UnitPet,
        callback = PushUIAPI.UnitPet._onHealthChanged
    }
}
PushUIAPI.UnitPet.CanDisplay = function()
    return UnitExists("pet")
end
PushUIAPI.UnitPet.RegisterForDisplayStatus = function(obj, func)
    local _e = "PushUI_UnitPet_Event_HasTarget"
    PushUIAPI._UnitRegisterEvent(_e, obj, func)
end
PushUIAPI.UnitPet.UnRegisterForDisplayStatus = function(obj)
    local _e = "PushUI_UnitPet_Event_HasTarget"
    PushUIAPI._UnitUnRegisterEvent(_e, obj)
end

PushUIAPI.UnitPet.RegisterForValueChanged = function(obj, func)
    local _e = "PushUI_UnitPet_Event_ValueChanged"
    PushUIAPI._UnitRegisterEvent(_e, obj, func)
end
PushUIAPI.UnitPet.UnRegisterForValueChanged = function(obj)
    local _e = "PushUI_UnitPet_Event_ValueChanged"
    PushUIAPI._UnitUnRegisterEvent(_e, obj)
end

PushUIAPI.UnitPet.MaxValue = function()
    return UnitHealthMax("pet")
end

PushUIAPI.UnitPet.MinValue = function()
    return 0
end

PushUIAPI.UnitPet.Value = function()
    return UnitHealth("pet")
end
