local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))
    
if not IsAddOnLoaded("Skada") then return end

local _config = PushUIConfig.SkadaFrameDock
if not _config then 
    _config = {
        container = "PushUIFramesRightDockContainer",
        tint = "PushUIFrameRightTintContainer",
        color = PushUIColor.red,
        color2 = PushUIConfig.green,
        color3 = PushUIConfig.blue,
        displayOnLoad = true,
        width = 200
    }
end
_config._panelContainer = _G[_config.container]
_config._tintContainer = _G[_config.tint]
_config._defaultDockName = "PushUIFrameSkadaFrameDock"

_config._colors = {}
_config._colors[#_config._colors + 1] = _config.color
_config._colors[#_config._colors + 1] = _config.color2
_config._colors[#_config._colors + 1] = _config.color3

local function _winResize(swin, panel)
    swin:ClearAllPoints()
    swin:SetBackdrop(nil)
    swin.button:Hide()
    swin:SetWidth(_config.width - 10)
    swin:SetHeight(panel:GetHeight() - 10)
    swin:SetBarWidth(_config.width - 10)
    swin:SetBarHeight(panel:GetHeight() / 8 - 0.5)
    swin:SetPoint("TOPLEFT", panel, "TOPLEFT", 5, -5)
end

_config._skadadockGroup = {}

local function _createDockForSkadaWin(swin, name)
    local _gc = #_config._skadadockGroup
    local _cc = #_config._colors
    local _cindex = 1 + math.fmod(_gc, _cc)
    local _color = _config._colors[_cindex]
    local _skadadock = PushUIFrames.DockFrame.CreateNewDock(
        name, _color, "BOTTOM", _config._panelContainer, _config._tintContainer)
    _skadadock.panel:SetWidth(_config.width)
    PushUIConfig.skinType(_skadadock.panel)
    PushUIConfig.skinType(_skadadock.floatPanel)

    local _flb = PushUIFrames.Label.Create(name.."FloatLabel", _skadadock.floatPanel, true)
    _flb.SetTextString(swin.bargroup:GetName())
    _flb:SetPoint("TOPLEFT", _skadadock.floatPanel, "TOPLEFT", 0, 0)

    swin.bargroup:SetParent(_skadadock.panel)
    swin.bargroup.dockPanel = _skadadock.panel
    _winResize(swin.bargroup, _skadadock.panel)

    _config._skadadockGroup[#_config._skadadockGroup + 1] = _skadadock

    if _config.displayOnLoad then
        _config._panelContainer.Push(_skadadock.panel)
    else
        _config._tintContainer.Push(_skadadock.tintBar)
    end
end

local function _skadaDockInit()
    -- Create default config
    local _skadaWinCount = #Skada:GetWindows()
    local _skadaWins = Skada:GetWindows()

    for i = 1, _skadaWinCount do
        if _skadaWins[i].bargroup.dockPanel == nil then 
            local _defaultDockName = _config._defaultDockName.._skadaWins[i].bargroup:GetName()
            _createDockForSkadaWin(_skadaWins[i], _defaultDockName)
        end
    end

    local _skada = Skada.displays['bar']

    hooksecurefunc(_skada, 'AddDisplayOptions', function(self, win, options)
        options.baroptions.args.barspacing = nil
        options.baroptions.args.barslocked = true
        options.titleoptions.args.texture = nil
        options.titleoptions.args.bordertexture = nil
        options.titleoptions.args.thickness = nil
        options.titleoptions.args.margin = nil
        options.titleoptions.args.color = nil
        options.windowoptions = nil
    end)

    hooksecurefunc(_skada, 'ApplySettings', function(self, win)
        local _s = win.bargroup
        local _name = win.bargroup:GetName()
        if _s.dockPanel == nil then
            _createDockForSkadaWin(win, _defaultDockName.._name)
        else
            _winResize(_s, _s.dockPanel)
        end
    end)

    for k,v in pairs(Skada:GetWindows()) do
        v.bargroup:HookScript("OnShow", function(self, ...)
            if v.bargroup:GetParent():GetAlpha() == 0 then
                self:Hide()
            end
        end)
        v.bargroup:HookScript("OnHide", function(self, ...)
            if v.bargroup:GetParent():GetAlpha() ~= 0 then
                self:Show()
            end
        end)
    end

    PushUIAPI.UnregisterEvent("PLAYER_ENTERING_WORLD", _config._skadadockGroup)
end

PushUIAPI.RegisterEvent("PLAYER_ENTERING_WORLD", _config._skadadockGroup, _skadaDockInit)
