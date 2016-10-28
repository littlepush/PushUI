local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

-- Mouse Event
PushUIFrames._uiMap = PushUIAPI.Map()
PushUIFrames._uiEnteredMap = PushUIAPI.Map()
PushUIFrames._uiDownMap = PushUIAPI.Map()
PushUIFrames.__uiaDispatcher:add_action("PUIEventMouseMove", "_", function(e, ...)
    if PushUIFrames._uiMap:size() == 0 then return end

    -- Check if moved out
    local _templist = PushUIAPI.Array()
    PushUIFrames._uiEnteredMap:for_each(function(id, view, ...)
        if view:is_hit() or PushUIFrames._uiDownMap:contains(id) then 
            view:on_event("PUIEventMouseMove", ...)
        else
            _templist:push_back(id)
            view:on_event("PUIEventMouseLeave")
        end
    end, ...)
    _templist:for_each(function(_, id)
        PushUIFrames._uiEnteredMap:unset(id)
    end)

    -- Check if has any new enter
    PushUIFrames._uiMap:for_each(function(id, view)
        if PushUIFrames._uiEnteredMap:contains(id) then return end
        if not view:is_hit() then return end
        -- Add to new entered
        PushUIFrames._uiEnteredMap:set(id, view)
        view:on_event("PUIEventMouseEnter")
    end)
end)
PushUIFrames.__uiaDispatcher:add_action("PUIEventMouseDown", "_", function(e, btn)
    PushUIFrames._uiEnteredMap:for_each(function(id, view, ...)
        PushUIFrames._uiDownMap:set(id, view)
        view:on_event("PUIEventMouseDown", ...)
    end, btn)
end)
PushUIFrames.__uiaDispatcher:add_action("PUIEventMouseUp", "_", function(e, btn)
    PushUIFrames._uiDownMap:for_each(function(id, view, ...)
        view:on_event("PUIEventMouseUp", ...)
    end, btn)
    PushUIFrames._uiDownMap:clear()
end)
PushUIFrames.__uiaDispatcher:add_action("PUIEventMouseWheel", "_", function(e, zoom)
    PushUIFrames._uiEnteredMap:for_each(function(id, view, ...)
        view:on_event("PUIEventMouseWheel", ...)
    end, zoom)
end)


-- UIView
PushUIFrames.UIView = PushUIAPI.inhiert()

function PushUIFrames.UIView:c_str(parent, ...)
    self._dispatcher = PushUIAPI.Dispatcher()
    self._isMouseDown = false

    local _layerParent = UIParent
    if parent then
        if parent.layer then
            _layerParent = parent.layer
        else
            _layerParent = parent
        end
    end

    self._layerObject = PushUIFrames.PUILayer(_layerParent)
    self.layer = self._layerObject:object()
    self.id = self._layerObject.id
    self.layer.view = self;

    self._save_archor = "TOPLEFT"
    self._save_target_archor_obj = _layerParent
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

    if parent and parent._children then
        parent._children:push_back(self)
    end
end

function PushUIFrames.UIView:set_user_interactive(enable)
    if ( enable ) then
        PushUIFrames._uiMap:set(self.id, self)
    else
        PushUIFrames._uiMap:unset(self.id)
    end
end

function PushUIFrames.UIView:is_hit()
    -- local cs = self._children:size()
    -- local _childhit = false
    -- for i = 1, cs do
    --     local _cv = self._children:objectAtIndex(i)
    --     if _cv:is_hit() then _childhit = true; break end
    -- end
    -- if _childhit then return true end
    return self.layer:IsMouseOver()
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

local function PushUIFrames_UIView_onMouseDown(self)
    local x, y = GetCursorPosition()
    self._is_draging = true
    self._lastpos = {x, y}
end

local function PushUIFrames_UIView_onMouseUp(self)
    self._is_draging = false
end

local function PushUIFrames_UIView_onMouseMove(self, x, y)
    if not self._is_draging then return end
    local _dx = x - self._lastpos[1]
    local _dy = y - self._lastpos[2]

    local _x = self._save_x + _dx
    local _y = self._save_y + _dy

    self:set_position(_x, _y)
    self._lastpos[1] = x
    self._lastpos[2] = y
end

function PushUIFrames.UIView:on_event(event, ...)
    self._dispatcher:fire_event(event, ...)
end

function PushUIFrames.UIView:add_action(event, key, func)
    self._dispatcher:add_action(event, key, func)
end

function PushUIFrames.UIView:del_action(event, key)
    self._dispatcher:del_action(event, key)
end

function PushUIFrames.UIView:enable_drag(enable)
    if enable then
        self:add_action("PUIEventMouseDown", "_", function(_, ...) PushUIFrames_UIView_onMouseDown(self, ...) end)
        self:add_action("PUIEventMouseUp", "_", function(_, ...) PushUIFrames_UIView_onMouseUp(self, ...) end)
        self:add_action("PUIEventMouseMove", "_", function(_, ...) PushUIFrames_UIView_onMouseMove(self, ...) end)
    else
        self:del_action("PUIEventMouseDown", "_")
        self:del_action("PUIEventMouseUp", "_")
        self:del_action("PUIEventMouseMove", "_")
    end
end
function PushUIFrames.UIView:set_user_interactive(enable)
    if ( enable ) then
        PushUIFrames._uiMap:set(self.id, self)
    else
        PushUIFrames._uiMap:unset(self.id, self)
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
        self.layer:SetAlpha(alpha)
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
    if hidden then 
        self.layer:Hide() 
        self.layer:SetAlpha(0)
    else 
        self.layer:SetAlpha(1)
        self.layer:Show() 
    end
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

-- by Push Chen
-- twitter: @littlepush
