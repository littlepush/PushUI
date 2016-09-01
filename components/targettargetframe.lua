local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local PushUIFramesTargetTargetFrameHook = {}
local targettargetFrameConfig = PushUIConfig.TargetTargetFrameHook

-- Not config to enable player frame
if targettargetFrameConfig == nil then return end

targettargetFrameConfig.hookbar.anchorTarget = PushUIFramesTargetFrameHookHookBar

PushUIFramesTargetTargetFrameHook.name = "PushUIFramesTargetTargetFrameHook"
PushUIFramesTargetTargetFrameHook.object = "targettarget"
PushUIFramesTargetTargetFrameHook.apiObject = PushUIAPI.UnitTargetTarget

PushUIFrames.UnitFrame.Create(PushUIFramesTargetTargetFrameHook, targettargetFrameConfig)
