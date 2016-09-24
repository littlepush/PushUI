local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIFrames.AnimationStage = PushUIAPI.inhiert()
function PushUIFrames.AnimationStage:__create_snapshot()
    self._snapshot.alpha = self._relativelayer:GetAlpha()
    self._snapshot.scale_h, self._snapshot.scale_v = self._relativelayer:GetScale()
    local _a, _p, _pa, _x, _y = self._relativelayer:GetPoint()
    self._snapshot.archor = _a
    self._snapshot.parent = _p
    self._snapshot.parent_archor = _pa
    self._snapshot.x = _x
    self._snapshot.y = _y

    if self._relativelayer.GetRotation then
        self._snapshot.r = self._relativelayer:GetRotation()
    end
end

function PushUIFrames.AnimationStage:__finialized()
    print("In finialized")
    if self._fade then
        self._relativelayer:SetAlpha(self._fade:GetToAlpha())
    end
    print(self._relativelayer:GetScale())
    if self._scale then
        print(self._scale:GetToScale())
        self._relativelayer:SetScale(self._scale:GetToScale())
    end
    if self._rotation and self._relativelayer.GetRotation then
        self._relativelayer:SetRotation(self._rotation:GetRadians())
    end
    if self._translation then
        self._relativelayer:ClearAllPoints()
        self._relativelayer:SetPoint(
            self._snapshot.archor,
            self._snapshot.parent,
            self._snapshot.parent_archor,
            self._translation._toX,
            self._translation._toY)
    end
    self._fade = nil
    self._scale = nil
    self._translation = nil
    self._rotation = nil
end
function PushUIFrames.AnimationStage.__did_finish(ag)
    print("finished")
    ag.stage:__finialized()
    if ag.stage._handle then ag.stage._handle(ag.stage._relativeObj, true) end
end

function PushUIFrames.AnimationStage.__did_cancel(ag)
    print("canceled")
    ag.stage:__finialized()
    if ag.stage._handle then ag.stage._handle(ag.stage._relativeObj, false) end
end

function PushUIFrames.AnimationStage:play(duration, on_complete)
    self:stop()

    self._handle = on_complete
    self:__create_snapshot()

    if self._fade then self._fade:SetDuration(duration) end
    if self._scale then self._scale:SetDuration(duration) end
    if self._rotation then self._rotation:SetDuration(duration) end
    if self._translation then self._translation:SetDuration(duration) end

    if self._fade or self._scale or self._rotation or self._translation then
        self._agroup:SetScript("OnFinished", PushUIFrames.AnimationStage.__did_finish)
        self._agroup:SetScript("OnStop", PushUIFrames.AnimationStage.__did_cancel)
        self._agroup:Play()
    end
end

function PushUIFrames.AnimationStage:stop()
    if self._agroup:IsPlaying() then
        self:__create_snapshot()
        self._agroup:Stop()
    end
end

function PushUIFrames.AnimationStage:is_playing()
    return self._agroup:IsPlaying()
end

function PushUIFrames.AnimationStage:set_fade(to_alpha)
    if not self._fade then
        self._fade = self._agroup:CreateAnimation("Alpha")
        self._fade:SetFromAlpha(self._relativelayer:GetAlpha())
        self._fade:SetSmoothing("IN_OUT")
    end
    self._fade:SetToAlpha(to_alpha)
end

function PushUIFrames.AnimationStage:set_scale(h, v, origin, x, y)
    local _hrate = h or 1
    local _vrate = v or 1
    local _origin = "CENTER"
    local _x = 0
    local _y = 0
    if nil ~= origin then _origin = origin end
    if nil ~= x then _x = x end
    if nil ~= y then _y = y end
    if not self._scale then
        self._scale = self._agroup:CreateAnimation("Scale")
        self._scale:SetSmoothing("IN_OUT")
    end
    print("h/v: ".._hrate.."/".._vrate)
    print("o, x, y: ".._origin..", ".._x..", ".._y)
    self._scale:SetToScale(_hrate, _vrate)
    self._scale:SetOrigin(_origin, _x, _y)
end

function PushUIFrames.AnimationStage:set_rotation(r)
    if not self._relativelayer.GetRotation then return end
    if not self._rotation then
        self._rotation = self._agroup:CreateAnimation("Rotation")
    end
    self._rotation:SetRadians(r)
end

function PushUIFrames.AnimationStage:set_translation(to_x, to_y)
    if not self._translation then
        self._translation = self._agroup:CreateAnimation("Translation")
        self._translation:SetSmoothing("IN_OUT")
    end
    self._translation._toX = to_x
    self._translation._toY = to_y
end


function PushUIFrames.AnimationStage:c_str(view)
    print("In animation initialize")

    if not view then 
        print("No view to create animation")
    end
    if not view then return end
    local _layer = view.layer
    if not _layer then
        print("the view is not a uiview")
    end
    if not view.layer then _layer = view end
    self._relativeObj = view
    self._relativelayer = _layer
    self._agroup = _layer:CreateAnimationGroup()
    self._agroup.stage = self

    if not self._agroup then
        print("failed to craete animation group")
    end

    self._fade = nil
    self._scale = nil
    self._translation = nil
    self._rotation = nil

    self._snapshot = {}
end

-- by Push Chen
-- twitter: @littlepush

