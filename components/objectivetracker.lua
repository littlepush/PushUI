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
        width = 160,
        padding = 7,
        hideInCombat = true,
        objectiveFontSize = 12,
        outline = "OUTLINE",
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
            end, 
            function(ohv)
                ohv:set_hidden(true)
            end)
    end
    )
PushUIAPI.EventCenter:RegisterEvent(
    PushUIAPI.PUSHUIEVENT_PLAYER_END_COMBAT,
    "ObjectiveHookViewDisplayAnimation",
    function(...)
        _objHookView:set_hidden(false)
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
function PUIQuestProgressBar:c_str()
    self.label = PushUIFrames.UILabel(self)
end
function PUIQuestProgressBar:initialize()
    self:set_width(_config.width - 2 * _config.padding)
    self:set_height(_lineHeight)
    self:set_backgroundColor(PushUIColor.black)
    self:set_barColor(PushUIColor.blue)
    self:set_archor("TOPLEFT")
    -- Default style
    self:set_style("h-l-r")

    -- Label
    self.label:set_fontcolor(PushUIColor.white)
    self.label:set_fontflag(_config.outline)
    self.label:set_fontsize(_config.objectiveFontSize)
    self.label:set_align("CENTER")
    self.label:set_width(self:width())
    self.label:set_height(_lineHeight)
    self.label:set_position()
end
function PUIQuestProgressBar:update_currentValue(value, max)
    max = max or self.max()
    self:set_max(max)
    self:set_value(value)
    self.label:set_text(("%.1f"):format((value / max) * 100).."%")
end

-- Timer
local PUIQuestTimer = PushUIAPI.inhiert(PushUIFrames.UIProgressBar)
function PUIQuestTimer:c_str()
    self.label = PushUIFrames.UILabel(self)
end
function PUIQuestTimer:initialize()
    self:set_width(_config.width - 2 * _config.padding)
    self:set_height(_lineHeight)
    self:set_backgroundColor(PushUIColor.black)
    self:set_barColor(PushUIColor.blue)
    self:set_archor("TOPLEFT")
    -- Default style
    self:set_style("h-l-r")

    -- Label
    self.label:set_fontcolor(PushUIColor.white)
    self.label:set_fontflag(_config.outline)
    self.label:set_fontsize(_config.objectiveFontSize)
    self.label:set_align("CENTER")
    self.label:set_width(self:width())
    self.label:set_height(_lineHeight)
    self.label:set_position()

    -- Timer
    self._countdownTimer = PushUIAPI.Timer(1, self, function(qt)
        if qt:value() == 0 then return end
        qt:reduce_value()
        qt.label:set_text(PushUIAPI.DurationFormat(qt:value()))
    end)
end
function PUIQuestTimer:begin_countdown(now, duration)
    self:set_max(duration)
    self:set_value(now)
    self._countdownTimer:start()
end
function PUIQuestTimer:end_countdown()
    self._countdownTimer:stop()
end

-- Objective Label Stack
local _objPool = PushUIAPI.Pool(function()
    return PUIQuestObjLabel()
end)
local _pbPool = PushUIAPI.Pool(function()
    return PUIQuestProgressBar()
end)
local _qtPool = PushUIAPI.Pool(function()
    return PUIQuestTimer()
end)

-- Detail Block
local PUIQuestDetailPanel = PushUIAPI.inhiert(PushUIFrames.UIView)
function PUIQuestDetailPanel:initialize()
    self._objs = PushUIAPI.Array()
    self._dobjs = PushUIAPI.Array()
    self._pobjs = PushUIAPI.Array()
    self._tobjs = PushUIAPI.Array()

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
    _pb:update_currentValue(value, max)

    _pb:set_archor_target(self, "TOPLEFT")
    self._pobjs:push_back(_pb)
    self._objs:push_back(_pb)
end
function PUIQuestDetailPanel:add_detail_timer(now, duration)
    local _qt = _qtPool:get()
    _qt:set_hidden(false)
    _qt:set_archor_target(self, "TOPLEFT")
    self._tobjs:push_back(_qt)
    self._objs:push_back(_qt)

    _qt:begin_countdown(now, duration)
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
    self._tobjs:for_each(function(index, qt)
        qt:end_countdown()
        qt:set_hidden(true)
        _qtPool:release(qt)
    end)
    self._tobjs:clear()    

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
    if quest.isComplete and quest.isAutoComplete then
        QuestMapFrame_OpenToQuestDetails(quest.questID)
    end

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
    self.description:set_padding(_textPadding)
    self.description:set_position()

    -- Detail Panel
    self.detail:set_archor_target(self.layer, "BOTTOMLEFT")
    self.detail:set_position(0, -_config.padding)
end

function PUISpecialBlock:displayHeight() return self._displayHeight end

function PUISpecialBlock:set_infomation(title, subtitle, description)
    self.title:set_text(title)
    self.subtitle:set_text(subtitle)
    self.description:set_text(description)

end

function PUISpecialBlock:add_detail_text(text, finished)
    self.detail:add_detail_text(text, finished)
end

function PUISpecialBlock:add_detail_progress(value, max)
    self.detail:add_detail_progress(value, max)
end

function PUISpecialBlock:add_detail_timer(now, duration)
    self.detail:add_detail_timer(now, duration)
end

function PUISpecialBlock:autoResize()
    -- Redraw all parts
    -- title
    -- subtitle
    self.subtitle:set_position()
    -- description
    self.description:set_position()

    local _height = self.title:height() + self.subtitle:height() + self.description:height()
    self:set_height(_height)

    -- detail panel
    self.detail:set_position()
    self.detail:autoResize()

    self._displayHeight = (_height + self.detail:height() + _config.padding)
end

function PUISpecialBlock:recycle()
    self.detail:recycle()
end

-- Left Parts
local _leftDisplayingBlocks = PushUIAPI.Map()
local __leftBlockAllHeight = 0
local function _redrawLeftBlockParts()
    local _allHeight = 30
    _leftDisplayingBlocks:for_each(function(k, block)
        block:autoResize()
        block:set_position(25, -_allHeight)
        _allHeight = _allHeight + block:displayHeight() + _config.padding
    end)
end

-- Special Block Pool
local _sbPool = PushUIAPI.Pool(function() return PUISpecialBlock() end)

-- Scenario Block
local _scenarioBlock = _sbPool:get()
_scenarioBlock:set_hidden(true)
local function eventHandler_scenarioUpdate(_, squest)
    _scenarioBlock:recycle()
    local _title = squest.scenarioName
    if squest.numStages ~= nil then
        _title = _title..squest.currentStage.."/"..squest.numStages
    end
    _scenarioBlock:set_infomation(
        _title,
        squest.stageInfo.name, 
        squest.stageInfo.description
    )
    local _dc = #squest.criteriaList
    for i = 1, _dc do
        local _criteria = squest.criteriaList[i]
        if _criteria.isWeightedProgress then
            _scenarioBlock:add_detail_progress(_criteria.quantity, 100)
        elseif _criteria.duration > 0 then
            _scenarioBlock:add_detail_timer(_criteria.duration - _criteria.elapsed, _criteria.duration)
        else
            _scenarioBlock:add_detail_text("-- ".._criteria.quantity.."/".._criteria.totalQuantity.." ".._criteria.criteriaString)
        end
    end
    _redrawLeftBlockParts()
end
local function eventHandler_scenarioStart(_, squest)
    _scenarioBlock:set_hidden(false)
    _leftDisplayingBlocks:set("SCENARIO_BLOCK", _scenarioBlock)
    eventHandler_scenarioUpdate(nil, squest)
end
local function eventHandler_scenarioComplete(...)
    _scenarioBlock:set_hidden(true)
    _leftDisplayingBlocks:unset("SCENARIO_BLOCK")
    _scenarioBlock:recycle()
    _redrawLeftBlockParts()
end
if PushUIAPI.ScenarioQuest.quest then
    eventHandler_scenarioStart(nil, PushUIAPI.ScenarioQuest.quest)
end

-- register event
PushUIAPI.EventCenter:RegisterEvent(
    PushUIAPI.PUSHUIEVENT_SCENARIO_QUEST_START, 
    "sq_start",
    eventHandler_scenarioStart)
PushUIAPI.EventCenter:RegisterEvent(
    PushUIAPI.PUSHUIEVENT_SCENARIO_QUEST_UPDATE, 
    "sq_update", 
    eventHandler_scenarioUpdate)
PushUIAPI.EventCenter:RegisterEvent(
    PushUIAPI.PUSHUIEVENT_SCENARIO_QUEST_COMPLETE, 
    "sq_complete", 
    eventHandler_scenarioComplete)

-- Challenge Mode
local _challengeBlock = _sbPool:get()
_challengeBlock:set_hidden(true)
local function eventHandler_challengeUpdate(_, cquest)
    _challengeBlock:recycle()
    _challengeBlock:set_infomation(
        GetMapNameByID(GetCurrentMapAreaID()),
        "Challenge Mode",
        "Finish the challenge"
        )

    if cquest.level ~= nil then
        _challengeBlock:add_detail_text("LV: "..cquest.level)
    else
        _challengeBlock:add_detail_text("Wave "..cquest.currentWave.." of total "..cquest.maxWave)
    end

    _challengeBlock:add_detail_timer(cquest.timeLimit - cquest.elapsedTime, cquest.timeLimit)
    _redrawLeftBlockParts()
end
local function eventHandler_challengeStart(_, cquest)
    _challengeBlock:set_hidden(false)
    _leftDisplayingBlocks:set("CHALLENGE_BLOCK", _challengeBlock)
    eventHandler_challengeUpdate(nil, cquest)
end
local function eventHandler_challengeComplete(...)
    _challengeBlock:set_hidden(true)
    _leftDisplayingBlocks:unset("CHALLENGE_BLOCK")
    _challengeBlock:recycle()
    _redrawLeftBlockParts()
end

if PushUIAPI.ChallengeMode.modeInfo then
    eventHandler_challengeStart(nil, PushUIAPI.ChallengeMode.modeInfo)
end

-- register event
PushUIAPI.EventCenter:RegisterEvent(
    PushUIAPI.PUSHUIEVENT_CHALLENGE_MODE_START, 
    "cq_start",
    eventHandler_challengeStart)
PushUIAPI.EventCenter:RegisterEvent(
    PushUIAPI.PUSHUIEVENT_CHALLENGE_MODE_STOP, 
    "cq_stop", 
    eventHandler_challengeComplete)

-- Bonus Quest
local _bonusBlock = _sbPool:get()
_bonusBlock:set_hidden(true)
local function eventHanlder_bonusUpdate(_, bquest)
    _bonusBlock:recycle()
    _bonusBlock:set_infomation(
        bquest.taskName,
        GetMapNameByID(GetCurrentMapAreaID()),
        "Bonus quest"
        )

    local _oc = bquest.numObjectives
    for i = 1, _oc do
        local _obj = bquest.objectives[i]
        _bonusBlock:add_detail_text(_obj.title)
        if _obj.showProgressBar then
            _bonusBlock:add_detail_progress(_obj.percentage, 100)
        end
    end
    _redrawLeftBlockParts()
end
local function eventHanlder_bonusStart(_, bquest)
    _bonusBlock:set_hidden(false)
    _leftDisplayingBlocks:set("BONUSE_BLOCK", _bonusBlock)
    eventHanlder_bonusUpdate(nil, bquest)
end
local function eventHanlder_bonusEnd(_, bquest)
    _bonusBlock:set_hidden(true)
    _leftDisplayingBlocks:unset("BONUSE_BLOCK")
    _bonusBlock:recycle()
    _redrawLeftBlockParts()
end

if PushUIAPI.BonusQuest.quest then
    eventHanlder_bonusStart(nil, PushUIAPI.BonusQuest.quest)
end

-- register event
PushUIAPI.EventCenter:RegisterEvent(
    PushUIAPI.PUSHUIEVENT_BONUS_QUEST_STARTWATCHING, 
    "bq_start",
    eventHanlder_bonusStart)
PushUIAPI.EventCenter:RegisterEvent(
    PushUIAPI.PUSHUIEVENT_BONUS_QUEST_UPDATE, 
    "bq_update", 
    eventHanlder_bonusUpdate)
PushUIAPI.EventCenter:RegisterEvent(
    PushUIAPI.PUSHUIEVENT_BONUS_QUEST_STOPWATCHING,
    "bq_end",
    eventHanlder_bonusEnd)

-- World Quest
local function eventHandler_worldquestUpdate(_, array)
    array:for_each(function(_, wquest)
        local _key = "WORLDQUEST_BLOCK_"..wquest.questID
        local _wblock = _leftDisplayingBlocks:object(_key)
        _wblock:recycle()
        _wblock:set_infomation(
            wquest.taskName,
            GetMapNameByID(GetCurrentMapAreaID()),
            "World Quest"
        )
        local _dc = wquest.numObjectives
        for i = 1, _dc do
            local _obj = wquest.objectives[i]
            _wblock:add_detail_text(_obj.title)
            if _obj.showProgressBar then
                _wblock:add_detail_progress(_obj.percentage, 100)
            end
        end
    end)
    _redrawLeftBlockParts()
end

local function eventHandler_worldquestStart(_, array)
    array:for_each(function(_, wquest)
        local _wblock = _sbPool:get()
        _wblock:set_hidden(false)
        _leftDisplayingBlocks:set("WORLDQUEST_BLOCK_"..wquest.questID, _wblock)
    end)
    eventHandler_worldquestUpdate(nil, array)
end

local function eventHandler_worldquestComplete(_, array)
    array:for_each(function(_, wquest)
        local _key = "WORLDQUEST_BLOCK_"..wquest.questID
        local _wblock = _leftDisplayingBlocks:object(_key)
        _wblock:recycle()
        _leftDisplayingBlocks:unset(_key)
        _wblock:set_hidden(true)
        _sbPool:release(_wblock)
    end)
    _redrawLeftBlockParts()
end

if PushUIAPI.WorldQuest.newWatchingList:size() > 0 then
    eventHandler_worldquestStart(nil, PushUIAPI.WorldQuest.newWatchingList)
end

-- register event
PushUIAPI.EventCenter:RegisterEvent(
    PushUIAPI.PUSHUIEVENT_WORLD_QUEST_STARTWATCHING, 
    "wq_start",
    eventHandler_worldquestStart)
PushUIAPI.EventCenter:RegisterEvent(
    PushUIAPI.PUSHUIEVENT_WORLD_QUEST_UPDATE, 
    "wq_update", 
    eventHandler_worldquestUpdate)
PushUIAPI.EventCenter:RegisterEvent(
    PushUIAPI.PUSHUIEVENT_WORLD_QUEST_STOPWATCHING,
    "wq_complete",
    eventHandler_worldquestComplete)
