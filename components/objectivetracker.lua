local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local PushUIFrameObjectiveTrackerHook = PushUIFrames.Frame.Create("PushUIFrameObjectiveTrackerHook", PushUIConfig.ObjectiveTrackerFrameHook)
PushUIFrameObjectiveTrackerHook.HookParent = PushUIConfig.ObjectiveTrackerFrameHook.parent.HookFrame

local fOTHook = PushUIFrameObjectiveTrackerHook

-- Create Scrll Quest Frame
fOTHook.OTContainer = CreateFrame("Frame", "PushUIOTContainer", fOTHook)
fOTHook.OTScrollView = CreateFrame("ScrollFrame", nil, fOTHook.OTContainer)
fOTHook.OTScrollContent = CreateFrame("Frame", nil, fOTHook.OTScrollView)

fOTHook.OTContainer.scrollframe = fOTHook.OTScrollView
fOTHook.OTScrollView.content = fOTHook.OTScrollContent
fOTHook.OTScrollView:SetScrollChild(fOTHook.OTScrollContent)
fOTHook.OTScrollView:EnableMouseWheel(true)
fOTHook.OTScrollView:SetScript("OnMouseWheel", function(_, delta)
    local _step = PushUIConfig.ObjectiveTrackerFrameHook.wheelStep or 10
    local _side = PushUIConfig.ObjectiveTrackerFrameHook.scrollside or 1
    if _side > 0 then _side = 1
    else _side = -1 end

    local _pos = _:GetVerticalScroll()
    local _newpos = _pos + delta * _step * _side
    if _newpos < 0 then _newpos = 0 end
    _:SetVerticalScroll(_newpos)
end)

PushUIFrameObjectiveTrackerHook.ToggleCanShow = true
PushUIFrameObjectiveTrackerHook.Toggle = function(status)
    PushUIFrameObjectiveTrackerHook.ToggleCanShow = status
    if status then
        fOTHook.OTContainer:Show()
    else
        fOTHook.OTContainer:Hide()
    end
end

PushUIFrameObjectiveTrackerHook.ReSize = function(...)
    -- ObjectiveTrackerFrame:SetWidth(160)

    local _w, _h, _x, _y = fOTHook.HookParent.GetBlockRect(1, 2)
    local _p = PushUISize.padding

    _x = _x * PushUISize.Resolution.scale
    _y = _y * PushUISize.Resolution.scale
    _w = _w * PushUISize.Resolution.scale
    _h = _h * PushUISize.Resolution.scale
    _p = _p * PushUISize.Resolution.scale

    _w = _w + (_w - _h)

    fOTHook.OTContainer:SetWidth(_w)
    fOTHook.OTContainer:SetHeight(_h)
    fOTHook.OTContainer:SetPoint("TOPLEFT", fOTHook.HookParent, "TOPLEFT", _x, _y)

    -- Resize the inner scroll view
    fOTHook.OTScrollView:SetAllPoints(fOTHook.OTContainer)

    -- Resize the inner content view
    local otbf = ObjectiveTrackerBlocksFrame
    local _oth = otbf:GetHeight()

    fOTHook.OTScrollContent:SetWidth(_w)
    fOTHook.OTScrollContent:SetHeight(_oth)

    otbf:SetWidth(_w - 2 * _p)
    otbf:SetAllPoints(fOTHook.OTScrollContent)
    otbf:SetPoint("TOPLEFT", 30, 0)
end

PushUIFrameObjectiveTrackerHook.SetHeaderText = function(text)
    PushUIStyle.SetFontSize(text, 13)
    PushUIStyle.SetFontOutline(text)
    PushUIStyle.SetFontColor(text, unpack(PushUIColor.white))
end
PushUIFrameObjectiveTrackerHook.SetContentText = function(text)
    PushUIStyle.SetFontSize(text, 12)
    -- PushUIStyle.SetFontOutline(text)
    PushUIStyle.SetFontColor(text, unpack(PushUIColor.white))
end

local function fixBlockHeight(block)
    if block.shouldFix then
        local height = block:GetHeight()

        if block.lines then
            for _, line in pairs(block.lines) do
                if line:IsShown() then
                    height = height + 4
                end
            end
        end

        block.shouldFix = false
        block:SetHeight(height + 5)
        block.shouldFix = true
    end
end

PushUIFrameObjectiveTrackerHook.Init = function(...)
    local hm = ObjectiveTrackerFrame.HeaderMenu
    hm:SetScript("OnShow", hm.Hide)
    hm:Hide()

    local otbf = ObjectiveTrackerBlocksFrame
    otbf:SetParent(fOTHook.OTScrollContent)
    fOTHook.OTScrollView:SetVerticalScroll(0)

    local ot = ObjectiveTrackerFrame
    local BlocksFrame = ot.BlocksFrame

    for _, headerName in pairs({"QuestHeader", "AchievementHeader", "ScenarioHeader"}) do
        local header = BlocksFrame[headerName]
        header.Background:Hide()
        PushUIFrameObjectiveTrackerHook.SetHeaderText(header.Text)
    end

    do
        local header = BONUS_OBJECTIVE_TRACKER_MODULE.Header

        header.Background:Hide()
        PushUIFrameObjectiveTrackerHook.SetHeaderText(header.Text)
    end

    hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "SetBlockHeader", function(_, block)
        if not block.headerStyled then
            PushUIFrameObjectiveTrackerHook.SetHeaderText(block.HeaderText)
            block.headerStyled = true
        end
    end)

    hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader", function(_, block)
        if not block.headerStyled then
            PushUIFrameObjectiveTrackerHook.SetHeaderText(block.HeaderText)
            block.headerStyled = true
        end

        local itemButton = block.itemButton

        if itemButton and not itemButton.styled then
            itemButton:SetNormalTexture("")
            itemButton:SetPushedTexture("")

            itemButton.HotKey:ClearAllPoints()
            itemButton.HotKey:SetPoint("CENTER", itemButton, 1, 0)
            itemButton.HotKey:SetJustifyH("CENTER")
            PushUIFrameObjectiveTrackerHook.SetContentText(itemButton.HotKey)

            itemButton.Count:ClearAllPoints()
            itemButton.Count:SetPoint("TOP", itemButton, 2, -1)
            itemButton.Count:SetJustifyH("CENTER")
            PushUIFrameObjectiveTrackerHook.SetContentText (itemButton.Count)

            itemButton.icon:SetTexCoord(.08, .92, .08, .92)
            PushUIConfig.skinType(itemButton)

            itemButton.styled = true
        end
    end)

    hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "AddObjective", function(self, block)
        if block.module == QUEST_TRACKER_MODULE or block.module == ACHIEVEMENT_TRACKER_MODULE then
            local line = block.currentLine

            local p1, a, p2, x, y = line:GetPoint()
            line:SetPoint(p1, a, p2, x, y - 4)
        end
    end)

    hooksecurefunc("ObjectiveTracker_AddBlock", function(block)
        if block.lines then
            for _, line in pairs(block.lines) do
                if not line.styled then
                    PushUIFrameObjectiveTrackerHook.SetContentText(line.Text)
                    line.Text:SetSpacing(2)

                    if line.Dash then
                        PushUIFrameObjectiveTrackerHook.SetContentText(line.Dash)
                    end

                    line:SetHeight(line.Text:GetHeight())

                    line.styled = true
                end
            end
        end

        if not block.styled then
            block.shouldFix = true
            hooksecurefunc(block, "SetHeight", fixBlockHeight)
            block.styled = true
        end
    end)

    -- [[ Bonus objective progress bar ]]

    hooksecurefunc(BONUS_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", function(self, block, line)
        local progressBar = line.ProgressBar
        local bar = progressBar.Bar
        local icon = bar.Icon

        if not progressBar.styled then
            local label = bar.Label

            bar.BarBG:Hide()

            icon:SetMask(nil)
            icon:SetDrawLayer("BACKGROUND", 1)
            icon:ClearAllPoints()
            icon:SetPoint("RIGHT", 35, 2)
            --bar.newIconBg = F.ReskinIcon(icon)

            bar.BarFrame:Hide()

            --bar:SetStatusBarTexture(C.media.backdrop)

            label:ClearAllPoints()
            label:SetPoint("CENTER")
            PushUIFrameObjectiveTrackerHook.SetContentText(label)

            --local bg = F.CreateBDFrame(bar)
            --bg:SetPoint("TOPLEFT", -1, 1)
            --bg:SetPoint("BOTTOMRIGHT", 0, -2)

            progressBar.styled = true
        end

        --bar.IconBG:Hide()
        --bar.newIconBg:SetShown(icon:IsShown())
    end)

    -- ScenarioStageBlock:SetHeight(0)
    -- -- ScenarioStageBlock:SetScript("OnShow", ScenarioStageBlock.Hide)
    -- ScenarioStageBlock:Hide()


    ObjectiveTrackerFrame:Hide()
    PushUIConfig.skinType(fOTHook.OTContainer)
    fOTHook.ReSize()
end

PushUIAPI.RegisterEvent(
    "PLAYER_ENTERING_WORLD", 
    PushUIFrameObjectiveTrackerHook,
    PushUIFrameObjectiveTrackerHook.Init
)
