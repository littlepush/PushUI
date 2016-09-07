local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

-- The quest system has 6 different module:
-- Normal, Achievement, Auto Accept/Complete, Scenario, Bonus, World
-- This module will not support Achievement right now.

local _config = PushUIConfig.ObjectiveTrackerHook
if not _config then
    _config = {
        width = 200,
        height = 34,
        titleLineCount = 3,
        padding = 8,
        hideInCombat = true,
        titleFontSize = 14,
        objectiveFontSize = 13,
        outline = "OUTLINE",
        fontName = "Fonts\\ARIALN.TTF",
        autoResize = true
    }
end

local PushUIFramesObjectiveTrackerHook = {}
local _othook = PushUIFramesObjectiveTrackerHook    -- alias
_othook.name = "PushUIFramesObjectiveTrackerHook"
local _normalQuestContainer = CreateFrame("Frame", _othook.name.."Container", UIParent)
local _nqcontainer = _normalQuestContainer  --alias
_othook.normalQuestContainer = _nqcontainer
_nqcontainer:SetWidth(_config.width)
_nqcontainer:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -30, -30)

-- Cause auto accept/complete quest is also a normal quest, we don't need to 
-- cache this quest in our code.
_othook.normalQuests = PushUIAPI.Vector.New()
_othook.scenarioQuest = nil
_othook.bonusQuest = nil
_othook.worldQuest = nil

-- Freed Block Stack
_othook._normalQuestBlockStack = PushUIAPI.Stack.New()

_othook._normalQuestReleaseFreeBlock = function(block)
    block.questID = nil
    block:Hide()
    _othook._normalQuestBlockStack.Push(block)
end
_othook._normalQuestGetFreeBlock = function(block)
    if _othook._normalQuestBlockStack.Size() > 0 then
        local _b = _othook._normalQuestBlockStack.Top()
        _othook._normalQuestBlockStack.Pop()
        _b:Show()
        return _b
    end
    return nil
end

_othook._openNormalQuestOnMap = function(questBlock, ...)
    QuestMapFrame_OpenToQuestDetails(questBlock.questID)
end

_othook._createNormalQuestBlock = function()
    local _block = CreateFrame("Frame", nil, _nqcontainer)
    _block:SetWidth(_config.width)
    _block:SetHeight(_config.height)
    PushUIConfig.skinType(_block)

    local _titleLabel = PushUIFrames.Label.Create(nil, _block, _config.autoResize)
    _titleLabel.SetFont(_config.fontName, _config.titleFontSize, _config.outline)
    _titleLabel.SetMaxLines(_config.titleLineCount)
    _titleLabel.SetJustifyH("LEFT")
    _titleLabel.SetPadding(_config.padding)
    _titleLabel:SetPoint("TOPLEFT", _block, "TOPLEFT", 0, 0)
    _block.titleLabel = _titleLabel

    local _detailBlcok = CreateFrame("Frame", nil, _block)
    _detailBlcok:SetFrameLevel(_block:GetFrameLevel() - 1)
    _detailBlcok:SetWidth(_config.width)
    _detailBlcok:SetPoint("TOPRIGHT", _block, "TOPLEFT", -_config.padding, 0)
    _block.detailPanel = _detailBlcok
    PushUIConfig.skinType(_detailBlcok)
    _detailBlcok:SetAlpha(0)

    local _detailLabel = PushUIFrames.Label.Create(nil, _detailBlcok, true)
    _detailLabel.SetFont(_config.fontName, _config.objectiveFontSize, _config.outline)
    _detailLabel:SetPoint("TOPRIGHT", _detailBlcok, "TOPRIGHT", 0, 0)
    _detailLabel.SetJustifyH("LEFT")
    _detailLabel.SetMaxLines(20)
    _detailLabel.SetPadding(_config.padding)
    _detailBlcok.objectiveLabel = _detailLabel

    _block:EnableMouse(true)
    _block:SetScript("OnMouseDown", _othook._openNormalQuestOnMap)

    PushUIFrames.Animations.EnableAnimationForFrame(_detailBlcok)
    PushUIFrames.Animations.AddStage(_detailBlcok, "OnMouseIn")
    _detailBlcok.AnimationStage("OnMouseIn").EnableFade(0.3, 1)
    _detailBlcok.AnimationStage("OnMouseIn").EnableTranslation(0.3, -_config.padding, 0)
    --_detailBlcok.AnimationStage("OnMouseIn").EnableScale(0.3, 1, "TOPLEFT")

    PushUIFrames.Animations.AddStage(_detailBlcok, "OnMouseOut")
    --_detailBlcok.AnimationStage("OnMouseOut").EnableScale(0.3, 0.01, "TOPLEFT")
    _detailBlcok.AnimationStage("OnMouseOut").EnableTranslation(0.3, _config.width, 0)
    _detailBlcok.AnimationStage("OnMouseOut").EnableFade(0.3, 0)

    _block:SetScript("OnEnter", function(self, ...)
        PushUIConfig.skinHighlightType(self)
        if _block.hasDetailInfo then
            self.detailPanel.CancelAnimationStage("OnMouseOut")
            self.detailPanel.PlayAnimationStage("OnMouseIn")
        end
    end)
    _block:SetScript("OnLeave", function(self, ...)
        PushUIConfig.skinType(self)
        if _block.hasDetailInfo then
            self.detailPanel.CancelAnimationStage("OnMouseIn")
            self.detailPanel.PlayAnimationStage("OnMouseOut")
        end
    end)

    return _block
end

_othook._getNormalQuestBlock = function()
    local _newBlock = _othook._normalQuestGetFreeBlock()
    if _newBlock == nil then
        _newBlock = _othook._createNormalQuestBlock()
    end
    return _newBlock
end

_othook._formatNormalQuestBlock = function(block, quest)
    local _finishCount = 0
    local _titleLb = block.titleLabel
    local _detail = block.detailPanel
    local _detailLb = _detail.objectiveLabel
    local _detailText = ""
    if quest.numObjectives == nil or quest.numObjectives == 0 then
        block.hasDetailInfo = false
    else
        block.hasDetailInfo = true
    end

    if block.hasDetailInfo then
        for i = 1, quest.numObjectives do
            local text, _, finished = GetQuestLogLeaderBoard(i, quest.questLogIndex);
            if finished then
                _finishCount = _finishCount + 1
            end
            if _detailText ~= "" then
                _detailText = _detailText.."\n\n"..text
            else
                _detailText = text
            end
        end
        _titleLb.SetTextString(quest.title.."  (".._finishCount.."/"..quest.numObjectives..")")
    else
        _titleLb.SetTextString(quest.title)
    end
    if quest.isComplete then
        _titleLb.SetTextColor(unpack(PushUIColor.green))
    elseif quest.isOnMap then
        _titleLb.SetTextColor(unpack(PushUIColor.orange))
    else
        _titleLb.SetTextColor(unpack(PushUIColor.white))
    end

    _detailLb.SetTextString(_detailText)
end

_othook._displayNormalQuest = function(...)
    local _qc = _othook.normalQuests.Size()
    local _ah = 0
    for i = 1, _qc do
        local _q = _othook.normalQuests.ObjectAtIndex(i)
        local _b = _q.usingBlock

        _b:ClearAllPoints()
        _b:SetPoint("TOPRIGHT", _nqcontainer, "TOPRIGHT", 0, -_ah)
        _ah = _b:GetHeight() + _config.padding + _ah
    end
    _nqcontainer:SetHeight(_ah)
end

_othook._gainNormalQuests = function()
    -- 1: questID, 2: title, 3: questLogIndex, 4: numObjectives, 
    -- 5: requiredMoney, 6: isComplete, 7: startEvent, 8: isAutoComplete, 
    -- 9: failureTime, 10: timeElapsed, 11: questType, 12: isTask, 
    -- 13: isBounty, 14: isStory, 15: isOnMap, 16: hasLocalPOI
    local _nq = GetNumQuestWatches()
    local _qlist = PushUIAPI.Vector.New()
    for i = 1, _nq do
        local _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16 = GetQuestWatchInfo(i)
        local _relativedBlock = nil
        local _index = _othook.normalQuests.Search(_1, function(q, id) return q.questID == id end)
        if _index > 0 then
            _relativedBlock = _othook.normalQuests.ObjectAtIndex(_index).usingBlock
        end
        if _relativedBlock == nil then
            _relativedBlock = _othook._getNormalQuestBlock()
            _relativedBlock.questID = _1
        end
        local _q = {
            questID = _1,
            title = i.." ".._2,
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
            hasLocalPOI = _16,
            usingBlock = _relativedBlock
        }
        _qlist.PushBack(_q)
        _othook._formatNormalQuestBlock(_relativedBlock, _q)
    end

    -- Set to the quest list.
    local _old_nq = #_othook.normalQuests
    for i = 1, _old_nq do
        local _q = _othook.normalQuests.ObjectAtIndex(i)
        local _nindex = _qlist.Search(_q.questID, function(qobj, id) return qobj.questID == id end)
        if _nindex == 0 then
            -- The quest is not in list
            _othook._normalQuestReleaseFreeBlock(_q.usingBlock)
        end
        _q.usingBlock = nil
    end
    _othook.normalQuests.Clear()

    -- Replace the vector with new 
    _othook.normalQuests = _qlist
end

_othook.OnNormalQuestListChange = function(...)
    _othook._gainNormalQuests()
    _othook._displayNormalQuest()
end

local OTH = PushUIFramesObjectiveTrackerHook
OTH._scenarioBlock = nil
OTH._formatScenarioBlock = function()
    local _b = OTH._scenarioBlock
    local _s = _b.scenario
    local _pb = _b.progressBar

    _b:SetWidth(200)

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

    local _detailText = ""
    local _displayPB = false
    if _numCriteria ~= nil and _numCriteria > 0 then
        for i = 1, _numCriteria do
            --print(C_Scenario.GetCriteriaInfo(i))
            local _name, _, _, _value, _max = C_Scenario.GetCriteriaInfo(i)
            if _detailText == "" then
                _detailText = _value.."/".._max.." ".._name
            else
                _detailText = _detailText.."\n\n".._value.."/".._max.." ".._name
            end
        end
    end
    _b.detailFont:SetText(_detailText)
    local _dh = _b.detailFont:GetStringHeight()
    _b.detailFont:SetHeight(_dh)
    if _dh > 0 then
        _allHeight = _allHeight + _dh + 10
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
        PushUIConfig.skinType(_b)
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

        local _detailfs = _b:CreateFontString()
        _detailfs:SetWidth(180)
        _detailfs:SetFont(_fn, _fsize - 1, _foutline)
        _detailfs:SetJustifyH("LEFT")
        _detailfs:SetPoint("TOPLEFT", _descriptionfs, "BOTTOMLEFT", 0, -10)
        _detailfs:SetMaxLines(10)
        _b.detailFont = _detailfs

        local _pb = PushUIFrames.ProgressBar.Create(_b:GetName().."Progress", _b, nil, "HORIZONTAL")
        _pb:SetWidth(180)
        _pb:SetHeight(15)
        _pb:SetStatusBarColor(unpack(PushUIColor.green))
        _pb:SetMinMaxValues(0, 100)
        _pb:SetPoint("TOPLEFT", _detailfs, "BOTTOMLEFT", 0, -10)
        _b.progressBar = _pb

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


OTH._bonusBlock = nil
OTH._bonusIsInArea = false
OTH._bonusQuestID = nil
OTH._bonusTaskName = nil
OTH._bonusNumObjectives = 0
OTH._gainBonus = function(questLogIndex, questID)
    if nil == questID then return end
    if IsQuestComplete(questID) then
        OTH._bonusQuestID = nil
        return
    end
    if questID == OTH._bonusQuestID then return end
    if not IsQuestBounty(questID) then
        if IsQuestTask(questID) then
            if QuestMapFrame_IsQuestWorldQuest(questID) then
                print("world map quest")
            else
                OTH._bonusQuestID = questID
                -- isInArea, isOnMap, numObjectives, taskName, displayAsObjective...
                OTH._bonusIsInArea, _, OTH._bonusNumObjectives, OTH._bonusTaskName = GetTaskInfo(questID)
                -- for objectiveIndex = 1, numObjectives do
                --     local text, objectiveType, finished = GetQuestObjectiveInfo(questID, objectiveIndex, false)
                --     print(text)
                -- end
                -- print(GetTaskInfo(questID))
            end
        end
    end
end

OTH._bonusUpdate = function()
    if nil ~= OTH._bonusQuestID then
        OTH._bonusIsInArea, _, OTH._bonusNumObjectives, OTH._bonusTaskName = GetTaskInfo(OTH._bonusQuestID)

        if OTH._bonusIsInArea == false or not OTH._bonusNumObjectives then
            OTH._bonusQuestID = nil
            if nil ~= OTH._bonusBlock then
                OTH._bonusBlock:Hide()
            end
        end
    end
end

OTH._formatBonusBlock = function()
    local _b = OTH._bonusBlock
    local _pb = _b.progressBar
    local _titlefs = _b.titleFont
    local _objectivesfs = _b.objectivesFont

    local _objText = ""
    local _showProgressBar = false
    local _progressBarIndex = 0
    for i = 1, OTH._bonusNumObjectives do
        local _t, _objType = GetQuestObjectiveInfo(OTH._bonusQuestID, i, false)
        if _objText == "" then
            _objText = _t
        else
            _objText = _objText.."\n\n".._t
        end
        if _objType == "progressbar" then
            _showProgressBar = true
            _progressBarIndex = i
        end
    end

    _objectivesfs:SetText(_objText)
    local _objHeight = _objectivesfs:GetStringHeight()
    _objectivesfs:SetHeight(_objHeight)

    local _allheight = 10 + _titlefs:GetStringHeight() + 10 + _objHeight + 10

    if _showProgressBar then

        --local _pb = _b.progressBar
        local _pencentagefs = _pb.percentageFont
        local _percentage = GetQuestProgressBarPercent(OTH._bonusQuestID)

        _pb:SetValue(_percentage)
        _pencentagefs:SetText(_percentage)

        _pb:Show()
        _allheight = _allheight + _pb:GetHeight() + 10
    else
        _pb:Hide()
    end

    _b:SetHeight(_allheight)
end

OTH._showBonus = function()
    if (OTH._bonusQuestID == nil) or (OTH._bonusIsInArea == false) then
        if OTH._bonusBlock ~= nil and OTH._bonusBlock:IsShown() then
            OTH._bonusBlock:Hide()
        end
        return
    end

    if OTH._bonusBlock == nil then
        local _b = CreateFrame("Frame", OTH.name.."Bonus", UIParent)
        PushUIConfig.skinType(_b)
        OTH._bonusBlock = _b

        local _fn = "Fonts\\ARIALN.TTF"
        local _fsize = 14
        local _foutline = "OUTLINE"

        local _titlefs = _b:CreateFontString()
        _titlefs:SetWidth(180)
        _titlefs:SetHeight(_fsize)
        _titlefs:SetFont(_fn, _fsize, _foutline)
        _titlefs:SetJustifyH("LEFT")
        _titlefs:SetPoint("TOPLEFT", _b, "TOPLEFT", 10, -10)
        _titlefs:SetTextColor(unpack(PushUIColor.orange))
        _b.titleFont = _titlefs

        local _objectivesfs = _b:CreateFontString()
        _objectivesfs:SetWidth(180)
        _objectivesfs:SetMaxLines(10)
        _objectivesfs:SetFont(_fn, _fsize - 1, _foutline)
        _objectivesfs:SetJustifyH("LEFT")
        _objectivesfs:SetPoint("TOPLEFT", _titlefs, "BOTTOMLEFT", 0, -10)
        _b.objectivesFont = _objectivesfs

        local _pb = PushUIFrames.ProgressBar.Create(_b:GetName().."Progress", _b, nil, "HORIZONTAL")
        _pb:SetStatusBarColor(unpack(PushUIColor.green))
        _pb:SetMinMaxValues(0, 100)
        _pb:SetPoint("TOPLEFT", _objectivesfs, "BOTTOMLEFT", 0, -10)
        _b.progressBar = _pb
        _pb:SetWidth(180)
        _pb:SetHeight(15)

        local _percentagefs = _pb:CreateFontString()
        _percentagefs:SetWidth(180)
        _percentagefs:SetHeight(15)
        _percentagefs:SetFont(_fn, _fsize - 1, _foutline)
        _percentagefs:SetJustifyH("CENTER")
        _percentagefs:SetPoint("CENTER", _pb, "CENTER", 0, 0)
        _pb.percentageFont = _percentagefs

        _b:SetWidth(200)
    end

    OTH._bonusBlock.titleFont:SetText(OTH._bonusTaskName)
    OTH._formatBonusBlock()
    OTH._bonusBlock:Show()

    if nil ~= OTH._scenarioBlock and OTH._scenarioBlock:IsShown() then
        OTH._bonusBlock:SetPoint("TOPLEFT", OTH._scenarioBlock, "BOTTOMLEFT", 0, -10)
    else
        OTH._bonusBlock:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 30, -30)
    end
end

OTH._bonusCheckIfComplete = function(event, questID)
    if questID ~= OTH._bonusQuestID then return end
    OTH._bonusQuestID = nil
    if OTH._bonusBlock ~= nil and OTH._bonusBlock:IsShown() then
        OTH._bonusBlock:Hide()
    end
end


-- Hide objective tracker
ObjectiveTrackerFrame:SetScript("OnShow", ObjectiveTrackerFrame.Hide)
ObjectiveTrackerFrame:Hide()

OTH._onUpdate = function(event, ...)
    _othook.OnNormalQuestListChange()

    if event == "QUEST_ACCEPTED" then
        local questLogIndex, questID = ...
        OTH._gainBonus(questLogIndex, questID)
        if nil ~= OTH._bonusQuestID and OTH._bonusIsInArea then
            OTH._showBonus()
        end
    end

    if event == "QUEST_LOG_UPDATE" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" then
        OTH._bonusUpdate()
        OTH._showBonus()
    end
end

OTH._onScenarioUpdate = function()
    OTH._showScenario()
    OTH._showBonus()
end

OTH._onUpdate()
OTH._onScenarioUpdate()

OTH._onPlayerEnteringWorld = function()
    -- Recheck the bonus quest
    -- local _areaId = GetCurrentMapAreaID()
    local _tasks = GetTasksTable()
    for i = 1, #_tasks do
        OTH._gainBonus(nil, _tasks[i])
        if nil ~= OTH._bonusQuestID and OTH._bonusIsInArea then
            OTH._showBonus()
            break
        end
    end
end

OTH._eventDebug = function(event, ...)
    if nil ~= event then
        print("Track on event "..event)
    else
        print("Get event call but failed to get the event name")
    end
end

PushUIAPI.RegisterEvent("QUEST_LOG_UPDATE", OTH, OTH._onUpdate)
PushUIAPI.RegisterEvent("QUEST_WATCH_LIST_CHANGED", OTH, OTH._onUpdate)
PushUIAPI.RegisterEvent("QUEST_ACCEPTED", OTH, OTH._onUpdate)
PushUIAPI.RegisterEvent("VARIABLES_LOADED", OTH, OTH._onUpdate)
PushUIAPI.RegisterEvent("QUEST_POI_UPDATE", OTH, OTH._onUpdate)
PushUIAPI.RegisterEvent("QUEST_TURNED_IN", OTH, OTH._bonusCheckIfComplete)
PushUIAPI.RegisterEvent("ZONE_CHANGED_NEW_AREA", OTH, OTH._onUpdate)
PushUIAPI.RegisterEvent("ZONE_CHANGED", OTH, OTH._onUpdate)

PushUIAPI.RegisterEvent("SCENARIO_UPDATE", OTH, OTH._onScenarioUpdate)
PushUIAPI.RegisterEvent("SCENARIO_CRITERIA_UPDATE", OTH, OTH._onScenarioUpdate)
PushUIAPI.RegisterEvent("SCENARIO_COMPLETED", OTH, OTH._onScenarioUpdate)

PushUIAPI.RegisterEvent("PLAYER_ENTERING_WORLD", OTH, OTH._onPlayerEnteringWorld)
PushUIAPI.RegisterEvent("SUPER_TRACKED_QUEST_CHANGED", OTH, OTH._onUpdate)
-- PushUIAPI.RegisterEvent("SCENARIO_SPELL_UPDATE", OTH, OTH._eventDebug)
-- --PushUIAPI.RegisterEvent("ZONE_CHANGED", OTH, OTH._eventDebug)
-- PushUIAPI.RegisterEvent("QUEST_TURNED_IN", OTH, OTH._eventDebug)
