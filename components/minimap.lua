local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

-- Create default config
local _config = PushUIConfig.MinimapFrameDock
if not _config then 
    _config = {
        container = "PushUIFramesRightDockContainer",
        tint = "PushUIFrameRightTintContainer",
        color = PushUIColor.gray,
        displayOnLoad = true,
        width = 150
    }
end
local _panelContainer = _G[_config.container]
local _tintContainer = _G[_config.tint]
local _name = "PushUIFrameMinimapFrameDock"

local _minimapdock = PushUIFrames.DockFrame.CreateNewDock(
    _name, _config.color, "BOTTOM", _panelContainer, _tintContainer)
_minimapdock.panel:SetWidth(_config.width)
PushUIConfig.skinType(_minimapdock.panel)
PushUIConfig.skinType(_minimapdock.floatPanel)

local _floatLabel = PushUIFrames.Label.Create(_name.."FloatLabel", _minimapdock.floatPanel, true)
_floatLabel:SetTextString("Minimap")
_floatLabel:SetPoint("TOPLEFT", _minimapdock.floatPanel, "TOPLEFT", 0, 0)

_minimapdock.floatPanel.WillAppear = function()
    local _x, _y = UnitPosition("player")
    _floatLabel.SetTextString(("%.2f"):format(_x)..", "..("%.2f"):format(_y))
end

_minimapdock.panel.WillDisappear = function()
    Minimap:Hide()
end
_minimapdock.panel.DidAppear = function()
    Minimap:Show()
end

_minimapdock.__resize = function()
    local _mm = Minimap
    _mm:ClearAllPoints()
    _mm:SetWidth(_config.width - 10)
    _mm:SetHeight(_minimapdock.panel:GetHeight() - 10)
    _mm:SetPoint("TOPLEFT", _minimapdock.panel, "TOPLEFT", 5, -5)
end

_minimapdock.__init = function(...)
    
    local mc = MinimapCluster
    local mm = Minimap

    PushUIConfig.skinType(mm)
    mm:SetMaskTexture(PushUIStyle.TextureClean)

    -- Hide Everything
    do
        local frames = {
            "MiniMapInstanceDifficulty",
            "MiniMapVoiceChatFrame",
            "MiniMapWorldMapButton",
            "MiniMapMailBorder",
            "MinimapBorderTop",
            "MinimapNorthTag",
            "MiniMapTracking",
            "MinimapZoomOut",
            "MinimapZoomIn",
            "MinimapBorder",
            "GarrisonLandingPageMinimapButton",
            "TimeManagerClockButton",
            "GameTimeFrame",
            "MiniMapMailFrame"
        }

        for i = 1, #frames do
            local _f = _G[frames[i]]
            if _f ~= nil then
                _G[frames[i]]:Hide()
                _G[frames[i]].Show = function(...) end
            end
        end
    end

    -- No North Arrow
    MinimapCompassTexture:SetTexture(nil)

    mm:SetParent(_minimapdock.panel)
    mc:SetParent(_minimapdock.panel)
    mc:Hide()

    MinimapBackdrop:Hide()

    mm:EnableMouseWheel(true)
    mm:SetScript("OnMouseWheel", function(_, zoom)
        if zoom > 0 then
            Minimap_ZoomIn()
        else
            Minimap_ZoomOut()
        end
    end)
    if _config.displayOnLoad then
        _panelContainer.Push(_minimapdock.panel)
    else
        _tintContainer.Push(_minimapdock.tintBar)
    end
    _minimapdock.__resize()

    PushUIAPI.UnregisterEvent("PLAYER_ENTERING_WORLD", _minimapdock)
end

PushUIAPI.RegisterEvent("PLAYER_ENTERING_WORLD", _minimapdock, _minimapdock.__init)

