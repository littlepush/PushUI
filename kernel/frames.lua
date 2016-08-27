local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIFrames.Frame = {}
PushUIFrames.Button = {}
PushUIFrames.ProgressBar = {}

PushUIFrames.Frame.Create = function(name, config)
    local _f = CreateFrame("Frame", name, UIParent)
    PushUIFrames.AllFrames[#PushUIFrames.AllFrames + 1] = _f

    -- Bind the config
    if config then
        _f.Config = config
        config.HookFrame = _f
        if config.parent then
            if config.parent.HookFrame.ChildHookFrames then
                config.parent.HookFrame.ChildHookFrames[#config.parent.HookFrame.ChildHookFrames + 1] = _f
            end
        end
    end

    return _f
end

PushUIFrames.Button.Create = function(name, parent, config)
    local _p = parent or UIParent
    local _b = CreateFrame("Button", name, _p)

    if config then
        _b.Config = config
        config.HookFrame = _b
        if config.selected then
            _b:SetAlpha(PushUIColor.alphaAvailable)
        else
            _b:SetAlpha(PushUIColor.alphaDim)
        end

        if config.skin then
            config.skin(_b)
        end

        if _b.Config.binding and name then
            SetBindingClick(_b.Config.binding, _b:GetName())
        end
    end

    _b:SetScript("OnClick", function(self, ...)
        local _p = self:GetParent()
        if _p.OnButtonClick then
            _p.OnButtonClick(self, ...)
        end
    end)

    return _b
end

PushUIFrames.ProgressBar.Create = function(name, parent, config, orientation)
    local _p = parent or UIParent
    local _pb = CreateFrame("StatusBar", name, _p)
    local _o = orientation or "VERTICAL"

    _pb:SetMinMaxValues(0, 100)
    _pb:SetValue(50)
    _pb:SetOrientation(_o)
    _pb:SetStatusBarTexture(PushUIStyle.TextureClean)
    if _o == "VERTICAL" then
        _pb:GetStatusBarTexture():SetHorizTile(false)
    else
        _pb:GetStatusBarTexture():SetVertTile(false)
    end
    PushUIStyle.BackgroundFormatForProgressBar(_pb)


    if config then
        _pb.Config = config
        config.HookFrame = _pb

        --RegisterForDisplayStatus
        --RegisterForValueChanged
        --MaxValue
        --MinValue
        --Value
        --CanDisplay
        _pb.UpdateFillValueColor = function(index, target)
            repeat
                if #_pb.Config.fillColor >= index then
                    _pb:SetStatusBarColor(
                        unpack(_pb.Config.fillColor[index](
                            target.Value(), 
                            target.MaxValue(), 
                            target.MinValue()
                        ))
                    )
                    break
                end
                index = index - 1
                if index == 0 then
                    break
                end
            until true
        end
        _pb.OnDisplayStatusChanged = function(target, status)
            local _displayableTarget = nil
            local _displayableIndex = -1
            -- Find the first displayable target
            for _, t in pairs(_pb.Config.targets) do
                if t.CanDisplay() then 
                    _displayableIndex = _
                    _displayableTarget = t
                    break
                end
            end

            -- UnRegister all value changed event
            for _, t in pairs(_pb.Config.targets) do
                t.UnRegisterForValueChanged(_pb)
            end

            -- Hide on not show
            if not _displayableTarget then 
                _pb.Config.displayed = false
                if not _pb.Config.alwaysDisplay then
                    _pb:Hide()
                end
                return 
            end

            _pb.Config.displayed = true
            _pb:Show()

            _pb:SetMinMaxValues(
                _displayableTarget.MinValue(), 
                _displayableTarget.MaxValue()
            )
            _pb:SetValue(_displayableTarget.Value())
            _pb.UpdateFillValueColor(_displayableIndex, _displayableTarget)

            _displayableTarget.RegisterForValueChanged(_pb, function()
                _pb:SetMinMaxValues(_displayableTarget.MinValue(), _displayableTarget.MaxValue())
                _pb:SetValue(_displayableTarget.Value())
                _pb.UpdateFillValueColor(_displayableIndex, _displayableTarget)
            end)
        end

        if _pb.Config.targets then
            local _initidx = 0

            for idx, t in pairs(_pb.Config.targets) do
                local _chk = (
                    t.RegisterForDisplayStatus and 
                    t.RegisterForValueChanged and
                    t.MaxValue and
                    t.MinValue and
                    t.Value and
                    t.CanDisplay
                )
                -- The target is validate
                if _chk then
                    -- Set Displayed Status
                    _pb.Config.displayed = (
                        _pb.Config.displayed or 
                        t.CanDisplay() or 
                        _pb.Config.alwaysDisplay)

                    t.RegisterForDisplayStatus(_pb, function(status)
                        _pb.OnDisplayStatusChanged(t, status)
                        _pb:GetParent().ReSize()
                    end)

                    if _pb.Config.displayed and _initidx == 0 then
                        _initidx = idx

                        _pb:SetMinMaxValues(t.MinValue(), t.MaxValue())
                        _pb:SetValue(t.Value())
                        _pb.UpdateFillValueColor(idx, t)

                        t.RegisterForValueChanged(_pb, function()
                            _pb:SetMinMaxValues(t.MinValue(), t.MaxValue())
                            _pb:SetValue(t.Value())
                            _pb.UpdateFillValueColor(idx, t)
                        end)
                    end
                end
            end
        end
    end
    return _pb
end

-- Create and config for the bottom frame
PushUIFrames.BottomFrame = {}
PushUIFrames.BottomFrame.IsDisplayLeftSwitcher = function(frame)
    local _displayingLeftSwitcher = false
    for _, sw in pairs(frame.LeftSwitchers) do
        repeat
            if _displayingLeftSwitcher then break end
            if nil ~= sw.Config.displayed then
                _displayingLeftSwitcher = sw.Config.displayed
                break
            end
            if nil ~= sw.Config.alwaysDisplay then
                _displayingLeftSwitcher = sw.Config.alwaysDisplay
                break
            end
        until true
    end
    return _displayingLeftSwitcher
end
PushUIFrames.BottomFrame.IsDisplayRightSwitcher = function(frame)
    local _displayingRightSwitcher = false
    for _, sw in pairs(frame.RightSwitchers) do
        repeat
            if _displayingRightSwitcher then break end
            if nil ~= sw.Config.displayed then
                _displayingRightSwitcher = sw.Config.displayed
                break
            end
            if nil ~= sw.Config.alwaysDisplay then
                _displayingRightSwitcher = sw.Config.alwaysDisplay
                break
            end
        until true
    end
    return _displayingRightSwitcher
end

PushUIFrames.BottomFrame.GetDisplayRect = function(frame)
    local _swsize = 0
    local _lswsize = 0
    if frame.Config.switchers then
        local _lsw = PushUIFrames.BottomFrame.IsDisplayLeftSwitcher(frame)
        if _lsw then _swsize = _swsize + PushUISize.tinyButtonWidth + PushUISize.padding end
        _lswsize = _swsize
        local _rsw = PushUIFrames.BottomFrame.IsDisplayRightSwitcher(frame)
        if _rsw then _swsize = _swsize + PushUISize.tinyButtonWidth + PushUISize.padding end
    end

    local _w = frame:GetWidth()
    _w = _w - _swsize - PushUISize.padding * 2
    local _h = frame:GetHeight() - (PushUISize.padding * 2)
    local _x = PushUISize.padding + _lswsize
    local _y = -PushUISize.padding

    _w = _w * frame.Config.scale
    _h = _h * frame.Config.scale
    _x = _x * frame.Config.scale
    _y = _y * frame.Config.scale

    return _w, _h, _x, _y
end

PushUIFrames.BottomFrame.GetBlockRect = function(frame, index, count, align, be_square)
    local _bc = frame.Config.blockCount or 2
    local _w, _h, _x, _y = PushUIFrames.BottomFrame.GetDisplayRect(frame)
    local _scale = frame.Config.scale or 1
    local _p = PushUISize.padding * _scale
    local _square = false
    if nil ~= be_square then _square = be_square end
    local _align_left = true
    if nil ~= align then
        if align == "right" then
            _align_left = false
        end
    end

    local _dw = _w
    -- Block Width
    _w = (_w - ((count - 1) * _p)) / count
    if _square then
        if _h < _w then
            _w = _h
        else
            _h = _w
        end
    end

    -- X Position to TOP LEFT
    if _align_left == false then
        _x = _x + (_dw - (_w + _p) * index + _p)    -- last block has no padding
    else
        _x = _x + ((_w + _p) * (index - 1))
    end

    return _w, _h, _x, _y
end

PushUIFrames.BottomFrame.OnSwitcherClick = function(frame, switcher)
    local _c = frame.Config
    local _sc = switcher.Config

    -- No action defined
    if _sc.action == nil then
        return
    end

    local _sel = _sc.selected
    local _aa = not _sc.alwaysAction
    if _aa and _sel then return end

    local _myAlpha = PushUIColor.alphaAvailable
    local _otherAlpha = PushUIColor.alphaDim
    if _sel then
        _myAlpha = PushUIColor.alphaDim
        _otherAlpha = PushUIColor.alphaAvailable
    end

    local _sg = nil     -- switchers group
    local _sgc = false  -- switchers group config

    for _, sw in pairs(frame.LeftSwitchers) do
        if sw == switcher then 
            _sg = frame.LeftSwitchers
            if nil ~= _c.switchers.groupleft then
                _sgc = _c.switchers.groupleft
            end
        end
    end
    if not _sg then
        for _, sw in pairs(frame.RightSwitchers) do
            if sw == switcher then 
                _sg = frame.RightSwitchers 
                if nil ~= _c.switchers.groupright then
                    _sgc = _c.switchers.groupright
                end
            end
        end
    end

    -- the switcher is not in any group
    if not _sg then
        return
    end

    _sc.selected = not _sc.selected
    for _, tar in pairs(_sc.targets) do
        if tar.HookFrame then
            local _act = _sc.action
            if tar.HookFrame[_act] then
                tar.HookFrame[_act](_sc.selected)
            end
        end
    end
    switcher:SetAlpha(_myAlpha)

    -- Not grouped switcher
    if not _sgc then return end

    for _, sw in pairs(_sg) do
        if sw ~= switcher then
            sw.Config.selected = not _sc.selected
            for __, tar in pairs(sw.Config.targets) do
                if tar.HookFrame then
                    local _act = sw.Config.action
                    if tar.HookFrame[_act] then
                        tar.HookFrame[_act](sw.Config.selected)
                    end
                end
            end
            sw:SetAlpha(_otherAlpha)
        end
    end
end

PushUIFrames.BottomFrame.CreateSwitcher = function(frame)
    local _cfg = frame.Config
    if _cfg.switchers then
        if frame.Config.switchers.left then
            for _, scfg in pairs(frame.Config.switchers.left) do
                local _n = frame:GetName().."LeftSwitcher".._
                local _s = scfg.mode.Create(_n, frame, scfg)
                frame.LeftSwitchers[#frame.LeftSwitchers + 1] = _s
            end
        end
        if frame.Config.switchers.right then
            for _, scfg in pairs(frame.Config.switchers.right) do
                local _n = frame:GetName().."RightSwitcher".._
                local _s = scfg.mode.Create(_n, frame, scfg)
                frame.RightSwitchers[#frame.RightSwitchers + 1] = _s
            end
        end
    end
end

PushUIFrames.BottomFrame.ReSize = function(frame, is_left)
    local c = frame.Config
    local w = PushUISize.FormatWithPadding(
        c.blockCount,
        PushUISize.blockNormalWidth,
        PushUISize.padding
        )
    local h = PushUISize.FormatWithPadding(
        1,
        PushUISize.blockNormalHeight,
        PushUISize.padding
        )

    -- Calculate the switcher's position
    local _displayingLeftSwitcher = PushUIFrames.BottomFrame.IsDisplayLeftSwitcher(frame)
    if _displayingLeftSwitcher then
        w = w + PushUISize.tinyButtonWidth + PushUISize.padding
    end
    local _displayingRightSwitcher = PushUIFrames.BottomFrame.IsDisplayRightSwitcher(frame)
    if _displayingRightSwitcher then
        w = w + PushUISize.tinyButtonWidth + PushUISize.padding
    end

    frame:SetWidth(w * c.scale * PushUISize.Resolution.scale)
    frame:SetHeight(h * c.scale * PushUISize.Resolution.scale)

    local _points = {
        {"BOTTOMRIGHT", _G["PushUIFrameActionBarFrame"], "BOTTOMLEFT", -c.stickPadding, 0},
        {"BOTTOMLEFT", UIParent, "BOTTOMLEFT", c.stickPadding, PushUISize.screenBottomPadding},
        {"BOTTOMLEFT", _G["PushUIFrameActionBarFrame"], "BOTTOMRIGHT", c.stickPadding, 0},
        {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -c.stickPadding, PushUISize.screenBottomPadding}
    }
    local _anchor, _object, _objectAnchor, _xoffset, _yoffset

    if is_left then
        if not c.stickToActionBar then
            _anchor, _object, _objectAnchor, _xoffset, _yoffset = unpack(_points[2])
        else
            _anchor, _object, _objectAnchor, _xoffset, _yoffset = unpack(_points[1])
        end
    else
        if not c.stickToActionBar then
            _anchor, _object, _objectAnchor, _xoffset, _yoffset = unpack(_points[4])
        else
            _anchor, _object, _objectAnchor, _xoffset, _yoffset = unpack(_points[3])
        end
    end
    frame:ClearAllPoints()
    frame:SetPoint(_anchor, _object, _objectAnchor, _xoffset, _yoffset)

    local _p = PushUISize.padding * PushUISize.Resolution.scale * c.scale
    -- Resize the left switcher
    if _displayingLeftSwitcher then
        local _scount = #frame.LeftSwitchers
        local _sh = (h - PushUISize.padding) / _scount - PushUISize.padding
        local _sw = PushUISize.tinyButtonWidth
        _sw = _sw * c.scale * PushUISize.Resolution.scale
        _sh = _sh * c.scale * PushUISize.Resolution.scale
        local _sx = PushUISize.padding * c.scale * PushUISize.Resolution.scale
        local _sy = _sx

        for i = 1, _scount do
            local _s = frame.LeftSwitchers[i]
            if _s.Config.mode == PushUIFrames.ProgressBar then
                _s:SetWidth(_sw - 2)
                _s:SetHeight(_sh - 2)
                _s:SetPoint("TOPLEFT", frame, "TOPLEFT", _sx + 1, -(_sy + (_sh + _p) * (i - 1)) - 1)
            else
                _s:SetWidth(_sw)
                _s:SetHeight(_sh)
                _s:SetPoint("TOPLEFT", frame, "TOPLEFT", _sx, -(_sy + (_sh + _p) * (i - 1)))
            end
        end
    end

    if _displayingRightSwitcher then
        local _scount = #frame.RightSwitchers
        local _sh = (h - PushUISize.padding) / _scount - PushUISize.padding
        local _sw = PushUISize.tinyButtonWidth
        _sw = _sw * c.scale * PushUISize.Resolution.scale
        _sh = _sh * c.scale * PushUISize.Resolution.scale
        local _sx = PushUISize.padding * c.scale * PushUISize.Resolution.scale
        local _sy = _sx

        for i = 1, _scount do
            local _s = frame.RightSwitchers[i]
            if _s.Config.mode == PushUIFrames.ProgressBar then
                _s:SetWidth(_sw - 2)
                _s:SetHeight(_sh - 2)
                _s:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -_sx - 1, -(_sy + (_sh + _p) * (i - 1)) - 1)
            else
                _s:SetWidth(_sw)
                _s:SetHeight(_sh)
                _s:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -_sx, -(_sy + (_sh + _p) * (i - 1)))
            end
        end
    end
end

PushUIFrames.BottomFrame.Create = function(name, is_left, config)
    local _bf = PushUIFrames.Frame.Create(name, config)

    _bf:SetFrameStrata("BACKGROUND")
    _bf.LeftSwitchers = {}
    _bf.RightSwitchers = {}
    _bf.ChildHookFrames = {}

    _bf.GetBlockRect = function(...)
        return PushUIFrames.BottomFrame.GetBlockRect(_bf, ...)
    end

    _bf.InitializeSwitcher = function()
        PushUIFrames.BottomFrame.CreateSwitcher(_bf)
    end

    _bf.OnButtonClick = function(btn)
        PushUIFrames.BottomFrame.OnSwitcherClick(_bf, btn)
    end

    _bf.ReSize = function(...)
        PushUIFrames.BottomFrame.ReSize(_bf, is_left)
        for _, c in pairs(_bf.ChildHookFrames) do
            if c.ReSize then
                c.ReSize()
            end
        end
    end

    return _bf
end
