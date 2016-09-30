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

    _testView:set_user_interactive(true)
    _testView:enable_drag(true)

    -- local _label = PushUIFrames.UILabel()
    -- print(_label.id)
    -- _label:set_position(200, -200)
    -- _label:set_padding(5, 10, 20, 40)
    -- _label:set_backgroundColor(PushUIColor.green)
    -- _label:set_align("CENTER")
    -- _label:set_size(200, 0)
    -- _label:set_text("This is a label")
    -- _label:enable_drag(true)

    -- local _image = PushUIFrames.UIImage()
    -- _image:set_image("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
    -- _image:set_backgroundColor(PushUIColor.orange)
    -- _image:set_position(400, -300)
    -- _image:set_size(100, 100)
    -- _image:set_cropSize(0.25, 0.5, 0, 0.25)
    -- _image:enable_drag(true)

    local _pb = PushUIFrames.UIProgressBar()
    _pb:set_barColor(PushUIColor.gray)
    _pb:set_backgroundColor(PushUIColor.white)
    _pb:set_size(200, 20)
    _pb:set_position(400, -500)
    _pb:set_style("h-l-r")
    -- _pb:label():set_fontflag("OUTLINE")
    _pb:enable_drag(true)

    local _playerHp = PushUIAPI.PlayerHP:current_value();
    _pb:set_max(_playerHp.max_hp)
    _pb:set_value(_playerHp.hp)
    -- _pb:set_tiptext(_playerHp.hp.."/".._playerHp.max_hp)

    PushUIAPI.PlayerHP:add_valueChanged("player_hp_bar", function(_, value)
        print("hp changed")
        _pb:set_max(value.max_hp)
        _pb:set_value(value.hp)
        -- _pb:set_tiptext(value.hp.."/"..value.max_hp)
    end)

    local _tpb = PushUIFrames.UIProgressBar()
    _tpb:set_barColor(PushUIColor.red)
    _tpb:set_backgroundColor(PushUIColor.white)
    _tpb:set_size(200, 20)
    _tpb:set_style("h-r-l")
    _tpb:set_position(1000, -500)
    -- _tpb:label():set_fontflag("OUTLINE")
    _tpb:set_hidden(true)

    PushUIAPI.TargetHP:add_displayChanged("target_hp_bar", function(_, can_display)
        _tpb:set_hidden((not can_display))
    end)
    PushUIAPI.TargetHP:add_valueChanged("target_hp_bar", function(_, value)
        _tpb:set_max(value.max_hp)
        _tpb:set_value(value.hp)
        -- _tpb:set_tiptext(value.hp.."/"..value.max_hp)
    end)


    -- local _testlayer = PushUIFrames.PUILayer()
    -- _testlayer:SetWidth(150)
    -- _testlayer:SetHeight(150)
    -- _testlayer:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 500, -300)
    -- _testlayer:SetBackdropColor(PushUIColor.unpackColor(PushUIColor.black, 0.4))
end

PushUIAPI.EventCenter:RegisterEvent(PushUIAPI.PUSHUIEVENT_PLAYER_FIRST_ENTERING_WORLD, "debug_init", _debug_initFunction)

