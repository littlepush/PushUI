local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))


PushUIFrames.UnitFrame = {}

-- A unit frame contains the following parts:
-- HookBar: The background empty hookbar to response for the mouse click
-- LifeBar: The life info status bar
-- Percentage: The percentage of the life, a text
-- Name: The name of the unit
-- HealthValue: The detail health value of the unit
-- Auras: Buff and Debuff of the unit
-- PowerBar: Unit's power info
-- Resource Item.

PushUIFrames.UnitFrame.CreateHookBar = function(unithook, config)
    local _c = config
    local _hb = CreateFrame(
        "Button", 
        unithook.name.."HookBar",
        UIParent,
        "SecureUnitButtonTemplate"
        )
    unithook.HookBar = _hb;

    PushUIStyle.BackgroundSolidFormat(_hb, 0, 0, 0, 0, 0, 0, 0, 0)    

    local _a = _c.anchorPoint or "TOPLEFT"
    local _hbside = _c.displaySide or "CENTER"
    local _atar = _c.anchorTarget or UIParent
    local _pos = _c.position or {x = -325, y = -95}
    local _size = _c.size or {w = 200, h = 40}

    _hb:SetWidth(_size.w)
    _hb:SetHeight(_size.h)
    _hb:SetPoint(_a, _atar, _hbside, _pos.x, _pos.y)

    _hb.unit = unithook.object
    _hb:SetAttribute("unit", _hb.unit)
    _hb:SetAttribute("type", "target")

    if unithook.object == "player" or unithook.object == "target" then
        _hb:EnableMouse(true)
        if unithook.object == "player" then
            _hb:SetScript("OnMouseDown", function(self, button)
                    if button == "RightButton" then
                        ToggleDropDownMenu(1, nil, PlayerFrameDropDown, _hb, 0, 0)
                    end
                end
            )
        else
            _hb:SetScript("OnMouseDown", function(self, button)
                    if button == "RightButton" then
                        ToggleDropDownMenu(1, nil, TargetFrameDropDown, _hb, 0, 0)
                    end
                end
            )
        end
    end

    -- Player's hookbar will always be displayed, otherwise, register for display status change
    if unithook.object ~= "player" then
        _hb._EventForDisplayStatus = function(status)
            if status then _hb:Show() else _hb:Hide() end
        end
        unithook.apiObject.RegisterForDisplayStatus(_hb, _hb._EventForDisplayStatus)
        _hb:Hide()
    end
end

PushUIFrames.UnitFrame.CreateLifeBar = function(unithook, config)
    local _c = config
    _c.targets = {
        unithook.apiObject
    }
    local _orientation = _c.orientation or "HORIZONTAL"
    local _lb = PushUIFrames.ProgressBar.Create(
        unithook.name.."LifeBar", 
        unithook.HookBar, 
        _c, 
        _orientation)
    unithook.LifeBar = _lb
    -- Set Background
    if _c.background then
        _c.background(_lb)
    end

    local _a = _c.anchorPoint or "TOPRIGHT"
    local _pos = _c.position or {x = 0, y = -35}
    local _size = _c.size or {w = 200, h = 5}

    _lb:SetWidth(_size.w)
    _lb:SetHeight(_size.h)
    _lb:SetPoint(_a, unithook.HookBar, "TOPLEFT", _pos.x, _pos.y)

    if _c.reverse then
        _lb:SetReverseFill()
    end
    _lb._ForceUpdate = function()
        _lb.OnDisplayStatusChanged(unithook.apiObject, unithook.apiObject.CanDisplay)
    end

    -- Player's hookbar will always be displayed, otherwise, register for display status change
    if unithook.object ~= "player" then
        _lb._EventForDisplayStatus = function(status)
            if status then _lb:Show(); _lb._ForceUpdate() else _lb:Hide() end
        end
        unithook.apiObject.RegisterForDisplayStatus(_lb, _lb._EventForDisplayStatus)
        _lb:Hide()
    end
end

PushUIFrames.UnitFrame.CreatePercentage = function(unithook, config)
    local _c = config
    local _pf = CreateFrame(
        "Frame", 
        unithook.name.."Percentage", 
        unithook.HookBar)
    unithook.Percentage = _pf

    local _fs = _pf:CreateFontString(_pf:GetName().."_Text")
    _pf.text = _fs

    local _fn = _c.fontName or "Interface\\AddOns\\PushUI\\media\\fontn.ttf"
    local _fsize = _c.size or 14
    local _foutline = _c.outline or "OUTLINE"

    _fs:SetFont(_fn, _fsize, _foutline)

    -- align
    local _align = _c.align or "CENTER"
    _fs:SetJustifyH(_align)

    local _w = unithook.HookBar:GetWidth()
    local _h = _fsize
    _pf:SetWidth(_w)
    _pf:SetHeight(_h)

    local _a = _c.anchorPoint or "TOPRIGHT"
    local _pos = _c.position or {x = PushUISize.padding, y = PushUISize.padding}
    local _hbside = _c.displaySide or "TOPLEFT"
    _pf:SetPoint(_a, unithook.HookBar, _hbside, _pos.x, _pos.y)
    _fs:SetAllPoints(_pf)

    _fs.OnValueChange = function()
        local _afk = UnitIsAFK(unithook.object)    
        local _pv = unithook.apiObject.Value() / unithook.apiObject.MaxValue() * 100
        if _afk then
            _fs:SetText("<AFK>"..("%.1f"):format(_pv).."%")
        else
            _fs:SetText(("%.1f"):format(_pv).."%")
        end
        _fs:SetTextColor(unpack(_c.color(
                unithook.apiObject.Value(),
                unithook.apiObject.MaxValue(),
                unithook.apiObject.MinValue(),
                UnitClass(unithook.object)
            )))
    end
    unithook.apiObject.RegisterForValueChanged(_fs, _fs.OnValueChange)

    -- Init the value
    _pf._ForceUpdate = _fs.OnValueChange

    -- Player's hookbar will always be displayed, otherwise, register for display status change
    if unithook.object ~= "player" then
        _pf._EventForDisplayStatus = function(status)
            if status then _pf:Show(); _pf._ForceUpdate() else _pf:Hide() end
        end
        unithook.apiObject.RegisterForDisplayStatus(_pf, _pf._EventForDisplayStatus)
        _pf:Hide()
    end
end

PushUIFrames.UnitFrame.CreateName = function(unithook, config)
    local _c = config
    local _nf = CreateFrame(
        "Frame", 
        unithook.name.."Name", 
        unithook.HookBar)
    unithook.Name = _nf

    local _fs = _nf:CreateFontString()

    local _fn = _c.fontName or "Fonts\\FRIZQT__.TTF"
    local _fsize = _c.size or 14
    local _foutline = _c.outline or "OUTLINE"

    _fs:SetFont(_fn, _fsize, _foutline)

    -- align
    local _align = _c.align or "CENTER"
    _fs:SetJustifyH(_align)

    local _w = unithook.HookBar:GetWidth()
    local _h = _fsize
    _nf:SetWidth(_w)
    _nf:SetHeight(_h)

    local _a = _c.anchorPoint or "TOPRIGHT"
    local _pos = _c.position or {x = PushUISize.padding, y = PushUISize.padding}
    local _hbside = _c.displaySide or "TOPLEFT"
    _nf:SetPoint(_a, unithook.HookBar, _hbside, _pos.x, _pos.y)
    _fs:SetAllPoints(_nf)

    _fs.OnValueChange = function()
        _fs:SetText(UnitName(unithook.object))
        _fs:SetTextColor(unpack(_c.color(
                unithook.apiObject.Value(),
                unithook.apiObject.MaxValue(),
                unithook.apiObject.MinValue(),
                UnitClass(unithook.object)
            )))
    end
    unithook.apiObject.RegisterForValueChanged(_fs, _fs.OnValueChange)

    -- Init the value
    _nf._ForceUpdate = _fs.OnValueChange

    -- Player's hookbar will always be displayed, otherwise, register for display status change
    if unithook.object ~= "player" then
        _nf._EventForDisplayStatus = function(status)
            if status then _nf:Show(); _nf._ForceUpdate() else _nf:Hide() end
        end
        unithook.apiObject.RegisterForDisplayStatus(_nf, _nf._EventForDisplayStatus)
        _nf:Hide()
    end
end

PushUIFrames.UnitFrame.CreateHealthValue = function(unithook, config)
    local _c = config
    local _hf = CreateFrame(
        "Frame",
        unithook.name.."HealthValue",
        unithook.HookBar
        )
    unithook.HealthValue = _hf

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
    local _hbside = _c.displaySide or "TOPLEFT"
    _hf:SetPoint(_a, unithook.HookBar, _hbside, _pos.x, _pos.y)
    _fs:ClearAllPoints()
    _fs:SetAllPoints(_hf)

    _fs.OnValueChange = function()
        _fs:SetText(UnitHealth(unithook.object))
        _fs:SetTextColor(unpack(_c.color(
                unithook.apiObject.Value(),
                unithook.apiObject.MaxValue(),
                unithook.apiObject.MinValue(),
                UnitClass(unithook.object)
            )))
    end
    -- Init the value
    _hf._ForceUpdate = _fs.OnValueChange

    -- Player's hookbar will always be displayed, otherwise, register for display status change
    if unithook.object ~= "player" then
        _hf._EventForDisplayStatus = function(status)
            if status then _hf:Show(); _hf._ForceUpdate() else _hf:Hide() end
        end
        unithook.apiObject.RegisterForDisplayStatus(_hf, _hf._EventForDisplayStatus)
        _hf:Hide()
    end
end

PushUIFrames.UnitFrame.__onAuraUpdate = function(btn, time)
    if not btn:IsShown() then return end

    local _aura = btn._auraInfo
    if _aura == nil then return end

    local _pb = btn._pb

    if _aura.expirationTime ~= 0 then
        _pb:SetMinMaxValues(0, _aura.duration)
        _pb:SetValue(_aura.expirationTime - GetTime())
    else
        _pb:SetMinMaxValues(0, 1)
        _pb:SetValue(1)
    end
end

PushUIFrames.UnitFrame.__onUpdateAuraList = function(btnTable, unithook, config)
    local _auraCount = unithook.auraApiObject.Count()
    local _btnCount = #btnTable

    local _btnWidth = 20
    local _btnHeight = 20
    if config.size then _btnWidth = config.size.w; _btnHeight = config.size.h end

    for i = 1, _auraCount do
        local _btn = nil
        if i <= _btnCount then
            _btn = btnTable[i]
        else
            -- Create new button
            _btn = PushUIFrames.Button.Create(unithook.name.."AurasButton"..i, unithook.Auras)
            btnTable[_btnCount + 1] = _btn
            _btnCount = _btnCount + 1
            _btn:SetWidth(_btnWidth)
            _btn:SetHeight(_btnHeight)
            PushUIConfig.skinType(_btn)

            -- Create aura count font string
            local _countfs = _btn:CreateFontString(_btn:GetName().."Count")
            _countfs:SetFont("Interface\\AddOns\\PushUI\\media\\fontn.ttf", _btnWidth * 0.5, "OUTLINE")
            _countfs:SetJustifyH("RIGHT")
            _countfs:SetHeight(_btnWidth * 0.5)
            _countfs:SetWidth(_btnWidth)
            _countfs:SetPoint("TOPRIGHT", _btn, "TOPRIGHT", -2, -2)
            _btn:SetFontString(_countfs)
            _btn.fs = _countfs

            -- Create Progress bar
            local _pb = PushUIFrames.ProgressBar.Create(_btn:GetName().."Porgress", _btn, nil, "HORIZONTAL")
            _pb:SetWidth(_btnWidth - 2)
            _pb:SetHeight(_btnHeight * 0.15)
            _pb:SetPoint("TOPLEFT", _btn, "BOTTOMLEFT", 1, 0)
            PushUIStyle.BackgroundFormatForProgressBar(_pb)
            _btn:SetScript("OnUpdate", PushUIFrames.UnitFrame.__onAuraUpdate)
            _btn._pb = _pb
        end

        -- Get Aura and set the button's display status
        local _aura = unithook.auraApiObject.Value(i)
        _btn._auraInfo = _aura
        if _aura.isbuff then
            _btn._pb:SetStatusBarColor(unpack(PushUIColor.green))
        else
            _btn._pb:SetStatusBarColor(unpack(PushUIColor.red))
        end

        _btn:Show()
        _btn:SetNormalTexture(_aura.icon)

        -- Change normal texture position
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

    if _auraCount < _btnCount then
        for i = _auraCount + 1, _btnCount do
            btnTable[i]:Hide()
        end
    end
end

PushUIFrames.UnitFrame.__onOrderAuraList = function(btnTable, unithook, config)
    local _c = config

    local _ancpt = _c.anchorPoint or "TOPLEFT"
    local _pos = _c.position or { x = 0, y = 10 }
    local _hbside = _c.displaySide or "BOTTOMLEFT"
    local _afw = _c.width or unithook.HookBar:GetWidth()

    local _lineheight = 20 * 1.2
    if _c.size then
        _lineheight = _c.size.h * 1.2
    end

    local _allheight = 0
    local _linewidth = 0
    local _ypos = 0
    local _btncount = #btnTable

    local _btnAnchor = "TOPLEFT"
    local _afAnchor = "TOPLEFT"
    local _direction = 1
    if unithook.object == "target" then
        _btnAnchor = "TOPRIGHT"
        _afAnchor = "TOPRIGHT"
        _direction = -1
    end

    for i = 1, _btncount do
        if not btnTable[i]:IsShown() then break end
        local _b = btnTable[i]
        if _linewidth + _b:GetWidth() + 2 > _afw then
            _ypos = _ypos + _lineheight
            _linewidth = 0
        end
        _b:SetPoint(_btnAnchor, unithook.Auras, _afAnchor, _linewidth * _direction, -_ypos)
        _linewidth = _linewidth + _b:GetWidth() + 2
    end

    unithook.Auras:SetWidth(_afw)
    unithook.Auras:SetHeight(_ypos + _lineheight)
    unithook.Auras:SetPoint(_ancpt, unithook.HookBar, _hbside, _pos.x, _pos.y)
end

PushUIFrames.UnitFrame.CreateAuras = function(unithook, config)
    -- Auras only available for player and current target
    if unithook.object ~= "player" and unithook.object ~= "target" then return end

    local _af = CreateFrame(
        "Frame", 
        unithook.name.."Auras",
        unithook.HookBar
        )
    unithook.Auras = _af

    -- Init the button cache
    _af._auraButtons = {}

    -- Hide global buff frame
    if unithook.object == "player" then
        BuffFrame:UnregisterEvent("UNIT_AURA")
        BuffFrame:Hide()
        TemporaryEnchantFrame:Hide()
    end

    _af._ShowAuraButtons = function()
        PushUIFrames.UnitFrame.__onUpdateAuraList(_af._auraButtons, unithook, config)
        PushUIFrames.UnitFrame.__onOrderAuraList(_af._auraButtons, unithook, config)
    end
    unithook.auraApiObject.RegisterForValueChanged(_af, _af._ShowAuraButtons)

    _af._ForceUpdate = function()
        unithook.auraApiObject.CanDisplay()
        _af._ShowAuraButtons()
    end

    if unithook.object == "target" then
        _af._EventForDisplayStatus = function(status)
            if status then _af:Show(); _af._ForceUpdate() else _af:Hide() end
        end
        unithook.auraApiObject.RegisterForDisplayStatus(_af, _af._EventForDisplayStatus)
        _af:Hide()
    end
end

PushUIFrames.UnitFrame.Create = function(unithook, config)
    if not config.enable then return end
    if not config.hookbar then return end

    PushUIFrames.UnitFrame.CreateHookBar(unithook, config.hookbar)
    if config.lifebar then
        PushUIFrames.UnitFrame.CreateLifeBar(unithook, config.lifebar)
    end

    if config.percentage then
        PushUIFrames.UnitFrame.CreatePercentage(unithook, config.percentage)
    end

    if config.name then
        PushUIFrames.UnitFrame.CreateName(unithook, config.name)
    end

    if config.healthvalue then
        PushUIFrames.UnitFrame.CreateHealthValue(unithook, config.healthvalue)
    end

    if config.auras then
        PushUIFrames.UnitFrame.CreateAuras(unithook, config.auras)
    end
end

PushUIFrames.UnitFrame.ForceUpdate = function(unithook)
    if not unithook.HookBar then return end

    if unithook.LifeBar then unithook.LifeBar._ForceUpdate() end
    if unithook.Percentage then unithook.Percentage._ForceUpdate() end
    if unithook.Name then unithook.Name._ForceUpdate() end
    if unithook.HealthValue then unithook.HealthValue._ForceUpdate() end
    if unithook.Auras then unithook.Auras._ForceUpdate() end
end
