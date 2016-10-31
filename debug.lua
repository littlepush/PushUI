local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local function _debug_initFunction()
    SELECTED_CHAT_FRAME:AddMessage("PushUI by Push @littlepush")
    --eventHandler_newWatchingQuest(nil, PushUIAPI.NormalQuests.questList)
    PushUIAPI.EventCenter:FireEvent(PushUIAPI.PUIEVENT_NORMAL_QUEST_NEWWATCH, PushUIAPI.NormalQuests.questList)

    GarrisonLandingPageMinimapButton:SetScript("OnShow", GarrisonLandingPageMinimapButton.Hide)
    GarrisonLandingPageMinimapButton:Hide()

    PushUIAPI.PlayerHP:valueChanged()
    -- PushUIAPI.PlayerAuras:force_refresh()
    PushUIAPI.PlayerAuras:valueChanged()

    WorldMapFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 30, -30)
    WorldMapFrame:SetScale(0.8)
end

PushUIAPI.EventCenter:RegisterEvent(PushUIAPI.PUSHUIEVENT_PLAYER_FIRST_ENTERING_WORLD, "debug_init", _debug_initFunction)

