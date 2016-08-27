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
PushUIFrameUnitFrameHook.InitHookBar = function()
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
end

-- Name of the player
PushUIFrameUnitFrameHook.InitName = function()
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
end

PushUIFrameUnitFrameHook.InitLifeBar = function()
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
end

PushUIFrameUnitFrameHook.InitPercentage = function()
    if PushUIConfig.UnitFrameHook.Percentage and PushUIConfig.UnitFrameHook.Percentage.display then
        local _c = PushUIConfig.UnitFrameHook.Percentage
        local _pf = CreateFrame("Frame", "PushUIFrameUnitFramePercentageFrame", PushUIFrameUnitFrameHook.HookBar)
        PushUIFrameUnitFrameHook.PercentageFrame = _pf

        local _fs = _pf:CreateFontString(_pf:GetName().."_Text")
        _pf.text = _fs

        local _fn = _c.fontName or "Interface\\AddOns\\PushUI\\media\\fontn.ttf"
        print("Font Name: ".._fn)
        local _fsize = _c.size or 14
        local _foutline = _c.outline or "OUTLINE"

        _fs:SetFont(_fn, _fsize, _foutline)

        -- align
        local _align = _c.align or "CENTER"
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
        _pf:SetWidth(_pf:GetParent():GetWidth())
        _pf:SetHeight(_fsize)

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
            -- local _w = _fs:GetStringWidth()
            -- _pf:SetWidth(_w)
        end
        PushUIAPI.UnitPlayer.RegisterForValueChanged(_fs, _fs.OnValueChange)

        -- Init the value
        _fs.OnValueChange()
    end
end

PushUIFrameUnitFrameHook.InitHealthValue = function()
    if PushUIConfig.UnitFrameHook.HealthValue and PushUIConfig.UnitFrameHook.HealthValue.display then
        local _c = PushUIConfig.UnitFrameHook.HealthValue
        local _hf = CreateFrame("Frame", "PushUIFrameUnitFrameHealthValueFrame", PushUIFrameUnitFrameHook.HookBar)
        PushUIFrameUnitFrameHook.HealthValueFrame = _hf

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
        _hf:SetPoint(_a, PushUIFrameUnitFrameHook.HookBar, "TOPLEFT", _pos.x, _pos.y)
        _fs:ClearAllPoints()
        _fs:SetWidth(_hf:GetWidth())
        _fs:SetHeight(_hf:GetHeight())
        _fs:SetAllPoints(_hf)

        _fs:SetText(UnitHealth("player"))

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
end

-- PushUIConfig.UnitFrameHook.Auras = {
--     display = true
    -- displayBuffFirst = true,
    -- buff = {
    --     available = true,
    --     size = { w = 20, h = 20 },
    --     displayPlayerOnly = false
    -- }, 
    -- debuff = {
    --     available = true,
    --     size = { w = 24, h = 24 },
    --     displayPlayerOnly = false
    -- }
-- }

PushUIFrameUnitFrameHook._buffButtons = {}
PushUIFrameUnitFrameHook._debuffButtons = {}

PushUIFrameUnitFrameHook.InitAuras = function()
    if PushUIConfig.UnitFrameHook.Auras and PushUIConfig.UnitFrameHook.Auras.display then
        BuffFrame:UnregisterEvent("UNIT_AURA")
        BuffFrame:Hide()
        TemporaryEnchantFrame:Hide()

        local _af = CreateFrame("Frame", "PushUIFrameUnitFrameAurasFrame", PushUIFrameUnitFrameHook.HookBar)
        _af.OnButtonClick = function(btn, mousebtn)
            if not btn.IsBuff then return end
            print("click on buff button: "..btn.AurasInfo.name)
            CancelUnitBuff("player", btn.AurasInfo.name)
        end
        local _c = PushUIConfig.UnitFrameHook.Auras
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

            for i = 1, _bc do
                local _btn = nil
                if i <= _btnc then
                    _btn = _btntable[i]
                else
                    _btn = PushUIFrames.Button.Create(namePrefix..i, _af, nil)
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
                end
                local _aura = apiObject.Value(i)
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
            local _ancpt = _c.anchorPoint or "BOTTOMLEFT"
            local _pos = _c.position or { x = 0, y = 10 }
            local _afw = _c.width or PushUIFrameUnitFrameHook.HookBar:GetWidth()
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
                    [1] = PushUIFrameUnitFrameHook._buffButtons,
                    [2] = PushUIFrameUnitFrameHook._debuffButtons
                }
            else
                _btntables = {
                    [1] = PushUIFrameUnitFrameHook._debuffButtons,
                    [2] = PushUIFrameUnitFrameHook._buffButtons
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
                        _ypos = _ypos + _lineheight + 2
                        _linewidth = 0
                    end
                    _n:SetPoint("TOPLEFT", _af, "TOPLEFT", _linewidth, -_ypos)
                    _linewidth = _linewidth + _nw + 2
                end
            end

            _af:SetWidth(_afw)
            _af:SetHeight(_ypos + _lineheight + 2)
            _af:SetPoint("TOPLEFT", PushUIFrameUnitFrameHook.HookBar, _ancpt, _pos.x, _pos.y)
        end

        PushUIAPI.PlayerBuff.RegisterForValueChanged(
            PushUIFrameUnitFrameHook,
            function()
                _showAuraButotns(
                    PushUIFrameUnitFrameHook._buffButtons, 
                    PushUIAPI.PlayerBuff, 
                    _c.buff, 
                    "PushUIFrameUnitFrameAurasFrameBuffButton", 
                    true)
                _showAuraButotns(
                    PushUIFrameUnitFrameHook._debuffButtons, 
                    PushUIAPI.PlayerDebuff, 
                    _c.debuff, 
                    "PushUIFrameUnitFrameAurasFrameDebuffButton", 
                    false)
                _orderAuras()
            end
            )
        PushUIAPI.PlayerDebuff.RegisterForValueChanged(
            PushUIFrameUnitFrameHook,
            function()
                _showAuraButotns(
                    PushUIFrameUnitFrameHook._buffButtons, 
                    PushUIAPI.PlayerBuff, 
                    _c.buff, 
                    "PushUIFrameUnitFrameAurasFrameBuffButton", 
                    true)
                _showAuraButotns(
                    PushUIFrameUnitFrameHook._debuffButtons, 
                    PushUIAPI.PlayerDebuff, 
                    _c.debuff, 
                    "PushUIFrameUnitFrameAurasFrameDebuffButton", 
                    false)
                _orderAuras()
            end
            )

        PushUIAPI.PlayerBuff.CanDisplay()
        PushUIAPI.PlayerDebuff.CanDisplay()
        _showAuraButotns(
            PushUIFrameUnitFrameHook._buffButtons, 
            PushUIAPI.PlayerBuff, 
            _c.buff, 
            "PushUIFrameUnitFrameAurasFrameBuffButton", 
            true)
        _showAuraButotns(
            PushUIFrameUnitFrameHook._debuffButtons, 
            PushUIAPI.PlayerDebuff, 
            _c.debuff, 
            "PushUIFrameUnitFrameAurasFrameDebuffButton", 
            false)
        _orderAuras()
    end
end

PushUIFrameUnitFrameHook.Init = function()
    PushUIFrameUnitFrameHook.InitHookBar()
    PushUIFrameUnitFrameHook.InitName()
    PushUIFrameUnitFrameHook.InitLifeBar()
    PushUIFrameUnitFrameHook.InitPercentage()
    PushUIFrameUnitFrameHook.InitHealthValue()
    PushUIFrameUnitFrameHook.InitAuras()
end

PushUIAPI.RegisterEvent("PLAYER_ENTERING_WORLD", PushUIFrameUnitFrameHook, PushUIFrameUnitFrameHook.Init)

-- PushUIConfig.UnitFrameHook.PowerBar = {
--     display = true
--     -- pending...
-- }
-- PushUIConfig.UnitFrameHook.ResourceBar = {
--     display = true
--     -- pending...
-- }
