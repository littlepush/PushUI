local addon, core = ...

core[1] = {}  -- Size
core[2] = {}  -- Colors
core[3] = {}  -- Styles
core[4] = {}  -- APIs
core[5] = {}  -- Configs
core[6] = {}  -- Frames

PushUI = core

local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

-- Global data initialize
PushUIFrames.AllFrames = {}

-- Global Event Handler
-- This is a event handler queue
-- An event can has a serious functions to handle in order.
local _eventDispatcher = CreateFrame("Frame")
local _eventsMap = {}

_eventDispatcher:SetScript("OnEvent", function(_, event, ...)
    if not (_eventDispatcher == _) then
        return
    end
    print(event)
    for i = 1, #_eventsMap[event] do
        local _f, _o = unpack(_eventsMap[event][i])
        -- print("Dispatch Event: ".._o:GetName().."/"..event)
        _f(event, ...)
    end
end)

PushUIAPI.RegisterEvent = function(event, obj, func)
    -- Create empty table for the first event handler
    if not _eventsMap[event] then
        print("create new map for event "..event)
        _eventsMap[event] = {}
        _eventDispatcher:RegisterEvent(event)
    end
    _eventsMap[event][#_eventsMap[event] + 1] = {func, obj}
    -- table.insert(_eventsMap[event], func)
end

PushUIAPI.UnregisterEvent = function(event, obj)
    for idx, rf in ipairs(_eventsMap[event]) do
        local _f, _o = unpack(_eventsMap[event][idx])
        if ( _o == obj ) then
            table.remove(_eventsMap[event], idx)
            break
        end
    end
    if #_eventsMap[event] == 0 then
        _eventsMap[event] = nil
        _eventDispatcher:UnregisterEvent(event)
    end
end

PushUISize.Resolution = {}
PushUISize.Resolution.scale = 1.0
PushUISize.Resolution.Change = function(event)
    PushUISize.Resolution.width = GetScreenWidth()
    PushUISize.Resolution.height = GetScreenHeight()
    local _sw = PushUISize.Resolution.width
    local _scale = 1.0
    if _sw < 1280 then
        _scale = (_sw / 1280)
    elseif _sw > 2280 then
        _scale = (_sw / 2280)
    end
    PushUISize.Resolution.scale = _scale

    if PushUIConfig.uiScaleAuto then
        if not InCombatLockdown() then
            for _,f in pairs(PushUIFrames.AllFrames) do
                if f.ReSize then
                    f.ReSize()
                end
            end
        else
            PushUIAPI.RegisterEvent(
                "PLAYER_REGEN_ENABLED",
                PushUISize.Resolution.Change
                )
        end

        if event == "PLAYER_REGEN_ENABLED" then
            PushUIAPI.UnregisterEvent(
                "PLAYER_REGEN_ENABLED",
                PushUISize.Resolution.Change
                )
        end
    end
end

-- PushUIAPI.RegisterEvent("VARIABLES_LOADED", PushUISize.Resolution.Change)
-- PushUIAPI.RegisterEvent("UI_SCALE_CHANGED", PushUISize.Resolution.Change)

-- Create the main frame and hide
local PushUIMainFrame = CreateFrame("Frame", "PushUIMainFrame", UIParent)
PushUIMainFrame:Hide()
PushUIMainFrame.OnBoot = function()
    SELECTED_CHAT_FRAME:AddMessage("PushUI Version 1.0.alpha")
    SELECTED_CHAT_FRAME:AddMessage("Visit the project on Github https://github.com/littlepush/PushUI")
    SELECTED_CHAT_FRAME:AddMessage("Connect the author on Twitter: @littlepush")
    SELECTED_CHAT_FRAME:AddMessage("You are welcomed to join our guild: [TW][Lambda]!")
    PushUIAPI.UnregisterEvent("PLAYER_ENTERING_WORLD", PushUIMainFrame)
end
PushUIAPI.RegisterEvent("PLAYER_ENTERING_WORLD", PushUIMainFrame, PushUIMainFrame.OnBoot)

