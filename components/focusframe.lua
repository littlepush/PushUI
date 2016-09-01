local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local PushUIFramesFocusFrameHook = {}
local focusFrameConfig = PushUIConfig.FocusFrameHook

-- Not config to enable player frame
if focusFrameConfig == nil then return end

focusFrameConfig.hookbar.anchorTarget = PushUIFramesPlayerFrameHookHookBar

PushUIFramesFocusFrameHook.name = "PushUIFramesFocusFrameHook"
PushUIFramesFocusFrameHook.object = "focus"
PushUIFramesFocusFrameHook.apiObject = PushUIAPI.UnitFocus

PushUIFrames.UnitFrame.Create(PushUIFramesFocusFrameHook, focusFrameConfig)

FocusFrame:SetScript("OnEvent", nil)
FocusFrame:Hide()
