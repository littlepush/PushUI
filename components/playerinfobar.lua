local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

-- Create default config
local _config = PushUIConfig.PlayerInfoFrameDock
if not _config then 
    _config = {
        container = "PushUIFramesLeftDockContainer",
        tint = "PushUIFrameLeftTintContainer",
        color = PushUIColor.orange,
        displayOnLoad = false,
        width = 150
    }
end

local _panelContainer = _G[_config.container]
local _tintContainer = _G[_config.tint]
local _name = "PushUIFrameUserInfoBarFrameDock"

local _uibdock = PushUIFrames.DockFrame.CreateNewDock(
    _name, _config.color, "BOTTOM", _panelContainer, _tintContainer)
_uibdock.panel:SetWidth(_config.width)
PushUIConfig.skinType(_uibdock.panel)
PushUIConfig.skinType(_uibdock.floatPanel)

local _floatLabel = PushUIFrames.Label.Create(_name.."FloatLabel", _uibdock.floatPanel, true)
_floatLabel:SetPoint("TOPLEFT", _uibdock.floatPanel, "TOPLEFT", 0, 0)

_uibdock.floatPanel.WillAppear = function()
    local _exp = PushUIAPI.UnitExp.Value() / PushUIAPI.UnitExp.MaxValue() * 100
    local _repName = "Nan"
    local _rep = "nan"
    if PushUIAPI.WatchedFactionInfo.CanDisplay() then
        _rep = PushUIAPI.WatchedFactionInfo.Value() / PushUIAPI.WatchedFactionInfo.MaxValue() * 100
        _rep = ("%.2f"):format(_rep)
        _repName = PushUIAPI.WatchedFactionInfo.name
    end
    local _userinfo = "Level: "..UnitLevel("player").."\n\n"
    _userinfo = _userinfo.."Exp: "..("%d"):format(_exp).."%\n\n"
    _userinfo = _userinfo.."Rep: ".._repName.." ".._rep.."%\n\n"

    if PushUIAPI.Artifact.CanDisplay() then
        local _artValue = ("%.2f"):format(PushUIAPI.Artifact.Value() / PushUIAPI.Artifact.MaxValue() * 100).."%"
        _userinfo = _userinfo..PushUIAPI.Artifact.name..": ".._artValue
    end

    _floatLabel.SetTextString(_userinfo)
end

local _textHeight = 14
local _barHeight = 20
local _itemPadding = 5
local _groupHeight = _textHeight + _barHeight + _itemPadding

local _panelHeight = _uibdock.panel:GetHeight()

local _expLabel = PushUIFrames.Label.Create(_name.."ExpLabel", _uibdock.panel)
_expLabel.SetPadding(0)
_expLabel.SetFont(nil, 14)
_expLabel.__onDataUpdate = function()
    _expLabel.SetTextString("Level: "..UnitLevel("player")..", Exp:")
end
PushUIAPI.UnitExp.RegisterForValueChanged(_expLabel, _expLabel.__onDataUpdate)
_expLabel.__onDataUpdate()
local _expBarConfig = {
    targets = { PushUIAPI.UnitExp },
    fillColor = { PushUIColor.expColorDynamic },
    alwaysDisplay = true
}
local _expBar = PushUIFrames.ProgressBar.Create(_name.."ExpBar", _uibdock.panel, _expBarConfig, "HORIZONTAL")
_expBar:SetWidth(_config.width - 10)
_expBar:SetHeight(_barHeight)

PushUIAPI.WatchedFactionInfo.CanDisplay()
local _repLabel = PushUIFrames.Label.Create(_name.."RepLabel", _uibdock.panel)
_repLabel.SetPadding(0)
_repLabel.SetFont(nil, 14)
_repLabel.__onDataUpdate = function()
    local _repName = PushUIAPI.WatchedFactionInfo.name or "Nan"
    local _repRank = PushUIAPI.WatchedFactionInfo.rank or "nan"
    _repLabel.SetTextString(_repName..", ".._repRank..":")
end
PushUIAPI.WatchedFactionInfo.RegisterForValueChanged(_repLabel, _repLabel.__onDataUpdate)
PushUIAPI.WatchedFactionInfo.RegisterForDisplayStatus(_repLabel, _repLabel.__onDataUpdate)
_repLabel.__onDataUpdate()
local _repBarConfig = {
    targets = { PushUIAPI.WatchedFactionInfo },
    fillColor = { PushUIColor.factionColorDynamic },
    alwaysDisplay = true
}
local _repBar = PushUIFrames.ProgressBar.Create(_name.."RepBar", _uibdock.panel, _repBarConfig, "HORIZONTAL")
_repBar:SetWidth(_config.width - 10)
_repBar:SetHeight(_barHeight)

PushUIAPI.Artifact.CanDisplay()
local _artiLabel = PushUIFrames.Label.Create(_name.."ArtifactLabel", _uibdock.panel)
_artiLabel.SetPadding(0)
_artiLabel.SetFont(nil, 14)
_artiLabel.__onDataUpdate = function()
    local _artiName = PushUIAPI.Artifact.name or "Nan"
    _artiLabel.SetTextString(_artiName..":")
end
PushUIAPI.WatchedFactionInfo.RegisterForValueChanged(_artiLabel, _artiLabel.__onDataUpdate)
PushUIAPI.WatchedFactionInfo.RegisterForDisplayStatus(_artiLabel, _artiLabel.__onDataUpdate)
_artiLabel.__onDataUpdate()
local _artiBarConfig = {
    targets = { PushUIAPI.Artifact },
    fillColor = { function(...) return {unpack(PushUIColor.yellow), 1} end },
    alwaysDisplay = true
}
local _artiBar = PushUIFrames.ProgressBar.Create(_name.."ArtifactBar", _uibdock.panel, _artiBarConfig, "HORIZONTAL")
_artiBar:SetWidth(_config.width - 10)
_artiBar:SetHeight(_barHeight)

local function __formatBarDisplay()
    -- Always Show Exp Bar, even max level
    local _barToShow = 1

    local _showRep = false
    local _showArti = false

    if PushUIAPI.WatchedFactionInfo.CanDisplay() then
        _barToShow = _barToShow + 1
        _showRep = true
    end

    if PushUIAPI.Artifact.CanDisplay() then
        _barToShow = _barToShow + 1
        _showArti = true
    end

    local _groupPadding = (_panelHeight - _groupHeight * _barToShow) / (_barToShow + 1)
    _expLabel:ClearAllPoints()
    _expLabel:SetPoint("TOPLEFT", _uibdock.panel, "TOPLEFT", 5, -_groupPadding)
    _expBar:ClearAllPoints()
    _expBar:SetPoint("TOPLEFT", _uibdock.panel, "TOPLEFT", 5, -(_groupPadding + _textHeight + _itemPadding))

    local _top = _groupPadding + _groupHeight + _groupPadding
    if _showRep then
        _repLabel:ClearAllPoints()
        _repLabel:SetPoint("TOPLEFT", _uibdock.panel, "TOPLEFT", 5, -_top)
        _repBar:ClearAllPoints()
        _repBar:SetPoint("TOPLEFT", _uibdock.panel, "TOPLEFT", 5, -(_top + _textHeight + _itemPadding))

        _top = _top + _groupHeight + _groupPadding
    end

    if _showArti then
        _artiLabel:ClearAllPoints()
        _artiLabel:SetPoint("TOPLEFT", _uibdock.panel, "TOPLEFT", 5, -_top)
        _artiBar:ClearAllPoints()
        _artiBar:SetPoint("TOPLEFT", _uibdock.panel, "TOPLEFT", 5, -(_top + _textHeight + _itemPadding))
    end
end

PushUIAPI.WatchedFactionInfo.RegisterForDisplayStatus(_uibdock, __formatBarDisplay)
PushUIAPI.WatchedFactionInfo.RegisterForDisplayStatus(_uibdock, __formatBarDisplay)
__formatBarDisplay()

if _config.displayOnLoad then
    _panelContainer.Push(_uibdock.panel)
else
    _tintContainer.Push(_uibdock.tintBar)
end
