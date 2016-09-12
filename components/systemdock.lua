local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local _sysdockPrefixName = "PushUIFramesSystemDock"
local _colorUsage = {0.22, 0.56, 0.66}
local _colorSysStat = {0.81, 0.71, 0.5}

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
-- _addonUsageDock.addonListLabel.SetForceWidth(200)
_addonUsageDock.memUsageLabel.SetForceWidth(100)
_addonUsageDock.addonListLabel.SetJustifyH("LEFT")
_addonUsageDock.memUsageLabel.SetJustifyH("RIGHT")
_addonUsageDock.addonListLabel.SetMaxLines(999)
_addonUsageDock.memUsageLabel.SetMaxLines(999)
_addonUsageDock.floatPanel:SetWidth(300)

_addonUsageDock.allAddonList = {}
local _c_addonCount = GetNumAddOns()
local _addonNameString = ""
for i = 1, _c_addonCount do
    repeat 
        local _name, _, _, _loadable = GetAddOnInfo(i)
        if not _loadable then break end
        _addonUsageDock.allAddonList[#_addonUsageDock.allAddonList + 1] = _name

        if _addonNameString == "" then _addonNameString = _name
        else _addonNameString = _addonNameString.."\n".._name
        end
    until true
end
_addonUsageDock.addonListLabel.SetTextString(_addonNameString)
local _addonHeight = _addonUsageDock.addonListLabel:GetHeight()
local _addonWidth = _addonUsageDock.addonListLabel:GetWidth()
_addonUsageDock.floatPanel:SetWidth(_addonWidth + 100)
_addonUsageDock.floatPanel:SetHeight(_addonHeight)


_addonUsageDock.__gatherAddonInfo = function()
    local _addonMems = ""
    local _c_loadedAddons = #_addonUsageDock.allAddonList
    for i = 1, _c_loadedAddons do 
        local _name = _addonUsageDock.allAddonList[i]
        local _mem = GetAddOnMemoryUsage(_name)

        if _mem >= 1024 then 
            _mem = _mem / 1024
            _mem = ("%.2f"):format(_mem).."MB"
        else
            _mem = ("%.2f"):format(_mem).."KB"
        end

        if _addonMems == "" then _addonMems = _mem
        else _addonMems = _addonMems.."\n".._mem
        end
    end

    _addonUsageDock.memUsageLabel.SetTextString(_addonMems)
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


--
-- System Status
local _sysstatDock = PushUIFrames.DockFrame.CreateNewDock(
    _sysdockPrefixName.."SysStat", _colorSysStat, "BOTTOM", _lpanelContainer, _ltintContainer)
_sysstatDock.__name = _sysdockPrefixName.."SysStat"
_sysstatDock.panelAvailable = false;
PushUIConfig.skinTooltipType(_sysstatDock.floatPanel)

local _netStatTitleLabel = PushUIFrames.Label.Create(_sysstatDock.__name.."NetTitleState", _sysstatDock.floatPanel)
local _netStatLabel = PushUIFrames.Label.Create(_sysstatDock.__name.."NetState", _sysstatDock.floatPanel)
_netStatTitleLabel.SetMaxLines(4)
_netStatTitleLabel.SetForceWidth(150)
_netStatTitleLabel.SetFont(nil, 14)
_netStatTitleLabel.SetJustifyH("LEFT")
_netStatTitleLabel:SetPoint("TOPLEFT", _sysstatDock.floatPanel, "TOPLEFT")
_netStatLabel.SetMaxLines(4)
_netStatLabel.SetForceWidth(100)
_netStatLabel.SetFont(nil, 14)
_netStatLabel.SetJustifyH("RIGHT")
_netStatLabel:SetPoint("TOPRIGHT", _sysstatDock.floatPanel, "TOPRIGHT")

local _fpsTitleLabel = PushUIFrames.Label.Create(_sysstatDock.__name.."FPSTitle", _sysstatDock.floatPanel)
local _fpsLabel = PushUIFrames.Label.Create(_sysstatDock.__name.."FPS", _sysstatDock.floatPanel)
_fpsTitleLabel.SetForceWidth(150)
_fpsTitleLabel.SetFont(nil, 14)
_fpsTitleLabel.SetJustifyH("LEFT")
_fpsTitleLabel:SetPoint("TOPLEFT", _netStatTitleLabel, "BOTTOMLEFT")
_fpsLabel.SetMaxLines(4)
_fpsLabel.SetForceWidth(100)
_fpsLabel.SetFont(nil, 14)
_fpsLabel.SetJustifyH("RIGHT")
_fpsLabel:SetPoint("TOPRIGHT", _netStatLabel, "BOTTOMRIGHT")

_sysstatDock.floatPanel:SetWidth(250)

_netStatTitleLabel.SetTextString("Downloading:\nUploading:\nLatency Home:\nLatency World:")
_fpsTitleLabel.SetTextString("FPS:")
_sysstatDock.floatPanel:SetHeight(_netStatTitleLabel:GetHeight() + _fpsTitleLabel:GetHeight())

_sysstatDock.__gatherSysInfo = function()
    local _down, _up, _lhome, _lworld = GetNetStats()
    if _down == nil then _down = 0 end
    if _up == nil then _up = 0 end
    if _down >= 1024 then 
        _down = _down / 1024
        _down = ("%.2f"):format(_down).."MB/s"
    else
        _down = ("%.2f"):format(_down).."KB/s"
    end
    if _up >= 1024 then 
        _up = _up / 1024
        _up = ("%.2f"):format(_up).."MB/s"
    else
        _up = ("%.2f"):format(_up).."KB/s"
    end
    if _lhome == nil then _lhome = 0 end
    if _lworld == nil then _lworld = 0 end
    local _sys = _down.."\n".._up.."\n".._lhome.."ms\n".._lworld.."ms"

    _netStatLabel.SetTextString(_sys)

    _fpsLabel.SetTextString(("%.2f"):format(GetFramerate()))
end

_sysstatDock.__gatherSysInfo()
_sysstatDock.__refreshTimer = PushUIFrames.Timer.Create(1, _sysstatDock.__gatherSysInfo)
_sysstatDock.floatPanel.WillAppear = function()
    _sysstatDock.__refreshTimer:StartTimer()
end
_sysstatDock.floatPanel.WillDisappear = function()
    _sysstatDock.__refreshTimer:StopTimer()
end
_ltintContainer.Push(_sysstatDock.tintBar)

