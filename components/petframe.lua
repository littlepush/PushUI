local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local PushUIFramesPetFrameHook = {}
local petFrameConfig = PushUIConfig.PetFrameHook

-- Not config to enable player frame
if petFrameConfig == nil then return end

petFrameConfig.hookbar.anchorTarget = PushUIFramesPlayerFrameHookHookBar

PushUIFramesPetFrameHook.name = "PushUIFramesPetFrameHook"
PushUIFramesPetFrameHook.object = "pet"
PushUIFramesPetFrameHook.apiObject = PushUIAPI.UnitPet

PushUIFrames.UnitFrame.Create(PushUIFramesPetFrameHook, petFrameConfig)
