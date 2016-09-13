local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIFrames.__allTempFrameCount = 0
function PushUIFrames:GetNewFrameName()
    PushUIFrames.__allTempFrameCount = PushUIFrames.__allTempFrameCount + 1
    return "PushUIFrame_TempFrame_"..PushUIFrames.__allTempFrameCount
end

PushUIFrames.Frame = {}
PushUIFrames.Button = {}
PushUIFrames.ProgressBar = {}
PushUIFrames.Label = {}

PushUIFrames.Timer = {}
PushUIFrames.Timer.Create = function(interval, handler)
    interval = interval or 1
    local _tf = CreateFrame("Frame")

    _tf.__interval = 1
    _tf.__lastFiredTime = time()
    _tf.__handler = handler

    function _tf:StartTimer()
        _tf:SetScript("OnUpdate", function(...)
            local _time = time()
            if _time - _tf.__lastFiredTime >= _tf.__interval then
                _tf.__lastFiredTime = _time
                if _tf.__handler then _tf.__handler() end
            end
        end)
    end

    function _tf:StopTimer()
        _tf:SetScript("OnUpdate", nil)
    end

    function _tf:SetInterval(int)
        _tf.__interval = int
    end

    function _tf:SetHandler(func)
        _tf.__handler = func
    end

    return _tf
end

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
                        if _pb:GetParent().Resize then
                            _pb:GetParent().ReSize()
                        end
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

PushUIFrames.Label.Create = function(name, parent, autoResizeParent)
    if nil == autoResizeParent then autoResizeParent = false end
    local _lb = CreateFrame("Frame", name, parent)
    _lb.__autoresize = autoResizeParent
    _lb.__padding = 5
    _lb:SetParent(parent)
    _lb.__forceWidth = 0
    _lb.__forceHeight = 0

    local _fs = _lb:CreateFontString()
    _lb.__text = _fs

    _lb.__resize = function()
        if _lb.__forceWidth ~= 0 then
            _lb.__text:SetWidth(_lb.__forceWidth - 2 * _lb.__padding)
            _lb:SetWidth(_lb.__forceWidth)
        else
            _lb.__text:SetWidth(0)
            local _fw = _lb.__text:GetStringWidth()
            _lb.__text:SetWidth(_fw)
            _lb:SetWidth(_fw + 2 * _lb.__padding)
        end

        if _lb.__forceHeight ~= 0 then
            _lb.__text:SetHeight(_lb.__forceHeight - 2 * _lb.__padding)
            _lb:SetHeight(_lb.__forceHeight)
        else
            _lb.__text:SetHeight(0)
            local _fh = _lb.__text:GetStringHeight()
            _lb.__text:SetHeight(_fh)
            _lb:SetHeight(_fh + 2 * _lb.__padding)
        end

        _lb.__text:ClearAllPoints()
        _lb.__text:SetPoint("TOPLEFT", _lb, "TOPLEFT", _lb.__padding, -_lb.__padding)
        if _lb.__autoresize then
            local _p = _lb:GetParent()
            _p:SetWidth(_lb:GetWidth())
            _p:SetHeight(_lb:GetHeight())
        end
    end

    _lb.SetForceWidth = function(w)
        _lb.__forceWidth = w
        _lb.__resize()
    end

    _lb.SetForceHeight = function(h)
        _lb.__forceHeight = h
        _lb.__resize()
    end

    _lb.SetTextString = function(text)
        local _f = _lb.__text
        _f:SetText(text)
        _lb.__resize()
    end

    _lb.SetPadding = function(padding)
        _lb.__padding = padding
        _lb.__resize()
    end

    _lb.SetMaxLines = function(lines)
        _lb.__text:SetMaxLines(lines)
        _lb.__resize()
    end

    _lb.SetTextColor = function(...)
        _lb.__text:SetTextColor(...)
    end

    _lb.SetJustifyH = function(...)
        _lb.__text:SetJustifyH(...)
    end

    _lb.SetFont = function(fn, fs, fo)
        local _n, _s, _o = _lb.__text:GetFont()
        if fn ~= nil then
            _n = fn
        end
        if _n == nil then _n = "Fonts\\ARIALN.TTF" end

        if fs ~= nil and fs > 1 then
            _s = fs
        end
        if _s == nil or _s < 1 then _s = 14 end
        if fo ~= nil then
            _o = fo
        end
        if _o == nil or _o == "" then _o = "OUTLINE" end
        _lb.__text:SetFont(_n, _s, _o)

        _lb.__resize()
    end

    -- Default padding is 5
    _lb.SetPadding(5)
    _lb.SetMaxLines(10)
    _lb.SetFont()
    _lb.SetTextColor(1, 1, 1, 1)

    return _lb
end

PushUIFrames.UIView = {}
PushUIFrames.UIView.Create = function(name, parent)
    if not name then 
        name = PushUIFrames:GetNewFrameName()
    end
    parent = parent or UIParent
    local _frame = CreateFrame("Frame", name, parent)
    _frame.__type = "UIFrame"

    _frame.__backgroundColor = {0, 0, 0, 0}
    _frame.__borderColor = {0, 0, 0, 0}
    _frame.__borderWidth = 1

    _frame.__backdrop = {
        bgFile = PushUIStyle.TextureClean,
        edgeFile = PushUIStyle.TextureClean,
        tile = true,
        tileSize = 10,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    }

    -- Timer
    _frame.__delayTimerPool = PushUIAPI.Pool.New()
    _frame.__delayTimerPool.SetCreateDelegate(function()
        return PushUIFrames.Timer.Create()
    end)

    -- Animation Stage
    _frame.__currentAnimationStage = nil
    _frame.__currentAnimationDuration = 0
    _frame.__allTempAnimationCount = 0
    _frame.__animationStageNamePool = PushUIAPI.Pool.New()
    _frame.__animationStageNamePool.SetCreateDelegate(function()
        _frame.__allTempAnimationCount = _frame.__allTempAnimationCount + 1
        return name.."TempAnimation".._frame.__allTempAnimationCount
    end)

    _frame.SetBackgroundColor = function(colorPack)
        local _r, _g, _b, _a = unpack(colorPack)
        if _a == nil then _a = 1 end
        frame:SetBackdropColor(_r, _g, _b, _a)
    end
    function _frame:SetBackgroundColor(...) _frame.SetBackgroundColor(...) end

    _frame.SetBorderColor = function(colorPack)
        local _r, _g, _b, _a = unpack(colorPack)
        if _a == nil then _a = 1 end
        _frame:SetBackdropBorderColor(_r, _g, _b, _a)
    end
    function _frame:SetBorderColor(...) _frame.SetBorderColor(...) end

    _frame.SetBorderWidth = function(width)
        if width < 0 then width = 0 end
        _frame.__backdrop.edgeSize = width
        _frame.__backdrop.insets = { left = -width, right = -width, top = -width, bottom = -width }
        _frame:SetBackdrop(_frame.__backdrop)
    end
    function _frame:SetBorderWidth(...) _frame.SetBorderWidth(...) end

    _frame.DelayToDo = function(sec, action)
        local _timer = _frame.__delayTimerPool.Get()
        _timer:SetInterval(sec)
        _timer:SetHandler(function()
            if action then action() end
            _timer:StopTimer()
            _frame.__delayTimerPool.Release(_timer)
        end)
        _timer:StartTimer()
    end
    function _frame:DelayToDo(...) _frame.DelayToDo(...) end

    _frame.UIType = function() return _frame.__type end
    function _frame:UIType() return _frame.__type end

    -- Animation
    _frame.animationFade = function(toAlpah)
        if not _frame.__currentAnimationStage then return end
        _frame.AnimationStage(_frame.__currentAnimationStage).EnableFade(_frame.__currentAnimationDuration, toAlpah)
    end
    function _frame:animationFade(...) _frame.animationFade(...) end

    _frame.animationScale = function(scale, origin)
        if not _frame.__currentAnimationStage then return end
        _frame.AnimationStage(_frame.__currentAnimationStage).EnableScale(_frame.__currentAnimationDuration, scale, origin)
    end
    function _frame:animationScale(...) _frame.animationScale(...) end

    _frame.animationTranslation = function(toX, toY)
        if not _frame.__currentAnimationStage then return end
        _frame.AnimationStage(_frame.__currentAnimationStage).EnableTranslation(_frame.__currentAnimationDuration, toX, toY)
    end
    function _frame:animationTranslation(...) _frame.animationTranslation(...) end

    _frame.AnimationWithDuration = function(duration, animation, completed)
        if not animation then return end

        -- Enable animation and add temp stage
        PushUIFrames.Animations.EnableAnimationForFrame(_frame)
        local _stageName = _frame.__animationStageNamePool.Get()
        PushUIFrames.Animations.AddStage(_frame, _stageName)

        _frame.__currentAnimationStage = _stageName
        _frame.__currentAnimationDuration = duration
        -- Do the animation
        animation()

        _frame.PlayAnimationStage(_stageName, function(_, _, isCompleted)
            _frame.__currentAnimationStage = nil
            _frame.AnimationStage(_stageName).DisableAllAnimations()
            if completed then completed(isCompleted) end
            _frame.__animationStageNamePool.Release(_stageName)
        end)
    end
    function _frame:AnimationWithDuration(...) _frame.AnimationWithDuration(...) end

    return _frame
end

PushUIFrames.UIButton = {}
PushUIFrames.UIButton.Create = function(name, parent)
    local _button = PushUIFrames.UIView.Create(name, parent)
end
