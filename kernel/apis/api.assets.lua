local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIAPI.Assets = {}
PushUIAPI.Assets.__index = PushUIAPI.Assets

function PushUIAPI.Assets:can_display()
    return self.__displayStatus
end
function PushUIAPI.Assets:displayStatusChanged()
    self.__dispatcher:fire_event("display_status", self.__displayStatus)
end
function PushUIAPI.Assets:add_displayChanged(key, func)
    self.__dispatcher:add_action("display_status", key, func)
end
function PushUIAPI.Assets:del_displayChanged(key)
    self.__dispatcher:del_action("display_status", key)
end
function PushUIAPI.Assets:set_candisplay(can)
    local _old = self.__displayStatus
    self.__displayStatus = can
    if _old == can then return end
    self:displayStatusChanged()
end
function PushUIAPI.Assets:valueChanged()
    self.__dispatcher:fire_event("value_status", self:current_value())
end
function PushUIAPI.Assets:add_valueChanged(key, func)
    self.__dispatcher:add_action("value_status", key, func)
end
function PushUIAPI.Assets:del_valueChanged(key)
    self.__dispatcher:del_action("value_status", key)
end
function PushUIAPI.Assets:current_value()
    return self.__current_value
end
function PushUIAPI.Assets:set_current_value(value)
    self.__current_value = value
    self:valueChanged()
end
function PushUIAPI.Assets:update_on_event(event, ...)
    if (self[event]) then self[event](self, ...) end
end
function PushUIAPI.Assets.new(...)
    local _obj = setmetatable({
        __dispatcher = PushUIAPI.Dispatcher(),
        __displayStatus = false,
        __current_value = 0
        }, PushUIAPI.Assets)
    local _event_count = select("#", ...)
    for i = 1, _event_count do
        PushUIRegisterEvent(select(i, ...), _obj, function(obj, event, ...) obj:update_on_event(event, ...) end)
    end
    return _obj
end

setmetatable(PushUIAPI.Assets, {
    __call = function(_, ...) return PushUIAPI.Assets.new(...) end
    })

-- by Push Chen
-- twitter: @littlepush
