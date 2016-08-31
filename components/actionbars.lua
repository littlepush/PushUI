local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIFrameActionBarLayout = CreateFrame("Frame", "PushUIFrameActionBarLayout", PushUIFrameActionBarFrame)
PushUIFrames.AllFrames[#PushUIFrames.AllFrames + 1] = PushUIFrameActionBarLayout
--table.insert(PushUIFrames.AllFrames, PushUIFrameActionBarLayout)

PushUIFrameActionBarLayout.HideEverything = function()
    -- Reformat old action bars
    ReputationWatchBar:SetScript("OnShow", ReputationWatchBar.Hide)
    ReputationWatchBar:Hide()

    --MainMenuBarLeftEndCap:SetScript("OnShow", MainMenuBarLeftEndCap.Hide)
    MainMenuBarLeftEndCap:Hide()

    --MainMenuBarRightEndCap:SetScript("OnShow", MainMenuBarRightEndCap.Hide)
    MainMenuBarRightEndCap:Hide()

    MainMenuBarTexture0:SetTexture(nil)
    MainMenuBarTexture1:SetTexture(nil)
    MainMenuBarTexture2:SetTexture(nil)
    MainMenuBarTexture3:SetTexture(nil)
    StanceBarLeft:SetTexture(nil)
    StanceBarMiddle:SetTexture(nil)
    StanceBarRight:SetTexture(nil)
    SlidingActionBarTexture0:SetTexture(nil)
    SlidingActionBarTexture1:SetTexture(nil)
    PossessBackground1:SetTexture(nil)
    PossessBackground2:SetTexture(nil)
    MainMenuBarPageNumber:Hide()
    ActionBarUpButton:Hide()
    ActionBarDownButton:Hide()

    MainMenuExpBar:SetScript("OnShow", MainMenuExpBar.Hide)
    MainMenuExpBar:Hide()

    ArtifactWatchBar:SetScript("OnShow", ArtifactWatchBar.Hide)
    ArtifactWatchBar:Hide()

    -- OverrideActionBar
    local textureList = {
        "_BG","EndCapL","EndCapR",
        "_Border","Divider1","Divider2",
        "Divider3","ExitBG","MicroBGL",
        "MicroBGR","_MicroBGMid",
        "ButtonBGL","ButtonBGR",
        "_ButtonBGMid"
    }
    for _, tex in pairs(textureList) do
        OverrideActionBar[tex]:SetAlpha(0)
    end

    -- Hide Bags
    for i=0,3 do
        _G["CharacterBag"..i.."Slot"]:Hide()
    end
    MainMenuBarBackpackButton:Hide()

    -- Hide MainMenu Bar
    local _main_menus = {
        "Character",
        "Spellbook",
        "Talent",
        "Achievement",
        "QuestLog",
        "Guild",
        "LFD",
        "Collections",
        "EJ",
        "Store",
        "MainMenu"
    }
    for idx,title in pairs(_main_menus) do
        local _b = _G[title.."MicroButton"]
        _b:SetScript("OnShow", _b.Hide)
        _b:Hide()
    end
    -- Fix Achievement Error
    if not AchievementMicroButton_Update then
        AchievementMicroButton_Update = function() end
    end

    for i=0, 3 do
        _G["MainMenuMaxLevelBar"..i]:Hide()
    end

    TalentMicroButtonAlert:SetScript("OnShow", TalentMicroButtonAlert.Hide)
    TalentMicroButtonAlert:Hide()
end

PushUIFrameActionBarLayout.DefaultButtonPlace = function(btn, row, col)
    btn:ClearAllPoints()
    --btn:SetParent(PushUI.Frames.ActionBarBackground)
    btn:SetWidth(PushUISize.actionButtonSize * PushUISize.Resolution.scale)
    btn:SetHeight(PushUISize.actionButtonSize * PushUISize.Resolution.scale)
    local x = 
        ((col - 1) * (PushUISize.actionButtonSize + PushUISize.actionButtonPadding)
                + 
        PushUISize.actionButtonPadding)
    local y = 
        ((row - 1) * (PushUISize.actionButtonSize + PushUISize.actionButtonPadding) 
                + 
        PushUISize.actionButtonPadding)

    btn:SetPoint("BOTTOMLEFT", PushUIFrameActionBarFrame, "BOTTOMLEFT", 
        x * PushUISize.Resolution.scale, 
        y * PushUISize.Resolution.scale
        )
end

PushUIFrameActionBarLayout.ReSizeVehicleButton = function()
    local _barWidth = PushUIFrameActionBarFrame:GetWidth()
    -- PushUISize.actionButtonPadding
    -- PushUIConfig.ActionBarGridScale
    -- PushUISize.Resolution.scale
    local _padding = (
        PushUISize.actionButtonPadding * 
        PushUIConfig.ActionBarGridScale * 
        PushUISize.Resolution.scale)
    local _btnW = ((_barWidth - _padding) / (NUM_PET_ACTION_SLOTS + 2)) - _padding

        
end

PushUIFrameActionBarLayout.ReSizePetButtons = function()
    local _barWidth = PushUIFrameActionBarFrame:GetWidth()
    -- PushUISize.actionButtonPadding
    -- PushUIConfig.ActionBarGridScale
    -- PushUISize.Resolution.scale
    local _padding = (
        PushUISize.actionButtonPadding * 
        PushUIConfig.ActionBarGridScale * 
        PushUISize.Resolution.scale)
    local _btnW = ((_barWidth - _padding) / (NUM_PET_ACTION_SLOTS + 2)) - _padding

    for i = 1, NUM_PET_ACTION_SLOTS do
        local btn = _G["PetActionButton"..i]
        btn:SetWidth(_btnW)
        btn:SetHeight(_btnW)
        btn:ClearAllPoints()
        btn:SetPoint("BOTTOMLEFT", PushUIFrameActionBarFrame, "TOPLEFT", 
            (_btnW + _padding) * i + _padding, _padding
            )
    end
end

PushUIFrameActionBarLayout.RestoreToDefault = function() 
    for i=1, PushUISize.actionButtonPerLine do
        local _abtn = _G["ActionButton"..i]
        local _mblbtn = _G["MultiBarBottomLeftButton"..i]
        local _mbrbtn = _G["MultiBarBottomRightButton"..i]

        PushUIFrameActionBarLayout.DefaultButtonPlace(_abtn, 1, i)
        PushUIFrameActionBarLayout.DefaultButtonPlace(_mblbtn, 2, i)
        PushUIFrameActionBarLayout.DefaultButtonPlace(_mbrbtn, 3, i)
    end
    PushUIFrameActionBarLayout.ReSizePetButtons()
end

PushUIFrameActionBarLayout.ApplyFormat = function(btn)
    if not btn or (btn and btn.styled) then return end

    local _name = btn:GetName()
    local _action = btn.action

    -- Floating Background
    local _floatingBG = _G[_name.."FloatingBG"]
    if _floatingBG then _floatingBG:Hide() end

    -- Flyout Border
    local _flyoutBorder = _G[_name.."FlyoutBorder"]
    if _flyoutBorder then _flyoutBorder:SetTexture(nil) end

    -- Flyout Border Shadow
    local _flyoutBorderShadow = _G[_name.."FlyoutBorderShadow"]
    if _flyoutBorderShadow then _flyoutBorderShadow:SetTexture(nil) end

    -- Hide Border
    _G[_name.."Border"]:SetTexture(nil)

    -- cut the default border of the icons and make them shiny
    local _icon = _G[_name.."Icon"]
    _icon:SetTexCoord(0.1,0.9,0.1,0.9)
    _icon:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
    _icon:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
    -- adjust the cooldown frame
    local _cooldown = _G[_name.."Cooldown"]
    _cooldown:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
    _cooldown:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)

    -- Hotkey
    local _hotkey = _G[_name.."HotKey"]
    PushUIStyle.SetFontSize(_hotkey, PushUIConfig.ActionBarFontSize)

    -- Macro Name
    local _macroname = _G[_name.."Name"]
    PushUIStyle.SetFontSize(_macroname, PushUIConfig.ActionBarFontSize)

    -- Item Stack Count
    local _stackcount = _G[_name.."Count"]
    PushUIStyle.SetFontSize(_stackcount, PushUIConfig.ActionBarFontSize)    

    -- Set Texture Points
    btn.NewActionTexture:SetTexture("")
    btn:SetNormalTexture("")
    btn:SetPushedTexture("")
    btn:SetHighlightTexture("")
    -- btn:SetCheckedTexture(PushUIStyle.TextureClean)

    -- local ch = btn:GetCheckedTexture()
    -- ch:SetVertexColor(unpack(PushUIColor.red))
    -- ch:SetDrawLayer("ARTWORK")
    -- ch:SetAllPoints(btn)

    -- Set Backgound
    local r,g,b = unpack(PushUIConfig.actionButtonBorderColor)
    PushUIStyle.BackgroundSolidFormat(
        btn, 
        0, 0, 0, 0,
        r, g, b, 1)

    btn.styled = true
end

PushUIFrameActionBarLayout.ApplyPetFormat = function(btn)
    if not btn or (btn and btn.styled) then return end

    local name = btn:GetName()
    local icon  = _G[name.."Icon"]

    _G[name.."NormalTexture2"]:SetAllPoints(btn)
    _G[name.."AutoCastable"]:SetAlpha(0)

    btn:SetNormalTexture("")
    btn:SetPushedTexture("")

    hooksecurefunc(btn, "SetNormalTexture", function(self, texture)
        if texture and texture ~= "" then
            self:SetNormalTexture("")
        end
    end)

    icon:SetTexCoord(.08, .92, .08, .92)
    icon:SetPoint("TOPLEFT", btn, "TOPLEFT", 1, -1)
    icon:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -1, 1)
    icon:SetDrawLayer("OVERLAY")

    local r,g,b = unpack(PushUIConfig.actionButtonBorderColor)
    PushUIStyle.BackgroundSolidFormat(
        btn, 
        0, 0, 0, 0,
        r, g, b, 1)

    btn.styled = true
end

PushUIFrameActionBarLayout.FormatButtonWithGridInfo = function(btn, fid)
    if not PushUIConfig.ActionBarGridPlacedCood[fid] then
        -- The button will not display if not specified in the config
        PushUIStyle.HideFrame(btn)
        return
    end

    local x, y, w, h = unpack(PushUIConfig.ActionBarGridPlacedCood[fid])

    x = x * PushUIConfig.ActionBarGridScale * PushUISize.Resolution.scale
    y = y * PushUIConfig.ActionBarGridScale * PushUISize.Resolution.scale
    w = w * PushUIConfig.ActionBarGridScale * PushUISize.Resolution.scale
    h = h * PushUIConfig.ActionBarGridScale * PushUISize.Resolution.scale

    btn:ClearAllPoints()
    btn:SetWidth(w)
    btn:SetHeight(h)
    btn:SetPoint("TOPLEFT", PushUIFrameActionBarFrame, "TOPLEFT", x, -y)
end

PushUIFrameActionBarLayout.ReSize = function()
    local f = PushUIFrameActionBarLayout

    if PushUIConfig.ActionBarGridValidate == false then
        PushUIFrameActionBarLayout.RestoreToDefault()
        return
    end

    --Check the data in ActionBarGridPlacedCood
    for i=1, PushUISize.actionButtonPerLine do
        local _abtn = _G["ActionButton"..i]
        PushUIFrameActionBarLayout.FormatButtonWithGridInfo(_abtn, "A"..i)

        -- VehicleMenuBarActionButton
        -- BonusActionButton

        local _mbblbtn = _G["MultiBarBottomLeftButton"..i]
        PushUIFrameActionBarLayout.FormatButtonWithGridInfo(_mbblbtn, "MBL"..i)

        local _mbbrbtn = _G["MultiBarBottomRightButton"..i]
        PushUIFrameActionBarLayout.FormatButtonWithGridInfo(_mbbrbtn, "MBR"..i)

        local _mblbtn = _G["MultiBarLeftButton"..i]
        PushUIFrameActionBarLayout.FormatButtonWithGridInfo(_mblbtn, "ML"..i)

        local _mbrbtn = _G["MultiBarRightButton"..i]
        PushUIFrameActionBarLayout.FormatButtonWithGridInfo(_mbrbtn, "MR"..i)
    end

    PushUIFrameActionBarLayout.ReSizePetButtons()
end

PushUIFrameActionBarLayout.Init = function(...)
    PushUIFrameActionBarLayout.HideEverything()

    for i=1, PushUISize.actionButtonPerLine do
        local _abtn = _G["ActionButton"..i]
        PushUIFrameActionBarLayout.ApplyFormat(_abtn)
        local _mbblbtn = _G["MultiBarBottomLeftButton"..i]
        PushUIFrameActionBarLayout.ApplyFormat(_mbblbtn)
        local _mbbrbtn = _G["MultiBarBottomRightButton"..i]
        PushUIFrameActionBarLayout.ApplyFormat(_mbbrbtn)
        local _mblbtn = _G["MultiBarLeftButton"..i]
        PushUIFrameActionBarLayout.ApplyFormat(_mblbtn)
        local _mbrbtn = _G["MultiBarRightButton"..i]
        PushUIFrameActionBarLayout.ApplyFormat(_mbrbtn)
    end
    for i = 1, NUM_PET_ACTION_SLOTS do
        PushUIFrameActionBarLayout.ApplyPetFormat(_G["PetActionButton"..i])
    end

    PushUIFrameActionBarLayout.ReSize()

    PushUIConfig.skinType(ItemRefTooltip)
end

PushUIFrameActionBarLayout.Init()
