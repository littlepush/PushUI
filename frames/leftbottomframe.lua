local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local PushUIFrameLeftBottomFrame = PushUIFrames.BottomFrame.Create("PushUIFrameLeftBottomFrame", true, PushUIConfig.LeftBottomFrame)
PushUIFrameLeftBottomFrame.InitializeSwitcher()

PushUIFrameLeftBottomFrame.Init = function(event, ...)
    local f = PushUIFrameLeftBottomFrame
    PushUIConfig.skinType(f)
    f.ReSize()
end

PushUIFrameLeftBottomFrame.Init()

