local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local PushUIFrameUnitFrameHook = PushUIFrames.Frame.Create("PushUIFrameUnitFrameHook", PushUIConfig.UnitFrameHook)
-- Enable Flag
if PushUIConfig.UnitFrameHook.enable == false then
    return
end

-- Hide Player Frame
PlayerFrame:SetScript("OnEvent", nil)
PlayerFrame:Hide()

local anchorTarget = PushUIConfig.UnitFrameHook.anchorTarget or UIParent
local anchorPoint = PushUIConfig.UnitFrameHook.anchorPoint or "CENTER"

-- Create HookBar
if PushUIConfig.UnitFrameHook.HookBar then
    local _c = PushUIConfig.UnitFrameHook.HookBar
    local _hb = CreateFrame("Button", 
        "PushUIFrameUnitFrameHookBar", 
        UIParent, "SecureUnitButtonTemplate")
    PushUIFrameUnitFrameHook.HookBar = _hb

    -- Test
    PushUIStyle.BackgroundSolidFormat(_hb, 0, 0, 0, 0, 0, 0, 0, 0)

    local _pos = _c.position or {x = -325, y = -95}
    local _size = _c.size or {w = 200, h = 40}
    _hb:SetWidth(_size.w)
    _hb:SetHeight(_size.h)
    _hb:SetPoint(anchorPoint, anchorTarget, anchorPoint, _pos.x, _pos.y)

    _hb.unit = "player"
    _hb:SetAttribute("unit", _hb.unit)
    _hb:SetAttribute("type", "target")
    _hb:EnableMouse(true)
    _hb:SetScript("OnMouseDown", function(self, button)
            if button == "RightButton" then
                ToggleDropDownMenu(1, nil, PlayerFrameDropDown, _hb, 0, 0)
            end
        end
    )
end

-- Name of the player
if PushUIConfig.UnitFrameHook.Name and PushUIConfig.UnitFrameHook.Name.display then
    local _c = PushUIConfig.UnitFrameHook.Name
    local _nf = CreateFrame("Frame", "PushUIFrameUnitFrameNameFrame", PushUIFrameUnitFrameHook.HookBar)
    PushUIFrameUnitFrameHook.NameFrame = _nf

    local _fs = _nf:CreateFontString()

    local _fn = _c.fontName or "Fonts\\FRIZQT__.TTF"
    local _fsize = _c.size or 14
    local _foutline = _c.outline or "OUTLINE"

    _fs:SetFont(_fn, _fsize, _foutline)

    -- align
    local _align = _c.aling or "CENTER"
    _fs:SetJustifyH(_align)

    _fs:SetText(UnitName("player"))
    local _w = _fs:GetStringWidth()
    local _h = _fs:GetStringHeight()
    _nf:SetWidth(_w)
    _nf:SetHeight(_h)

    local _a = _c.anchorPoint or "TOPRIGHT"
    local _pos = _c.position or {x = PushUISize.padding, y = PushUISize.padding}
    _nf:SetPoint(_a, PushUIFrameUnitFrameHook.HookBar, "TOPLEFT", _pos.x, _pos.y)
    _fs:SetAllPoints(_nf)

    _fs.OnValueChange = function()
        _fs:SetTextColor(unpack(_c.color(
                PushUIAPI.UnitPlayer.Value(),
                PushUIAPI.UnitPlayer.MaxValue(),
                PushUIAPI.UnitPlayer.MinValue(),
                UnitClass("player")
            )))
    end
    PushUIAPI.UnitPlayer.RegisterForValueChanged(_fs, _fs.OnValueChange)

    -- Init Color
    _fs.OnValueChange()
end

if PushUIConfig.UnitFrameHook.LifeBar and PushUIConfig.UnitFrameHook.LifeBar.display then
    local _c = PushUIConfig.UnitFrameHook.LifeBar
    _c.targets = {
        PushUIAPI.UnitPlayer
    }
    local _orientation = _c.orientation or "HORIZONTAL"
    local _lb = PushUIFrames.ProgressBar.Create(nil, PushUIFrameUnitFrameHook.HookBar, _c, _orientation)
    PushUIFrameUnitFrameHook.LifeBarFrame = _lb

    -- Set Background
    if _c.background then
        _c.background(_lb)
    end

    local _a = _c.anchorPoint or "TOPRIGHT"
    local _pos = _c.position or {x = 0, y = -35}
    local _size = _c.size or {w = 200, h = 5}

    _lb:SetWidth(_size.w)
    _lb:SetHeight(_size.h)
    _lb:SetPoint(_a, PushUIFrameUnitFrameHook.HookBar, "TOPLEFT", _pos.x, _pos.y)
end

if PushUIConfig.UnitFrameHook.Percentage and PushUIConfig.UnitFrameHook.Percentage.display then
    local _c = PushUIConfig.UnitFrameHook.Percentage
    local _pf = CreateFrame("Frame", "PushUIFrameUnitFramePercentageFrame", PushUIFrameUnitFrameHook.HookBar)
    PushUIFrameUnitFrameHook.PercentageFrame = _pf

    local _fs = _pf:CreateFontString()

    local _fn = _c.fontName or "Fonts\\bLE100D.TTF"
    local _fsize = _c.size or 14
    local _foutline = _c.outline or "OUTLINE"

    _fs:SetFont(_fn, _fsize, _foutline)

    -- align
    local _align = _c.aling or "CENTER"
    _fs:SetJustifyH(_align)

    local _afk = UnitIsAFK("player")    
    local _pv = PushUIAPI.UnitPlayer.Value() / PushUIAPI.UnitPlayer.MaxValue() * 100
    if _afk then
        _fs:SetText("<AFK>"..("%.1f"):format(_pv).."%")
    else
        _fs:SetText(("%.1f"):format(_pv).."%")
    end

    local _w = _fs:GetStringWidth()
    local _h = _fs:GetStringHeight()
    _pf:SetWidth(_w)
    _pf:SetHeight(_h)

    local _a = _c.anchorPoint or "TOPRIGHT"
    local _pos = _c.position or {x = PushUISize.padding, y = PushUISize.padding}
    _pf:SetPoint(_a, PushUIFrameUnitFrameHook.HookBar, "TOPLEFT", _pos.x, _pos.y)
    _fs:SetAllPoints(_pf)

    _fs.OnValueChange = function()
        local _afk = UnitIsAFK("player")    
        local _pv = PushUIAPI.UnitPlayer.Value() / PushUIAPI.UnitPlayer.MaxValue() * 100
        if _afk then
            _fs:SetText("<AFK>"..("%.1f"):format(_pv).."%")
        else
            _fs:SetText(("%.1f"):format(_pv).."%")
        end
        _fs:SetTextColor(unpack(_c.color(
                PushUIAPI.UnitPlayer.Value(),
                PushUIAPI.UnitPlayer.MaxValue(),
                PushUIAPI.UnitPlayer.MinValue(),
                UnitClass("player")
            )))
        local _w = _fs:GetStringWidth()
        _pf:SetWidth(_w)
    end
    PushUIAPI.UnitPlayer.RegisterForValueChanged(_fs, _fs.OnValueChange)

    -- Init the value
    _fs.OnValueChange()
end

if PushUIConfig.UnitFrameHook.HealthValue and PushUIConfig.UnitFrameHook.HealthValue.display then
    local _c = PushUIConfig.UnitFrameHook.HealthValue
    local _hf = CreateFrame("Frame", "PushUIFrameUnitFrameHealthValueFrame", PushUIFrameUnitFrameHook.HookBar)
    PushUIFrameUnitFrameHook.HealthValueFrame = _hf

    local _fs = _hf:CreateFontString()

    local _fn = _c.fontName or "Fonts\\FRIZQT__.TTF"
    local _fsize = _c.size or 14
    local _foutline = _c.outline or "OUTLINE"

    _fs:SetFont(_fn, _fsize, _foutline)

    -- align
    local _align = _c.aling or "CENTER"
    _fs:SetJustifyH(_align)

    _fs:SetText(UnitHealth("player"))
    local _w = _fs:GetStringWidth()
    local _h = _fs:GetStringHeight()
    _hf:SetWidth(_w)
    _hf:SetHeight(_h)

    local _a = _c.anchorPoint or "TOPRIGHT"
    local _pos = _c.position or {x = PushUISize.padding, y = PushUISize.padding}
    _hf:SetPoint(_a, PushUIFrameUnitFrameHook.HookBar, "TOPLEFT", _pos.x, _pos.y)
    _fs:SetAllPoints(_hf)

    _fs.OnValueChange = function()
        _fs:SetText(UnitHealth("player"))
        _fs:SetTextColor(unpack(_c.color(
                PushUIAPI.UnitPlayer.Value(),
                PushUIAPI.UnitPlayer.MaxValue(),
                PushUIAPI.UnitPlayer.MinValue(),
                UnitClass("player")
            )))
    end
    PushUIAPI.UnitPlayer.RegisterForValueChanged(_fs, _fs.OnValueChange)

    -- Init Color
    _fs.OnValueChange()
end

-- PushUIConfig.UnitFrameHook.HealthValue = {
--     display = true,
--     size = 20,
--     color = function(value, min, max, class) = {
--         return 1, 1, 1, 1
--     },
--     outline = "",   -- "OUTLINE"
--     align = "right",
--     position = { x = -300, y = -102 }
-- }
-- PushUIConfig.UnitFrameHook.Auras = {
--     display = true
--     -- pending...
-- }
-- PushUIConfig.UnitFrameHook.PowerBar = {
--     display = true
--     -- pending...
-- }
-- PushUIConfig.UnitFrameHook.ResourceBar = {
--     display = true
--     -- pending...
-- }
