local PushUI = {}

PushUI.Console = getglobal("ChatFrame1")
PushUI.Console.Log = function(msg)
    PushUI.Console:AddMessage(msg)
end
PushUI.UpdateConsole = function(console)
    console.Log = PushUI.Console.Log
    PushUI.Console = console
end    

PushUI.Size = {}
PushUI.Size.padding = 5
PushUI.Size.blockNoramlHeight = 150
PushUI.Size.blockNormalWidth = 210
PushUI.Size.tinyButtonWidth = 10
PushUI.Size.actionButtonSize = 34
PushUI.Size.actionButtonPerLine = 12
PushUI.Size.actionButtonPadding = 2
PushUI.Size.tinyButtonHeight = (PushUI.Size.blockNoramlHeight - PushUI.Size.padding) / 2
PushUI.Size.FormatWidth = function( count, width, padding )
    local _w = PushUI.Size.blockNormalWidth
    local _p = PushUI.Size.padding
    if width then
        _w = width
    end
    if padding then
        _p = padding
    end

    return _p + (_w + _p) * count
end

PushUI.Size.FormatHeight = function( count, height, padding )
    local _h = PushUI.Size.blockNoramlHeight
    local _p = PushUI.Size.padding
    if height then
        _h = height
    end
    if padding then
        _p = padding
    end

    return _p + (_h + _p) * count
end

PushUI.Style = {}
PushUI.Style.TextureClean = "Interface\\ChatFrame\\ChatFrameBackground"
PushUI.Style.Backdrop = {
    bgFile = PushUI.Style.TextureClean,
    edgeFile = PushUI.Style.TextureClean,
    tile = true,
    tileSize = 100,
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0}
}
PushUI.Style.BackgroundFormat = function(frame, bR, bG, bB, bA, bbR, bbG, bbB, bbA)
    frame:SetBackdrop(PushUI.Style.Backdrop)
    frame:SetBackdropColor(bR, bG, bB, bA)
    frame:SetBackdropBorderColor(bbR, bbG, bbB, bbA)
end
PushUI.Style.BackgroundGradientFormat = function(
    frame, 
    bSR, bSG, bSB, bSA, 
    bER, bEG, bEB, bEA, 
    bbR, bbG, bbB, bbA
)
    local _t = frame:CreateTexture(nil, "BACKGROUND")
    _t:SetTexture(PushUI.Style.TextureClean)
    _t:SetAllPoints(frame)
    _t:SetGradientAlpha(
        "VERTICAL", 
        bER, bEG, bEB, bEA,
        bSR, bSG, bSB, bSA
        )
    frame.texture = _t

    PushUI.Style.BackgroundFormat(frame, 0, 0, 0, 0, bbR, bbG, bbB, bbA)
end

PushUI.Style.BackgroundFormat1 = function(frame)
    PushUI.Style.BackgroundGradientFormat(
        frame,
        0.15625, 0.15625, 0.15625, 0.9,
        0, 0, 0, 0.9,
        0.535, 0.535, 0.535, 1
        )
end
PushUI.Style.BackgroundFormat2 = function(frame)
    PushUI.Style.BackgroundGradientFormat(
        frame,
        0.15625, 0.15625, 0.15625, 0.9,
        0, 0, 0, 0.9,
        0, 0, 0, 1
        )
end
PushUI.Style.BackgroundFormat3 = function(frame)
    PushUI.Style.BackgroundFormat(
        frame,
        0.23046875, 0.23046875, 0.23046875, 0.9,
        0, 0, 0, 1
        )
end
PushUI.Style.BackgroundFormat4 = function(frame)
    PushUI.Style.BackgroundFormat(
        frame,
        0.23046875, 0.23046875, 0.23046875, 0.9,
        0.53515625, 0.53515625, 0.53515625, 1
        )
end
PushUI.Style.BackgroundFormatBlue = function(frame)
    PushUI.Style.BackgroundFormat(
        frame,
        0.26, 0.49, 0.91, 1,
        0, 0, 0, 1
        )
end
PushUI.Style.BackgroundFormatRed = function(frame)
    PushUI.Style.BackgroundFormat(
        frame,
        0.89, 0.25, 0.20, 1,
        0, 0, 0, 1
        )
end
PushUI.Style.BackgroundFormatDark = function(frame)
    PushUI.Style.BackgroundFormat(
        frame,
        0.15, 0.15, 0.15, 1,
        0, 0, 0, 1
        )
end

PushUI.Style.SetFontSize = function(frame, newSize)
    local _text = frame:GetFontString()
    local _p, _s, _f = _text:GetFont()
    _s = newSize
    _text:SetFont(_p, _s, _f)
end
PushUI.Style.SetFontColor = function(frame, ...)
    local _text = frame:GetFontString()
    _text:SetTextColor(...)
end

PushUI.Style.ShowChat = true

-- Skada Skin
PushUI.Style.SkinSkada = function()
    local _skada = Skada.displays['bar']

    hooksecurefunc(_skada, 'AddDisplayOptions', function(self, win, options)
        options.baroptions.args.barspacing = nil
        options.baroptions.args.barslocked = true
        options.titleoptions.args.texture = nil
        options.titleoptions.args.bordertexture = nil
        options.titleoptions.args.thickness = nil
        options.titleoptions.args.margin = nil
        options.titleoptions.args.color = nil
        options.windowoptions = nil
        print(options)
    end)

    hooksecurefunc(_skada, 'ApplySettings', function(self, win)
        local _s = win.bargroup
        local _name = win.bargroup:GetName()

        _s:ClearAllPoints()
        local _barWidth = PushUI.Size.blockNormalWidth
        _s:SetBackdrop(nil)
        _s.button:Hide()
        _s:SetWidth(_barWidth)
        _s:SetBarWidth(_barWidth)
        _s:SetBarHeight(PushUI.Size.blockNoramlHeight / 8 - 0.5)
        _s:SetHeight(PushUI.Size.blockNoramlHeight)

        local _index = 0
        for k,v in pairs(Skada:GetWindows()) do
            if v.bargroup:GetName() == _name then
                _index = k - 1
                break
            end
        end
        _s:SetPoint('TOPLEFT', PushUIBottomLeftBackgroundFrame, 'TOPLEFT', 
            PushUI.Size.padding + (PushUI.Size.padding + PushUI.Size.blockNormalWidth) * _index, 
            -PushUI.Size.padding)
    end)

    hooksecurefunc(_skada, 'Show', function(self, win)
        if PushUI.Style.ShowChat then return end
        win:Show()
    end)
end

PushUI.Style.ToggleSkada = function()
    for index,win in pairs(Skada:GetWindows()) do
        if PushUI.Style.ShowChat then
            win.bargroup:Hide()
        else
            win.bargroup:Show()
        end
    end
end

PushUI.Style.SkinChatFrame = function()
    CHAT_FRAME_FADE_OUT_TIME = 86400
    -- Seconds to wait before fading out chat frames the mouse moves out of.
    -- Default is 2.

    CHAT_TAB_HIDE_DELAY = 86400
    -- Seconds to wait before fading out chat tabs the mouse moves out of.
    -- Default is 1.

    CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
    CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0.5
    -- Opacity of the currently selected chat tab.
    -- Defaults are 1 and 0.4.

    CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
    CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 0.5
    -- Opacity of currently alerting chat tabs.
    -- Defaults are 1 and 1.

    CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1
    CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0.5
    -- Opacity of non-selected, non-alerting chat tabs.
    -- Defaults are 0.6 and 0.2.

    FriendsMicroButton:SetScript("OnShow", FriendsMicroButton.Hide)
    FriendsMicroButton:Hide()

    GeneralDockManagerOverflowButton:SetScript("OnShow", GeneralDockManagerOverflowButton.Hide)
    GeneralDockManagerOverflowButton:Hide()

    ChatFrameMenuButton:SetScript("OnShow", ChatFrameMenuButton.Hide)
    ChatFrameMenuButton:Hide()

    hooksecurefunc('FCFTab_UpdateColors', function(frame, sel)
        if sel then
            PushUI.Style.SetFontColor(frame, 1, 1, 1)
        else
            PushUI.Style.SetFontColor(frame, 0.7, 0.7, 0.7)
        end
    end)

    hooksecurefunc('FCF_StartAlertFlash', function(frame)
        local _tab = _G['ChatFrame'..frame:GetID()..'Tab']
        PushUI.Style.SetFontColor(_tab, 0.89, 0.25, 0.20)
    end)

    --NUM_CHAT_WINDOWS is the max number of available chat frame.
    --not the chat frame number now being loaded.
    local _chatNum = NUM_CHAT_WINDOWS
    for i = 1, NUM_CHAT_WINDOWS do
        local _chatF = _G["ChatFrame"..i]
        local _chatFTab = _G["ChatFrame"..i.."Tab"]

        -- No more loaded chat frame
        if _chatF == nil then
            _chatNum = i - 1
            break
        end

        -- Change the tab font size to 11
        PushUI.Style.SetFontSize(_chatFTab, 11)

        -- Clear the tab texture
        _chatFTab.texture = nil
        --PushUI.Style.BackgroundFormatDark(_chatFTab)
        local _tabL = getglobal("ChatFrame"..i.."TabLeft")
        local _tabHL = getglobal("ChatFrame"..i.."TabHighlightLeft")
        local _tabSL = getglobal("ChatFrame"..i.."TabSelectedLeft")

        local _tabM = getglobal("ChatFrame"..i.."TabMiddle")
        local _tabHM = getglobal("ChatFrame"..i.."TabHighlightMiddle")
        local _tabSM = getglobal("ChatFrame"..i.."TabSelectedMiddle")

        local _tabR = getglobal("ChatFrame"..i.."TabRight")
        local _tabHR = getglobal("ChatFrame"..i.."TabHighlightRight")
        local _tabSR = getglobal("ChatFrame"..i.."TabSelectedRight")

        _tabL:SetTexture(nil)
        _tabHL:SetTexture(nil)
        _tabSL:SetTexture(nil)

        _tabM:SetTexture(nil)
        _tabHM:SetTexture(nil)
        _tabSM:SetTexture(nil)

        _tabR:SetTexture(nil)
        _tabHR:SetTexture(nil)
        _tabSR:SetTexture(nil)

        -- Can move to the screen side. 
        _chatF:SetClampedToScreen(true)
        _chatF:SetClampRectInsets(0, 0, 0, 0)

        -- Remove the Arrow Frame
        local _btnFrame = _G["ChatFrame"..i.."ButtonFrame"]
        _btnFrame:SetScript("OnShow", _btnFrame.Hide)
        _btnFrame:Hide()
    end

    SELECTED_CHAT_FRAME:ClearAllPoints()
    SELECTED_CHAT_FRAME:SetPoint("TOPLEFT", PushUIBottomLeftBackgroundFrame, "TOPLEFT", PushUI.Size.padding, -PushUI.Size.padding)
    SELECTED_CHAT_FRAME:SetWidth(PushUI.Size.blockNormalWidth * 2 + PushUI.Size.padding)
    SELECTED_CHAT_FRAME:SetHeight(PushUI.Size.blockNoramlHeight)
end

PushUI.Style.ToggleChatFrame = function()
    if PushUI.Style.ShowChat then
        SELECTED_CHAT_FRAME:Show()
        GeneralDockManager:Show()
    else
        SELECTED_CHAT_FRAME:Hide()
        GeneralDockManager:Hide()
    end
end

-- Colors
local _csR,_csG,_csB = 0.26, 0.49, 0.91
local _ssR,_ssG,_ssB = 0.89, 0.25, 0.20
local _sAOn,_sAOff = 1.0, 0.3

PushUI.Colors = {}
PushUI.Colors.Style1 = {
    
}

-- Create All Needed Frames
PushUI.Frames = {}
PushUI.Frames.Create = function(name, width, height, bkgnd)
    local _f = CreateFrame("Frame", name, UIParent)
    _f:SetWidth(width)
    _f:SetHeight(height)
    if bkgnd then
        _f:SetFrameStrata("BACKGROUND")
    end
    return _f
end
PushUI.Frames.CreateButton = function(name, parent, width, height)
    local _b = CreateFrame("Button", name, parent)
    _b:SetWidth(width)
    _b:SetHeight(height)
    return _b
end

PushUI.Frames.BottomLeftBackground = PushUI.Frames.Create(
    "PushUIBottomLeftBackgroundFrame", 
    PushUI.Size.FormatWidth(2) + PushUI.Size.tinyButtonWidth + PushUI.Size.padding,
    PushUI.Size.FormatHeight(1),
    true
)
    PushUI.Frames.BottomLeftBackground.btnSwitchChatframe = PushUI.Frames.CreateButton(
        "PushUIChatSwitch", 
        PushUI.Frames.BottomLeftBackground,
        PushUI.Size.tinyButtonWidth,
        PushUI.Size.tinyButtonHeight
    )
    PushUI.Frames.BottomLeftBackground.btnSwitchSkada = PushUI.Frames.CreateButton(
        "PushUISkadaChatSwitch", 
        PushUI.Frames.BottomLeftBackground,
        PushUI.Size.tinyButtonWidth,
        PushUI.Size.tinyButtonHeight
    )
PushUI.Frames.BottomRightBackground = PushUI.Frames.Create(
    "PushUIBottomRightBackgroundFrame",
    PushUI.Size.FormatWidth(2) + PushUI.Size.tinyButtonWidth + PushUI.Size.padding,
    PushUI.Size.FormatHeight(1),
    true
    )

PushUI.Frames.ActionBarBackground = PushUI.Frames.Create(
    "PushUIActionBarBackgroundFrame",
    PushUI.Size.FormatWidth(PushUI.Size.actionButtonPerLine, PushUI.Size.actionButtonSize, PushUI.Size.actionButtonPadding),
    PushUI.Size.FormatWidth(3, PushUI.Size.actionButtonSize, PushUI.Size.actionButtonPadding),
    true
    )

-- Format All Frames
PushUI.Frames.BottomLeftBackground.Format = function()
    local _blFrame = PushUI.Frames.BottomLeftBackground
    _blFrame:SetPoint("BOTTOMRIGHT", PushUI.Frames.ActionBarBackground, "BOTTOMLEFT", 0, 0)
    PushUI.Style.BackgroundFormat3(_blFrame)

    _blFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    _blFrame:RegisterEvent("UPDATE_CHAT_WINDOWS")
    _blFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            PushUI.Style.SkinSkada()
            PushUI.Style.ToggleSkada()
        end
        PushUI.Style.SkinChatFrame()
    end)
end

PushUI.Frames.BottomRightBackground.Format = function()
    local _brFrame = PushUI.Frames.BottomRightBackground
    _brFrame:SetPoint("BOTTOMLEFT", PushUI.Frames.ActionBarBackground, "BOTTOMRIGHT", 0, 0)
    PushUI.Style.BackgroundFormat3(_brFrame)
end

PushUI.Frames.BottomLeftBackground.btnSwitchChatframe.Format = function()
    local _btn = PushUI.Frames.BottomLeftBackground.btnSwitchChatframe
    PushUI.Style.BackgroundFormatBlue(_btn)
    _btn:SetPoint("TOPRIGHT", _btn:GetParent(), "TOPRIGHT", -PushUI.Size.padding, -PushUI.Size.padding)
    _btn:SetAlpha(_sAOn)
end

PushUI.Frames.BottomLeftBackground.btnSwitchChatframe.Toggle = function()
    local _btn = PushUI.Frames.BottomLeftBackground.btnSwitchChatframe
    if PushUI.Style.ShowChat then
        _btn:SetAlpha(_sAOn)
    else 
        _btn:SetAlpha(_sAOff)
    end
end

PushUI.Frames.BottomLeftBackground.btnSwitchSkada.Format = function()
    local _btn = PushUI.Frames.BottomLeftBackground.btnSwitchSkada
    PushUI.Style.BackgroundFormatRed(_btn)
    _btn:SetPoint("BOTTOMRIGHT", _btn:GetParent(), "BOTTOMRIGHT", -PushUI.Size.padding, PushUI.Size.padding)
    _btn:SetAlpha(_sAOff)
end
PushUI.Frames.BottomLeftBackground.btnSwitchSkada.Toggle = function()
    local _btn = PushUI.Frames.BottomLeftBackground.btnSwitchSkada
    if PushUI.Style.ShowChat then
        _btn:SetAlpha(_sAOff)
    else 
        _btn:SetAlpha(_sAOn)
    end
end

PushUI.Frames.BottomLeftBackground.ButtonSwitchEvent = function()
    PushUI.Style.ShowChat = not PushUI.Style.ShowChat
    PushUI.Style.ToggleSkada()
    PushUI.Style.ToggleChatFrame()
    PushUI.Frames.BottomLeftBackground.btnSwitchChatframe.Toggle()
    PushUI.Frames.BottomLeftBackground.btnSwitchSkada.Toggle()
end

PushUI.Frames.BottomLeftBackground.btnSwitchChatframe:SetScript(
    "OnClick", PushUI.Frames.BottomLeftBackground.ButtonSwitchEvent
)
PushUI.Frames.BottomLeftBackground.btnSwitchSkada:SetScript(
    "OnClick", PushUI.Frames.BottomLeftBackground.ButtonSwitchEvent
)

PushUI.Frames.ActionButtonFormat = function(btn)
    local action = btn.action
    local name = btn:GetName()
    local ic  = _G[name.."Icon"]
    local co  = _G[name.."Count"]
    local bo  = _G[name.."Border"]
    local ho  = _G[name.."HotKey"]
    local cd  = _G[name.."Cooldown"]
    local na  = _G[name.."Name"]
    local fl  = _G[name.."Flash"]
    local nt  = _G[name.."NormalTexture"]
    local fbg  = _G[name.."FloatingBG"]
    local fob = _G[name.."FlyoutBorder"]
    local fobs = _G[name.."FlyoutBorderShadow"]
    if fbg then fbg:Hide() end  --floating background
    --flyout border stuff
    if fob then 
        PushUI.Console.Log("Has FlyoutBorder, will set to nil")
        fob:SetTexture(nil) 
    end
    if fobs then 
        PushUI.Console.Log("Has FlyoutBorderShadow, will set to nil")
        fobs:SetTexture(nil) 
    end

    -- Hide Border
    bo:SetTexture(nil)

    --hotkey
--    ho:SetFont(cfg.font, cfg.hotkeys.fontsize, "OUTLINE")
--    ho:ClearAllPoints()
--    ho:SetPoint(cfg.hotkeys.pos1.a1,bu,cfg.hotkeys.pos1.x,cfg.hotkeys.pos1.y)
--    ho:SetPoint(cfg.hotkeys.pos2.a1,bu,cfg.hotkeys.pos2.x,cfg.hotkeys.pos2.y)
--    if not dominos and not bartender4 and not cfg.hotkeys.show then
--      ho:Hide()
--    end
    --macro name
--    na:SetFont(cfg.font, cfg.macroname.fontsize, "OUTLINE")
--    na:ClearAllPoints()
--    na:SetPoint(cfg.macroname.pos1.a1,bu,cfg.macroname.pos1.x,cfg.macroname.pos1.y)
--    na:SetPoint(cfg.macroname.pos2.a1,bu,cfg.macroname.pos2.x,cfg.macroname.pos2.y)
--    if not dominos and not bartender4 and not cfg.macroname.show then
--      na:Hide()
--    end
    --item stack count
--    co:SetFont(cfg.font, cfg.itemcount.fontsize, "OUTLINE")
--    co:ClearAllPoints()
--    co:SetPoint(cfg.itemcount.pos1.a1,bu,cfg.itemcount.pos1.x,cfg.itemcount.pos1.y)
--    if not dominos and not bartender4 and not cfg.itemcount.show then
--      co:Hide()
--    end

    --applying the textures
    -- fl:SetTexture(PushUI.Style.TextureClean)
    -- btn:SetHighlightTexture(PushUI.Style.TextureClean)
    -- btn:SetPushedTexture(PushUI.Style.TextureClean)
    -- btn:SetCheckedTexture(PushUI.Style.TextureClean)

    if not nt then
      --fix the non existent texture problem (no clue what is causing this)
      nt = btn:GetNormalTexture()
    end

    --cut the default border of the icons and make them shiny
    ic:SetTexCoord(0.1,0.9,0.1,0.9)
    ic:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
    ic:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
    --adjust the cooldown frame
    cd:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
    cd:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)

    --apply the normaltexture
    if action and  IsEquippedAction(action) then
        btn:SetNormalTexture(PushUI.Style.TextureClean)
        nt:SetVertexColor(0.7, 0.7, 0.1, 0.1)
    else
        btn:SetNormalTexture(PushUI.Style.TextureClean)
        nt:SetVertexColor(0.1, 0.1, 0.1, 0.1)
    end
    nt:SetAllPoints(btn)
    --make the normaltexture match the buttonsize
    --hook to prevent Blizzard from reseting our colors
    -- THE HOOK CAUSE FSTACK NOT WORKING!!!!!!!
    -- hooksecurefunc(nt, "SetVertexColor", function(nt, r, g, b, a)
    --     local btn = nt:GetParent()
    --     local action = btn.action
    --     if action and  IsEquippedAction(action) then
    --         btn:SetNormalTexture(PushUI.Style.TextureClean)
    --         nt:SetVertexColor(0.7, 0.7, 0.1, 0.1)
    --     else
    --         btn:SetNormalTexture(PushUI.Style.TextureClean)
    --         nt:SetVertexColor(0.1, 0.1, 0.1, 0.1)
    --     end
    -- end)
    --shadows+background

    btn:SetBackdrop(PushUI.Style.Backdrop)
    btn:SetBackdropColor(0, 0, 0, 0)
    btn:SetBackdropBorderColor(0, 0, 0, 1)

    if bartender4 then --fix the normaltexture
      nt:SetTexCoord(0,1,0,1)
      nt.SetTexCoord = function() return end
      btn.SetNormalTexture = function() return end
    end
end

PushUI.Frames.ActionBarPlace = function(btn, row, col)
    btn:ClearAllPoints()
    --btn:SetParent(PushUI.Frames.ActionBarBackground)
    btn:SetWidth(PushUI.Size.actionButtonSize)
    btn:SetHeight(PushUI.Size.actionButtonSize)
    btn:SetPoint("BOTTOMLEFT", PushUI.Frames.ActionBarBackground, "BOTTOMLEFT", 
        (col - 1) * (PushUI.Size.actionButtonSize + PushUI.Size.actionButtonPadding) + PushUI.Size.actionButtonPadding,
        (row - 1) * (PushUI.Size.actionButtonSize + PushUI.Size.actionButtonPadding) + PushUI.Size.actionButtonPadding
        )
end
PushUI.Frames.ActionBarBackground.Format = function()
    local _abf = PushUI.Frames.ActionBarBackground;
    PushUI.Style.BackgroundFormat3(_abf)
    _abf:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 25)

    -- Reformat old action bars
    ReputationWatchBar:SetScript("OnShow", ReputationWatchBar.Hide)
    ReputationWatchBar:Hide()

    --MainMenuBarLeftEndCap:SetScript("OnShow", MainMenuBarLeftEndCap.Hide)
    MainMenuBarLeftEndCap:Hide()

    --MainMenuBarRightEndCap:SetScript("OnShow", MainMenuBarRightEndCap.Hide)
    MainMenuBarRightEndCap:Hide()

    MainMenuBarTexture0:SetTexture(nil)
    MainMenuBarTexture1:SetTexture(nil)
    MainMenuBarTexture2:SetTexture(nil)
    MainMenuBarTexture3:SetTexture(nil)
    StanceBarLeft:SetTexture(nil)
    StanceBarMiddle:SetTexture(nil)
    StanceBarRight:SetTexture(nil)
    SlidingActionBarTexture0:SetTexture(nil)
    SlidingActionBarTexture1:SetTexture(nil)
    PossessBackground1:SetTexture(nil)
    PossessBackground2:SetTexture(nil)
    MainMenuBarPageNumber:Hide()
    ActionBarUpButton:Hide()
    ActionBarDownButton:Hide()

    -- OverrideActionBar
    local textureList = {
        "_BG","EndCapL","EndCapR",
        "_Border","Divider1","Divider2",
        "Divider3","ExitBG","MicroBGL",
        "MicroBGR","_MicroBGMid",
        "ButtonBGL","ButtonBGR",
        "_ButtonBGMid"
    }
    for _, tex in pairs(textureList) do
        OverrideActionBar[tex]:SetAlpha(0)
    end

    -- Hide Bags
    for i=0,3 do
        _G["CharacterBag"..i.."Slot"]:Hide()
    end
    MainMenuBarBackpackButton:Hide()

    for i=1,PushUI.Size.actionButtonPerLine do
        local _abtn = _G["ActionButton"..i]
        PushUI.Frames.ActionButtonFormat(_abtn)
        PushUI.Frames.ActionBarPlace(_abtn, 1, i)
        local _mblbtn = _G["MultiBarBottomLeftButton"..i]
        --PushUI.Frames.ActionButtonFormat(_mblbtn)
        PushUI.Frames.ActionBarPlace(_mblbtn, 2, i)
        local _mbrbtn = _G["MultiBarBottomRightButton"..i]
        --PushUI.Frames.ActionButtonFormat(_mbrbtn)
        PushUI.Frames.ActionBarPlace(_mbrbtn, 3, i)
    end

    -- Hide MainMenu Bar
    local _main_menus = {
        "Character",
        "Spellbook",
        "Talent",
        "Achievement",
        "QuestLog",
        "Guild",
        "LFD",
        "Collections",
        "EJ",
        "Store",
        "MainMenu"
    }
    for idx,title in pairs(_main_menus) do
        local _b = _G[title.."MicroButton"]
        _b:SetScript("OnShow", _b.Hide)
        _b:Hide()
    end
end


-- Start Point
PushUI.Frames.ActionBarBackground.Format()
PushUI.Frames.BottomLeftBackground.Format()
    PushUI.Frames.BottomLeftBackground.btnSwitchChatframe.Format()
    PushUI.Frames.BottomLeftBackground.btnSwitchSkada.Format()
PushUI.Frames.BottomRightBackground.Format()


