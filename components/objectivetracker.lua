local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

-- The quest system has 6 different module:
-- Normal, Achievement, Auto Accept/Complete, Scenario, Bonus, World
-- This module will not support Achievement right now.

-- Hide objective tracker
ObjectiveTrackerFrame:SetScript("OnShow", ObjectiveTrackerFrame.Hide)
ObjectiveTrackerFrame:Hide()

local _config = PushUIConfig.ObjectiveTrackerHook
if not _config then
    _config = {
        width = 200,
        titleLineCount = 3,
        padding = 5,
        hideInCombat = true,
        titleFontSize = 12,
        objectiveFontSize = 12,
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

PushUIFrames.Animations.EnableAnimationForFrame(_nqcontainer)
PushUIFrames.Animations.AddStage(_nqcontainer, "RegenEnable")
_nqcontainer.AnimationStage("RegenEnable").EnableFade(0.35, 1)

PushUIFrames.Animations.AddStage(_nqcontainer, "RegenDisable")
_nqcontainer.AnimationStage("RegenDisable").EnableFade(0.35, 0)

_nqcontainer.regenEnable = function(...)
    _nqcontainer.CancelAnimationStage("RegenDisable")
    _nqcontainer:Show()
    _nqcontainer.PlayAnimationStage("RegenEnable")
end

_nqcontainer.regenDisable = function(...)
    _nqcontainer.CancelAnimationStage("RegenEnable")
    _nqcontainer.PlayAnimationStage("RegenDisable", function(...) 
        _nqcontainer:Hide() 
    end)
end

if _config.hideInCombat then
    PushUIAPI.RegisterEvent("PLAYER_REGEN_ENABLED", _nqcontainer, _nqcontainer.regenEnable)
    PushUIAPI.RegisterEvent("PLAYER_REGEN_DISABLED", _nqcontainer, _nqcontainer.regenDisable)
end

-- Freed Block Stack
_othook._normalQuestBlockStack = PushUIAPI.Stack.New()
_othook._normalQuestDisplayingBlock = PushUIAPI.Map.New()

_othook._normalQuestReleaseFreeBlock = function(block)
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
    local _height = _config.titleFontSize + _config.padding * 2
    local _block = CreateFrame("Frame", nil, _nqcontainer)
    _block:SetWidth(_config.width)
    _block:SetHeight(_height)
    PushUIConfig.skinType(_block)

    local _titleLabel = PushUIFrames.Label.Create(nil, _block, _config.autoResize)
    _titleLabel.SetFont(_config.fontName, _config.titleFontSize, _config.outline)
    _titleLabel.SetMaxLines(_config.titleLineCount)
    _titleLabel.SetJustifyH("LEFT")
    _titleLabel.SetPadding(_config.padding)
    if _config.autoResize == false then
        _titleLabel.SetForceWidth(_config.width)
    end
    _titleLabel:SetPoint("TOPLEFT", _block, "TOPLEFT", 0, 0)
    _block.titleLabel = _titleLabel

    local _detailBlock = CreateFrame("Frame", nil, _block)
    _detailBlock:SetFrameLevel(_block:GetFrameLevel() - 1)
    _detailBlock:SetWidth(_config.width)
    _detailBlock:SetPoint("TOPRIGHT", _block, "TOPLEFT", -_config.padding, 0)
    _block.detailPanel = _detailBlock
    PushUIConfig.skinType(_detailBlock)
    _detailBlock:SetAlpha(0)

    local _detailLabel = PushUIFrames.Label.Create(nil, _detailBlock, true)
    _detailLabel.SetFont(_config.fontName, _config.objectiveFontSize, _config.outline)
    _detailLabel:SetPoint("TOPRIGHT", _detailBlock, "TOPRIGHT", 0, 0)
    _detailLabel.SetJustifyH("LEFT")
    _detailLabel.SetMaxLines(20)
    if _config.autoResize == false then
        _detailLabel.SetForceWidth(_config.width)
    end
    _detailLabel.SetPadding(_config.padding)
    _detailBlock.objectiveLabel = _detailLabel

    _block:EnableMouse(true)
    _block:SetScript("OnMouseDown", _othook._openNormalQuestOnMap)

    PushUIFrames.Animations.EnableAnimationForFrame(_detailBlock)
    PushUIFrames.Animations.AddStage(_detailBlock, "OnMouseIn")
    _detailBlock.AnimationStage("OnMouseIn").EnableFade(0.3, 1)
    _detailBlock.AnimationStage("OnMouseIn").EnableTranslation(0.3, -_config.padding, 0)
    --_detailBlock.AnimationStage("OnMouseIn").EnableScale(0.3, 1, "TOPLEFT")

    PushUIFrames.Animations.AddStage(_detailBlock, "OnMouseOut")
    --_detailBlock.AnimationStage("OnMouseOut").EnableScale(0.3, 0.01, "TOPLEFT")
    _detailBlock.AnimationStage("OnMouseOut").EnableTranslation(0.3, _config.width, 0)
    _detailBlock.AnimationStage("OnMouseOut").EnableFade(0.3, 0)

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

	if #quest.objList > 0 then
        block.hasDetailInfo = true
        for i = 1, quest.numObjectives do
			local _qo = quest.objList[i]
            if _detailText ~= "" then
                _detailText = _detailText.."\n\n".._qo.obj_text
            else
                _detailText = _qo.obj_text
            end
        end
        _titleLb.SetTextString(quest.title.."  ("..quest.objCompleteCount.."/"..quest.numObjectives..")")
    else
        block.hasDetailInfo = false
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
	local _ah = 0
	_othook._normalQuestDisplayingBlock.ForEach(function(questID, block)
		block:ClearAllPoints()
		block:SetPoint("TOPRIGHT", _nqcontainer, "TOPRIGHT", 0, -_ah)
		_ah = block:GetHeight() + _config.padding + _ah
	end)
    _nqcontainer:SetHeight(_ah)
end

_othook.OnNormalQuestListNewWatching = function(event, newQuestVector)
	local _s = newQuestVector.Size()
	for i = 1, _s do
		local _block = _othook._getNormalQuestBlock()
		local _newquest = newQuestVector.ObjectAtIndex(i)
        _block.questID = _newquest.questID
		_othook._formatNormalQuestBlock(_block, _newquest)
		_othook._normalQuestDisplayingBlock.Set(_newquest.questID, _block)
	end
	_othook._displayNormalQuest()
end
_othook.OnNormalQuestListUnWatch = function(event, unWatchQuestVector)
	local _s = unWatchQuestVector.Size()
	for i = 1, _s do
		local _quest = unWatchQuestVector.ObjectAtIndex(i)
		local _block = _othook._normalQuestDisplayingBlock.Object(_quest.questID)
        _othook._normalQuestDisplayingBlock.UnSet(_quest.questID)
		_othook._normalQuestReleaseFreeBlock(_block)
	end
	_othook._displayNormalQuest()
end
_othook.OnNormanQuestListUpdate = function(event, updateQuestVector)
	local _s = updateQuestVector.Size()
	for i = 1, _s do
		local _quest = updateQuestVector.ObjectAtIndex(i)
		local _block = _othook._normalQuestDisplayingBlock.Object(_quest.questID)
		_othook._formatNormalQuestBlock(_block, _quest)
	end
	_othook._displayNormalQuest()
end

-- Initialize to display all quest
_othook.OnNormalQuestListNewWatching(nil, PushUIAPI.NormalQuests.questList)

-- register event
PushUIAPI:RegisterPUIEvent(
    PushUIAPI.PUIEVENT_NORMAL_QUEST_UPDATE, 
    "othook_normal_quest_update",
    _othook.OnNormanQuestListUpdate)
PushUIAPI:RegisterPUIEvent(
    PushUIAPI.PUIEVENT_NORMAL_QUEST_UNWATCH, 
    "othook_normal_quest_unwatch", 
    _othook.OnNormalQuestListUnWatch)
PushUIAPI:RegisterPUIEvent(
    PushUIAPI.PUIEVENT_NORMAL_QUEST_NEWWATCH, 
    "othook_normal_quest_newwatch", 
    _othook.OnNormalQuestListNewWatching)


-- Stages
local _leftDisplayingBlocks = PushUIAPI.Map.New()
_othook.leftDisplayingBlocks = _leftDisplayingBlocks
local _blockKey_Scenario = "1"
local _blockKey_Challenge = "2"
local _blockKey_Bonus = "3"
local _blockKey_World = "4"

_othook.__leftBlockAllHeight = 0
_othook.LeftBlocksReDisplay = function()
    _othook.__leftBlockAllHeight = 30
    _othook.leftDisplayingBlocks.ForEach(function(_, block)
        block:ClearAllPoints()
        block:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 30, -_othook.__leftBlockAllHeight)
        _othook.__leftBlockAllHeight = _othook.__leftBlockAllHeight + block:GetHeight() + _config.padding
    end)
end

_othook._specialBlock = {}

_othook._setSpecialBlock = function(key, block)
    _othook._specialBlock[key] = block
end

_othook._getSpecialBlock = function(key)
    return _othook._specialBlock[key]
end

_othook._clearSpecialBlock = function(key)
    local _block = _othook._getSpecialBlock(key)
    if _block == nil then return end

    _block:Hide()
    _block.ClearAllDetailBlock()

    _leftDisplayingBlocks.UnSet(key)
end

_othook._initializeSpecialBlock = function(key)
    local _block = _othook._getSpecialBlock(key)
    if _block ~= nil then 
        _block:Show()
        if _leftDisplayingBlocks.Contains(key) == false then
            _leftDisplayingBlocks.Set(key, _block)
        end
        return 
    end

    _block = CreateFrame("Frame", _othook.name..key, UIParent)
    _block:SetWidth(_config.width)
    PushUIConfig.skinType(_block)

    -- Quest Title: Quest Name
    local _titlelb = PushUIFrames.Label.Create(_othook.name..key.."_Title", _block)
    _titlelb.SetFont(_config.fontName, _config.titleFontSize, _config.outline)
    _titlelb.SetJustifyH("CENTER")
    _titlelb.SetPadding(_config.padding)
    _titlelb.SetForceWidth(_config.width)
    _titlelb.SetTextColor(unpack(PushUIColor.orange))
    _block.titleLabel = _titlelb

    -- Subtitle: set to empty to hide the label
    local _subtitlelb = PushUIFrames.Label.Create(_othook.name..key.."_SubTitle", _block)
    _subtitlelb.SetFont(_config.fontName, _config.objectiveFontSize, _config.outline)
    _subtitlelb.SetJustifyH("LEFT")
    _subtitlelb.SetPadding(_config.padding)
    _subtitlelb.SetForceWidth(_config.width)
    _block.subtitleLabel = _subtitlelb

    -- Description Label
    local _desplb = PushUIFrames.Label.Create(_othook.name..key.."_Description", _block)
    _desplb.SetFont(_config.fontName, _config.objectiveFontSize, _config.outline)
    _desplb.SetJustifyH("LEFT")
    _desplb.SetPadding(_config.padding)
    _desplb.SetForceWidth(_config.width)
    _desplb.SetTextColor(unpack(PushUIColor.silver))
    _block.descriptionLabel = _desplb

    -- Detail Blocks
    _block.detailBlocks = PushUIAPI.Vector.New()

    -- Detail Block Cache
    _block._cachedDetailBlockStack = PushUIAPI.Stack.New()

    _block.CreateDetailBlock = function()
        local _detailBlock = CreateFrame("Frame", nil, _block)
        _detailBlock:SetWidth(_config.width)

        local _detailLabel = PushUIFrames.Label.Create(nil, _detailBlock)
        _detailLabel.SetForceWidth(_config.width - 2 * _config.padding)
        _detailLabel.SetFont(_config.fontName, _config.objectiveFontSize - 1, _config.outline)
        _detailLabel.SetJustifyH("LEFT")
        _detailLabel.SetPadding(_config.padding)
        _detailBlock.textLabel = _detailLabel
        _detailBlock.SetText = function(text) 
            _detailBlock.textLabel.SetTextString(text)
        end

        local _detailPb = PushUIFrames.ProgressBar.Create(nil, _detailBlock, nil, "HORIZONTAL")
        _detailPb:SetHeight(_config.objectiveFontSize - 1)
        _detailPb:SetWidth(_config.width - 2 * _config.padding)
        _detailPb:SetStatusBarColor(unpack(PushUIColor.green))
        _detailBlock.progressBar = _detailPb
        _detailBlock.SetProgressValue = function(v, min, max)
            _detailPb:SetMinMaxValues(min, max)
            _detailPb:SetValue(v)
        end

        local _pbLabel = PushUIFrames.Label.Create(nil, _detailPb)
        _pbLabel.SetJustifyH("CENTER")
        _pbLabel.SetFont(_config.fontName, _config.objectiveFontSize - 3, _config.outline)
        _pbLabel.SetPadding(1)
        _pbLabel.SetForceWidth(_config.width - 2 * _config.padding)
        _pbLabel:SetPoint("TOPLEFT", _detailPb, "TOPLEFT", 0, -1)
        _detailBlock.progressLabel = _pbLabel
        _detailBlock.SetProgressText = function(text)
            _detailBlock.progressLabel.SetTextString(text)
        end

        local _pbTimer = PushUIFrames.Timer.Create(1)
        _pbTimer:SetHandler(function()
            _detailPb:SetValue(_detailPb:GetValue() - 1)
            _remineTime = _detailPb:GetValue()
            local _timeString = ""
            if _remineTime >= 3600 then
                local _hours = math.floor(_remineTime / 3600)
                _remineTime = _remineTime - (_hours * 3600)
                _timeString = _hours.."H "
            end
            if _remineTime > 60 then
                local _mins = math.floor(_remineTime / 60)
                _remineTime = _remineTime - (_mins * 60)
                _timeString = _timeString.._mins.."M "
            end
            _timeString = _timeString.._remineTime.."S"
            _pbLabel.SetTextString(_timeString)
        end)
        _detailPb.timer = _pbTimer

        _detailBlock.showDetail = true
        _detailBlock.showProgress = false

        _detailBlock.Resize = function()
            local _ah = 0
            if _detailBlock.showDetail then
                local _th = _detailBlock.textLabel:GetHeight()
                _detailBlock.textLabel:ClearAllPoints()
                _detailBlock.textLabel:SetPoint("TOPLEFT", _detailBlock, "TOPLEFT", _config.padding, -_ah)
                _ah = _ah + _th
            else
                _detailBlock.textLabel:Hide()
            end

            if _detailBlock.showProgress then
                local _ph = _detailBlock.progressBar:GetHeight()
                _detailBlock.progressBar:ClearAllPoints()
                _detailBlock.progressBar:SetPoint("TOPLEFT", _detailBlock, "TOPLEFT", _config.padding, -_ah)
                _detailBlock.progressBar:Show()
                _ah = _ah + _ph + _config.padding
            else
                _detailBlock.progressBar:Hide()
            end

            _detailBlock:SetHeight(_ah)
            return _ah
        end

        return _detailBlock
    end

    _block.FreeDetailBlock = function(detailBlock)
        detailBlock:Hide()
        detailBlock.progressBar.timer:StopTimer()
        _block._cachedDetailBlockStack.Push(detailBlock)
    end

    _block.GetDetailBlock = function()
        if _block._cachedDetailBlockStack.Size() > 0 then
            local _db = _block._cachedDetailBlockStack.Top()
            _block._cachedDetailBlockStack.Pop()
            _db:Show()
            return _db
        end
        return _block.CreateDetailBlock()
    end

    _block.ClearAllDetailBlock = function()
        local _ds = _block.detailBlocks.Size()
        for i = 1, _ds do
            _block.FreeDetailBlock(_block.detailBlocks.ObjectAtIndex(i))
        end
        _block.detailBlocks.Clear()
    end

    _othook._setSpecialBlock(key, _block)
    _leftDisplayingBlocks.Set(key, _block)
end

-- Scenario
_othook._initializeScenarioBlock = function()
    _othook._initializeSpecialBlock(_blockKey_Scenario)
end

_othook._formatScenarioBlock = function(scenarioQuest)
    local _block = _othook._getSpecialBlock(_blockKey_Scenario)

    -- Set Static Text Info
    _block.titleLabel.SetTextString(scenarioQuest.scenarioName.." "..scenarioQuest.currentStage.."/"..scenarioQuest.numStages)
    _block.subtitleLabel.SetTextString(scenarioQuest.stageInfo.name)
    _block.descriptionLabel.SetTextString(scenarioQuest.stageInfo.description)

    local _ah = 0
    _block.titleLabel:ClearAllPoints()
    _block.titleLabel:SetPoint("TOPLEFT", _block, "TOPLEFT", 0, -_ah)
    local _th = _block.titleLabel:GetHeight()
    _ah = _ah + _th
    _block.subtitleLabel:ClearAllPoints()
    _block.subtitleLabel:SetPoint("TOPLEFT", _block, "TOPLEFT", 0, -_ah)
    local _sth = _block.subtitleLabel:GetHeight()
    _ah = _ah + _sth
    _block.descriptionLabel:ClearAllPoints()
    _block.descriptionLabel:SetPoint("TOPLEFT", _block, "TOPLEFT", 0, -_ah)
    local _dsph = _block.descriptionLabel:GetHeight()
    _ah = _ah + _dsph

    -- Set Dynamic 
    -- Remove all old detail block
    _block.ClearAllDetailBlock()

    local _ds = #scenarioQuest.criteriaList
    for i = 1, _ds do
        local _criteria = scenarioQuest.criteriaList[i]
        local _detailBlock = _block.GetDetailBlock()    -- Get an empty detail block
        -- Always show detail info
        _detailBlock.showDetail = true
        if _criteria.isWeightedProgress then
            _detailBlock.showProgress = true
            local _percentage = _criteria.quantity / _criteria.totalQuantity * 100
            _detailBlock.SetProgressValue(_criteria.quantity, 0, _criteria.totalQuantity)
            _detailBlock.SetProgressText(("%.2f"):format(_percentage))
            _detailBlock.SetText("-- ".._criteria.criteriaString)
        elseif _criteria.duration > 0 and _criteria.elapsed <= _criteria.duration then
            _detailBlock.showProgress = true
            _detailBlock.SetText("-- ".._criteria.criteriaString)
            _detailBlock.SetProgressValue(GetTime() - _criteria.elapsed, 0, _criteria.duration)
            _detailBlock.progressBar.timer:StartTimer()
        else
            _detailBlock.showProgress = false
            _detailBlock.SetText("-- ".._criteria.criteriaString.." ".._criteria.quantity.."/".._criteria.totalQuantity)
        end
        local _dh = _detailBlock.Resize()
        _block.detailBlocks.PushBack(_detailBlock)

        _detailBlock:ClearAllPoints()
        _detailBlock:SetPoint("TOPLEFT", _block, "TOPLEFT", 0, -_ah)
        _ah = _ah + _dh
    end

    _block:SetHeight(_ah)
end

_othook._releaseScenarioBlock = function()
    _othook._clearSpecialBlock(_blockKey_Scenario)
end

_othook.OnScenarioStart = function(event, scenarioQuest)
    _othook._initializeScenarioBlock()
    _othook._formatScenarioBlock(scenarioQuest)

    -- Redisplay all left blocks
    _othook.LeftBlocksReDisplay()
end

_othook.OnScenarioUpdate = function(event, scenarioQuest)
    _othook._formatScenarioBlock(scenarioQuest)

    -- Redisplay all left blocks
    _othook.LeftBlocksReDisplay()
end

_othook.OnScenarioComplete = function(event, ...)
    _othook._releaseScenarioBlock()

    -- Redisplay all left blocks
    _othook.LeftBlocksReDisplay()
end

local function _debugScenario()
    if PushUIAPI.ScenarioQuest.quest ~= nil then
        _othook.OnScenarioStart(nil, PushUIAPI.ScenarioQuest.quest)
    end
end
PushUIAPI.RegisterEvent("PLAYER_ENTERING_WORLD", _othook, _debugScenario)
-- register event
PushUIAPI:RegisterPUIEvent(
    PushUIAPI.PUSHUIEVENT_SCENARIO_QUEST_START, 
    "othook_scenario_quest_start",
    _othook.OnScenarioStart)
PushUIAPI:RegisterPUIEvent(
    PushUIAPI.PUSHUIEVENT_SCENARIO_QUEST_UPDATE, 
    "othook_scenario_quest_update", 
    _othook.OnScenarioUpdate)
PushUIAPI:RegisterPUIEvent(
    PushUIAPI.PUSHUIEVENT_SCENARIO_QUEST_COMPLETE, 
    "othook_scenario_quest_complete", 
    _othook.OnScenarioComplete)


-- Challenge Mode
_othook._initializeChallengeBlock = function()
    _othook._initializeSpecialBlock(_blockKey_Challenge)
end

_othook._formatChallengeBlock = function(modeInfo)
    local _block = _othook._getSpecialBlock(_blockKey_Challenge)

    -- Set Static Text Info
    _block.titleLabel:Hide()
    _block.subtitleLabel:Hide()
    _block.descriptionLabel:Hide()

    local _ah = 0

    -- Set Dynamic 
    -- Remove all old detail block
    _block.ClearAllDetailBlock()
    local _detailBlock = _block.GetDetailBlock()
    _detailBlock.showDetail = true
    if modeInfo.level ~= nil then
        _detailBlock.SetText(modeInfo.level)
    else
        _detailBlock.SetText(modeInfo.currentWave.."/"..modeInfo.maxWave)
    end

    _detailBlock.showProgress = true
    _detailBlock.SetProgressValue(GetTime() - modeInfo.elapsedTime, 0, modeInfo.timeLimit)
    _detailBlock.progressBar.timer:StartTimer()

    _block.detailBlocks.PushBack(_detailBlock)
    local _dh = _detailBlock.Resize()
    _detailBlock:ClearAllPoints()
    _detailBlock:SetPoint("TOPLEFT", _block, "TOPLEFT", 0, -_ah)
    _ah = _ah + _dh

    _block:SetHeight(_ah)
end

_othook._releaseChallengeBlock = function()
    _othook._clearSpecialBlock(_blockKey_Challenge)
end

_othook.OnChallengeStart = function(event, modeInfo)
    _othook._initializeChallengeBlock()
    _othook._formatChallengeBlock(modeInfo)

    -- Redisplay all left blocks
    _othook.LeftBlocksReDisplay()
end

_othook.OnChallengeComplete = function(event, ...)
    _othook._releaseChallengeBlock()

    -- Redisplay all left blocks
    _othook.LeftBlocksReDisplay()
end

-- register event
PushUIAPI:RegisterPUIEvent(
    PushUIAPI.PUSHUIEVENT_CHALLENGE_MODE_START, 
    "othook_challenge_mode_start",
    _othook.OnChallengeStart)
PushUIAPI:RegisterPUIEvent(
    PushUIAPI.PUSHUIEVENT_CHALLENGE_MODE_STOP, 
    "othook_challenge_mode_stop", 
    _othook.OnChallengeComplete)

