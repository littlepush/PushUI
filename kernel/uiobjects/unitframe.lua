local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local _size = 24
local AConfig = {
    width = _size,
    height = _size,
    pbHeight = _size * 0.15,
    countfs = _size * 0.5,
    flag = "OUTLINE",
    buffColor = PushUIColor.blue,
    debuffColor = PushUIColor.red
}

PushUIFrames.AuraButton = PushUIAPI.inhiert(PushUIFrames.UIView)
function PushUIFrames.AuraButton:c_str(...)
    self.icon = PushUIFrames.UIImage(self)
    self.progress = PushUIFrames.UIProgressBar(self)
    self.count = PushUIFrames.UILabel(self)
    self.tip = PushUIFrames.UILabel(self)

    self._savedAura = nil
end
function PushUIFrames.AuraButton:initialize()
    self:set_backgroundColor(PushUIColor.black, 0)
    self:set_borderColor(PushUIColor.black, 0)

    self.icon:set_size(AConfig.width, AConfig.height)
    self.icon:set_position()

    self.progress:set_size(AConfig.width, AConfig.pbHeight)
    self.progress:set_style("h-l-r")
    self.progress:set_position(0, -AConfig.height)
    self.progress:set_backgroundColor(PushUIColor.black, 0.8)
    self.progress:set_borderColor(PushUIColor.black, 0.8)

    self.count:set_fontname("Interface\\AddOns\\PushUI\\meida\\fontn.ttf")
    self.count:set_fontsize(AConfig.countfs)
    self.count:set_fontflag(AConfig.flag)
    self.count:set_archor("TOPRIGHT")
    self.count:set_archor_target(self.layer, "TOPRIGHT")
    self.count:set_position(-2, -2)

    self:set_size(AConfig.width, AConfig.height + AConfig.pbHeight)
    self:set_archor("TOPLEFT")

    -- Tip
    self.tip:set_fontsize(14)
    self.tip:set_archor("TOPLEFT")
    self.tip:set_archor_target(self.layer, "BOTTOMLEFT")
    self.tip:set_position(0, -2)
    self.tip:set_padding(2)
    self.tip:set_maxline(99)
    self.tip:set_alpha(0)

    self:add_action("PUIEventMouseEnter", "move_in", function()
        self.tip:animation_with_duration(0.3, function(tip)
            tip:set_alpha(1)
        end)
    end)
    self:add_action("PUIEventMouseLeave", "move_out", function()
        self.tip:animation_with_duration(0.3, function(tip)
            tip:set_alpha(0)
        end)
    end)
    self:add_action("PUIEventMouseUp", "up", function()
        if self.aura and self.aura.isbuff then
            CancelUnitBuff("player", self.aura.name)
        end
    end)
    self:set_user_interactive(true)
end
function PushUIFrames.AuraButton:set_aura(aura)
    self._savedAura = aura;
    self.icon:set_image(aura.icon)

    if aura.isbuff then
        self.progress:set_barColor(AConfig.buffColor)
    else
        self.progress:set_barColor(AConfig.debuffColor)
    end
    if aura.expirationTime ~= 0 then
        self.progress:set_max(aura.duration)
        self.progress:set_value(aura.expirationTime - GetTime())
    else
        self.progress:set_max(1)
        self.progress:set_value(1)
    end

    if aura.count ~= 0 then
        self.count:set_text(aura.count)
    else 
        self.count:set_text("")
    end

    self.tip:set_text(aura.name)
end
function PushUIFrames.AuraButton:refresh_progress()
    if self._savedAura.expirationTime ~= 0 then
        self.progress:set_value(self._savedAura.expirationTime - GetTime())
    end
end
local _auraButtonPool = PushUIAPI.Pool(function() return PushUIFrames.AuraButton(); end)

PushUIFrames.UnitFrame = PushUIAPI.inhiert()
function PushUIFrames.UnitFrame:c_str( assets, obj_id, auras_assets )
    self.apiAssets = assets
    self.objectID = obj_id
    self.aurasAssets = auras_assets

    self.hookbar = PushUIFrames.UIView()
    self.name = PushUIFrames.UILabel(self.hookbar)
    self.healthBar = PushUIFrames.UIProgressBar(self.hookbar)
    self.healthMaxValue = PushUIFrames.UILabel(self.hookbar)
    self.healthPercentage = PushUIFrames.UILabel(self.hookbar)
    self.auraPanel = PushUIFrames.UIView(self.hookbar)
    self.buffGroup = PushUIAPI.Array()
    self.debuffGroup = PushUIAPI.Array()

    self._nameSize = 0

    -- Hook Bar
    self._fakeUF = CreateFrame("Button", "PushUIFrames"..obj_id.."HookBar", UIParent, "SecureUnitButtonTemplate")
    self._fakeUF.unit = obj_id
    self._fakeUF:SetAttribute("unit", obj_id)
    self._fakeUF:SetAttribute("type", "target")
    self._rightClickAction = nil;
    self._fakeUF:SetFrameLevel(self.healthBar.layer:GetFrameLevel() + 1)

    if self.aurasAssets ~= nil then
        self._auraTimer = PushUIAPI.Timer()
    end
end

function PushUIFrames.UnitFrame:reset_auras()
    self.buffGroup:for_each(function(_, auraBtn)
        auraBtn:set_hidden(true)
        _auraButtonPool:release(auraBtn)
    end)
    self.buffGroup:clear()
    self.debuffGroup:for_each(function(_, auraBtn)
        auraBtn:set_hidden(true)
        _auraButtonPool:release(auraBtn)
    end)
    self.debuffGroup:clear()
end

function PushUIFrames.UnitFrame:initialize()
    self.apiAssets:add_displayChanged("display_status", function(_, can)
        if not can then 
            self.hookbar:set_hidden(true)
            self._fakeUF:Hide()
            if self._auraTimer then self._auraTimer:stop() end
        else
            self.hookbar:set_hidden(false)
            self._fakeUF:Show()
            if self._auraTimer then self._auraTimer:start() end
        end
    end)
    self.apiAssets:add_valueChanged("value_changed", function(_, hpValue)
        --hp/max_hp
        local _name = UnitName(self.objectID)
        local _ns = self._nameSize
        local _nl = _name:len() / 3 -- Unicode
        if _nl > 6 then
            _ns = _ns / (_nl / 6)
        end
        self.name:set_fontsize(_ns)
        self.name:set_text(_name)

        self.healthBar:set_max(hpValue.max_hp)
        self.healthBar:set_value(hpValue.hp)
        self.healthMaxValue:set_text(hpValue.max_hp)
        self.healthPercentage:set_text(("%.1f"):format(hpValue.hp / hpValue.max_hp * 100).."%")
    end)
    if self.aurasAssets ~= nil then
        self.aurasAssets:add_displayChanged("display_status", function(_, can)
            if not can then
                -- hide 
                self.auraPanel:set_hidden(true)
            else
                self.auraPanel:set_hidden(false)
            end
        end)
        self.aurasAssets:add_valueChanged("value_changed", function(_, auraList)
            self:reset_auras()
            local _x = 0; local _y = 0
            local _maxWidth = self.hookbar:width()
            local _maxInLine = 1
            repeat
                _maxInLine = _maxInLine + 1
            until (_maxInLine + 1) * AConfig.width > _maxWidth
            local _padding = (_maxWidth - (_maxInLine * AConfig.width)) / (_maxInLine - 1)
            local _lineCount = 0

            auraList.buff:for_each(function(_, aura)
                abtn = _auraButtonPool:get()
                abtn:set_aura(aura)
                self.buffGroup:push_back(abtn)

                abtn:set_hidden(false)
                abtn.layer:SetParent(self.auraPanel.layer)
                abtn:set_archor_target(self.auraPanel.layer, "TOPLEFT")

                abtn:set_position(_x, _y)
                _lineCount = _lineCount + 1
                if _lineCount == _maxInLine then
                    _lineCount = 0
                    _x = 0; _y = _y + AConfig.height + AConfig.pbHeight + _padding
                else
                    _x = _x + AConfig.width + _padding
                end
            end)
            auraList.debuff:for_each(function(_, aura)
                abtn = _auraButtonPool:get()
                abtn:set_aura(aura)
                self.debuffGroup:push_back(abtn)
                
                abtn:set_hidden(false)
                abtn.layer:SetParent(self.auraPanel.layer)
                abtn:set_archor_target(self.auraPanel.layer, "TOPLEFT")

                abtn:set_position(_x, _y)
                _lineCount = _lineCount + 1
                if _lineCount == _maxInLine then
                    _lineCount = 0
                    _x = 0; _y = _y + AConfig.height + AConfig.pbHeight + _padding
                else
                    _x = _x + AConfig.width + _padding
                end
            end)
            self.auraPanel:set_height(_y + AConfig.height + AConfig.pbHeight)
        end)
    end

    -- Position
    self.healthBar:set_archor("TOPLEFT")
    self.healthBar:set_archor_target(self.hookbar.layer, "TOPLEFT")

    self.name:set_archor("TOPLEFT")
    self.name:set_archor_target(self.hookbar.layer, "TOPLEFT")

    self.healthMaxValue:set_archor("TOPLEFT")
    self.healthMaxValue:set_archor_target(self.hookbar.layer, "TOPLEFT")

    self.healthPercentage:set_archor("TOPLEFT")
    self.healthPercentage:set_archor_target(self.hookbar.layer, "TOPLEFT")

    -- Unchangable settings
    self.healthBar:set_backgroundColor(PushUIColor.black, 0)
    self.healthBar:set_borderColor(PushUIColor.black, 0)

    self.healthBar.layer:SetFrameLevel(0)

    self.auraPanel:set_archor("TOPLEFT")
    self.auraPanel:set_archor_target(self.hookbar.layer, "BOTTOMLEFT")
    self.auraPanel:set_position(0, -8)
    self.auraPanel:set_backgroundColor(PushUIColor.black, 0)
    self.auraPanel:set_borderColor(PushUIColor.black, 0)

    -- Fake UF
    self._fakeUF:EnableMouse(true)
    self._fakeUF:SetScript("OnMouseDown", function(_, btn)
        if btn == "RightButton" then
            if self._rightClickAction then self._rightClickAction() end
        end
    end)

    -- Timer
    if self._auraTimer then
        self._auraTimer:set_interval(1)
        self._auraTimer:set_target(self)
        self._auraTimer:set_handler(function(target)
            target.buffGroup:for_each(function(_, abtn)
                abtn:refresh_progress()
            end)
            target.debuffGroup:for_each(function(_, abtn)
                abtn:refresh_progress()
            end)
        end)
    end
end

function PushUIFrames.UnitFrame:layout(config)
    config = config or {
        width = 200, 
        height = 40,
        borderColor = PushUIColor.black,
        borderAlpha = 1,
        backgroundColor = PushUIColor.black,
        backgroundAlpha = 0.7,

        healthBarColor = PushUIColor.lifeColorDynamic,
        healthBarHeight = 35,
        healthBarXPosition = 0,
        healthBarYPosition = -5,
        healthBarStyle = "h-l-r",

        nameSize = 24,
        nameXPosition = 0,
        nameYPosition = 10,
        nameFlag = "OUTLINE",
        nameAlign = "LEFT",
        nameColor = function(...) return PushUIColor.white end,
        nameMaxWidth = 120,

        percentageSize = 24,
        percentageXPosition = 0,
        percentageYPosition = 10,
        percentageFlag = "OUTLINE",
        percentageAlign = "RIGHT",
        percentageColor = function(...) return PushUIColor.white end,
        percentageMaxWidth = 80,

        maxHpSize = 12,
        maxHpXPosition = 200,
        maxHpYPosition = -28,
        maxHpMaxWidth = 90,
        maxHpFlag = "OUTLINE",
        maxHpAlign = "LEFT",
        maxHpColor = function(...) return PushUIColor.white end
    }

    -- hookbar
    self.hookbar:set_backgroundColor(config.backgroundColor, config.backgroundAlpha)
    self.hookbar:set_borderColor(config.borderColor, config.borderAlpha)
    self.hookbar:set_size(config.width, config.height)
    self.hookbar:set_position()

    -- Aura size
    self.auraPanel:set_width(config.width)

    -- healthBar
    self.healthBar:set_size(config.width, config.healthBarHeight)
    self.healthBar:set_position(config.healthBarXPosition, config.healthBarYPosition)
    self.healthBar:set_style(config.healthBarStyle)

    -- name
    self.name:set_fontsize(config.nameSize)
    self._nameSize = config.nameSize
    self.name:set_fontflag(config.nameFlag)
    self.name:set_align(config.nameAlign)
    self.name:set_wbounds(config.nameMaxWidth)
    self.name:set_position(config.nameXPosition, config.nameYPosition)

    -- percentage
    self.healthPercentage:set_fontsize(config.percentageSize)
    self.healthPercentage:set_fontflag(config.percentageFlag)
    self.healthPercentage:set_align(config.percentageAlign)
    self.healthPercentage:set_wbounds(config.percentageMaxWidth)
    self.healthPercentage:set_position(config.percentageXPosition, config.percentageYPosition)

    -- MaxHp
    self.healthMaxValue:set_fontsize(config.maxHpSize)
    self.healthMaxValue:set_fontflag(config.maxHpFlag)
    self.healthMaxValue:set_align(config.maxHpAlign)
    self.healthMaxValue:set_wbounds(config.maxHpMaxWidth)
    self.healthMaxValue:set_position(config.maxHpXPosition, config.maxHpYPosition)

    -- FakeUF
    self._fakeUF:SetWidth(config.width)
    self._fakeUF:SetHeight(config.height)
    self._fakeUF:SetPoint("TOPLEFT", self.hookbar.layer, "TOPLEFT", 0, 0)

    self.apiAssets:del_valueChanged("uf_valueChanged")
    self.apiAssets:add_valueChanged("uf_valueChanged", function(_, hpValue)
        self.healthBar:set_barColor(config.healthBarColor(self.objectID, hpValue.hp, hpValue.max_hp))
        self.name:set_fontcolor(config.nameColor(self.objectID, hpValue.hp, hpValue.max_hp))
        self.healthPercentage:set_fontcolor(config.percentageColor(self.objectID, hpValue.hp, hpValue.max_hp))
        self.healthMaxValue:set_fontcolor(config.maxHpColor(self.objectID, hpValue.hp, hpValue.max_hp))
    end)
    if self.apiAssets:can_display() then
        self.hookbar:set_hidden(false)
        self.name:set_text(UnitName(self.objectID))
        self.apiAssets:valueChanged()
        if self._auraTimer then self._auraTimer:start() end
    else
        self.hookbar:set_hidden(true)
    end
end

function PushUIFrames.UnitFrame:set_rightClickAction(func)
    self._rightClickAction = func
end

function PushUIFrames.UnitFrame:set_archor(...)
    self.hookbar:set_archor(...)
end
function PushUIFrames.UnitFrame:set_archor_target(...)
    self.hookbar:set_archor_target(...)
end
function PushUIFrames.UnitFrame:set_position(...)
    self.hookbar:set_position(...)
end

