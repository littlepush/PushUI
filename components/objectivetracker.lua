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
        width = 150,
        padding = 7,
        hideInCombat = true,
        objectiveFontSize = 14,
        outline = "",
        fontName = "Fonts\\ARIALN.TTF",
        autoResize = false
    }
end

local _lineHeight = _config.objectiveFontSize + _config.padding * 2

local _objHookView = PushUIFrames.UIView()
_objHookView:set_width(_config.width)
_objHookView:set_backgroundColor(PushUIColor.black, 0)
_objHookView:set_borderColor(PushUIColor.black, 0)
_objHookView:set_archor("TOPRIGHT")
_objHookView:set_archor_target(UIParent, "TOPRIGHT")
_objHookView:set_position(-25, -30)

PushUIAPI.EventCenter:RegisterEvent(
    PushUIAPI.PUSHUIEVENT_PLAYER_BEGIN_COMBAT, 
    "ObjectiveHookViewHiddingAnimation", 
    function(...) 
        _objHookView:animation_with_duration(
            0.35, 
            function(ohv) 
                ohv:set_alpha(0)
            end)
    end
    )
PushUIAPI.EventCenter:RegisterEvent(
    PushUIAPI.PUSHUIEVENT_PLAYER_END_COMBAT,
    "ObjectiveHookViewDisplayAnimation",
    function(...)
        _objHookView:animation_with_duration(
            0.35,
            function(ohv)
                ohv:set_alpha(1)
            end)
    end
    )

-- QObj Label
local PUIQuestObjLabel = PushUIAPI.inhiert(PushUIFrames.UILabel)
function PUIQuestObjLabel:initialize()
    self.super:initialize()
    self:set_fontname(_config.fontName)
    self:set_fontsize(_config.objectiveFontSize)
    self:set_fontflag(_config.outline)
    self:set_wbounds(_config.width - 2 * _config.padding)
    self:set_width(_config.width - 2 * _config.padding)
    self:set_maxline(999)
    self:set_archor("TOPLEFT")
    self:set_fontcolor(PushUIColor.white)
end
function PUIQuestObjLabel:set_finished(is_finished)
    if is_finished then
        self:set_fontcolor(PushUIColor.green)
    else
        self:set_fontcolor(PushUIColor.white)
    end
end

-- Progress Bar
local PUIQuestProgressBar = PushUIAPI.inhiert(PushUIFrames.UIProgressBar)
function PUIQuestProgressBar:initialize()
    self:set_width(_config.width - 2 * _config.padding)
    self:set_height(_lineHeight)
    self:set_backgroundColor(PushUIColor.black)
    self:set_barColor(PushUIColor.blue)
    self:set_archor("TOPLEFT")
    -- Default style
    self:set_style("h-l-r")
end


-- Objective Label Stack
local _objPool = PushUIAPI.Pool(function()
    return PUIQuestObjLabel()
end)
local _pbPool = PushUIAPI.Pool(function()
    return PUIQuestProgressBar()
end)

-- Detail Block
local PUIQuestDetailPanel = PushUIAPI.inhiert(PushUIFrames.UIView)
function PUIQuestDetailPanel:initialize()
    self._objs = PushUIAPI.Array()
    self._dobjs = PushUIAPI.Array()
    self._pobjs = PushUIAPI.Array()

    self:set_width(_config.width)
    PushUIConfig.skinType(self.layer)
end
function PUIQuestDetailPanel:add_detail_text(text, finished)
    local _lb = _objPool:get()

    _lb.layer:SetParent(self.layer)
    _lb:set_hidden(false)
    _lb:set_text(text)
    _lb:set_archor_target(self.layer, "TOPLEFT")
    _lb:set_finished(finished)

    self._dobjs:push_back(_lb)
    self._objs:push_back(_lb)
end
function PUIQuestDetailPanel:add_detail_progress(value, max)
    local _pb = _pbPool:get()
    _pb:set_hidden(false)
    _pb:set_max(max)
    _pb:set_value(value)

    _pb:set_archor_target(self, "TOPLEFT")
    self._pobjs:push_back(_pb)
    self._objs:push_back(_pb)
end
function PUIQuestDetailPanel:add_detail_timer(now, duration)
    --
end
function PUIQuestDetailPanel:recycle()
    self._dobjs:for_each(function(index, lb)
        lb:set_hidden(true)
        _objPool:release(lb)
    end)
    self._dobjs:clear()
    self._pobjs:for_each(function(index, pb)
        pb:set_hidden(true)
        _pbPool:release(pb)
    end)
    self._pobjs:clear()

    self._objs:clear()
end
function PUIQuestDetailPanel:autoResize()
    local _top = _config.padding
    self._objs:for_each(function(index, obj)
        obj:set_position(_config.padding, -_top)
        _top = _top + obj:height() + _config.padding
    end)
    self:set_height(_top)
end

-- Quest Block
PUIQuestBlock = PushUIAPI.inhiert(PushUIFrames.UIView)
function PUIQuestBlock:c_str(...)
    self.questID = 0
    self._hasDetail = false

    self.layer:SetParent(_objHookView.layer)
end

function PUIQuestBlock:initialize()
    PushUIConfig.skinType(self.layer)
    self:set_user_interactive(true)

    self:set_archor("TOPLEFT")
    self:set_archor_target(_objHookView.layer, "TOPLEFT")

    self.titleLabel = PUIQuestObjLabel(self)
    self.detailPanel = PUIQuestDetailPanel(self)

    self.titleLabel:set_archor_target(self.layer, "TOPLEFT")
    self.titleLabel:set_position(_config.padding, -_config.padding)

    self.detailPanel:set_alpha(0)
    self.detailPanel:set_archor_target(self.layer, "TOPLEFT")
    self.detailPanel:set_archor("TOPRIGHT")
    self.detailPanel:set_position(-_config.padding, 0)
    self.detailPanel.layer:SetFrameLevel(self.layer:GetFrameLevel() - 1)

    self:set_width(_config.width)
    
    self:add_action("PUIEventMouseEnter", "mouse_enter", function()
        if self._hasDetail == false then return end
        self.detailPanel:animation_with_duration(0.3, function(dp)
            dp:set_alpha(1)
        end)
    end)
    self:add_action("PUIEventMouseLeave", "mouse_leave", function()
        if self._hasDetail == false then return end
        self.detailPanel:animation_with_duration(0.3, function(dp)
            dp:set_alpha(0)
        end)
    end)
    self:add_action("PUIEventMouseUp", "mouse_up", function()
        if not self.questID then return end
        QuestMapFrame_OpenToQuestDetails(self.questID)
    end)
end

function PUIQuestBlock:set_quest(quest)
    self.questID = quest.questID
    local _title
    if quest.numObjectives then
        _title = quest.objCompleteCount .. "/" .. quest.numObjectives .. " " .. quest.title
    else
        _title = quest.title 
    end
    self.titleLabel:set_text(_title)
    self.titleLabel:set_finished(quest.isComplete)
    self:set_height(self.titleLabel:height() + 2 * _config.padding)

    self.detailPanel:set_alpha(0)

    self._hasDetail = false

    -- Open auto complete quest
    -- if quest.isAutoComplete then
    --     QuestMapFrame_OpenToQuestDetails(quest.questID)
    -- end

    if quest.numObjectives == 0 then return end
    self._hasDetail = true

    self.detailPanel:recycle()
    for i = 1, quest.numObjectives do
        local _obj = quest.objList[i]
        self.detailPanel:add_detail_text(_obj.obj_text, _obj.obj_finished)
    end
    -- ReSize the detail panel
    self.detailPanel:autoResize()
end

local _allDisplayingQuestList = PushUIAPI.Map()
local function normal_quest_redraw()
    local _top = 0
    _allDisplayingQuestList:for_each(function(id, qb)
        qb:set_position(0, -_top)
        _top = _top + _config.padding + qb:height()
    end)
    _objHookView:set_height(_top)
end

local _qbPool = PushUIAPI.Pool(function() return PUIQuestBlock() end)
local function eventHandler_newWatchingQuest(_, questArray)
    questArray:for_each(function(_, quest)
        local _qb = _qbPool:get()
        _qb:set_hidden(false)
        _qb:set_quest(quest)
        _allDisplayingQuestList:set(quest.questID, _qb)
    end)
    normal_quest_redraw()
end

local function eventHandler_unWatchingQuest(_, questArray)
    questArray:for_each(function(_, quest)
        local _qb = _allDisplayingQuestList:object(quest.questID)
        if not _qb then return end
        _qb:set_hidden(true)
        _qbPool:release(_qb)
        _allDisplayingQuestList:unset(quest.questID)
    end)
    normal_quest_redraw()
end

local function eventHandler_updateQuest(_, questArray)
    questArray:for_each(function(_, quest)
        local _qb = _allDisplayingQuestList:object(quest.questID)
        if not _qb then return end
        _qb:set_quest(quest)
    end)
    normal_quest_redraw()
end

PushUIAPI.EventCenter:RegisterEvent(PushUIAPI.PUIEVENT_NORMAL_QUEST_NEWWATCH, "nq_watch", eventHandler_newWatchingQuest)
PushUIAPI.EventCenter:RegisterEvent(PushUIAPI.PUIEVENT_NORMAL_QUEST_UNWATCH, "nq_unwatch", eventHandler_unWatchingQuest)
PushUIAPI.EventCenter:RegisterEvent(PushUIAPI.PUIEVENT_NORMAL_QUEST_UPDATE, "nq_update", eventHandler_updateQuest)

-- Left Quest 
local _leftDisplayingBlocks = PushUIAPI.Map()
local _blockKey_Scenario = "a"
local _blockKey_Challenge = "b"
local _blockKey_Bonus = "c"
local _blockKey_World = "d"
local __leftBlockAllHeight = 0
local function LeftBlocksReDisplay()
    __leftBlockAllHeight = 30
    _leftDisplayingBlocks:for_each(function(_, block)
        block:ClearAllPoints()
        block:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 30, -_othook.__leftBlockAllHeight)
        __leftBlockAllHeight = __leftBlockAllHeight + block:GetHeight() + _config.padding
    end)
end

-- Special Block
local PUISpecialBlock = PushUIAPI.inhiert(PushUIFrames.UIView)
function PUISpecialBlock:c_str()
    self.title = PushUIFrames.UILabel(self)
    self.subtitle = PushUIFrames.UILabel(self)
    self.description = PushUIFrames.UILabel(self)

    self.detail = PUIQuestDetailPanel(self)
    self._displayHeight = 0
end

function PUISpecialBlock:initialize()
    self:set_width(_config.width)
    self:set_archor("TOPLEFT")
    self:set_archor_target(UIParent, "TOPLEFT")
    PushUIConfig.skinType(self.layer)

    local _textPadding = _config.padding
    -- Title Style
    self.title:set_maxline(1)
    self.title:set_bounds(_config.width, _config.objectiveFontSize + 1 + 2 * _textPadding)
    self.title:set_fontcolor(PushUIColor.orange)
    self.title:set_fontsize(_config.objectiveFontSize + 1)
    self.title:set_padding(_textPadding)
    self.title:set_align("CENTER")
    self.title:set_position()

    -- Subtitle
    self.subtitle:set_width(_config.width)
    self.subtitle:set_maxline(99)
    self.subtitle:set_wbounds(_config.width)
    self.subtitle:set_fontcolor(PushUIColor.white)
    self.subtitle:set_fontflag("OUTLINE")
    self.subtitle:set_padding(_textPadding)
    self.subtitle:set_archor_target(self.title.layer, "BOTTOMLEFT")
    self.subtitle:set_position()

    -- Description
    self.description:set_width(_config.width)
    self.description:set_maxline(99)
    self.description:set_wbounds(_config.width)
    self.description:set_fontcolor(PushUIColor.white)
    self.description:set_archor_target(self.subtitle.layer, "BOTTOMLEFT")
    self.description:set_position()

    -- Detail Panel
    self.detail:set_archor_target(self.layer, "BOTTOMLEFT")
    self.detail:set_position(0, -_config.padding)
end

function PUISpecialBlock:set_infomation(title, subtitle, description)
    self.title:set_text(title)
    self.subtitle:set_text(subtitle)
    self.description:set_text(description)

    self._displayHeight = self.title:height() + self.subtitle:height() + self.description:height()
end

function PUISpecialBlock:add_detail_text(text, finished)
    self.detail:add_detail_text(text, finished)
end


-- -- Stages

-- _othook._worldBlockKeyAllCount = 0
-- _othook._worldBlockKeyPool = PushUIAPI.Pool(function()
--     _othook._worldBlockKeyAllCount = _othook._worldBlockKeyAllCount + 1
--     return _blockKey_World.._othook._worldBlockKeyAllCount
-- end)

-- _othook._worldBlockKeyFree = function(key)
--     _othook._worldBlockKeyPool:release(key)
-- end
-- _othook._worldBlockKeyGet = function()
--     return _othook._worldBlockKeyPool:get()
-- end
-- _othook._worldQuestBlockKeyMap = PushUIAPI.Map()

-- _othook._specialBlock = {}

-- _othook._setSpecialBlock = function(key, block)
--     _othook._specialBlock[key] = block
-- end

-- _othook._getSpecialBlock = function(key)
--     return _othook._specialBlock[key]
-- end

-- _othook._clearSpecialBlock = function(key)
--     local _block = _othook._getSpecialBlock(key)
--     if _block == nil then return end

--     _block:Hide()
--     _block.ClearAllDetailBlock()

--     _leftDisplayingBlocks:unset(key)
-- end

-- _othook._initializeSpecialBlock = function(key)
--     local _block = _othook._getSpecialBlock(key)
--     if _block ~= nil then 
--         _block:Show()
--         if _leftDisplayingBlocks:contains(key) == false then
--             _leftDisplayingBlocks:set(key, _block)
--         end
--         return 
--     end

--     _block = CreateFrame("Frame", _othook.name..key, UIParent)
--     _block:SetWidth(_config.width)
--     PushUIConfig.skinType(_block)

--     -- Quest Title: Quest Name
--     local _titlelb = PushUIFrames.Label.Create(_othook.name..key.."_Title", _block)
--     _titlelb.SetFont(_config.fontName, _config.titleFontSize, _config.outline)
--     _titlelb.SetJustifyH("CENTER")
--     _titlelb.SetPadding(_config.padding)
--     _titlelb.SetForceWidth(_config.width)
--     _titlelb.SetTextColor(unpack(PushUIColor.orange))
--     _block.titleLabel = _titlelb

--     -- Subtitle: set to empty to hide the label
--     local _subtitlelb = PushUIFrames.Label.Create(_othook.name..key.."_SubTitle", _block)
--     _subtitlelb.SetFont(_config.fontName, _config.objectiveFontSize, _config.outline)
--     _subtitlelb.SetJustifyH("LEFT")
--     _subtitlelb.SetPadding(_config.padding)
--     _subtitlelb.SetForceWidth(_config.width)
--     _block.subtitleLabel = _subtitlelb

--     -- Description Label
--     local _desplb = PushUIFrames.Label.Create(_othook.name..key.."_Description", _block)
--     _desplb.SetFont(_config.fontName, _config.objectiveFontSize, _config.outline)
--     _desplb.SetJustifyH("LEFT")
--     _desplb.SetPadding(_config.padding)
--     _desplb.SetForceWidth(_config.width)
--     _desplb.SetTextColor(unpack(PushUIColor.silver))
--     _block.descriptionLabel = _desplb

--     -- Detail Blocks
--     _block.detailBlocks = PushUIAPI.Array()

--     -- Detail Block Cache
--     _block.CreateDetailBlock = function()
--         local _detailBlock = CreateFrame("Frame", nil, _block)
--         _detailBlock:SetWidth(_config.width)

--         local _detailLabel = PushUIFrames.Label.Create(nil, _detailBlock)
--         _detailLabel.SetForceWidth(_config.width - 2 * _config.padding)
--         _detailLabel.SetFont(_config.fontName, _config.objectiveFontSize - 1, _config.outline)
--         _detailLabel.SetJustifyH("LEFT")
--         _detailLabel.SetPadding(_config.padding)
--         _detailBlock.textLabel = _detailLabel
--         _detailBlock.SetText = function(text) 
--             _detailBlock.textLabel.SetTextString(text)
--         end

--         local _detailPb = PushUIFrames.ProgressBar.Create(nil, _detailBlock, nil, "HORIZONTAL")
--         _detailPb:SetHeight(_config.objectiveFontSize - 1)
--         _detailPb:SetWidth(_config.width - 2 * _config.padding)
--         _detailPb:SetStatusBarColor(unpack(PushUIColor.green))
--         _detailBlock.progressBar = _detailPb
--         _detailBlock.SetProgressValue = function(v, min, max)
--             _detailPb:SetMinMaxValues(min, max)
--             _detailPb:SetValue(v)
--         end

--         local _pbLabel = PushUIFrames.Label.Create(nil, _detailPb)
--         _pbLabel.SetJustifyH("CENTER")
--         _pbLabel.SetFont(_config.fontName, _config.objectiveFontSize - 3, _config.outline)
--         _pbLabel.SetPadding(1)
--         _pbLabel.SetForceWidth(_config.width - 2 * _config.padding)
--         _pbLabel:SetPoint("TOPLEFT", _detailPb, "TOPLEFT", 0, -1)
--         _detailBlock.progressLabel = _pbLabel
--         _detailBlock.SetProgressText = function(text)
--             _detailBlock.progressLabel.SetTextString(text)
--         end

--         local _pbTimer = PushUIFrames.Timer.Create(1)
--         _pbTimer:SetHandler(function()
--             _detailPb:SetValue(_detailPb:GetValue() - 1)
--             _remineTime = _detailPb:GetValue()
--             local _timeString = ""
--             if _remineTime >= 3600 then
--                 local _hours = math.floor(_remineTime / 3600)
--                 _remineTime = _remineTime - (_hours * 3600)
--                 _timeString = _hours.."H "
--             end
--             if _remineTime > 60 then
--                 local _mins = math.floor(_remineTime / 60)
--                 _remineTime = _remineTime - (_mins * 60)
--                 _timeString = _timeString.._mins.."M "
--             end
--             _timeString = _timeString.._remineTime.."S"
--             _pbLabel.SetTextString(_timeString)
--         end)
--         _detailPb.timer = _pbTimer

--         _detailBlock.showDetail = true
--         _detailBlock.showProgress = false

--         _detailBlock.Resize = function()
--             local _ah = 0
--             if _detailBlock.showDetail then
--                 local _th = _detailBlock.textLabel:GetHeight()
--                 _detailBlock.textLabel:ClearAllPoints()
--                 _detailBlock.textLabel:SetPoint("TOPLEFT", _detailBlock, "TOPLEFT", _config.padding, -_ah)
--                 _ah = _ah + _th
--             else
--                 _detailBlock.textLabel:Hide()
--             end

--             if _detailBlock.showProgress then
--                 local _ph = _detailBlock.progressBar:GetHeight()
--                 _detailBlock.progressBar:ClearAllPoints()
--                 _detailBlock.progressBar:SetPoint("TOPLEFT", _detailBlock, "TOPLEFT", _config.padding, -_ah)
--                 _detailBlock.progressBar:Show()
--                 _ah = _ah + _ph + _config.padding
--             else
--                 _detailBlock.progressBar:Hide()
--             end

--             _detailBlock:SetHeight(_ah)
--             return _ah
--         end

--         return _detailBlock
--     end

--     _block._detailBlockPool = PushUIAPI.Pool(_block.CreateDetailBlock)

--     _block.FreeDetailBlock = function(detailBlock)
--         detailBlock:Hide()
--         detailBlock.progressBar.timer:StopTimer()
--         _block._detailBlockPool:release(detailBlock)
--    end

--     _block.GetDetailBlock = function()
--         return _block._detailBlockPool:get()
--     end

--     _block.ClearAllDetailBlock = function()
--         local _ds = _block.detailBlocks:size()
--         for i = 1, _ds do
--             _block.FreeDetailBlock(_block.detailBlocks:objectAtIndex(i))
--         end
--         _block.detailBlocks:clear()
--     end

--     _othook._setSpecialBlock(key, _block)
--     _leftDisplayingBlocks:set(key, _block)
-- end

-- -- Scenario
-- _othook._initializeScenarioBlock = function()
--     _othook._initializeSpecialBlock(_blockKey_Scenario)
-- end

-- _othook._formatScenarioBlock = function(scenarioQuest)
--     local _block = _othook._getSpecialBlock(_blockKey_Scenario)

--     -- Set Static Text Info
--     _block.titleLabel.SetTextString(scenarioQuest.scenarioName.." "..scenarioQuest.currentStage.."/"..scenarioQuest.numStages)
--     _block.subtitleLabel.SetTextString(scenarioQuest.stageInfo.name)
--     _block.descriptionLabel.SetTextString(scenarioQuest.stageInfo.description)

--     local _ah = 0
--     _block.titleLabel:ClearAllPoints()
--     _block.titleLabel:SetPoint("TOPLEFT", _block, "TOPLEFT", 0, -_ah)
--     local _th = _block.titleLabel:GetHeight()
--     _ah = _ah + _th
--     _block.subtitleLabel:ClearAllPoints()
--     _block.subtitleLabel:SetPoint("TOPLEFT", _block, "TOPLEFT", 0, -_ah)
--     local _sth = _block.subtitleLabel:GetHeight()
--     _ah = _ah + _sth
--     _block.descriptionLabel:ClearAllPoints()
--     _block.descriptionLabel:SetPoint("TOPLEFT", _block, "TOPLEFT", 0, -_ah)
--     local _dsph = _block.descriptionLabel:GetHeight()
--     _ah = _ah + _dsph

--     -- Set Dynamic 
--     -- Remove all old detail block
--     _block.ClearAllDetailBlock()

--     local _ds = #scenarioQuest.criteriaList
--     for i = 1, _ds do
--         local _criteria = scenarioQuest.criteriaList[i]
--         local _detailBlock = _block.GetDetailBlock()    -- Get an empty detail block
--         -- Always show detail info
--         _detailBlock.showDetail = true
--         if _criteria.isWeightedProgress then
--             _detailBlock.showProgress = true
--             local _percentage = _criteria.quantity / _criteria.totalQuantity * 100
--             _detailBlock.SetProgressValue(_criteria.quantity, 0, _criteria.totalQuantity)
--             _detailBlock.SetProgressText(("%.2f"):format(_percentage))
--             _detailBlock.SetText("-- ".._criteria.criteriaString)
--         elseif _criteria.duration > 0 and _criteria.elapsed <= _criteria.duration then
--             _detailBlock.showProgress = true
--             _detailBlock.SetText("-- ".._criteria.criteriaString)
--             _detailBlock.SetProgressValue(GetTime() - _criteria.elapsed, 0, _criteria.duration)
--             _detailBlock.progressBar.timer:StartTimer()
--         else
--             _detailBlock.showProgress = false
--             _detailBlock.SetText("-- ".._criteria.criteriaString.." ".._criteria.quantity.."/".._criteria.totalQuantity)
--         end
--         local _dh = _detailBlock.Resize()
--         _block.detailBlocks:push_back(_detailBlock)

--         _detailBlock:ClearAllPoints()
--         _detailBlock:SetPoint("TOPLEFT", _block, "TOPLEFT", 0, -_ah)
--         _ah = _ah + _dh
--     end

--     _block:SetHeight(_ah)
-- end

-- _othook._releaseScenarioBlock = function()
--     _othook._clearSpecialBlock(_blockKey_Scenario)
-- end

-- _othook.OnScenarioStart = function(event, scenarioQuest)
--     _othook._initializeScenarioBlock()
--     _othook._formatScenarioBlock(scenarioQuest)

--     -- Redisplay all left blocks
--     _othook.LeftBlocksReDisplay()
-- end

-- _othook.OnScenarioUpdate = function(event, scenarioQuest)
--     _othook._formatScenarioBlock(scenarioQuest)

--     -- Redisplay all left blocks
--     _othook.LeftBlocksReDisplay()
-- end

-- _othook.OnScenarioComplete = function(event, ...)
--     _othook._releaseScenarioBlock()

--     -- Redisplay all left blocks
--     _othook.LeftBlocksReDisplay()
-- end

-- if PushUIAPI.ScenarioQuest.quest ~= nil then
--     _othook.OnScenarioStart(nil, PushUIAPI.ScenarioQuest.quest)
-- end

-- -- register event
-- PushUIAPI:RegisterPUIEvent(
--     PushUIAPI.PUSHUIEVENT_SCENARIO_QUEST_START, 
--     "othook_scenario_quest_start",
--     _othook.OnScenarioStart)
-- PushUIAPI:RegisterPUIEvent(
--     PushUIAPI.PUSHUIEVENT_SCENARIO_QUEST_UPDATE, 
--     "othook_scenario_quest_update", 
--     _othook.OnScenarioUpdate)
-- PushUIAPI:RegisterPUIEvent(
--     PushUIAPI.PUSHUIEVENT_SCENARIO_QUEST_COMPLETE, 
--     "othook_scenario_quest_complete", 
--     _othook.OnScenarioComplete)


-- -- Challenge Mode
-- _othook._initializeChallengeBlock = function()
--     _othook._initializeSpecialBlock(_blockKey_Challenge)
-- end

-- _othook._formatChallengeBlock = function(modeInfo)
--     local _block = _othook._getSpecialBlock(_blockKey_Challenge)

--     -- Set Static Text Info
--     _block.titleLabel:Hide()
--     _block.subtitleLabel:Hide()
--     _block.descriptionLabel:Hide()

--     local _ah = 0

--     -- Set Dynamic 
--     -- Remove all old detail block
--     _block.ClearAllDetailBlock()
--     local _detailBlock = _block.GetDetailBlock()
--     _detailBlock.showDetail = true
--     if modeInfo.level ~= nil then
--         _detailBlock.SetText(modeInfo.level)
--     else
--         _detailBlock.SetText(modeInfo.currentWave.."/"..modeInfo.maxWave)
--     end

--     _detailBlock.showProgress = true
--     _detailBlock.SetProgressValue(GetTime() - modeInfo.elapsedTime, 0, modeInfo.timeLimit)
--     _detailBlock.progressBar.timer:StartTimer()

--     _block.detailBlocks:push_back(_detailBlock)
--     local _dh = _detailBlock.Resize()
--     _detailBlock:ClearAllPoints()
--     _detailBlock:SetPoint("TOPLEFT", _block, "TOPLEFT", 0, -_ah)
--     _ah = _ah + _dh

--     _block:SetHeight(_ah)
-- end

-- _othook._releaseChallengeBlock = function()
--     _othook._clearSpecialBlock(_blockKey_Challenge)
-- end

-- _othook.OnChallengeStart = function(event, modeInfo)
--     _othook._initializeChallengeBlock()
--     _othook._formatChallengeBlock(modeInfo)

--     -- Redisplay all left blocks
--     _othook.LeftBlocksReDisplay()
-- end

-- _othook.OnChallengeComplete = function(event, ...)
--     _othook._releaseChallengeBlock()

--     -- Redisplay all left blocks
--     _othook.LeftBlocksReDisplay()
-- end

-- -- register event
-- PushUIAPI:RegisterPUIEvent(
--     PushUIAPI.PUSHUIEVENT_CHALLENGE_MODE_START, 
--     "othook_challenge_mode_start",
--     _othook.OnChallengeStart)
-- PushUIAPI:RegisterPUIEvent(
--     PushUIAPI.PUSHUIEVENT_CHALLENGE_MODE_STOP, 
--     "othook_challenge_mode_stop", 
--     _othook.OnChallengeComplete)

-- -- Bonus Quest
-- _othook._initializeBonusQuestBlock = function()
--     _othook._initializeSpecialBlock(_blockKey_Bonus)
-- end

-- _othook._formatBonusQuestBlock = function(bonusQuest)
--     local _block = _othook._getSpecialBlock(_blockKey_Bonus)

--     -- Set Static Text Info
--     _block.titleLabel.SetTextString(bonusQuest.taskName)
--     _block.subtitleLabel:Hide()
--     _block.descriptionLabel:Hide()

--     local _ah = 0
--     _block.titleLabel:ClearAllPoints()
--     _block.titleLabel:SetPoint("TOPLEFT", _block, "TOPLEFT", 0, -_ah)
--     local _th = _block.titleLabel:GetHeight()
--     _ah = _ah + _th

--     -- Set Dynamic 
--     -- Remove all old detail block
--     _block.ClearAllDetailBlock()

--     local _ds = bonusQuest.numObjectives
--     for i = 1, _ds do
--         local _objective = bonusQuest.objectives[i]
--         local _detailBlock = _block.GetDetailBlock()    -- Get an empty detail block
--         -- Always show detail info
--         _detailBlock.showDetail = true
--         _detailBlock.SetText(_objective.title)
--         _detailBlock.showProgress = _objective.showProgressBar
--         if _objective.showProgressBar then
--             _detailBlock.SetProgressValue(_objective.percentage, 0, 100)
--             _detailBlock.SetProgressText(_objective.percentage.."%")
--         end
--         local _dh = _detailBlock.Resize()
--         _block.detailBlocks:push_back(_detailBlock)

--         _detailBlock:ClearAllPoints()
--         _detailBlock:SetPoint("TOPLEFT", _block, "TOPLEFT", 0, -_ah)
--         _ah = _ah + _dh
--     end

--     _block:SetHeight(_ah)
-- end

-- _othook._releaseBonusQuestBlock = function()
--     _othook._clearSpecialBlock(_blockKey_Bonus)
-- end

-- _othook.OnBonusQuestStartWatching = function(event, bonusQuest)
--     _othook._initializeBonusQuestBlock()
--     _othook._formatBonusQuestBlock(bonusQuest)

--     -- Redisplay all left blocks
--     _othook.LeftBlocksReDisplay()
-- end

-- _othook.OnBonusQuestStopWatching = function(event, ...)
--     _othook._releaseBonusQuestBlock()

--     -- Redisplay all left blocks
--     _othook.LeftBlocksReDisplay()
-- end

-- _othook.OnBonusQuestUpdate = function(event, bonusQuest)
--     _othook._formatBonusQuestBlock(bonusQuest)

--     -- Redisplay all left blocks
--     _othook.LeftBlocksReDisplay()
-- end

-- -- register event
-- PushUIAPI:RegisterPUIEvent(
--     PushUIAPI.PUSHUIEVENT_BONUS_QUEST_STARTWATCHING, 
--     "othook_bonus_quest_start_watching",
--     _othook.OnBonusQuestStartWatching)
-- PushUIAPI:RegisterPUIEvent(
--     PushUIAPI.PUSHUIEVENT_BONUS_QUEST_UPDATE, 
--     "othook_bonus_quest_update", 
--     _othook.OnBonusQuestUpdate)
-- PushUIAPI:RegisterPUIEvent(
--     PushUIAPI.PUSHUIEVENT_BONUS_QUEST_STOPWATCHING,
--     "othook_bonus_quest_stop_watching",
--     _othook.OnBonusQuestStopWatching)

-- -- Bonus Quest
-- _othook._initializeWorldQuestBlock = function(blockKey)
--     _othook._initializeSpecialBlock(blockKey)
-- end

-- _othook._formatWorldQuestBlock = function(blockKey, worldQuest)
--     local _block = _othook._getSpecialBlock(blockKey)

--     -- Set Static Text Info
--     _block.titleLabel.SetTextString(worldQuest.taskName)
--     _block.subtitleLabel:Hide()
--     _block.descriptionLabel:Hide()

--     local _ah = 0
--     _block.titleLabel:ClearAllPoints()
--     _block.titleLabel:SetPoint("TOPLEFT", _block, "TOPLEFT", 0, -_ah)
--     local _th = _block.titleLabel:GetHeight()
--     _ah = _ah + _th

--     -- Set Dynamic 
--     -- Remove all old detail block
--     _block.ClearAllDetailBlock()

--     local _ds = worldQuest.numObjectives
--     for i = 1, _ds do
--         local _objective = worldQuest.objectives[i]
--         local _detailBlock = _block.GetDetailBlock()    -- Get an empty detail block
--         -- Always show detail info
--         _detailBlock.showDetail = true
--         _detailBlock.SetText(_objective.title)
--         _detailBlock.showProgress = _objective.showProgressBar
--         if _objective.showProgressBar then
--             _detailBlock.SetProgressValue(_objective.percentage, 0, 100)
--             _detailBlock.SetProgressText(_objective.percentage.."%")
--         end
--         local _dh = _detailBlock.Resize()
--         _block.detailBlocks:push_back(_detailBlock)

--         _detailBlock:ClearAllPoints()
--         _detailBlock:SetPoint("TOPLEFT", _block, "TOPLEFT", 0, -_ah)
--         _ah = _ah + _dh
--     end

--     _block:SetHeight(_ah)
-- end

-- _othook._releaseWorldQuestBlock = function(blockKey)
--     _othook._clearSpecialBlock(blockKey)
-- end

-- _othook.OnWorldQuestStartWatching = function(event, newWorldQuestList)
--     local _qs = newWorldQuestList:size()
--     for i = 1, _qs do
--         local _blockKey = _othook._worldBlockKeyGet()
--         local _quest = newWorldQuestList:objectAtIndex(i)
--         _othook._worldQuestBlockKeyMap:set(_quest.questID, _blockKey)
--         _othook._initializeWorldQuestBlock(_blockKey)
--         _othook._formatWorldQuestBlock(_blockKey, _quest)
--     end

--     -- Redisplay all left blocks
--     _othook.LeftBlocksReDisplay()
-- end

-- _othook.OnWorldQuestStopWatching = function(event, stopWatchingQuestList)

--     local _qs = stopWatchingQuestList:size()
--     for i = 1, _qs do
--         local _quest = stopWatchingQuestList:objectAtIndex(i)
--         local _blockKey = _othook._worldQuestBlockKeyMap:object(_quest.questID)
--         if _blockKey ~= nil then
--             _othook._releaseWorldQuestBlock(_blockKey)
--             _othook._worldQuestBlockKeyMap:unset(_quest.questID)
--             _othook._worldBlockKeyFree(_blockKey)
--         end
--     end

--     -- Redisplay all left blocks
--     _othook.LeftBlocksReDisplay()
-- end

-- _othook.OnWorldQuestUpdate = function(event, updatingQuestList)
    
--     local _qs = updatingQuestList:size()
--     for i = 1, _qs do
--         local _quest = updatingQuestList:objectAtIndex(i)
--         local _blockKey = _othook._worldQuestBlockKeyMap:object(_quest.questID)
--         if _blockKey ~= nil then 
--             _othook._formatWorldQuestBlock(_blockKey, _quest)
--         end
--     end

--     -- Redisplay all left blocks
--     _othook.LeftBlocksReDisplay()
-- end

-- -- register event
-- PushUIAPI:RegisterPUIEvent(
--     PushUIAPI.PUSHUIEVENT_WORLD_QUEST_STARTWATCHING, 
--     "othook_world_quest_start_watching",
--     _othook.OnWorldQuestStartWatching)
-- PushUIAPI:RegisterPUIEvent(
--     PushUIAPI.PUSHUIEVENT_WORLD_QUEST_UPDATE, 
--     "othook_world_quest_update", 
--     _othook.OnWorldQuestUpdate)
-- PushUIAPI:RegisterPUIEvent(
--     PushUIAPI.PUSHUIEVENT_WORLD_QUEST_STOPWATCHING,
--     "othook_world_quest_stop_watching",
--     _othook.OnWorldQuestStopWatching)

-- _othook._onPlayerFirstTimeEnteringWorld = function()
--     if PushUIAPI.BonusQuest.quest ~= nil then
--         _othook.OnBonusQuestStartWatching(nil, PushUIAPI.BonusQuest.quest)
--     end
--     if PushUIAPI.WorldQuest.newWatchingList:size() > 0 then
--         _othook.OnWorldQuestStartWatching(nil, PushUIAPI.WorldQuest.newWatchingList)
--     end
-- end
-- PushUIAPI:RegisterPUIEvent(
--     PushUIAPI.PUSHUIEVENT_PLAYER_FIRST_ENTERING_WORLD,
--     "othook_objective_tracker_first_entering_world",
--     _othook._onPlayerFirstTimeEnteringWorld
--     )

