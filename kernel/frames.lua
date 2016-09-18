local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIFrames._hiddenMainFrame = CreateFrame("Frame", "PushUIHiddenMainFrame")
PushUIFrames._hiddenMainFrame:SetScript("OnUpdate", function(...)
    local x, y = GetCursorPosition();

end)

PushUIFrames.__countByType = PushUIAPI.Map()
PushUIFrames.__objectPoolByType = PushUIAPI.Map()

local function __generateNewObjectNameByType(type)
    if PushUIFrames.__countByType:contains(type) == false then
        PushUIFrames.__countByType:set(type, 0)
    end
    local _count = PushUIFrames.__countByType:object(type)
    _count = _count + 1
    local _name = "PushUI_"..type.."_Name_".._count
    PushUIFrames.__countByType:set(type, _count)
    return _name
end

local function __generateNewObjectByType(type)
    if PushUIFrames.__objectPoolByType:contains(type) == false then
        local _objPool = PushUIAPI.Pool(function()
            local _objectName = __generateNewObjectNameByType(type)
            local _obj = CreateFrame(type, _objectName)
            _obj:SetScript("OnEnter", function(self)
                self.container._event_dispatcher:fire_event("PushUIEventMouseIn", self.container) 
            end)
            _obj:SetScript("OnLeave", function(self)
                self.container._event_dispatcher:fire_event("PushUIEventMouseOut", self.container)
            end)
            _obj:SetScript("OnMouseDown", function(self, button, ...)
                if button == "LeftButton" then
                    self.container._event_dispatcher:fire_event("PushUIEventLeftMouseDown", self.container)
                elseif button == "RightButton" then
                    self.container._event_dispatcher:fire_event("PushUIEventRightMouseDown", self.container)
                end
            end)
            _obj:SetScript("OnMouseUp", function(self, button, ...)
                if button == "LeftButton" then
                    self.container._event_dispatcher:fire_event("PushUIEventLeftMouseUp", self.container)
                elseif button == "RightButton" then
                    self.container._event_dispatcher:fire_event("PushUIEventRightMouseUp", self.container)
                end
            end)

            _obj.uiname = _objectName

            _obj:SetBackdrop({
                bgFile = PushUIStyle.TextureClean,
                edgeFile = PushUIStyle.TextureClean,
                tile = true,
                tileSize = 1,
                edgeSize = 1,
                insets = { left = 0, right = 0, top = 0, bottom = 0 }
                })
            return _obj
        end)
        PushUIFrames.__objectPoolByType:set(type, _objPool)
    end
    return PushUIFrames.__objectPoolByType:object(type):get()
end

local function __destroyObjectOfType(type, obj)
    PushUIFrames.__objectPoolByType:object(type):release(obj)
end

-- Basic Object
PushUIFrames.UIObject = {}
PushUIFrames.UIObject.__index = PushUIFrames.UIObject
function PushUIFrames.UIObject:destroy()
    __destroyObjectOfType(self.type, self.layer)
    self.type = nil
    self.layer = nil
    self.id = nil
end
function PushUIFrames.UIObject:delay(sec, action)
    if not action then return end
    if sec <= 0 then action(self); return end
    if not self._delay_timer then
        self._delay_timer = PushUIAPI.Timer()
    end
    self._delay_timer:start(sec, function()
        action(self)
        self._delay_timer:stop()
    end)
end
function PushUIFrames.UIObject:add_action_for_mouse_in(key, func)
    self._event_dispatcher:add_action("PushUIEventMouseIn", key, func)
end
function PushUIFrames.UIObject:del_action_for_mouse_in(key)
    self._event_dispatcher:del_action("PushUIEventMouseIn", key)
end
function PushUIFrames.UIObject:add_action_for_mouse_out(key, func)
    self._event_dispatcher:add_action("PushUIEventMouseOut", key, func)
end
function PushUIFrames.UIObject:del_action_for_mouse_out(key)
    self._event_dispatcher:del_action("PushUIEventMouseOut")
end
function PushUIFrames.UIObject:add_action_for_left_mouse_down(key, func)
    self._event_dispatcher:add_action("PushUIEventLeftMouseDown", key, func)
end
function PushUIFrames.UIObject:del_action_for_left_mouse_down(key)
    self._event_dispatcher:del_action("PushUIEventLeftMouseDown")
end
function PushUIFrames.UIObject:add_action_for_left_mouse_up(key, func)
    self._event_dispatcher:add_action("PushUIEventLeftMouseUp", key, func)
end
function PushUIFrames.UIObject:del_action_for_left_mouse_up(key)
    self._event_dispatcher:del_action("PushUIEventLeftMouseUp")
end
function PushUIFrames.UIObject:add_action_for_right_mouse_down(key, func)
    self._event_dispatcher:add_action("PushUIEventRightMouseDown", key, func)
end
function PushUIFrames.UIObject:del_action_for_right_mouse_down(key)
    self._event_dispatcher:del_action("PushUIEventRightMouseDown")
end
function PushUIFrames.UIObject:add_action_for_right_mouse_up(key, func)
    self._event_dispatcher:add_action("PushUIEventRightMouseUp", key, func)
end
function PushUIFrames.UIObject:del_action_for_right_mouse_up(key)
    self._event_dispatcher:del_action("PushUIEventRightMouseUp")
end

function PushUIFrames.UIObject:new(type, parent)
    local _frame = __generateNewObjectByType(type)
    local _uiname = _frame.uiname

    -- Default is set to UIParent
    parent = parent or UIParent
    _frame:SetParent(parent)

    local _obj = setmetatable({
        layer = _frame,
        id = _uiname,
        type = type,
        -- flags
        _save_archor = "TOPLEFT",
        _save_target_archor_obj = parent,
        _save_target_archor = "TOPLEFT",
        _save_x = 0,
        _save_y = 0,
        _doing_animation = false,
        _animation_duration = 0,
        _current_animation_stage = _uiname.."_animationStage",
        _enable_drag = false,
        _event_dispatcher = PushUIAPI.Dispatcher(),
        _backgroundColor = PushUIColor.white,
        _borderWidth = 1,
        _borderColor = PushUIColor.white
        }, self)
    _frame.container = _obj
    return _obj
end

setmetatable(PushUIFrames.UIObject, {
    __call = function(self, ...)
        return self:new(...)
    end
    })

-- by Push Chen
-- twitter: @littlepush

