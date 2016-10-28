local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

-- Get target info
PushUIAPI.TargetHP = PushUIAPI.Assets("PLAYER_TARGET_CHANGED", "UNIT_HEALTH")
-- When the player log into the game, no target will be selected.
PushUIAPI.TargetHP:set_candisplay(false)
function PushUIAPI.TargetHP:PLAYER_TARGET_CHANGED()
    local _hasTarget = UnitExists("target")
    self:set_candisplay(_hasTarget)
    if _hasTarget then
        self:set_current_value({hp = UnitHealth("target"), max_hp = UnitHealthMax("target")})
    end
end
function PushUIAPI.TargetHP:UNIT_HEALTH(unit_id)
    if not self:can_display() and unit_id ~= "target" then return end
    if not UnitName("target") then
        self:set_candisplay(false)
        return
    end
    self:set_current_value({hp = UnitHealth("target"), max_hp = UnitHealthMax("target")})
end
-- PushUIAPI.TargetHP._refreshTimer = PushUIAPI.Timer(1, nil, function(...)
--     if false == UnitExists("target") then
--         PushUIAPI.TargetHP:set_candisplay(false)
--         PushUIAPI.TargetHP:displayStatusChanged()
--     end
-- end)
-- PushUIAPI.TargetHP._refreshTimer:start()

-- Get TargetTarget Info
PushUIAPI.TargetTargetHP = PushUIAPI.Assets("UNIT_TARGET", "UNIT_HEALTH")
-- Default no target, so no target target
PushUIAPI.TargetTargetHP:set_candisplay(false)
PushUIAPI.TargetHP:add_displayChanged("PUSHUIAPI_TARGETTARGET_HP", function(_, can)
    PushUIAPI.TargetTargetHP:on_targetDisplayChanged(can)
end)
function PushUIAPI.TargetTargetHP:on_targetDisplayChanged(can)
    if not can then
        self:set_candisplay(false)
        return
    end
    local _tt_hasTarget = UnitExists("targettarget")
    self:set_candisplay(_tt_hasTarget)
    if _tt_hasTarget then
        self:set_current_value({hp = UnitHealth("targettarget"), max_hp = UnitHealthMax("targettarget")})
    end
end
function PushUIAPI.TargetTargetHP:UNIT_TARGET(unit_id)
    local _tt_hasTarget = UnitExists("targettarget")
    self:set_candisplay(_tt_hasTarget)
    if _tt_hasTarget then
        self:set_current_value({hp = UnitHealth("targettarget"), max_hp = UnitHealthMax("targettarget")})
    end
end
function PushUIAPI.TargetTargetHP:UNIT_HEALTH(unit_id)
    if not self:can_display() or unit_id ~= "targettarget" then return end
    self:set_current_value({hp = UnitHealth("targettarget"), max_hp = UnitHealthMax("targettarget")})
end

-- Get Focus Info
PushUIAPI.FocusHP = PushUIAPI.Assets("PLAYER_FOCUS_CHANGED", "UNIT_HEALTH")
-- Default has no focus
PushUIAPI.FocusHP:set_candisplay(false)
function PushUIAPI.FocusHP:PLAYER_FOCUS_CHANGED()
    local _f_hasTarget = UnitExists("focus")
    self:set_candisplay(_f_hasTarget)
    if _f_hasTarget then
        self:set_current_value({hp = UnitHealth("focus"), max_hp = UnitHealthMax("focus")})
    end
end
function PushUIAPI.FocusHP:UNIT_HEALTH(unit_id)
    if not self:can_display() or unit_id ~= "focus" then return end
    self:set_current_value({hp = UnitHealth("focus"), max_hp = UnitHealthMax("focus")})
end

-- by Push Chen
-- twitter: @littlepush
