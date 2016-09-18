local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

-- Dock Frame

PushUIFrames.DockFrame = {}

PushUIFrames.DockFrame.CreateDockContainer = function(name, side)
    local _frameStack = CreateFrame("Frame", name, UIParent)
    _frameStack:ClearAllPoints()
    _frameStack.panelStack = PushUIAPI.Vector.New()
    _frameStack._pushSide = side
    _frameStack._padding = 5
    _frameStack._allPanelWidth = _frameStack._padding
    --_frameStack:SetFrameStrata("BACKGROUND")

    if side == "LEFT" then
        _frameStack.__anchor = "TOPLEFT"
        _frameStack.__relativeAnchor = "TOPLEFT"
        _frameStack.__abs = 1
    else
        _frameStack.__anchor = "TOPRIGHT"
        _frameStack.__relativeAnchor = "TOPRIGHT"
        _frameStack.__abs = -1
    end

    _frameStack.Push = function(panel, animationStage, onFinished)
        if not panel or not panel.dock then return end
        if _frameStack.panelStack.Contains(panel) then return end
        _frameStack.panelStack.PushBack(panel)

        panel:SetPoint(
            _frameStack.__anchor, 
            _frameStack, 
            _frameStack.__relativeAnchor, 
            _frameStack._allPanelWidth * _frameStack.__abs, 0)

        if animationStage then
            panel:Show()
            panel.PlayAnimationStage(animationStage, function(...)
                _frameStack._allPanelWidth = _frameStack._allPanelWidth + panel:GetWidth() + _frameStack._padding
                if onFinished then onFinished() end
            end)
        else
            panel:SetAlpha(1)
            panel:Show()
            _frameStack._allPanelWidth = _frameStack._allPanelWidth + panel:GetWidth() + _frameStack._padding
        end
    end

    _frameStack.Erase = function(panel, animationStage, onFinished)
        if not panel or not panel.dock then return end

        if not _frameStack.panelStack.Contains(panel) then return end

        local _resizeFromIndex = 1
        for i = 1, _frameStack.panelStack.Size() do
            if _frameStack.panelStack.ObjectAtIndex(i):GetName() == panel:GetName() then
                _frameStack.panelStack.Erase(i)
                _resizeFromIndex = i
                break
            end
        end
        _frameStack._allPanelWidth = _frameStack._allPanelWidth - panel:GetWidth() - _frameStack._padding

        if animationStage then
            panel.PlayAnimationStage(animationStage, function(...)
                panel:Hide()
                if onFinished then onFinished() end
            end)
        else
            panel:SetAlpha(0)
            panel:Hide()
        end

        local _skipSize = _frameStack._padding
        local _eraseAnimationName = _frameStack:GetName().."EraseAnimation"
        for i = 1, _resizeFromIndex - 1 do
            _skipSize = _skipSize + _frameStack.panelStack.ObjectAtIndex(i):GetWidth() + _frameStack._padding
        end
        for i = _resizeFromIndex, _frameStack.panelStack.Size() do
            local _p = _frameStack.panelStack.ObjectAtIndex(i)
            PushUIFrames.Animations.EnableAnimationForFrame(_p)
            PushUIFrames.Animations.AddStage(_p, _eraseAnimationName)
            _p.AnimationStage(_eraseAnimationName).EnableTranslation(0.35, 
                _skipSize * _frameStack.__abs, 0)
            _skipSize = _skipSize + _p:GetWidth() + _frameStack._padding
            _p.PlayAnimationStage(_eraseAnimationName)
        end
    end

    return _frameStack
end

PushUIFrames.DockFrame.CreateNewDock = function(name, color, tintSide, panelStack, tintStack)
    local _dock = {}
    local _dockTintFrame = CreateFrame("Button", name.."Tint", tintStack)
    local _dockNormalPanel = CreateFrame("Frame", name.."Panel", panelStack)
    local _dockPanelTint = CreateFrame("Button", name.."PanelTint", _dockNormalPanel)
    local _dockFloatPanel = CreateFrame("Frame", name.."FloatPanel", tintStack)
    _dockNormalPanel:SetFrameStrata("BACKGROUND")
    _dockPanelTint:SetFrameStrata("TOOLTIP")
    _dockTintFrame:SetFrameStrata("TOOLTIP")
    _dockFloatPanel:SetFrameStrata("TOOLTIP")

    _dock.panelAvailable = true
    _dock.floatAvailable = true
    _dock.tintOnLeftClick = nil
    _dock.tintOnRightClick = nil

    _dock.tintBar = _dockTintFrame
    _dock.panel = _dockNormalPanel
    _dock.panel.tintBar = _dockPanelTint
    _dock.floatPanel = _dockFloatPanel
    
    _dockTintFrame.dock = _dock
    _dockNormalPanel.dock = _dock
    _dockPanelTint.dock = _dock
    _dockFloatPanel.dock = _dock

    -- Init Style
    _dockFloatPanel:SetPoint("BOTTOM", _dockTintFrame, "TOP", 0, 5)

    if tintSide == "TOP" then
        _dockPanelTint:SetPoint("BOTTOM", _dockNormalPanel, "TOP", 0, 2)
        _dockPanelTint:SetPoint("BOTTOMLEFT", _dockNormalPanel, "TOPLEFT", 0, 0)
        _dockPanelTint:SetPoint("BOTTOMRIGHT", _dockNormalPanel, "TOPRIGHT", 0, 0)
    else
        _dockPanelTint:SetPoint("TOP", _dockNormalPanel, "BOTTOM", 0, -2)
        _dockPanelTint:SetPoint("TOPLEFT", _dockNormalPanel, "BOTTOMLEFT", 0, 0)
        _dockPanelTint:SetPoint("TOPRIGHT", _dockNormalPanel, "BOTTOMRIGHT", 0, 0)
    end

    _dockPanelTint:SetHeight(8)
    _dockTintFrame:SetWidth(32)
    _dockTintFrame:SetHeight(20)
    local _r,_g,_b,_a = unpack(color)
    if _a == nil then _a = 1 end

    PushUIStyle.BackgroundSolidFormat(
        _dockTintFrame, 
        _r,_g,_b,_a,
        0, 0, 0, 1      -- Black border
        )
    PushUIStyle.BackgroundSolidFormat(
        _dockPanelTint,
        _r,_g,_b,_a,
        0, 0, 0, 0.3
        )

    _dockNormalPanel:SetAlpha(0)
    _dockFloatPanel:SetAlpha(0)
    _dockPanelTint:SetAlpha(0)
    _dockNormalPanel:SetHeight(panelStack:GetHeight())

    _dock.panelStack = panelStack
    _dock.tintStack = tintStack

    -- Set Animation For Float Panel
    PushUIFrames.Animations.EnableAnimationForFrame(_dockFloatPanel)
    PushUIFrames.Animations.AddStage(_dockFloatPanel, "OnTintEnterToDisplay")
    _dockFloatPanel.AnimationStage("OnTintEnterToDisplay").EnableFade(0.3, 1)

    PushUIFrames.Animations.AddStage(_dockFloatPanel, "OnTintLeaveToHide")
    _dockFloatPanel.AnimationStage("OnTintLeaveToHide").EnableFade(0.3, 0)

    _dockTintFrame:EnableMouse(true)
    _dockPanelTint:EnableMouse(true)

    _dockTintFrame:SetScript("OnEnter", function(tint, ...)
        if _dock.floatAvailable == false then return end
        local _d = tint.dock
        local _f = _d.floatPanel
        if _f.WillAppear then _f.WillAppear(_f) end
        -- Do animate to display the float
        _f.CancelAnimationStage("OnTintLeaveToHide")
        _f.PlayAnimationStage("OnTintEnterToDisplay", function(self, ...)
            if _f.DidAppear then _f.DidAppear(_f) end
        end)
    end)

    _dockTintFrame:SetScript("OnLeave", function(tint, ...)
        if _dock.floatAvailable == false then return end
        local _d = tint.dock
        local _f = _d.floatPanel
        --_f:SetPoint("BOTTOM", tint, "TOP", 0, -5)
        if _f.WillDisappear then _f.WillDisappear(_f) end

        _f.CancelAnimationStage("OnTintEnterToDisplay")
        _f.PlayAnimationStage("OnTintLeaveToHide", function(self, ...)
            if _f.DidDisappear then _f.DidDisappear(_f) end
            _f:Hide()
        end)
    end)

    -- Enable Animation for panel
    PushUIFrames.Animations.EnableAnimationForFrame(_dockNormalPanel)
    PushUIFrames.Animations.AddStage(_dockNormalPanel, "OnClickToShow")
    _dockNormalPanel.AnimationStage("OnClickToShow").EnableFade(0.3, 1)

    PushUIFrames.Animations.AddStage(_dockNormalPanel, "OnClickToHide")
    _dockNormalPanel.AnimationStage("OnClickToHide").EnableFade(0.3, 0)

    PushUIFrames.Animations.EnableAnimationForFrame(_dockTintFrame)
    PushUIFrames.Animations.AddStage(_dockTintFrame, "AfterPanelShow")
    _dockTintFrame.AnimationStage("AfterPanelShow").EnableFade(0.3, 0)

    PushUIFrames.Animations.AddStage(_dockTintFrame, "WhilePanelHiding")
    _dockTintFrame.AnimationStage("WhilePanelHiding").EnableFade(0.3, 1)

    -- Click the tint icon
    _dockTintFrame:SetScript("OnMouseDown", function(tint, ...)
        local _d = tint.dock
        local _p = _d.panel

        if _d.panelAvailable then

            if _p.WillAppear then _p.WillAppear(_p) end

            local _f = _d.floatPanel
            --_f:SetPoint("BOTTOM", tint, "TOP", 0, -5)
            if _f.WillDisappear then _f.WillDisappear(_f) end
            _f.CancelAnimationStage("OnTintEnterToDisplay")
            _f.CancelAnimationStage("OnTintLeaveToHide")
            _f:SetAlpha(0)
            if _f.DidDisappear then _f.DidDisappear(_f) end

            -- Do Animate
            _d.panelStack.Push(_p, "OnClickToShow", function(self, ...)
                if _p.DidAppear then _p.DidAppear() end
                tint.PlayAnimationStage("AfterPanelShow", function(...)
                    _d.tintStack.Erase(tint)
                end)
            end)
        end

        local _button = ...
        if _button == "LeftButton" and _d.tintOnLeftClick then
            _d.tintOnLeftClick(_d)
        end
        if _button == "RightButton" and _d.tintOnRightClick then
            _d.tintOnRightClick(_d)
        end
    end)

    PushUIFrames.Animations.EnableAnimationForFrame(_dockPanelTint)
    PushUIFrames.Animations.AddStage(_dockPanelTint, "OnMouseEnter")
    _dockPanelTint.AnimationStage("OnMouseEnter").EnableFade(0.3, 1)
    PushUIFrames.Animations.AddStage(_dockPanelTint, "OnMouseLeave")
    _dockPanelTint.AnimationStage("OnMouseLeave").EnableFade(0.3, 0)

    _dockPanelTint:SetScript("OnClick", function(paneltint, ...)
        local _p = paneltint.dock.panel
        local _d = _p.dock
        local _t = _d.tintBar

        if _p.AnimationStage("OnClickToHide"):IsPlaying() then return end

        if _p.WillDisappear then _p.WillDisappear(_p) end

        _d.panelStack.Erase(_p, "OnClickToHide", function(...)
            if _p.DidDisappear then _p.DidDisappear(_p) end
            _d.tintStack.Push(_t, "WhilePanelHiding", function(...)
                -- log
            end)
        end)
    end)

    _dockPanelTint:SetScript("OnEnter", function(pt, ...)
        pt.CancelAnimationStage("OnMouseLeave")
        pt.PlayAnimationStage("OnMouseEnter")
    end)
    _dockPanelTint:SetScript("OnLeave", function(pt, ...)
        pt.CancelAnimationStage("OnMouseEnter")
        pt.PlayAnimationStage("OnMouseLeave")
    end)

    return _dock
end
