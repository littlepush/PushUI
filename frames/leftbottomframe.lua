local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

if not (PushUIConfig.LeftDockContainer and PushUIConfig.LeftDockContainer.enable) then
    return
end

local _dockContainer = PushUIFrames.DockFrame.CreateDockContainer(
    PushUIConfig.LeftDockContainer.name, PushUIConfig.LeftDockContainer.side)
_dockContainer:SetWidth((GetScreenWidth() - PushUIFrameActionBarFrame:GetWidth()) / 2)
_dockContainer:SetHeight(PushUIConfig.LeftDockContainer.height)
_dockContainer:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, PushUISize.screenBottomPadding)

local _tintContainer = PushUIFrames.DockFrame.CreateDockContainer(
    PushUIConfig.LeftDockContainer.tintContainer.name, 
    PushUIConfig.LeftDockContainer.tintContainer.side)
_tintContainer:SetWidth(GetScreenWidth() / 2)
_tintContainer:SetHeight(PushUIConfig.LeftDockContainer.tintContainer.height)
_tintContainer:SetPoint("TOPLEFT", _dockContainer, "BOTTOMLEFT", 0, 0)

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
