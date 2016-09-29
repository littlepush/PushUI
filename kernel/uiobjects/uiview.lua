local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIFrames._hiddenMainFrame = CreateFrame("Frame", "PushUIHiddenMainFrame")
PushUIFrames._hiddenMainFrameHitmap = PushUIAPI.Map()
PushUIFrames._hiddenMainFrame:SetScript("OnUpdate", function(...)
    if PushUIFrames._hiddenMainFrameHitmap:size() == 0 then return end

    PushUIFrames._hiddenMainFrameHitmap:for_each(function(_, view)
        if view:is_hit() then
            local x, y = GetCursorPosition(); 
            view._event_dispatcher:fire_event("PushUIEventMouseMove", view, x, y)
        end
    end);
end)


PushUIFrames.UIView = PushUIAPI.inhiert()
function PushUIFrames.UIView:destroy()
    __destroyObjectOfType(self.type, self.layer)
    self.type = nil
    self.layer = nil
    self.id = nil
end
function PushUIFrames.UIView:delay(sec, action)
    if not action then return end
    if sec <= 0 then action(self); return end
    if not self._delay_timer then
        self._delay_timer = PushUIAPI.Timer()
    end
    self._delay_timer:start(sec, function()
        self._delay_timer:stop()
        action(self)
    end)
end
function PushUIFrames.UIView:is_hit()
    if self._is_draging then return true end
    local cs = self._children:size()
    local _childhit = false
    for i = 1, cs do
        local _cv = self._children:objectAtIndex(i)
        if _cv:is_hit() then _childhit = true; break end
    end
    if _childhit then return true end
    return self.layer:IsMouseOver()
end

function PushUIFrames.UIView:enable_drag(enable)
    self:set_user_interactive(enable)
    if enable then
        self:add_action_for_left_mouse_down("__puiViewMouseDown", function(event, self)
            print("get left mouse down")
            local x, y = GetCursorPosition()
            self._is_draging = true
            self._lastpos = {x, y}
        end)
        self:add_action_for_left_mouse_up("__puiViewMouseUp", function(event, self)
            self._is_draging = false
        end)
        self:add_action_for_mouse_move("__puiViewMouseMove", function(event, self, x, y)
            if self._is_draging == false then return end

            local _dx = x - self._lastpos[1]
            local _dy = y - self._lastpos[2]

            local _x = self._save_x + _dx
            local _y = self._save_y + _dy

            self:set_position(_x, _y)
            self._lastpos[1] = x
            self._lastpos[2] = y
        end)
    else
        self:del_action_for_left_mouse_down("__puiViewMouseDown")
        self:del_action_for_left_mouse_up("__puiViewMouseUp")
        self:del_action_for_mouse_move("__puiViewMouseMove")
    end
end
function PushUIFrames.UIView:add_action_for_mouse_in(key, func)
    self._event_dispatcher:add_action("PushUIEventMouseIn", key, func)
end
function PushUIFrames.UIView:del_action_for_mouse_in(key)
    self._event_dispatcher:del_action("PushUIEventMouseIn", key)
end
function PushUIFrames.UIView:add_action_for_mouse_out(key, func)
    self._event_dispatcher:add_action("PushUIEventMouseOut", key, func)
end
function PushUIFrames.UIView:del_action_for_mouse_out(key)
    self._event_dispatcher:del_action("PushUIEventMouseOut", key)
end
function PushUIFrames.UIView:add_action_for_left_mouse_down(key, func)
    self._event_dispatcher:add_action("PushUIEventLeftMouseDown", key, func)
end
function PushUIFrames.UIView:del_action_for_left_mouse_down(key)
    self._event_dispatcher:del_action("PushUIEventLeftMouseDown", key)
end
function PushUIFrames.UIView:add_action_for_left_mouse_up(key, func)
    self._event_dispatcher:add_action("PushUIEventLeftMouseUp", key, func)
end
function PushUIFrames.UIView:del_action_for_left_mouse_up(key)
    self._event_dispatcher:del_action("PushUIEventLeftMouseUp", key)
end
function PushUIFrames.UIView:add_action_for_right_mouse_down(key, func)
    self._event_dispatcher:add_action("PushUIEventRightMouseDown", key, func)
end
function PushUIFrames.UIView:del_action_for_right_mouse_down(key)
    self._event_dispatcher:del_action("PushUIEventRightMouseDown", key)
end
function PushUIFrames.UIView:add_action_for_right_mouse_up(key, func)
    self._event_dispatcher:add_action("PushUIEventRightMouseUp", key, func)
end
function PushUIFrames.UIView:del_action_for_right_mouse_up(key)
    self._event_dispatcher:del_action("PushUIEventRightMouseUp", key)
end
function PushUIFrames.UIView:add_action_for_mouse_move(key, func)
    self._event_dispatcher:add_action("PushUIEventMouseMove", key, func)
end
function PushUIFrames.UIView:del_action_for_mouse_move(key)
    self._event_dispatcher:del_action("PushUIEventMouseMove", key)
end
function PushUIFrames.UIView:set_user_interactive(enable)
    self.layer:EnableMouse(enable)
    self._enable_drag = enable
    if ( enable ) then
        PushUIFrames._hiddenMainFrameHitmap:set(self.id, self)
    else
        PushUIFrames._hiddenMainFrameHitmap:unset(self.id, self)
    end
end
function PushUIFrames.UIView:set_backgroundColor(color_pack, alpha)
    self.layer:SetBackdropColor(PushUIColor.unpackColor(color_pack, alpha))
    self._backgroundColor = color_pack
end
function PushUIFrames.UIView:backgroundColor()
    return self._backgroundColor
end
function PushUIFrames.UIView:set_borderColor(color_pack, alpha)
    self.layer:SetBackdropBorderColor(PushUIColor.unpackColor(color_pack, alpha))
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

function PushUIFrames.UIView:redraw()
    -- Override to do something
end

function PushUIFrames.UIView:set_width(w)
    self.layer:SetWidth(w)
    self:redraw()
end
function PushUIFrames.UIView:width()
    return self.layer:GetWidth()
end
function PushUIFrames.UIView:set_height(h)
    self.layer:SetHeight(h)
    self:redraw()
end
function PushUIFrames.UIView:height()
    return self.layer:GetHeight()
end
function PushUIFrames.UIView:set_size(w, h)
    self.layer:SetSize(w, h)
    self:redraw()
end
function PushUIFrames.UIView:size()
    return self.layer:GetSize()
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

    if self._doing_animation then
        self._animationStage:stop()
    end

    self._doing_animation = true

    animation(self)

    self._animationStage:play(duration, function(self, completed)
        self._doing_animation = false
        if not completed then return end
        if complete then complete(self) end
    end)
end

function PushUIFrames.UIView:c_str(parent, ...)
    self._event_dispatcher = PushUIAPI.Dispatcher()
    self._is_draging = false

    local _frame = __generateNewObjectByType("Frame")
    self.layer = _frame
    self.id = _frame.uiname
    self.type = type
    _frame.container = self

    local _saved_parent = parent
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

    self._children = PushUIAPI.Array()

    if _saved_parent and _saved_parent._children then
        print("i have a father")
        _saved_parent._children:push_back(self)
    end
end

-- by Push Chen
-- twitter: @littlepush
