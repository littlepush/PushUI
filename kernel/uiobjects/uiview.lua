local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIFrames.UIView = {}
PushUIFrames.UIView.__index = self
function PushUIFrames.UIView:set_backgroundColor(color_pack)
    self.layer:SetBackdropColor(PushUIColor.unpackColor(color_pack))
end
function PushUIFrames.UIView:set_borderColor(color_pack)
    self.layer:SetBackdropBorderColor(PushUIColor.unpackColor(color_pack))
end
function PushUIFrames.UIView:set_borderWidth(width)
    if width < 0 then width = 0 end
    local _tempBackdrop = {
        bgFile = PushUIStyle.TextureClean,
        edgeFile = PushUIStyle.TextureClean,
        tile = true,
        tileSize = 10,
        edgeSize = 1,
        insets = { left = -width, right = -width, top = -width, bottom = -width }
    }
    self.layer:SetBackdrop(_tempBackdrop)
end
function PushUIFrames.UIView:set_gradientColor(from_color, to_color, v_or_h)
    if nil == v_or_h then v_or_h = "v" end
    if (v_or_h ~= "v") and (v_or_h ~= "h") then v_or_h = "v" end
    local _direction = "VERTICAL"
    if v_or_h == "h" then _direction = "HORIZONTAL" end

    if not self.layer.gradientTexture then
        self.layer.gradientTexture = self.layer:CreateTexture(nil, "BACKGROUND")
        self.layer.gradientTexture:SetTexture(PushUIStyle.TextureClean)
        self.layer.gradientTexture:SetAllPoints(self.layer)
    end

    self.layer.gradientTexture:SetGradientAlpha(
        _direction, 
        PushUIColor.unpackColor(to_color),
        PushUIColor.unpackColor(from_color)
        )
end
function PushUIFrames.UIView:set_width(w)
    self.layer:SetWidth(w)
end
function PushUIFrames.UIView:set_height(h)
    self.layer:SetHeight(h)
end
function PushUIFrames.UIView:set_size(w, h)
    self.layer:SetSize(w, h)
end
function PushUIFrames.UIView:set_archor_target(archor_obj, archor)
    if archor_obj then
        self._save_target_archor_obj = archor_obj
    end
    if archor then
        self._save_target_archor = archor
    end
    self:set_position()
end
function PushUIFrames.UIView:set_archor(archor)
    if archor then
        self._save_archor = archor
    end
    self:set_position()
end
function PushUIFrames.UIView:set_position(x, y)
    if self._doing_animation then
        self.layer.AnimationStage(self._current_animation_stage).EnableTranslation(
            self._animation_duration, x, y)
    else
        if nil ~= x then
            self._save_x = x
        end
        if nil ~= y then
            self._save_y = y
        end
        self.layer:ClearAllPoints()
        self.layer:SetPoint(
            self._save_archor, 
            self._save_target_archor_obj,
            self._save_target_archor,
            self._save_x,
            self._save_y)
    end
end
function PushUIFrames.UIView:set_alpha(alpha)
    if self._doing_animation then
        self.layer.AnimationStage(self._current_animation_stage).EnableFade(
            self._animation_duration, 
            alpha)
    else
        self.layer:SetAlhpa(alpha)
    end
end
function PushUIFrames.UIView:set_scale(scale)
    if self._doing_animation then
        self.layer.AnimationStage(self._current_animation_stage).EnableScale(
            self._animation_duration, scale)
    else
        self.layer:SetScale(scale)
    end
end

function PushUIFrames.UIView:animation_with_duration(duration, animation, complete)
    if not animation then return end
    if nil == duration or duration <= 0 then return end

    PushUIFrames.Animations.EnableAnimationForFrame(self.layer)
    if self._doing_animation then
        self.CancelAnimationStage(self._current_animation_stage)
    end

    self._doing_animation = true
    self._animation_duration = duration
    animation()

    self.layer.PlayAnimation(self._current_animation_stage, function(layer, stage_name, completed)
        if not completed then return end
        self._doing_animation = false
        self._animation_duration = 0
        layer.AnimationStage(stage_name).DisableAllAnimations()
        if complete then complete() end
    end)
end

function PushUIFrames.UIView.new(parent)
    local _mt = PushUIFrames.UIObject("Frame", parent)
    return setmetatable(_mt, PushUIFrames.UIView)
end

setmetatable(PushUIFrames.UIView, {
    __call = function(_, ...) return PushUIFrames.UIView.new(...) end
    })

-- by Push Chen
-- twitter: @littlepush
