local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

if not (PushUIConfig.RightDockContainer and PushUIConfig.RightDockContainer.enable) then
    return
end

local _dockContainer = PushUIFrames.DockFrame.CreateDockContainer(
    PushUIConfig.RightDockContainer.name, PushUIConfig.RightDockContainer.side)
_dockContainer:SetWidth((GetScreenWidth() - PushUIFrameActionBarFrame:GetWidth()) / 2)
_dockContainer:SetHeight(PushUIConfig.RightDockContainer.height)
_dockContainer:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, PushUISize.screenBottomPadding)

local _tintContainer = PushUIFrames.DockFrame.CreateDockContainer(
    PushUIConfig.RightDockContainer.tintContainer.name, 
    PushUIConfig.RightDockContainer.tintContainer.side)
_tintContainer:SetWidth(GetScreenWidth() / 2)
_tintContainer:SetHeight(PushUIConfig.RightDockContainer.tintContainer.height)
_tintContainer:SetPoint("TOPRIGHT", _dockContainer, "BOTTOMRIGHT", 0, 0)
