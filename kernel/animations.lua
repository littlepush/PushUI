local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIFrames.Animations = {}
PushUIFrames.Animations._fade = function(ag, duration, to_alpha)
    local _a = ag:CreateAnimation("Alpha")
    _a:SetOrder(1)
    _a:SetToAlpha(to_alpha)
    _a:SetOrder(1)
    _a:SetDuration(duration)
    _a:SetSmoothing("IN_OUT")

    _a.__uiInit = function()
        _a.__savedFromAlpha = ag.affectFrame:GetAlpha()
    end
    _a.__uiFinished = function()
        ag.affectFrame:SetAlpha(_a:GetToAlpha())
    end
    _a.__uiWillCancel = function()
        _a.__savedAlpha = (_a:GetToAlpha() - _a.__savedFromAlpha) * _a:GetProgress()
    end
    _a.__uiDidCancel = function()
        ag.affectFrame:SetAlpha(_a.__savedAlpha)
    end

    return _a
end
PushUIFrames.Animations._delayedFade = function(ag, duration, delay, to_alpha)
    local _a = ag:CreateAnimation("Alpha")
    _a:SetToAlpha(to_alpha)
    _a:SetOrder(#ag.__theOrderedAnimations + 1)
    _a:SetDuration(duration)
    _a:SetSmoothing("IN_OUT")
    _a:SetStartDelay(delay)

    _a.__uiInit = function() 
        _a.__savedFromAlpha = ag.affectFrame:GetAlpha()
    end
    _a.__uiFinished = function()
        ag.affectFrame:SetAlpha(_a:GetToAlpha())
    end
    _a.__uiWillCancel = function()
        _a.__savedAlpha = (_a:GetToAlpha() - _a.__savedFromAlpha) * _a:GetProgress()
    end
    _a.__uiDidCancel = function()
        ag.affectFrame:SetAlpha(_a.__savedAlpha)
    end

    return _a
end
PushUIFrames.Animations._scale = function(ag, duration, origin, rate)
    local _a = ag:CreateAnimation("Scale")
    _a:SetOrder(1)
    _a:SetDuration(duration)
    _a:SetToScale(rate, rate)
    _a:SetSmoothing("IN_OUT")
    _a:SetOrigin(origin, 0, 0)

    _a.__uiInit = function() 
        _a.__savedInitScale = ag.affectFrame:GetScale()
    end
    _a.__uiFinished = function()
        ag.affectFrame:SetScale(_a:GetToScale())
    end
    _a.__uiWillCancel = function()
        local _ts = _a:GetToScale()
        local _p = _a:GetProgress()
        _a.__savedScale = (_ts - _a.__savedInitScale) * _p
        if _a.__savedScale < 0 then _a.__savedScale = _a.__savedScale * -1 end
        if _a.__savedScale == 0 then _a.__savedScale = _a.__savedInitScale end
    end
    _a.__uiDidCancel = function()
        ag.affectFrame:SetScale(_a.__savedScale)
    end

    return _a
end
PushUIFrames.Animations._delayedScale = function(ag, duration, delay, origin, rate)
    local _a = ag:CreateAnimation("Scale")
    _a:SetOrder(#ag.__theOrderedAnimations + 1)
    _a:SetDuration(duration)
    _a:SetToScale(rate, rate)
    _a:SetSmoothing("IN_OUT")
    _a:SetOrigin(origin, 0, 0)
    _a:SetStartDelay(delay)

    _a.__uiInit = function() 
        _a.__savedInitScale = ag.affectFrame:GetScale()
    end
    _a.__uiFinished = function()
        ag.affectFrame:SetScale(_a:GetToScale())
    end
    _a.__uiWillCancel = function()
        local _ts = _a:GetToScale()
        local _p = _a:GetProgress()
        _a.__savedScale = (_ts - _a.__savedInitScale) * _p
        if _a.__savedScale < 0 then _a.__savedScale = _a.__savedScale * -1 end
        if _a.__savedScale == 0 then _a.__savedScale = _a.__savedInitScale end
    end
    _a.__uiDidCancel = function()
        ag.affectFrame:SetScale(_a.__savedScale)
    end

    return _a
end
PushUIFrames.Animations._translation = function(ag, duration, to_x, to_y)
    local _a = ag:CreateAnimation("Translation")
    _a:SetOrder(1)
    _a:SetDuration(duration)
    _a:SetOffset(0, 0)
    _a:SetSmoothing("IN_OUT")
    _a.__toX = to_x
    _a.__toY = to_y

    _a.__uiInit = function()
        local _p, _rt, _rtp, _x, _y = ag.affectFrame:GetPoint()
        _a.__p = _p
        _a.__rt = _rt
        _a.__rtp = _rtp
        _a.__x = _x
        _a.__y = _y
        _a:SetOffset(_a.__toX - _x, _a.__toY - _y)
    end
    _a.__uiFinished = function()
        ag.affectFrame:SetPoint(_a.__p, _a.__rt, _a.__rtp, _a.__toX, _a.__toY)
    end
    _a.__uiWillCancel = function()
        local _p = _a:GetProgress()
        local _ox, _oy = _a:GetOffset()
        _ox = _ox * _p
        _oy = _oy * _p
        _a.__savedToX = _ox + _a.__x
        _a.__savedToY = _oy + _a.__y
    end
    _a.__uiDidCancel = function ()
        ag.affectFrame:SetPoint(_a.__p, _a.__rt, _a.__rtp, _a.__savedToX, _a.__savedToY)
    end

    return _a
end
PushUIFrames.Animations._delayedTranslation = function(ag, duration, delay, to_x, to_y)
    local _a = ag:CreateAnimation("Translation")
    _a:SetOrder(#ag.__theOrderedAnimations + 1)
    _a:SetDuration(duration)
    _a:SetOffset(0, 0)
    _a:SetSmoothing("IN_OUT")
    _a.__toX = to_x
    _a.__toY = to_y

    _a.__uiInit = function()
        local _p, _rt, _rtp, _x, _y = ag.affectFrame:GetPoint()
        _a.__p = _p
        _a.__rt = _rt
        _a.__rtp = _rtp
        _a.__x = _x
        _a.__y = _y
        _a:SetOffset(_a.__toX - _x, _a.__toY - _y)
    end
    _a.__uiFinished = function()
        ag.affectFrame:SetPoint(_a.__p, _a.__rt, _a.__rtp, _a.__toX, _a.__toY)
    end
    _a.__uiWillCancel = function()
        local _p = _a:GetProgress()
        local _ox, _oy = _a:GetOffset()
        _ox = _ox * _p
        _oy = _oy * _p
        _a.__savedToX = _ox + _a.__x
        _a.__savedToY = _oy + _a.__y
    end
    _a.__uiDidCancel = function ()
        ag.affectFrame:SetPoint(_a.__p, _a.__rt, _a.__rtp, _a.__savedToX, _a.__savedToY)
    end

    return _a
end

PushUIFrames.Animations.EnableAnimationForFrame = function(frame)
    if frame._animations then return end
    frame._animations = {}

    frame.PlayAnimationStage = function(stage_name, on_finished)
        if not frame._animations[stage_name] then return end

        local _stage = frame._animations[stage_name]
        if _stage.__isOrdered == false then
            for i, a in ipairs(_stage.__theAnimations) do
                a.__uiInit()
            end
        else
            for i, a in ipairs(_stage.__theOrderedAnimations) do
                a.__uiInit()
            end
        end
        -- Frame must is shown
        frame:Show()

        _stage._this_time_finished = on_finished
        _stage:Play()
    end

    frame.CancelAnimationStage = function(stage_name)
        if not frame._animations[stage_name] then return end

        local _stage = frame._animations[stage_name]
            if _stage:IsPlaying() then
            if _stage.__isOrdered == false then
                for i, a in ipairs(_stage.__theAnimations) do
                    a.__uiWillCancel()
                end
            else
                for i, a in ipairs(_stage.__theOrderedAnimations) do
                    a.__uiWillCancel()
                end
            end
            _stage:Stop()
        end
    end

    frame.AnimationStage = function(stage_name)
        return frame._animations[stage_name]
    end

end

PushUIFrames.Animations.DisableAnimationForFrame = function(frame)
    if not frame._animations then return end
    for i = 1, #frame._animations do
        frame._animations[i] = nil
    end
    frame.PlayAnimationStage = function(...)
        print("Animation not enalbed on this frame")
    end
end

PushUIFrames.Animations.AddStage = function(frame, stage_name)
    if not frame._animations then return end
    if frame._animations[stage_name] then return end
    frame._animations[stage_name] = frame:CreateAnimationGroup()
    frame._animations[stage_name].__isOrdered = false
    frame._animations[stage_name].affectFrame = frame
    frame._animations[stage_name].stageName = stage_name
    frame._animations[stage_name]:SetScript("OnFinished", function(self)
        local _f = self.affectFrame
        if _f._animations[stage_name]._this_time_finished then
            _f._animations[stage_name]._this_time_finished(_f, self.stageName)
        end
        _f._animations[stage_name]._this_time_finished = nil

        local _stage = _f._animations[stage_name]
        for i, a in ipairs(_stage.__theAnimations) do
            a.__uiFinished()
        end
    end)
    frame._animations[stage_name]:SetScript("OnStop", function(self)
        local _f = self.affectFrame
        _f._animations[stage_name]._this_time_finished = nil

        local _stage = _f._animations[stage_name]
        for i, a in ipairs(_stage.__theAnimations) do
            a.__uiDidCancel()
        end
    end)

    -- Animations
    local _stage = frame._animations[stage_name]    
    _stage.__theAnimations = {}

    -- FadeIn/Out
    _stage.EnableFade = function(duration, toAlpha)
        if _stage.__theFade then 
            _stage.__theFade:SetDuration(duration)
            _stage.__theFade:SetToAlpha(toAlpha)
        else
            local _a = PushUIFrames.Animations._fade(_stage, duration, toAlpha)
            _stage.__theFade = _a
            _stage.__theAnimations[#_stage.__theAnimations + 1] = _a
        end
    end
    -- Scale
    _stage.EnableScale = function(duration, scale, origin)
        if not origin then
            origin = "CENTER"
        end
        if _stage.__theScale then
            _stage.__theScale:SetDuration(duration)
            _stage.__theScale:SetToScale(scale, scale)
            _stage.__theScale:SetOrigin(origin, 0, 0)
        else
            local _a = PushUIFrames.Animations._scale(_stage, duration, origin, scale)
            _stage.__theScale = _a
            _stage.__theAnimations[#_stage.__theAnimations + 1] = _a
        end
    end
    _stage.EnableTranslation = function(duration, to_x, to_y)
        if _stage.__theTranslationAnimation then
            _stage.__theTranslationAnimation:SetDuration(duration)
            _stage.__theTranslationAnimation.__toX = to_x
            _stage.__theTranslationAnimation.__toY = to_y
            _stage.__theTranslationAnimation:SetOffset(to_x, to_y)
        else
            local _a = PushUIFrames.Animations._translation(_stage, duration, to_x, to_y)
            _stage.__theTranslationAnimation = _a
            _stage.__theAnimations[#_stage.__theAnimations + 1] = _a
        end
    end
end

PushUIFrames.Animations.AddOrderedStage = function(frame, stage_name)
    if not frame._animations then return end
    if frame._animations[stage_name] then return end
    frame._animations[stage_name] = frame:CreateAnimationGroup()
    frame._animations[stage_name].__isOrdered = true
    frame._animations[stage_name].affectFrame = frame
    frame._animations[stage_name].stageName = stage_name
    frame._animations[stage_name]:SetScript("OnFinished", function(self)
        local _f = self.affectFrame
        if _f._animations[stage_name]._this_time_finished then
            _f._animations[stage_name]._this_time_finished(_f, self.stageName)
        end
        _f._animations[stage_name]._this_time_finished = nil

        local _stage = self
        for i, a in ipairs(_stage.__theOrderedAnimations) do
            a.__uiFinished()
        end
    end)
    frame._animations[stage_name]:SetScript("OnStop", function(self)
        local _f = self.affectFrame
        _f._animations[stage_name]._this_time_finished = nil

        local _stage = self
        for i, a in ipairs(_stage.__theOrderedAnimations) do
            a.__uiDidCancel()
        end
    end)

    -- Play In Order
    local _stage = frame._animations[stage_name]    
    _stage.__in_order_last_duration = 0
    _stage.__theOrderedAnimations = {}
    _stage.EnableFadeInOrder = function(duration, toAlpha)
        local _a = PushUIFrames.Animations._delayedFade(_stage, duration, _stage.__in_order_last_duration, toAlpha)
        _stage.__in_order_last_duration = _stage.__in_order_last_duration + duration
        _stage.__theOrderedAnimations[#_stage.__theOrderedAnimations + 1] = _a
    end
    _stage.EnableScaleInOrder = function(duration, scale, origin)
        if not origin then
            origin = "CENTER"
        end
        local _a = PushUIFrames.Animations._delayedScale(_stage, duration, _stage.__in_order_last_duration, origin, scale)
        _stage.__in_order_last_duration = _stage.__in_order_last_duration + duration
        _stage.__theOrderedAnimations[#_stage.__theOrderedAnimations + 1] = _a
    end
    _stage.EnableTranslationInOrder = function(duration, to_x, to_y)
        local _a = PushUIFrames.Animations._delayedTranslation(_stage, duration, _stage.__in_order_last_duration, to_x, to_y)
        _stage.__in_order_last_duration = _stage.__in_order_last_duration + duration
        _stage.__theOrderedAnimations[#_stage.__theOrderedAnimations + 1] = _a
    end
end

PushUIFrames.Animations.RemoveStage = function(frame, stage_name)
    if not frame._animations then return end
    if not frame._animations[stage_name] then return end
    frame._animations[stage_name] = nil
end
