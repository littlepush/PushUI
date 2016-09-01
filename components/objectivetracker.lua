local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local PushUIFramesObjectiveTrackerHook = {}
local OTH = PushUIFramesObjectiveTrackerHook
OTH.name = "PushUIFramesObjectiveTrackerHook"
local _quests = {}
local _bonus = {}
OTH.quests = _quests
OTH.bonus = _bonus

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

    block:EnableMouse(true)
    block:SetScript("OnMouseDown", function(self, ...)
        OTH._openQuestOnMap(self)
    end)
end

OTH._formatBlock = function(block)
    local _quest = block.quest
    local _finishCount = 0
    if _quest.numObjectives > 0 then
        for i = 1, _quest.numObjectives do
            local _, _, finished = GetQuestLogLeaderBoard(i, _quest.questLogIndex);
            if finished then
                _finishCount = _finishCount + 1
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
end

OTH._blocks = {}
OTH._showQuest = function(event, ...)
    if event then
        print("ShowQuest: "..event)
    end
    local _qc = #_quests
    local _bc = #OTH._blocks

    for i = 1, _qc do
        local _blockFrame = nil
        if i <= _bc then
            _blockFrame = OTH._blocks[i]
        else
            _blockFrame = CreateFrame("Frame", OTH.name.."Block"..i, UIParent)
            OTH._initBlock(_blockFrame)
            OTH._blocks[i] = _blockFrame
            _bc = _bc + 1
        end
        _blockFrame.quest = _quests[i]
        _blockFrame:ClearAllPoints()
        OTH._formatBlock(_blockFrame)
        _blockFrame:Show()
        _blockFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -(i - 1) * 28 - 30)
    end

    if _qc < _bc then
        for i = _qc + 1, _bc do
            OTH._blocks[i]:Hide()
        end
    end
end
OTH._bonusBlock = nil

-- Hide objective tracker
ObjectiveTrackerFrame:SetScript("OnShow", ObjectiveTrackerFrame.Hide)
ObjectiveTrackerFrame:Hide()

OTH._onUpdate = function()
    OTH._gainQuest()
    OTH._showQuest()
end

OTH._onUpdate()

PushUIAPI.RegisterEvent("QUEST_LOG_UPDATE", OTH, OTH._onUpdate)
PushUIAPI.RegisterEvent("QUEST_WATCH_LIST_CHANGED", OTH, OTH._onUpdate)
PushUIAPI.RegisterEvent("QUEST_ACCEPTED", OTH, OTH._onUpdate)
PushUIAPI.RegisterEvent("QUEST_AUTOCOMPLETE", OTH, OTH._onUpdate)
--PushUIAPI.RegisterEvent("QUEST_POI_UPDATE", OTH, OTH._onUpdate)
--PushUIAPI.RegisterEvent("QUEST_TURNED_IN", OTH, OTH._onUpdate)
PushUIAPI.RegisterEvent("ZONE_CHANGED_NEW_AREA", OTH, OTH._onUpdate)
--PushUIAPI.RegisterEvent("ZONE_CHANGED", OTH, OTH._onUpdate)
