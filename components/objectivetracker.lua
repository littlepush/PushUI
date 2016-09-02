local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local PushUIFramesObjectiveTrackerHook = {}
local OTH = PushUIFramesObjectiveTrackerHook
OTH.name = "PushUIFramesObjectiveTrackerHook"
local _quests = {}
local _bonus = {}
local _scenario = {}
OTH.quests = _quests
OTH.bonus = _bonus
OTH.scenario = _scenario

OTH._gainQuest = function()
    local _oqc = #_quests
    for i = 1, _oqc do _quests[i] = nil end
    -- 1: questID, 2: title, 3: questLogIndex, 4: numObjectives, 
    -- 5: requiredMoney, 6: isComplete, 7: startEvent, 8: isAutoComplete, 
    -- 9: failureTime, 10: timeElapsed, 11: questType, 12: isTask, 
    -- 13: isBounty, 14: isStory, 15: isOnMap, 16: hasLocalPOI
    local _qc = GetNumQuestWatches()
    for i = 1, _qc do
        local _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16 = GetQuestWatchInfo(i)
        _quests[i] = {
            questID = _1,
            title = _2,
            questLogIndex = _3,
            numObjectives = _4,
            requiredMoney = _5,
            isComplete = _6,
            startEvent = _7,
            isAutoComplete = _8,
            failureTime = _9,
            timeElapsed = _10,
            questType = _11,
            isTask = _12,
            isBounty = _13,
            isStory = _14,
            isOnMap = _15,
            hasLocalPOI = _16
        }
    end
end

OTH._openQuestOnMap = function(block)
    QuestMapFrame_OpenToQuestDetails(block.quest.questID)
end

OTH._initBlock = function(block)
    block:SetWidth(200)
    block:SetHeight(24)
    PushUIConfig.skinType(block)

    local _fs = block:CreateFontString()

    local _fn = "Fonts\\ARIALN.TTF"
    local _fsize = 14
    local _foutline = "OUTLINE"

    _fs:SetFont(_fn, _fsize, _foutline)

    -- align
    local _align = "LEFT"
    _fs:SetJustifyH(_align)

    local _w = 180
    local _h = _fsize
    _fs:SetWidth(180)
    _fs:SetHeight(_fsize)
    _fs:ClearAllPoints()
    _fs:SetPoint("TOPLEFT", block, "TOPLEFT", 10, -5)

    block.text = _fs

    local _detailBlcok = CreateFrame("Frame", block:GetName().."Detail", block)
    PushUIConfig.skinType(_detailBlcok)
    _detailBlcok:SetWidth(200)
    _detailBlcok:SetPoint("TOPRIGHT", block, "TOPLEFT", -10, 0)
    local _detailfs = _detailBlcok:CreateFontString()
    _detailfs:SetWidth(180)
    _detailfs:SetMaxLines(10)
    _detailfs:SetFont(_fn, _fsize - 2, _foutline)
    _detailfs:SetJustifyH("LEFT")
    _detailfs:SetPoint("TOPLEFT", _detailBlcok, "TOPLEFT", 10, -10)
    _detailBlcok.detailFont = _detailfs
    block.detailPanel = _detailBlcok
    _detailBlcok:Hide()

    block:SetScript("OnEnter", function(self, ...)
        self.detailPanel:Show()
        PushUIConfig.skinHighlightType(self)
    end)
    block:SetScript("OnLeave", function(self, ...)
        self.detailPanel:Hide()
        PushUIConfig.skinType(self)
    end)
    block:EnableMouse(true)
    block:SetScript("OnMouseDown", function(self, ...)
        OTH._openQuestOnMap(self)
    end)
end

OTH._formatBlock = function(block)
    local _quest = block.quest
    local _finishCount = 0
    local _detail = block.detailPanel
    local _detailfs = _detail.detailFont
    local _detailText = ""
    if _quest.numObjectives ~= nil then
        for i = 1, _quest.numObjectives do
            local text, _, finished = GetQuestLogLeaderBoard(i, _quest.questLogIndex);
            if finished then
                _finishCount = _finishCount + 1
            end
            if _detailText ~= "" then
                _detailText = _detailText.."\n\n"..text
            else
                _detailText = text
            end
        end
        block.text:SetText(_quest.title.."  (".._finishCount.."/".._quest.numObjectives..")")
    else
        block.text:SetText(_quest.title)
    end
    if _quest.isComplete then
        block.text:SetTextColor(unpack(PushUIColor.green))
    elseif _quest.isOnMap then
        block.text:SetTextColor(unpack(PushUIColor.orange))
    else
        block.text:SetTextColor(unpack(PushUIColor.white))
    end

    if _detailText == "" then
        _detailText = _quest.title
    end
    _detailfs:SetText(_detailText)
    local _th = _detailfs:GetStringHeight()
    _detailfs:SetHeight(_th)
    _detail:SetHeight(_th + 20)
end

OTH._blocks = {}
OTH._showQuest = function(event, ...)
    local _qc = #_quests
    local _bc = #OTH._blocks

    for i = 1, _qc do
        local _blockFrame = nil
        if i <= _bc then
            _blockFrame = OTH._blocks[i]
        else
            _blockFrame = CreateFrame("Frame", OTH.name.."Block"..i, UIParent)
            OTH._blocks[i] = _blockFrame
            _bc = _bc + 1
            OTH._initBlock(_blockFrame)
        end
        _blockFrame.quest = _quests[i]
        _blockFrame:ClearAllPoints()
        OTH._formatBlock(_blockFrame)
        _blockFrame:Show()
        _blockFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -30, -(i - 1) * 28 - 30)
    end

    if _qc < _bc then
        for i = _qc + 1, _bc do
            OTH._blocks[i]:Hide()
        end
    end
end
OTH._bonusBlock = nil

OTH._scenarioBlock = nil

OTH._formatScenarioBlock = function()
    local _b = OTH._scenarioBlock
    local _s = _b.scenario
    local _pb = _b.progressBar

    _b:SetWidth(200)
    _pb:SetWidth(180)
    _pb:SetHeight(15)

    _b.titleFont:SetText(_s.scenarioName.." (".._s.currentStage.."/".._s.numStages..")")
    local _name, _description, _numCriteria, _, _, _, _numSpells, _spellInfo, weightedProgress = C_Scenario.GetStepInfo()
    _b.stageFont:SetText(_name)
    _b.descriptionFont:SetText(_description)

    local _allHeight = (
        _b.titleFont:GetStringHeight() + 
        _b.stageFont:GetStringHeight() + 
        _b.descriptionFont:GetStringHeight())

    _b.descriptionFont:SetHeight(_b.descriptionFont:GetStringHeight())
    _b:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 30, -30)
    _allHeight = _allHeight + 40

    local _displayPB = false
    if _numCriteria ~= nil and _numCriteria > 0 then
        local _, _, _, _value, _max = C_Scenario.GetCriteriaInfo(1)
        _displayPB = true
        _pb:SetMinMaxValues(0, _max)
        _pb:SetValue(_value)
        _pb.percentageFont:SetText(_value.."/".._max)
    else
        if _s.showCriteria and nil ~= weightedProgress then
            _displayPB = true
            _pb:SetMinMaxValues(0, 100)
            _pb:SetValue(weightedProgress)
            _pb.percentageFont:SetText(weightedProgress.."%%")
        end
    end
    if _displayPB then
        _pb:SetPoint("TOPLEFT", _b, "TOPLEFT", 10, -_allHeight)
        _pb:Show()
        _allHeight = _allHeight + 15 + 10
    else
        _pb:Hide()
    end
    _b:SetHeight(_allHeight)
end
OTH._gainScenario = function()
    _scenario = nil
    local _1, _2, _3, _4, _5, _6, _7, _8, _9, _10 = C_Scenario.GetInfo()
    if not _1 then return end
    if 0 == _2 and 0 == _3 then return end
    _scenario = {
        scenarioName = _1,
        currentStage = _2,
        numStages = _3,
        flags = _4,
        unknow1 = _5,
        unknow2 = _6,
        unknow3 = _7,
        xp = _8, 
        money = _9,
        scenarioType = _10,
        showCriteria = C_Scenario.ShouldShowCriteria()
    }
end 
OTH._showScenario = function(event, ...)
    OTH._gainScenario()
    if not _scenario then 
        if OTH._scenarioBlock then
            OTH._scenarioBlock:Hide()
        end
        return
    end

    if not OTH._scenarioBlock then
        local _b = CreateFrame("Frame", OTH.name.."ScenarioBlock", UIParent)
        local _pb = PushUIFrames.ProgressBar.Create(_b:GetName().."Progress", _b, nil, "HORIZONTAL")
        PushUIConfig.skinType(_b)
        _pb:SetStatusBarColor(unpack(PushUIColor.green))
        _pb:SetMinMaxValues(0, 100)
        _b.progressBar = _pb
        OTH._scenarioBlock = _b

        local _fn = "Fonts\\ARIALN.TTF"
        local _fsize = 14
        local _foutline = "OUTLINE"

        local _tiltefs = _b:CreateFontString()
        _tiltefs:SetWidth(180)
        _tiltefs:SetHeight(_fsize)
        _tiltefs:SetFont(_fn, _fsize, _foutline)
        _tiltefs:SetJustifyH("LEFT")
        _tiltefs:SetPoint("TOPLEFT", _b, "TOPLEFT", 10, -10)
        _tiltefs:SetTextColor(unpack(PushUIColor.orange))
        _b.titleFont = _tiltefs

        local _stagefs = _b:CreateFontString()
        _stagefs:SetWidth(180)
        _stagefs:SetHeight(_fsize - 1)
        _stagefs:SetFont(_fn, _fsize - 1, _foutline)
        _stagefs:SetJustifyH("LEFT")
        _stagefs:SetPoint("TOPLEFT", _tiltefs, "BOTTOMLEFT", 0, -10)
        _b.stageFont = _stagefs

        local _descriptionfs = _b:CreateFontString()
        _descriptionfs:SetWidth(180)
        _descriptionfs:SetHeight(_fsize - 1)
        _descriptionfs:SetFont(_fn, _fsize - 1, _foutline)
        _descriptionfs:SetJustifyH("LEFT")
        _descriptionfs:SetPoint("TOPLEFT", _stagefs, "BOTTOMLEFT", 0, -10)
        _descriptionfs:SetTextColor(unpack(PushUIColor.yellow))
        _descriptionfs:SetMaxLines(3)
        _b.descriptionFont = _descriptionfs

        local _percentagefs = _pb:CreateFontString()
        _percentagefs:SetWidth(180)
        _percentagefs:SetHeight(15)
        _percentagefs:SetFont(_fn, _fsize - 1, _foutline)
        _percentagefs:SetJustifyH("CENTER")
        _percentagefs:SetPoint("CENTER", _pb, "CENTER", 0, 0)
        _pb.percentageFont = _percentagefs
    end

    OTH._scenarioBlock.scenario = _scenario
    OTH._formatScenarioBlock()
    OTH._scenarioBlock:Show()
end

-- Hide objective tracker
ObjectiveTrackerFrame:SetScript("OnShow", ObjectiveTrackerFrame.Hide)
ObjectiveTrackerFrame:Hide()

OTH._onUpdate = function()
    OTH._gainQuest()
    OTH._showQuest()
end

OTH._onScenarioUpdate = function()
    OTH._showScenario()
end

OTH._onUpdate()
OTH._onScenarioUpdate()

PushUIAPI.RegisterEvent("QUEST_LOG_UPDATE", OTH, OTH._onUpdate)
PushUIAPI.RegisterEvent("QUEST_WATCH_LIST_CHANGED", OTH, OTH._onUpdate)
PushUIAPI.RegisterEvent("QUEST_ACCEPTED", OTH, OTH._onUpdate)
PushUIAPI.RegisterEvent("QUEST_AUTOCOMPLETE", OTH, OTH._onUpdate)
--PushUIAPI.RegisterEvent("QUEST_POI_UPDATE", OTH, OTH._onUpdate)
--PushUIAPI.RegisterEvent("QUEST_TURNED_IN", OTH, OTH._onUpdate)
PushUIAPI.RegisterEvent("ZONE_CHANGED_NEW_AREA", OTH, OTH._onUpdate)
--PushUIAPI.RegisterEvent("ZONE_CHANGED", OTH, OTH._onUpdate)

PushUIAPI.RegisterEvent("SCENARIO_UPDATE", OTH, OTH._onScenarioUpdate)
PushUIAPI.RegisterEvent("SCENARIO_CRITERIA_UPDATE", OTH, OTH._onScenarioUpdate)
PushUIAPI.RegisterEvent("SCENARIO_COMPLETED", OTH, OTH._onScenarioUpdate)


