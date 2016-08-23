local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local PushUIFrameChatFrameHook = PushUIFrames.Frame.Create("PushUIFrameChatFrameHook", PushUIConfig.ChatFrameHook)
PushUIFrameChatFrameHook.HookParent = PushUIConfig.ChatFrameHook.parent.HookFrame
PushUIFrameChatFrameHook.ToggleCanShow = true

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

PushUIFrameChatFrameHook.Toggle = function(statue)
    PushUIFrameChatFrameHook.ToggleCanShow = statue
    if statue then
        SELECTED_CHAT_FRAME:Show()
        GeneralDockManager:Show()
    else
        SELECTED_CHAT_FRAME:Hide()
        GeneralDockManager:Hide()
    end
end

PushUIFrameChatFrameHook.ReSize = function()
    SELECTED_CHAT_FRAME:ClearAllPoints()
    local _w, _h, _x, _y = PushUIFrameChatFrameHook.HookParent.GetBlockRect(1, 1)
    _w = _w * PushUISize.Resolution.scale
    _h = _h * PushUISize.Resolution.scale
    _x = _x * PushUISize.Resolution.scale
    _y = _y * PushUISize.Resolution.scale

    SELECTED_CHAT_FRAME:SetWidth(_w)
    SELECTED_CHAT_FRAME:SetHeight(_h)

    SELECTED_CHAT_FRAME:SetPoint(
        "TOPLEFT", PushUIFrameChatFrameHook.HookParent, "TOPLEFT", 
        _x, _y)
end

PushUIFrameChatFrameHook.Init = function(...)
    local f = PushUIFrameChatFrameHook

    -- Format
    FriendsMicroButton:SetScript("OnShow", FriendsMicroButton.Hide)
    FriendsMicroButton:Hide()

    GeneralDockManagerOverflowButton:SetScript("OnShow", GeneralDockManagerOverflowButton.Hide)
    GeneralDockManagerOverflowButton:Hide()

    ChatFrameMenuButton:SetScript("OnShow", ChatFrameMenuButton.Hide)
    ChatFrameMenuButton:Hide()

    hooksecurefunc('FCFTab_UpdateColors', function(frame, sel)
        if sel then
            PushUIStyle.SetFontColor(frame:GetFontString(), unpack(PushUIColor.white))
        else
            PushUIStyle.SetFontColor(frame:GetFontString(), unpack(PushUIColor.gray))
        end
    end)

    hooksecurefunc('FCF_StartAlertFlash', function(frame)
        local _tab = _G['ChatFrame'..frame:GetID()..'Tab']
        PushUIStyle.SetFontColor(_tab:GetFontString(), unpack(PushUIColor.orange))
    end)

    GeneralDockManager:HookScript("OnShow", function(self, ...)
        if not PushUIFrameChatFrameHook.ToggleCanShow then
            self:Hide()
        end
    end)
    --NUM_CHAT_WINDOWS is the max number of available chat frame.
    --not the chat frame number now being loaded.
    local _chatNum = NUM_CHAT_WINDOWS
    for i = 1, NUM_CHAT_WINDOWS do
        local _chatF = _G["ChatFrame"..i]
        local _chatFTab = _G["ChatFrame"..i.."Tab"]

        PushUIFrameChatFrameHook.OnShowChatFrame = _chatF:GetScript("OnShow")
        _chatF:HookScript("OnShow", function(self, ...)
            if PushUIFrameChatFrameHook.ToggleCanShow then
                return
            end
            self:Hide()
        end)

        -- No more loaded chat frame
        if _chatF == nil then
            _chatNum = i - 1
            break
        end

        -- Change the tab font size to 11
        PushUIStyle.SetFontSize(_chatFTab:GetFontString(), 11)

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

        -- BottomFrame
        local _btnfbb = _G["ChatFrame"..i.."ButtonFrameBottomButton"]
        --PushUIConfig.skinType(_btnfbb)
    end

    PushUIConfig.skinType(BNToastFrame)

    f.ReSize()

    if not PushUIConfig.ChatFrameHook.displayOnLoad then
        print("will hide chat frame because set not to display on load")
        PushUIFrameChatFrameHook.Toggle(false)
    end
end

PushUIAPI.RegisterEvent(
    "PLAYER_ENTERING_WORLD", 
    PushUIFrameChatFrameHook,
    PushUIFrameChatFrameHook.Init
)

