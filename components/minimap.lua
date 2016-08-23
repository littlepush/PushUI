local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local PushUIFrameMinimapHook = PushUIFrames.Frame.Create("PushUIFrameMinimapHook", PushUIConfig.MinimapFrameHook)
PushUIFrameMinimapHook.HookParent = PushUIConfig.MinimapFrameHook.parent.HookFrame
PushUIFrameMinimapHook.ToggleCanShow = true
PushUIFrameMinimapHook.Toggle = function(statue)
    PushUIFrameMinimapHook.ToggleCanShow = statue
    if statue then
        Minimap:Show()
    else
        Minimap:Hide()
    end
end

PushUIFrameMinimapHook.ReSize = function(...)
    local mm = Minimap

    PushUIConfig.MinimapFrameHook.align = PushUIConfig.MinimapFrameHook.align or "right"
    local _align = PushUIConfig.MinimapFrameHook.align

    local _w, _h, _x, _y = PushUIFrameMinimapHook.HookParent.GetBlockRect(
                            1, 2, PushUIConfig.MinimapFrameHook.align,
                            PushUIConfig.MinimapFrameHook.mustBeSquare)

    _x = _x * PushUISize.Resolution.scale
    _y = _y * PushUISize.Resolution.scale
    _w = _w * PushUISize.Resolution.scale
    _h = _h * PushUISize.Resolution.scale

    mm:ClearAllPoints()

    local _anchor = "TOPLEFT"
    local _objAnchor = "TOPLEFT"

    mm:SetWidth(_w)
    mm:SetHeight(_h)
    mm:SetPoint(_anchor, PushUIFrameMinimapHook.HookParent, _objAnchor, _x, _y)
end

PushUIFrameMinimapHook.Init = function(...)
    
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
            "GameTimeFrame"
        }

        for i = 1, #frames do
            _G[frames[i]]:Hide()
            _G[frames[i]].Show = function(...) end
        end
    end

    -- No North Arrow
    MinimapCompassTexture:SetTexture(nil)

    mm:SetParent(PushUIFrameMinimapHook.HookParent)
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

    PushUIFrameMinimapHook.ReSize()
end

PushUIAPI.RegisterEvent(
    "PLAYER_ENTERING_WORLD", 
    PushUIFrameMinimapHook,
    PushUIFrameMinimapHook.Init
)
