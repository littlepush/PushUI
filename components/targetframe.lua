local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local PushUIFramesTargetFrameHook = {}
local targetFrameConfig = PushUIConfig.TargetFrameHook

-- Not config to enable player frame
if targetFrameConfig == nil then return end

PushUIFramesTargetFrameHook.name = "PushUIFramesTargetFrameHook"
PushUIFramesTargetFrameHook.object = "target"
PushUIFramesTargetFrameHook.apiObject = PushUIAPI.UnitTarget
PushUIFramesTargetFrameHook.auraApiObject = PushUIAPI.TargetAuras

PushUIFrames.UnitFrame.Create(PushUIFramesTargetFrameHook, targetFrameConfig)

TargetFrame:SetScript("OnEvent", nil)
TargetFrame:Hide()

--     --Boss1Frame:Hide()
--     Boss1TargetFrame:Hide()
--     Boss2TargetFrame:Hide()
--     Boss3TargetFrame:Hide()
--     Boss4TargetFrame:Hide()
--     Boss5TargetFrame:Hide()
    
--     PartyMemberFrame1:Hide()
--     PartyMemberFrame2:Hide()
--     PartyMemberFrame3:Hide()
--     PartyMemberFrame4:Hide()    
