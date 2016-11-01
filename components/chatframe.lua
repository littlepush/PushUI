local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local _chatbackground = PushUIFrames.UIView()
PushUIConfig.skinType(_chatbackground.layer)
_chatbackground:set_size(
    PushUIFrameActionBarFrame:GetWidth() + PushUISize.padding * 2, 
    PushUIFrameActionBarFrame:GetHeight() * 1.5 + PushUISize.padding * 2)
_chatbackground:set_archor("BOTTOMLEFT")
_chatbackground:set_archor_target(UIParent, "BOTTOMLEFT")
_chatbackground:set_position(15, 30)

function PushUIFrames_FormatChat()

    CHAT_FRAME_FADE_OUT_TIME = 0
    -- Seconds to wait before fading out chat frames the mouse moves out of.
    -- Default is 2.

    CHAT_TAB_HIDE_DELAY = 0
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

    SELECTED_CHAT_FRAME:ClearAllPoints()

    -- Hide Unused
    -- FriendsMicroButton:SetScript("OnShow", FriendsMicroButton.Hide)
    -- FriendsMicroButton:Hide()

    GeneralDockManagerOverflowButton:SetScript("OnShow", GeneralDockManagerOverflowButton.Hide)
    GeneralDockManagerOverflowButton:Hide()

    ChatFrameMenuButton:SetScript("OnShow", ChatFrameMenuButton.Hide)
    ChatFrameMenuButton:Hide()

    -- Set the background frame as the parent
    GeneralDockManager:SetParent(_chatbackground.layer)

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
        -- PushUIStyle.SetFontSize(_chatFTab:GetFontString(), 11)

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
        -- _chatF:SetClampedToScreen(true)
        -- _chatF:SetClampRectInsets(0, 0, 0, 0)

        -- Remove the Arrow Frame
        local _btnFrame = _G["ChatFrame"..i.."ButtonFrame"]
        _btnFrame:SetScript("OnShow", _btnFrame.Hide)
        _btnFrame:Hide()

        -- BottomFrame
        --local _btnfbb = _G["ChatFrame"..i.."ButtonFrameBottomButton"]
        --PushUIConfig.skinType(_btnfbb)
        _chatF:SetParent(_chatbackground.layer)
    end

    SELECTED_CHAT_FRAME:ClearAllPoints()
    SELECTED_CHAT_FRAME:SetPoint("TOPLEFT", _chatbackground.layer, "TOPLEFT", PushUISize.padding, -PushUISize.padding)
    SELECTED_CHAT_FRAME:SetWidth(_chatbackground:width() - PushUISize.padding * 2)
    SELECTED_CHAT_FRAME:SetHeight(_chatbackground:height() - PushUISize.padding * 2)

end

function PushUIFrames_MoveActionBar()
    PushUIFrameActionBarFrame:ClearAllPoints()
    PushUIFrameActionBarFrame:SetPoint("BOTTOMLEFT", _chatbackground.layer, "BOTTOMRIGHT", PushUISize.padding, 0)
end

-- -- Create default config
-- local _config = PushUIConfig.ChatFrameDock
-- if not _config then 
--     _config = {
--         container = "PushUIFramesLeftDockContainer",
--         tint = "PushUIFrameLeftTintContainer",
--         color = PushUIColor.white,
--         displayOnLoad = true,
--         width = 400
--     }
-- end
-- local _panelContainer = _G[_config.container]
-- local _tintContainer = _G[_config.tint]
-- local _name = "PushUIFrameChatFrameDock"

-- local _chatdock = PushUIFrames.DockFrame.CreateNewDock(
--     "PushUIFrameChatFrameDock", _config.color, "BOTTOM", 
--     _panelContainer, _tintContainer)
-- _chatdock.panel:SetWidth(_config.width)
-- PushUIConfig.skinType(_chatdock.panel)
-- PushUIConfig.skinType(_chatdock.floatPanel)

-- local _floatLabel = PushUIFrames.Label.Create(_name.."FloatLabel", _chatdock.floatPanel, true)
-- _floatLabel.SetTextString("Chat")
-- _floatLabel:SetPoint("TOPLEFT", _chatdock.floatPanel, "TOPLEFT", 0, 0)

-- _chatdock.__resize = function()
--     SELECTED_CHAT_FRAME:ClearAllPoints()
--     SELECTED_CHAT_FRAME:SetPoint("TOPLEFT", _chatdock.panel, "TOPLEFT", 5, -5)
--     SELECTED_CHAT_FRAME:SetWidth(_config.width - 10)
--     SELECTED_CHAT_FRAME:SetHeight(_chatdock.panel:GetHeight() - 10)
-- end


-- _chatdock.__init = function()
--     FriendsMicroButton:SetScript("OnShow", FriendsMicroButton.Hide)
--     FriendsMicroButton:Hide()

--     GeneralDockManagerOverflowButton:SetScript("OnShow", GeneralDockManagerOverflowButton.Hide)
--     GeneralDockManagerOverflowButton:Hide()

--     ChatFrameMenuButton:SetScript("OnShow", ChatFrameMenuButton.Hide)
--     ChatFrameMenuButton:Hide()

--     hooksecurefunc('FCFTab_UpdateColors', function(frame, sel)
--         if sel then
--             PushUIStyle.SetFontColor(frame:GetFontString(), unpack(PushUIColor.white))
--         else
--             PushUIStyle.SetFontColor(frame:GetFontString(), unpack(PushUIColor.gray))
--         end
--     end)

--     hooksecurefunc('FCF_StartAlertFlash', function(frame)
--         local _tab = _G['ChatFrame'..frame:GetID()..'Tab']
--         PushUIStyle.SetFontColor(_tab:GetFontString(), unpack(PushUIColor.orange))
--     end)

--     -- GeneralDockManager:HookScript("OnShow", function(self, ...)
--     --     if _chatdock.panel:GetAlpha() == 0 then
--     --         self:Hide()
--     --     end
--     -- end)

--     GeneralDockManager:SetParent(_chatdock.panel)


--     --NUM_CHAT_WINDOWS is the max number of available chat frame.
--     --not the chat frame number now being loaded.
--     local _chatNum = NUM_CHAT_WINDOWS
--     for i = 1, NUM_CHAT_WINDOWS do
--         local _chatF = _G["ChatFrame"..i]
--         local _chatFTab = _G["ChatFrame"..i.."Tab"]

--         -- _chatF:HookScript("OnShow", function(self, ...)
--         --     if _chatdock.panel:GetAlpha() == 0 then
--         --         self:Hide()
--         --     end
--         -- end)

--         -- No more loaded chat frame
--         if _chatF == nil then
--             _chatNum = i - 1
--             break
--         end

--         -- Change the tab font size to 11
--         PushUIStyle.SetFontSize(_chatFTab:GetFontString(), 11)

--         -- Clear the tab texture
--         _chatFTab.texture = nil
--         --PushUI.Style.BackgroundFormatDark(_chatFTab)
--         local _tabL = getglobal("ChatFrame"..i.."TabLeft")
--         local _tabHL = getglobal("ChatFrame"..i.."TabHighlightLeft")
--         local _tabSL = getglobal("ChatFrame"..i.."TabSelectedLeft")

--         local _tabM = getglobal("ChatFrame"..i.."TabMiddle")
--         local _tabHM = getglobal("ChatFrame"..i.."TabHighlightMiddle")
--         local _tabSM = getglobal("ChatFrame"..i.."TabSelectedMiddle")

--         local _tabR = getglobal("ChatFrame"..i.."TabRight")
--         local _tabHR = getglobal("ChatFrame"..i.."TabHighlightRight")
--         local _tabSR = getglobal("ChatFrame"..i.."TabSelectedRight")

--         _tabL:SetTexture(nil)
--         _tabHL:SetTexture(nil)
--         _tabSL:SetTexture(nil)

--         _tabM:SetTexture(nil)
--         _tabHM:SetTexture(nil)
--         _tabSM:SetTexture(nil)

--         _tabR:SetTexture(nil)
--         _tabHR:SetTexture(nil)
--         _tabSR:SetTexture(nil)

--         -- Can move to the screen side. 
--         _chatF:SetClampedToScreen(true)
--         _chatF:SetClampRectInsets(0, 0, 0, 0)

--         -- Remove the Arrow Frame
--         local _btnFrame = _G["ChatFrame"..i.."ButtonFrame"]
--         _btnFrame:SetScript("OnShow", _btnFrame.Hide)
--         _btnFrame:Hide()

--         -- BottomFrame
--         --local _btnfbb = _G["ChatFrame"..i.."ButtonFrameBottomButton"]
--         --PushUIConfig.skinType(_btnfbb)
--         _chatF:SetParent(_chatdock.panel)
--     end

--     PushUIConfig.skinType(BNToastFrame)

--     -- Resize the chat frame
--     _chatdock.__resize()

--     if _config.displayOnLoad then
--         _panelContainer.Push(_chatdock.panel)
--     else
--         _tintContainer.Push(_chatdock.tintBar)
--     end

--     PushUIAPI.UnregisterEvent("PLAYER_ENTERING_WORLD", _chatdock)
-- end

-- PushUIAPI.RegisterEvent(
--     "PLAYER_ENTERING_WORLD", 
--     _chatdock,
--     _chatdock.__init
-- )

