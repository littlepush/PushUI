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

-- Test Successful
-- local _leftDockContainer = PushUIFrames.DockFrame.CreateDockContainer("PushUIFramesDockContainerLeft", "LEFT")
-- _leftDockContainer:SetWidth(GetScreenWidth())
-- _leftDockContainer:SetHeight(PushUISize.blockNormalHeight)
-- _leftDockContainer:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
-- PushUIConfig.skinType(_leftDockContainer)

-- local _tintDockContainer = PushUIFrames.DockFrame.CreateDockContainer("PushUIFramesDockContainerTint", "RIGHT")
-- _tintDockContainer:SetWidth(GetScreenWidth())
-- _tintDockContainer:SetHeight(20)
-- _tintDockContainer:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
-- PushUIConfig.skinType(_tintDockContainer)

-- local _colors = {PushUIColor.red, PushUIColor.blue, PushUIColor.orange}
-- for i = 1, 3 do
--     local _dock = PushUIFrames.DockFrame.CreateNewDock("PushUIFramesDock"..i, _colors[i], _leftDockContainer, _tintDockContainer)
--     _dock.floatPanel:SetWidth(200)
--     _dock.floatPanel:SetHeight(i * PushUISize.blockNormalHeight)
--     local _r, _g, _b = unpack(_colors[i])
--     PushUIStyle.BackgroundSolidFormat(_dock.floatPanel, _r, _g, _b, 0.5, 0, 0, 0, 1)

--     _dock.panel:SetWidth(i * 200)
--     PushUIStyle.BackgroundSolidFormat(_dock.panel, _r, _g, _b, 0.7, 0, 0, 0, 1)

--     _tintDockContainer.Push(_dock.tintBar)
-- end
