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
