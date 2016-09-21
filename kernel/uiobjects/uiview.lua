local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIFrames.UIView = PushUIAPI.inhiert(PushUIFrames.UIObject)

function PushUIFrames.UIView:set_backgroundColor(color_pack)
    self.layer:SetBackdropColor(PushUIColor.unpackColor(color_pack))
    self._backgroundColor = color_pack
end
function PushUIFrames.UIView:backgroundColor()
    return self._backgroundColor
end
function PushUIFrames.UIView:set_borderColor(color_pack)
    self.layer:SetBackdropBorderColor(PushUIColor.unpackColor(color_pack))
    self._borderColor = color_pack
end
function PushUIFrames.UIView:borderColor()
    return self._borderColor
end
function PushUIFrames.UIView:set_borderWidth(width)
    if width < 0 then width = 0 end
    local _tempBackdrop = {
        bgFile = PushUIStyle.TextureClean,
        edgeFile = PushUIStyle.TextureClean,
        tile = true,
        tileSize = 10,
        edgeSize = width,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    }
    self.layer:SetBackdrop(_tempBackdrop)
    self._borderWidth = width
    self.layer:SetBackdropColor(PushUIColor.unpackColor(self._backgroundColor))
    self.layer:SetBackdropBorderColor(PushUIColor.unpackColor(self._borderColor))
end
function PushUIFrames.UIView:borderWidth()
    return self._borderWidth
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
function PushUIFrames.UIView:width()
    return self.layer:GetWidth()
end
function PushUIFrames.UIView:set_height(h)
    self.layer:SetHeight(h)
end
function PushUIFrames.UIView:height()
    return self.layer:GetHeight()
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
    if nil ~= x then
        self._save_x = x
    end
    if nil ~= y then
        self._save_y = y
    end
    if self._doing_animation then
        self._animationStage:set_translation(x, y)
    else
        self.layer:ClearAllPoints()
        self.layer:SetPoint(
            self._save_archor, 
            self._save_target_archor_obj,
            self._save_target_archor,
            self._save_x,
            self._save_y)
    end
end
function PushUIFrames.UIView:position()
    return self._save_x, self._save_y
end
function PushUIFrames.UIView:set_alpha(alpha)
    if self._doing_animation then
        self._animationStage:set_fade(alpha)
    else
        self.layer:SetAlhpa(alpha)
    end
end
function PushUIFrames.UIView:alpha()
    return self.layer:GetAlpha()
end
function PushUIFrames.UIView:set_scale(scale_x, scale_y, origin, x, y)
    if self._doing_animation then
        self._animationStage:set_scale(scale_x, scale_y, origin, x, y)
    else
        self.layer:SetScale(scale_x, scale_y)
    end
end
function PushUIFrames.UIView:scale()
    return self.layer:GetScale()
end

function PushUIFrames.UIView:set_hidden(hidden)
    if hidden then self.layer:Hide() 
    else self.layer:Show() end
end

function PushUIFrames.UIView:is_hidden()
    return not self.layer:IsShown()
end

function PushUIFrames.UIView:animation_with_duration(duration, animation, complete)
    if not animation then return end
    if nil == duration or duration <= 0 then return end

    print("in animation with duration")
    if self._doing_animation then
        print("will cancel last animation")
        self._animationStage:stop()
    end

    self._doing_animation = true

    print("allow to do the animation")
    animation(self)
    print("after set the animation")

    self._animationStage:play(duration, function(self, completed)
        self._doing_animation = false
        if not completed then return end
        if complete then complete(self) end
    end)
end

function PushUIFrames.UIView:c_str(parent, ...)
    local _frame = __generateNewObjectByType("Frame")
    self.layer = _frame
    self.id = _frame.uiname
    self.type = type
    _frame.container = self
    if parent == nil then parent = UIParent end
    if parent.layer then parent = parent.layer end
    _frame:SetParent(parent)

    self._save_archor = "TOPLEFT"
    self._save_target_archor_obj = parent
    self._save_target_archor = "TOPLEFT"
    self._save_x = 0
    self._save_y = 0

    self._animationStage = PushUIFrames.AnimationStage(self)
    self._doing_animation = false

    -- self._animation_duration = 0
    -- self._current_animation_stage = self.id.."_animationStage"

    self._backgroundColor = PushUIColor.white
    self._borderWidth = 1
    self._borderColor = PushUIColor.white
end

-- by Push Chen
-- twitter: @littlepush
