local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))
    
if not IsAddOnLoaded("Skada") then return end

local PushUIFrameSkadaHook = PushUIFrames.Frame.Create("PushUIFrameSkadaHook", PushUIConfig.SkadaFrameHook)
PushUIFrameSkadaHook.HookParent = PushUIConfig.SkadaFrameHook.parent.HookFrame
PushUIFrameSkadaHook.ToggleCanShow = true

PushUIFrameSkadaHook.Toggle = function(statue)
    PushUIFrameSkadaHook.ToggleCanShow = statue
    if statue then
        for index,win in pairs(Skada:GetWindows()) do
            win.bargroup:Show()
        end
    else
        for index,win in pairs(Skada:GetWindows()) do
            win.bargroup:Hide()
        end
    end
end

PushUIFrameSkadaHook.ReSizeBarGroup = function(swin, index, win_count)
    swin:ClearAllPoints()
    --GetBlockRect
    local _w, _h, _x, _y = PushUIFrameSkadaHook.HookParent.GetBlockRect(index, win_count)
    _w = _w * PushUISize.Resolution.scale
    _h = _h * PushUISize.Resolution.scale
    _x = _x * PushUISize.Resolution.scale
    _y = _y * PushUISize.Resolution.scale

    local bc = 8
    if not PushUIConfig.SkadaFrameHook.barCount then
        bc = PushUIConfig.SkadaFrameHook.barCount
    end

    swin:SetBackdrop(nil)
    swin.button:Hide()
    swin:SetWidth(_w)
    swin:SetBarWidth(_w)
    swin:SetBarHeight(_h / bc - 0.5)
    swin:SetHeight(_h)

    swin:SetPoint('TOPLEFT', PushUIFrameSkadaHook.HookParent, 'TOPLEFT', _x, _y)
end

PushUIFrameSkadaHook.ReSize = function(...)
    for k,v in pairs(Skada:GetWindows()) do
        PushUIFrameSkadaHook.ReSizeBarGroup(v.bargroup, k, #Skada:GetWindows())
    end
end

PushUIFrameSkadaHook.Init = function(...)
    if not Skada then return end
    if not PushUIFrameSkadaHook.HookParent then return end
    if not PushUIFrameSkadaHook.HookParent.GetBlockRect then return end

    local _skada = Skada.displays['bar']

    hooksecurefunc(_skada, 'AddDisplayOptions', function(self, win, options)
        options.baroptions.args.barspacing = nil
        options.baroptions.args.barslocked = true
        options.titleoptions.args.texture = nil
        options.titleoptions.args.bordertexture = nil
        options.titleoptions.args.thickness = nil
        options.titleoptions.args.margin = nil
        options.titleoptions.args.color = nil
        options.windowoptions = nil
    end)

    hooksecurefunc(_skada, 'ApplySettings', function(self, win)
        local _s = win.bargroup
        local _name = win.bargroup:GetName()

        local _index = 0
        for k,v in pairs(Skada:GetWindows()) do
            if v.bargroup:GetName() == _name then
                _index = k
                break
            end
        end
        PushUIFrameSkadaHook.ReSizeBarGroup(_s, _index, #Skada:GetWindows())
    end)

    for k,v in pairs(Skada:GetWindows()) do
        v.bargroup:HookScript("OnShow", function(self, ...)
            if not PushUIFrameSkadaHook.ToggleCanShow then
                self:Hide()
            end
        end)
        v.bargroup:HookScript("OnHide", function(self, ...)
            if PushUIFrameSkadaHook.ToggleCanShow then
                self:Show()
            end
        end)
    end

    PushUIFrameSkadaHook.ReSize()

    if not PushUIConfig.SkadaFrameHook.displayOnLoad then
        PushUIFrameSkadaHook.Toggle(false)
    end
end

PushUIAPI.RegisterEvent(
    "PLAYER_ENTERING_WORLD", 
    PushUIFrameSkadaHook,
    PushUIFrameSkadaHook.Init
)
