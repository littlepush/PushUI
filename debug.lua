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

    _testView:delay(2, function(self)
        self:animation_with_duration(3, function(self)
            self:set_alpha(0)
        end, function(self)
            print("do another animation")
            self:animation_with_duration(3, function(self)
                self:set_alpha(1)
            end)
        end)
    end)

    local _label = PushUIFrames.UILabel()
    print(_label.id)
    _label:set_position(200, -200)
    _label:set_padding(5, 10, 20, 40)
    _label:set_backgroundColor(PushUIColor.green)
    _label:set_align("CENTER")
    _label:set_size(200, 0)
    _label:set_text("This is a label")
    _label:delay(2, function(self)
        self:set_text("this is a label with delay 5 seconds")
        self:animation_with_duration(3, function(self)
            self:set_scale(0.3)
        end)
    end)
end

PushUIAPI.EventCenter:RegisterEvent(PushUIAPI.PUSHUIEVENT_PLAYER_FIRST_ENTERING_WORLD, "debug_init", _debug_initFunction)

