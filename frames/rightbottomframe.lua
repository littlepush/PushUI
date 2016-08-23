local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local PushUIFrameRightBottomFrame = PushUIFrames.BottomFrame.Create("PushUIFrameRightBottomFrame", false, PushUIConfig.RightBottomFrame)
PushUIFrameRightBottomFrame.InitializeSwitcher()

PushUIFrameRightBottomFrame.Init = function(event, ...)
    local f = PushUIFrameRightBottomFrame
    PushUIConfig.skinType(f)
    f.ReSize()
end

PushUIFrameRightBottomFrame.Init()
