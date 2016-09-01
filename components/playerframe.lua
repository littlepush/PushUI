local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local PushUIFramesPlayerFrameHook = {}
local playerFrameConfig = PushUIConfig.PlayerFrameHook

-- Not config to enable player frame
if playerFrameConfig == nil then return end

PushUIFramesPlayerFrameHook.name = "PushUIFramesPlayerFrameHook"
PushUIFramesPlayerFrameHook.object = "player"
PushUIFramesPlayerFrameHook.apiObject = PushUIAPI.UnitPlayer
PushUIFramesPlayerFrameHook.auraApiObject = PushUIAPI.PlayerAuras

PushUIFrames.UnitFrame.Create(PushUIFramesPlayerFrameHook, playerFrameConfig)

PushUIFramesPlayerFrameHook.ForceUpdate = function()
    PushUIFrames.UnitFrame.ForceUpdate(PushUIFramesPlayerFrameHook)
end
PushUIAPI.RegisterEvent(
    "PLAYER_ENTERING_WORLD", 
    PushUIFramesPlayerFrameHook,
    PushUIFramesPlayerFrameHook.ForceUpdate
)

PlayerFrame:SetScript("OnEvent", nil)
PlayerFrame:Hide()
