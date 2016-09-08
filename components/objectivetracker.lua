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
        autoResize = false
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
    print("enable")
    _nqcontainer.CancelAnimationStage("RegenDisable")
    _nqcontainer:Show()
    _nqcontainer.PlayAnimationStage("RegenEnable")
end

_nqcontainer.regenDisable = function(...)
    print("disable")
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
    if _config.autoResize == false then
        _detailLabel.SetForceWidth(_config.width)
    end
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
