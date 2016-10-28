local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIAPI.Aura = PushUIAPI.inhiert()
function PushUIAPI.Aura:c_str(target, is_buff, index)
    if not target or nil == is_buff or nil == index then return nil end
    local _func = nil
    if is_buff then _func = UnitBuff else _func = UnitDebuff end
    local _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11 = _func(target, index)
    self._validate = true
    if not _1 then
        self._validate = false
        return
    end
    self.name = _1
    self.rank = _2
    self.icon = _3
    self.count = _4
    self.debuffType = _5
    self.duration = _6
    self.expirationTime = _7
    self.unitCaster = _8
    self.isStealable = _9
    self.shouldConsolidate = _10
    self.spellId = _11
    self.isbuff = is_buff
end
function PushUIAPI.Aura:isValidate() return self._validate end

local function __pui_gainAuras(target, assets)
    assets._buff:clear()
    local i = 1
    repeat 
        local _a = PushUIAPI.Aura(target, true, i)
        if not _a:isValidate() then break end
        assets._buff:push_back(_a)
        i = i + 1
    until false

    assets._debuff:clear()
    i = 1
    repeat 
        local _a = PushUIAPI.Aura(target, false, i)
        if not _a:isValidate() then break end
        assets._debuff:push_back(_a)
        i = i + 1
    until false

    assets:set_current_value({buff = assets._buff, debuff = assets._debuff})
end

-- Auras For Player
PushUIAPI.PlayerAuras = PushUIAPI.Assets("UNIT_AURA")
PushUIAPI.PlayerAuras._buff = PushUIAPI.Array()
PushUIAPI.PlayerAuras._debuff = PushUIAPI.Array()
PushUIAPI.PlayerAuras:set_candisplay(true)  -- Always can display, but may be empty list
function PushUIAPI.PlayerAuras:UNIT_AURA(unit_id)
    if unit_id ~= "player" then return end
    __pui_gainAuras("player", self)
end
-- Initialize
__pui_gainAuras("player", PushUIAPI.PlayerAuras)
function PushUIAPI.PlayerAuras:force_refresh()
    __pui_gainAuras("player", PushUIAPI.PlayerAuras)
end

-- Auras For Target
PushUIAPI.TargetAuras = PushUIAPI.Assets("UNIT_AURA")
PushUIAPI.TargetAuras._buff = PushUIAPI.Array()
PushUIAPI.TargetAuras._debuff = PushUIAPI.Array()
PushUIAPI.TargetAuras._lastTargetName = ""
-- Default is false
PushUIAPI.TargetAuras:set_candisplay(false)
PushUIAPI.TargetHP:add_displayChanged("PUSHUIAPI_TARGET_AURAS", function(_, can)
    PushUIAPI.TargetAuras:set_candisplay(can)
    if not can then return end
    __pui_gainAuras("target", PushUIAPI.TargetAuras)
end)
PushUIAPI.TargetHP:add_valueChanged("PUSHUIAPI_TARGET_AURAS", function(_, value)
    local _name = UnitName("target")
    if _name == PushUIAPI.TargetAuras._lastTargetName then return end
    PushUIAPI.TargetAuras._lastTargetName = _name
    __pui_gainAuras("target", PushUIAPI.TargetAuras)
end)
function PushUIAPI.TargetAuras:UNIT_AURA(unit_id)
    if not self:can_display() or unit_id ~= "target" then return end
    __pui_gainAuras("target", self)
end

-- by Push Chen
-- twitter: @littlepush
