local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))
    
if not IsAddOnLoaded("Skada") then return end

local _skadaWinCount = #Skada:GetWindows()

-- Create default config
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
local _panelContainer = _G[_config.container]
local _tintContainer = _G[_config.tint]
local _name = "PushUIFrameSkadaFrameDock"

local _colors = {
    [1] = _config.color,
    [2] = _config.color2,
    [3] = _config.color3
}

local _skadaWins = Skada:GetWindows()

local function _winResize(swin, panel)
    swin:ClearAllPoints()
    swin:SetBackdrop(nil)
    swin.button:Hide()
    swin:SetWidth(_config.width)
    swin:SetHeight(panel:GetHeight())
    swin:SetBarWidth(_config.width)
    swin:SetBarHeight(panel:GetHeight() / 8 - 0.5)
    swin:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
end

local _skadadockGroup = {}

for i = 1, _skadaWinCount do
    local _skadadock = PushUIFrames.DockFrame.CreateNewDock(
        _name..i, _colors[i], "BOTTOM", _panelContainer, _tintContainer)
    _skadadock.panel:SetWidth(_config.width)
    PushUIConfig.skinType(_skadadock.panel)
    PushUIConfig.skinType(_skadadock.floatPanel)

    local _flb = PushUIFrames.Label.Create(_name..i.."FloatLabel", _skadadock.floatPanel, true)
    _flb:SetTextString(_skadaWins[i].bargroup:GetName())

    _skadaWins[i].bargroup:SetParent(_skadadock.panel)
    _winResize(_skadaWins[i].bargroup, _skadadock.panel)

    _skadadockGroup[i] = _skadadock
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

    _winResize(_s, _s:GetParent())
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

if _config.displayOnLoad then
    for i = 1, #_skadadockGroup do
        _panelContainer.Push(_skadadockGroup[i].panel)
    end
else
    for i = 1, #_skadadockGroup do
        _tintContainer.Push(_skadadockGroup[i].tintBar)
    end
end
