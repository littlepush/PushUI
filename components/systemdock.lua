local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local _sysdockPrefixName = "PushUIFramesSystemDock"
local _colorUsage = {0.11, 0.11, 0.13}

local lcontainer = "PushUIFramesLeftDockContainer"
local ltint = "PushUIFrameLeftTintContainer"
local rcontainer = "PushUIFramesRightDockContainer"
local rtint = "PushUIFrameRightTintContainer"

local _lpanelContainer = _G[lcontainer]
local _ltintContainer = _G[ltint]
local _rpanelContainer = _G[rcontainer]
local _rtintContainer = _G[rtint]

local _addonUsageDock = PushUIFrames.DockFrame.CreateNewDock(
    _sysdockPrefixName.."AddonUsage", _colorUsage, "BOTTOM", _lpanelContainer, _ltintContainer)
_addonUsageDock.__name = _sysdockPrefixName.."AddonUsage"
_addonUsageDock.panelAvailable = false;
PushUIConfig.skinTooltipType(_addonUsageDock.floatPanel)

_addonUsageDock.addonListLabel = PushUIFrames.Label.Create(_addonUsageDock.__name.."ListLabel", _addonUsageDock.floatPanel)
_addonUsageDock.memUsageLabel = PushUIFrames.Label.Create(_addonUsageDock.__name.."Memlabel", _addonUsageDock.floatPanel)
_addonUsageDock.addonListLabel:SetPoint("TOPLEFT", _addonUsageDock.floatPanel, "TOPLEFT")
_addonUsageDock.memUsageLabel:SetPoint("TOPRIGHT", _addonUsageDock.floatPanel, "TOPRIGHT")
_addonUsageDock.addonListLabel.SetFont(nil, 14)
_addonUsageDock.memUsageLabel.SetFont(nil, 14)
_addonUsageDock.addonListLabel.SetForceWidth(200)
_addonUsageDock.memUsageLabel.SetForceWidth(100)
_addonUsageDock.addonListLabel.SetJustifyH("LEFT")
_addonUsageDock.memUsageLabel.SetJustifyH("RIGHT")
_addonUsageDock.addonListLabel.SetMaxLines(999)
_addonUsageDock.memUsageLabel.SetMaxLines(999)
_addonUsageDock.floatPanel:SetWidth(300)

_addonUsageDock.__gatherAddonInfo = function()
    local _addonNames = ""
    local _addonMems = ""
    local _c_loadedAddons = GetNumAddOns()
    for i = 1, _c_loadedAddons do 
        repeat
            local _name, _, _, _loadable = GetAddOnInfo(i)
            if not _loadable then break end
            local _mem = GetAddOnMemoryUsage(_name)

            if _mem >= 1024 then 
                _mem = _mem / 1024
                _mem = ("%.2f"):format(_mem).."MB"
            else
                _mem = ("%.2f"):format(_mem).."KB"
            end

            if _addonNames == "" then _addonNames = _name
            else _addonNames = _addonNames.."\n".._name
            end

            if _addonMems == "" then _addonMems = _mem
            else _addonMems = _addonMems.."\n".._mem
            end
        until true
    end

    _addonUsageDock.addonListLabel.SetTextString(_addonNames)
    _addonUsageDock.memUsageLabel.SetTextString(_addonMems)

    _addonUsageDock.floatPanel:SetHeight(_addonUsageDock.addonListLabel:GetHeight())
end

_addonUsageDock.__refreshTimer = PushUIFrames.Timer.Create(1, _addonUsageDock.__gatherAddonInfo)

_addonUsageDock.floatPanel.WillAppear = function()
    _addonUsageDock.__gatherAddonInfo()
    _addonUsageDock.__refreshTimer.StartTimer()
end

_addonUsageDock.floatPanel.WillDisappear = function()
    _addonUsageDock.__refreshTimer:StopTimer()
end

_ltintContainer.Push(_addonUsageDock.tintBar)



