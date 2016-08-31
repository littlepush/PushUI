local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local PushUIFrameTargetFrameHook = PushUIFrames.Frame.Create("PushUIFrameTargetFrameHook", PushUIConfig.TargetFrameHook)
-- Enable Flag
if PushUIConfig.TargetFrameHook.enable == false then
    return
end

-- Hide Player Frame
PlayerFrame:SetScript("OnEvent", nil)
PlayerFrame:Hide()

local anchorTarget = PushUIConfig.TargetFrameHook.anchorTarget or UIParent
local anchorPoint = PushUIConfig.TargetFrameHook.anchorPoint or "CENTER"

-- Create HookBar
PushUIFrameTargetFrameHook.InitHookBar = function()
    if PushUIConfig.TargetFrameHook.HookBar then
        local _c = PushUIConfig.TargetFrameHook.HookBar
        local _hb = CreateFrame("Button", 
            "PushUIFrameTargetFrameHookBar", 
            UIParent, "SecureUnitButtonTemplate")
        PushUIFrameTargetFrameHook.HookBar = _hb

        -- Test
        PushUIStyle.BackgroundSolidFormat(_hb, 0, 0, 0, 0, 0, 0, 0, 0)

        local _pos = _c.position or {x = -325, y = -95}
        local _size = _c.size or {w = 200, h = 40}
        _hb:SetWidth(_size.w)
        _hb:SetHeight(_size.h)
        _hb:SetPoint(anchorPoint, anchorTarget, anchorPoint, _pos.x, _pos.y)

        _hb.unit = "target"
        _hb:SetAttribute("unit", _hb.unit)
        _hb:SetAttribute("type", "target")
        _hb:EnableMouse(true)
        _hb:SetScript("OnMouseDown", function(self, button)
                if button == "RightButton" then
                    ToggleDropDownMenu(1, nil, TargetFrameDropDown, _hb, 0, 0)
                end
            end
        )
    end
end

-- Name of the target
PushUIFrameTargetFrameHook.ForceUpdateName = nil
PushUIFrameTargetFrameHook.InitName = function()
    if PushUIConfig.TargetFrameHook.Name and PushUIConfig.TargetFrameHook.Name.display then
        local _c = PushUIConfig.TargetFrameHook.Name
        local _nf = CreateFrame("Frame", "PushUIFrameTargetFrameNameFrame", PushUIFrameTargetFrameHook.HookBar)
        PushUIFrameTargetFrameHook.NameFrame = _nf

        local _fs = _nf:CreateFontString()

        local _fn = _c.fontName or "Fonts\\FRIZQT__.TTF"
        local _fsize = _c.size or 14
        local _foutline = _c.outline or "OUTLINE"

        _fs:SetFont(_fn, _fsize, _foutline)

        -- align
        local _align = _c.align or "CENTER"
        _fs:SetJustifyH(_align)

        _fs:SetText(UnitName("target"))
        _nf:SetWidth(_nf:GetParent():GetWidth())
        _nf:SetHeight(_fsize)

        local _a = _c.anchorPoint or "TOPLEFT"
        local _pos = _c.position or {x = PushUISize.padding, y = PushUISize.padding}
        _nf:SetPoint(_a, PushUIFrameTargetFrameHook.HookBar, "TOPRIGHT", _pos.x, _pos.y)
        _fs:SetAllPoints(_nf)

        _fs.OnValueChange = function()
            _fs:SetText(UnitName("target"))
            _fs:SetTextColor(unpack(_c.color(
                    PushUIAPI.UnitTarget.Value(),
                    PushUIAPI.UnitTarget.MaxValue(),
                    PushUIAPI.UnitTarget.MinValue(),
                    UnitClass("target")
                )))
        end
        PushUIAPI.UnitTarget.RegisterForValueChanged(_fs, _fs.OnValueChange)

        -- Init Color
        _fs.OnValueChange()
        PushUIFrameTargetFrameHook.ForceUpdateName = _fs.OnValueChange
    end
end

PushUIFrameTargetFrameHook.ForceUpdateLifeBar = nil
PushUIFrameTargetFrameHook.InitLifeBar = function()
    if PushUIConfig.TargetFrameHook.LifeBar and PushUIConfig.TargetFrameHook.LifeBar.display then
        local _c = PushUIConfig.TargetFrameHook.LifeBar
        _c.targets = {
            PushUIAPI.UnitTarget
        }
        local _orientation = _c.orientation or "HORIZONTAL"
        local _lb = PushUIFrames.ProgressBar.Create(nil, PushUIFrameTargetFrameHook.HookBar, _c, _orientation)
        PushUIFrameTargetFrameHook.LifeBarFrame = _lb
        _lb:SetReverseFill()

        -- Set Background
        if _c.background then
            _c.background(_lb)
        end

        local _a = _c.anchorPoint or "TOPRIGHT"
        local _pos = _c.position or {x = 0, y = -35}
        local _size = _c.size or {w = 200, h = 5}

        _lb:SetWidth(_size.w)
        _lb:SetHeight(_size.h)
        _lb:SetPoint(_a, PushUIFrameTargetFrameHook.HookBar, "TOPRIGHT", _pos.x, _pos.y)
        PushUIFrameTargetFrameHook.ForceUpdateLifeBar = function()
            PushUIFrameTargetFrameHook.LifeBarFrame.OnDisplayStatusChanged(PushUIAPI.UnitTarget, true)
        end
    end
end

PushUIFrameTargetFrameHook.ForceUpdatePercentage = nil
PushUIFrameTargetFrameHook.InitPercentage = function()
    if PushUIConfig.TargetFrameHook.Percentage and PushUIConfig.TargetFrameHook.Percentage.display then
        local _c = PushUIConfig.TargetFrameHook.Percentage
        local _pf = CreateFrame("Frame", "PushUIFrameTargetFramePercentageFrame", PushUIFrameTargetFrameHook.HookBar)
        PushUIFrameTargetFrameHook.PercentageFrame = _pf

        local _fs = _pf:CreateFontString(_pf:GetName().."_Text")
        _pf.text = _fs

        local _fn = _c.fontName or "Interface\\AddOns\\PushUI\\media\\fontn.ttf"
        local _fsize = _c.size or 14
        local _foutline = _c.outline or "OUTLINE"

        _fs:SetFont(_fn, _fsize, _foutline)

        -- align
        local _align = _c.align or "CENTER"
        _fs:SetJustifyH(_align)

        local _afk = UnitIsAFK("target")    
        local _pv = PushUIAPI.UnitTarget.Value() / PushUIAPI.UnitTarget.MaxValue() * 100
        if _afk then
            _fs:SetText("<AFK>"..("%.1f"):format(_pv).."%")
        else
            _fs:SetText(("%.1f"):format(_pv).."%")
        end

        local _w = _fs:GetStringWidth()
        local _h = _fs:GetStringHeight()
        _pf:SetWidth(_pf:GetParent():GetWidth())
        _pf:SetHeight(_fsize)

        local _a = _c.anchorPoint or "TOPRIGHT"
        local _pos = _c.position or {x = PushUISize.padding, y = PushUISize.padding}
        _pf:SetPoint(_a, PushUIFrameTargetFrameHook.HookBar, "TOPRIGHT", _pos.x, _pos.y)
        _fs:SetAllPoints(_pf)

        _fs.OnValueChange = function()
            local _afk = UnitIsAFK("target")    
            local _pv = PushUIAPI.UnitTarget.Value() / PushUIAPI.UnitTarget.MaxValue() * 100
            if _afk then
                _fs:SetText("<AFK>"..("%.1f"):format(_pv).."%")
            else
                _fs:SetText(("%.1f"):format(_pv).."%")
            end
            _fs:SetTextColor(unpack(_c.color(
                    PushUIAPI.UnitTarget.Value(),
                    PushUIAPI.UnitTarget.MaxValue(),
                    PushUIAPI.UnitTarget.MinValue(),
                    UnitClass("target")
                )))
            -- local _w = _fs:GetStringWidth()
            -- _pf:SetWidth(_w)
        end
        PushUIAPI.UnitTarget.RegisterForValueChanged(_fs, _fs.OnValueChange)

        -- Init the value
        _fs.OnValueChange()
        PushUIFrameTargetFrameHook.ForceUpdatePercentage = _fs.OnValueChange
    end
end

PushUIFrameTargetFrameHook.ForceUpdateHealthValue = nil
PushUIFrameTargetFrameHook.InitHealthValue = function()
    if PushUIConfig.TargetFrameHook.HealthValue and PushUIConfig.TargetFrameHook.HealthValue.display then
        local _c = PushUIConfig.TargetFrameHook.HealthValue
        local _hf = CreateFrame("Frame", "PushUIFrameTargetFrameHealthValueFrame", PushUIFrameTargetFrameHook.HookBar)
        PushUIFrameTargetFrameHook.HealthValueFrame = _hf

        local _fs = _hf:CreateFontString()

        local _fn = _c.fontName or "Interface\\AddOns\\PushUI\\media\\fontn.ttf"
        local _fsize = _c.size or 14
        local _foutline = _c.outline or "OUTLINE"

        _fs:SetFont(_fn, _fsize, _foutline)

        -- align
        local _align = _c.align or "CENTER"
        _fs:SetJustifyH(_align)

        _hf:SetWidth(_hf:GetParent():GetWidth())
        _hf:SetHeight(_fsize)

        local _a = _c.anchorPoint or "TOPRIGHT"
        local _pos = _c.position or {x = PushUISize.padding, y = PushUISize.padding}
        _hf:SetPoint(_a, PushUIFrameTargetFrameHook.HookBar, "TOPRIGHT", _pos.x, _pos.y)
        _fs:ClearAllPoints()
        _fs:SetWidth(_hf:GetWidth())
        _fs:SetHeight(_hf:GetHeight())
        _fs:SetAllPoints(_hf)

        _fs:SetText(UnitHealth("target"))

        _fs.OnValueChange = function()
            _fs:SetText(UnitHealth("target"))
            _fs:SetTextColor(unpack(_c.color(
                    PushUIAPI.UnitTarget.Value(),
                    PushUIAPI.UnitTarget.MaxValue(),
                    PushUIAPI.UnitTarget.MinValue(),
                    UnitClass("target")
                )))
        end
        PushUIAPI.UnitTarget.RegisterForValueChanged(_fs, _fs.OnValueChange)

        -- Init Color
        _fs.OnValueChange()
        PushUIFrameTargetFrameHook.ForceUpdateHealthValue = _fs.OnValueChange
    end
end

PushUIFrameTargetFrameHook._buffButtons = {}
PushUIFrameTargetFrameHook._debuffButtons = {}

PushUIFrameTargetFrameHook._auraOnUpdate = function(self, elapsed)
    if self:IsShown() == false then return end
    local _aura = self.AurasInfo
    local _pb = self.pb
    if _aura.expirationTime ~= 0 then
        _pb:SetMinMaxValues(0, _aura.expirationTime - _aura.startTime)
        _pb:SetValue(_aura.expirationTime - GetTime())
    else
        _pb:SetMinMaxValues(0, 1)
        _pb:SetValue(1)
    end
end

PushUIFrameTargetFrameHook.ForceUpdateAuras = nil
PushUIFrameTargetFrameHook.InitAuras = function()
    if PushUIConfig.TargetFrameHook.Auras and PushUIConfig.TargetFrameHook.Auras.display then
        local _af = CreateFrame("Frame", "PushUIFrameTargetFrameAurasFrame", PushUIFrameTargetFrameHook.HookBar)
        PushUIFrameTargetFrameHook.AurasFrame = _af
        local _c = PushUIConfig.TargetFrameHook.Auras
        local _ancpt = _c.anchorPoint or "BOTTOMLEFT"
        local _pos = _c.position or { x = 0, y = 10 }

        local _showAuraButotns = function(btnTable, apiObject, config, namePrefix, isBuff)
            local _btntable = btnTable
            local _bc = apiObject.Count()
            local _btnc = #_btntable
            local _buffc = config

            local _btnw = 20
            local _btnh = 20
            if _buffc.size then
                _btnw = _buffc.size.w
                _btnh = _buffc.size.h
            end

            local _usingIndex = 1
            for i = 1, _bc do
                local _aura = apiObject.Value(i)
                local _should_display = true
                if _c.displayPlayerOnly then
                    if _aura.unitCaster ~= "player" then
                        _should_display = false
                    end
                end
                if _should_display then
                    local _btn = nil
                    if _usingIndex <= _btnc then
                        _btn = _btntable[_usingIndex]
                    else
                        _btn = PushUIFrames.Button.Create(namePrefix.._usingIndex, _af, nil)
                        _btn.IsBuff = isBuff
                        _btntable[_btnc + 1] = _btn
                        _btnc = #_btntable
                        _btn:SetWidth(_btnw)
                        _btn:SetHeight(_btnh)
                        local _countfs = _btn:CreateFontString(_btn:GetName().."Count")
                        _countfs:SetFont("Interface\\AddOns\\PushUI\\media\\fontn.ttf", _btnw * 0.5, "OUTLINE")
                        _countfs:SetJustifyH("RIGHT")
                        _countfs:SetHeight(_btnw * 0.5)
                        _countfs:SetWidth(_btnw)
                        _countfs:SetPoint("TOPRIGHT", _btn, "TOPRIGHT", -2, -2)
                        _btn:SetFontString(_countfs)
                        _btn.fs = _countfs
                        -- _btn:SetNormalFontObject(_countfs)
                        PushUIConfig.skinType(_btn)

                        _btn.pb = PushUIFrames.ProgressBar.Create(namePrefix.._usingIndex.."ProgressBar", _btn, nil, "HORIZONTAL")
                        _btn.pb:SetHeight(_btnh * 0.2 - 2)
                        _btn.pb:SetWidth(_btnw)
                        _btn.pb:SetPoint("TOPLEFT", _btn, "BOTTOMLEFT", 0, 0)
                        _btn.pb:SetMinMaxValues(0, 1)
                        _btn.pb:SetValue(1)
                        if isBuff then
                            _btn.pb:SetStatusBarColor(unpack(PushUIColor.green))
                        else
                            _btn.pb:SetStatusBarColor(unpack(PushUIColor.red))
                        end
                        PushUIStyle.BackgroundFormatForProgressBar(_btn.pb)

                        _btn:SetScript("OnUpdate", PushUIFrameTargetFrameHook._auraOnUpdate)
                    end
                    _usingIndex = _usingIndex + 1
                    _btn.AurasInfo = _aura

                    _btn:Show()
                    _btn:SetNormalTexture(_aura.icon)

                    local _nt = _btn:GetNormalTexture()
                    _nt:SetTexCoord(0.1,0.9,0.1,0.9)
                    _nt:SetPoint("TOPLEFT", _btn, "TOPLEFT", 2, -2)
                    _nt:SetPoint("BOTTOMRIGHT", _btn, "BOTTOMRIGHT", -2, 2)

                    if _aura.count ~= 0 then
                        _btn.fs:SetText(_aura.count)
                    else
                        _btn.fs:SetText("")
                    end
                end
            end

            -- Hide Unused button
            if _bc < _btnc then
                for i = _bc + 1, _btnc do
                    _btntable[i]:Hide()
                end
            end
            return _bc
        end

        -- multipleline = true,
        -- width = 200,

        local _orderAuras = function()
            local _ancpt = _c.anchorPoint or "BOTTOMRIGHT"
            local _pos = _c.position or { x = 0, y = 10 }
            local _afw = _c.width or PushUIFrameTargetFrameHook.HookBar:GetWidth()
            local _buff_line_height = 30
            local _debuff_line_height = 30
            if _c.buff.size and _c.buff.size.h then
                _buff_line_height = _c.buff.size.h
            end
            if _c.debuff.size and _c.debuff.size.h then
                _debuff_line_height = _c.debuff.size.h
            end
            local _lineheight = 30
            if _buff_line_height > _debuff_line_height then
                _lineheight = _buff_line_height
            else
                _lineheight = _debuff_line_height
            end

            local _btntables = {}
            if _c.displayBuffFirst then
                _btntables = {
                    [1] = PushUIFrameTargetFrameHook._buffButtons,
                    [2] = PushUIFrameTargetFrameHook._debuffButtons
                }
            else
                _btntables = {
                    [1] = PushUIFrameTargetFrameHook._debuffButtons,
                    [2] = PushUIFrameTargetFrameHook._buffButtons
                }
            end

            local _allheight = 0

            local _linewidth = 0
            local _ypos = 0
            for i = 1, 2 do
                local _bt = _btntables[i]
                local _btsize = #_bt
                for j = 1, _btsize do
                    local _n = _bt[j]
                    if not _n:IsShown() then
                        break
                    end
                    local _nw = _n:GetWidth()
                    -- Next line
                    if _nw + _linewidth > _afw then
                        _ypos = _ypos + _lineheight * 1.25
                        _linewidth = 0
                    end
                    _n:SetPoint("TOPLEFT", _af, "TOPLEFT", -_linewidth - _nw, -_ypos)
                    _linewidth = _linewidth + _nw + 2
                end
            end

            _af:SetWidth(_afw)
            _af:SetHeight(_ypos + _lineheight + 2)
            _af:SetPoint("TOPLEFT", PushUIFrameTargetFrameHook.HookBar, _ancpt, _pos.x, _pos.y)
        end

        PushUIAPI.TargetBuff.RegisterForValueChanged(
            PushUIFrameTargetFrameHook,
            function()
                _showAuraButotns(
                    PushUIFrameTargetFrameHook._buffButtons, 
                    PushUIAPI.TargetBuff, 
                    _c.buff, 
                    "PushUIFrameTargetFrameAurasFrameBuffButton", 
                    true)
                _showAuraButotns(
                    PushUIFrameTargetFrameHook._debuffButtons, 
                    PushUIAPI.TargetDebuff, 
                    _c.debuff, 
                    "PushUIFrameTargetFrameAurasFrameDebuffButton", 
                    false)
                _orderAuras()
            end
            )
        PushUIAPI.TargetDebuff.RegisterForValueChanged(
            PushUIFrameTargetFrameHook,
            function()
                _showAuraButotns(
                    PushUIFrameTargetFrameHook._buffButtons, 
                    PushUIAPI.TargetBuff, 
                    _c.buff, 
                    "PushUIFrameTargetFrameAurasFrameBuffButton", 
                    true)
                _showAuraButotns(
                    PushUIFrameTargetFrameHook._debuffButtons, 
                    PushUIAPI.TargetDebuff, 
                    _c.debuff, 
                    "PushUIFrameTargetFrameAurasFrameDebuffButton", 
                    false)
                _orderAuras()
            end
            )
        PushUIFrameTargetFrameHook.ForceUpdateAuras = function()
            PushUIAPI.TargetBuff.CanDisplay()
            PushUIAPI.TargetDebuff.CanDisplay()
            _showAuraButotns(
                PushUIFrameTargetFrameHook._buffButtons, 
                PushUIAPI.TargetBuff, 
                _c.buff, 
                "PushUIFrameTargetFrameAurasFrameBuffButton", 
                true)
            _showAuraButotns(
                PushUIFrameTargetFrameHook._debuffButtons, 
                PushUIAPI.TargetDebuff, 
                _c.debuff, 
                "PushUIFrameTargetFrameAurasFrameDebuffButton", 
                false)
            _orderAuras()
        end
        PushUIFrameTargetFrameHook.ForceUpdateAuras()
    end
end

PushUIFrameTargetFrameHook.InitHookBar()
PushUIFrameTargetFrameHook.InitName()
PushUIFrameTargetFrameHook.InitLifeBar()
PushUIFrameTargetFrameHook.InitPercentage()
PushUIFrameTargetFrameHook.InitHealthValue()
PushUIFrameTargetFrameHook.InitAuras()

TargetFrame:SetScript("OnEvent", nil)
TargetFrame:Hide()

PushUIFrameTargetFrameHook.Init = function()
    if PushUIFrameTargetFrameHook.ForceUpdateHealthValue then
        PushUIFrameTargetFrameHook.ForceUpdateHealthValue()
    end
    if PushUIFrameTargetFrameHook.ForceUpdateName then
        PushUIFrameTargetFrameHook.ForceUpdateName()
    end
    if PushUIFrameTargetFrameHook.ForceUpdateLifeBar then
        PushUIFrameTargetFrameHook.ForceUpdateLifeBar()
    end
    if PushUIFrameTargetFrameHook.ForceUpdatePercentage then
        PushUIFrameTargetFrameHook.ForceUpdatePercentage()
    end
    if PushUIFrameTargetFrameHook.ForceUpdateAuras then
        PushUIFrameTargetFrameHook.ForceUpdateAuras()
    end
end

PushUIFrameTargetFrameHook.DisplayStatusChanged = function(...)
    if PushUIAPI.UnitTarget.CanDisplay() then
        PushUIFrameTargetFrameHook.Init()
        if PushUIFrameTargetFrameHook.HookBar then
            PushUIFrameTargetFrameHook.HookBar:Show()
        end
        if PushUIFrameTargetFrameHook.NameFrame then
            PushUIFrameTargetFrameHook.NameFrame:Show()
        end
        if PushUIFrameTargetFrameHook.LifeBarFrame then
            PushUIFrameTargetFrameHook.LifeBarFrame:Show()
        end
        if PushUIFrameTargetFrameHook.PercentageFrame then
            PushUIFrameTargetFrameHook.PercentageFrame:Show()
        end
        if PushUIFrameTargetFrameHook.HealthValueFrame then
            PushUIFrameTargetFrameHook.HealthValueFrame:Show()
        end
        if PushUIFrameTargetFrameHook.AurasFrame then
            PushUIFrameTargetFrameHook.AurasFrame:Show()
        end
    else
        if PushUIFrameTargetFrameHook.HookBar then
            PushUIFrameTargetFrameHook.HookBar:Hide()
        end
        if PushUIFrameTargetFrameHook.NameFrame then
            PushUIFrameTargetFrameHook.NameFrame:Hide()
        end
        if PushUIFrameTargetFrameHook.LifeBarFrame then
            PushUIFrameTargetFrameHook.LifeBarFrame:Hide()
        end
        if PushUIFrameTargetFrameHook.PercentageFrame then
            PushUIFrameTargetFrameHook.PercentageFrame:Hide()
        end
        if PushUIFrameTargetFrameHook.HealthValueFrame then
            PushUIFrameTargetFrameHook.HealthValueFrame:Hide()
        end
        if PushUIFrameTargetFrameHook.AurasFrame then
            PushUIFrameTargetFrameHook.AurasFrame:Hide()
        end
    end
end

PushUIFrameTargetFrameHook.DisplayStatusChanged()

PushUIAPI.RegisterEvent(
    "PLAYER_ENTERING_WORLD", 
    PushUIFrameTargetFrameHook, 
    PushUIFrameTargetFrameHook.DisplayStatusChanged)

PushUIAPI.UnitTarget.RegisterForDisplayStatus(
    PushUIFrameTargetFrameHook, 
    PushUIFrameTargetFrameHook.DisplayStatusChanged)

-- PushUIConfig.TargetFrameHook.PowerBar = {
--     display = true
--     -- pending...
-- }
-- PushUIConfig.TargetFrameHook.ResourceBar = {
--     display = true
--     -- pending...
-- }
    
-- function(e)
--     FocusFrame:SetScript("OnEvent", nil)
--     FocusFrame:Hide()
--     --Boss1Frame:Hide()
--     Boss1TargetFrame:Hide()
--     Boss2TargetFrame:Hide()
--     Boss3TargetFrame:Hide()
--     Boss4TargetFrame:Hide()
--     Boss5TargetFrame:Hide()
    
--     PartyMemberFrame1:Hide()
--     PartyMemberFrame2:Hide()
--     PartyMemberFrame3:Hide()
--     PartyMemberFrame4:Hide()    
-- end
