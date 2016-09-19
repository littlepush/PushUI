local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local function _debug_initFunction()
    SELECTED_CHAT_FRAME:AddMessage("This is a test string for PLAYER ENTERING WORLD")

    local _testView = PushUIFrames.UIView()

    print(_testView.id)
    print(_testView._current_animation_stage)
    _testView:set_backgroundColor(PushUIColor.red)
    _testView:set_size(200, 200)
    _testView:set_borderWidth(5)
    _testView:set_borderColor(PushUIColor.blue)
    _testView:set_position()

    if _testView.delay then
        print("support delay function")
    end

    _testView:delay(5, function(self)
        self:animation_with_duration(3, function(self)
            self:set_alpha(0)
        end, function(self)
            print("do another animation")
            self:animation_with_duration(3, function(self)
                self:set_alpha(1)
            end)
        end)
    end)
end

PushUIAPI.EventCenter:RegisterEvent(PushUIAPI.PUSHUIEVENT_PLAYER_FIRST_ENTERING_WORLD, "debug_init", _debug_initFunction)

