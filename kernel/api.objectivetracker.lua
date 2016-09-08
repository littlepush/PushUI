local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIAPI.PUIEVENT_NORMAL_QUEST_UPDATE = "PUIEVENT_NORMAL_QUEST_UPDATE"
-- A quest can be completed or canceled, so the event is UnWatch rather then Complete
PushUIAPI.PUIEVENT_NORMAL_QUEST_UNWATCH = "PUIEVENT_NORMAL_QUEST_UNWATCH"
PushUIAPI.PUIEVENT_NORMAL_QUEST_NEWWATCH = "PUSHUIEVENT_NORMAL_QUEST_NEWWATCH"

PushUIAPI.NormalQuests = {}
PushUIAPI.NQ = PushUIAPI.NormalQuests		-- alias
PUI_NQ = PushUIAPI.NQ						-- alias

PushUIAPI.NormalQuests.questList = PushUIAPI.Vector.New()
PushUIAPI.NormalQuests.unWatchList = PushUIAPI.Vector.New()
PushUIAPI.NormalQuests.newWatchList = PushUIAPI.Vector.New()
PushUIAPI.NormalQuests.updatedList = PushUIAPI.Vector.New()

PushUIAPI.NormalQuests._gainQuestList = function()
	local _puiqlist = PushUIAPI.NormalQuests.questList
	local _puiCmptlist = PushUIAPI.NormalQuests.unWatchList
	local _puiAcptlist = PushUIAPI.NormalQuests.newWatchList
	local _puiupdtlist = PushUIAPI.NormalQuests.updatedList
	_puiCmptlist.Clear()
	_puiAcptlist.Clear()
	_puiupdtlist.Clear()
    -- 1: questID, 2: title, 3: questLogIndex, 4: numObjectives, 
    -- 5: requiredMoney, 6: isComplete, 7: startEvent, 8: isAutoComplete, 
    -- 9: failureTime, 10: timeElapsed, 11: questType, 12: isTask, 
    -- 13: isBounty, 14: isStory, 15: isOnMap, 16: hasLocalPOI
    local _nq = GetNumQuestWatches()
    local _qlist = PushUIAPI.Vector.New()
    for i = 1, _nq do
        repeat 
            local _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16 = GetQuestWatchInfo(i)
            if _1 == nil or _2 == nil then break end
            local _q = {
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
                hasLocalPOI = _16,
				objList = {},
				objCompleteCount = 0
            }
            _qlist.PushBack(_q)

			-- the quest has objective list
			if nil ~= _4 and _4 > 0 then
				for oi = 1, _4 do
					local _o1, _o2, _o3 = GetQuestLogLeaderBoard(oi, _3)
					local _qo = {
						obj_text = _o1, 
						obj_type = _o2,
						obj_finished = _o3
					}
					_q.objList[oi] = _qo
					if _o3 then _q.objCompleteCount = _q.objCompleteCount + 1 end
				end
			end

			local _containsInOldList = _puiqlist.Search(_1, function(obj, qid)
				return obj.questID == qid
			end)
			if _containsInOldList == 0 then
				-- This is a new accepted quest
				_puiAcptlist.PushBack(_q)
			else
				-- Still in old list, check if has something different things
				-- We only care about the completed objectives count
				local _oldq = _puiqlist.ObjectAtIndex(_containsInOldList)
				if _oldq.isComplete ~= _q.isComplete then
					-- New quest has completed
					_puiupdtlist.PushBack(_q)
				elseif _oldq.objCompleteCount ~= _q.objCompleteCount then
					-- Finish some new objectcive
					_puiupdtlist.PushBack(_q)
				end
			end
        until true
    end

	local _oldQc = _puiqlist.Size()
	for i = 1, _oldQc do
		local _oq = _puiqlist.ObjectAtIndex(i)
		local _containsInNewList = _qlist.Search(_oq, function(obj, oldquest)
			return obj.questID == oldquest.questID
		end)
		if _containsInNewList == 0 then
			-- Find a finished quest
			_puiCmptlist.PushBack(_oq)
		end
	end

    -- Replace the vector with new 
    PushUIAPI.NormalQuests.questList.Clear()
    PushUIAPI.NormalQuests.questList = _qlist
end

PushUIAPI.NormalQuests._updateQuestList  = function(event, ...)
	PUI_NQ._gainQuestList()
	if PUI_NQ.updatedList.Size() > 0 then
		PushUIAPI:FirePUIEvent(PushUIAPI.PUIEVENT_NORMAL_QUEST_UPDATE, PUI_NQ.updatedList)
	end
	if PUI_NQ.newWatchList.Size() > 0 then
		PushUIAPI:FirePUIEvent(PushUIAPI.PUIEVENT_NORMAL_QUEST_NEWWATCH, PUI_NQ.newWatchList)
	end
	if PUI_NQ.unWatchList.Size() > 0 then
		PushUIAPI:FirePUIEvent(PushUIAPI.PUIEVENT_NORMAL_QUEST_UNWATCH, PUI_NQ.unWatchList)
	end
end

PushUIAPI.NormalQuests._initialize = function()
	PushUIAPI.NormalQuests._gainQuestList()
	PushUIAPI.RegisterEvent("QUEST_LOG_UPDATE", PUI_NQ, PUI_NQ._updateQuestList)
	PushUIAPI.RegisterEvent("QUEST_WATCH_LIST_CHANGED", PUI_NQ, PUI_NQ._updateQuestList)
	PushUIAPI.RegisterEvent("QUEST_ACCEPTED", PUI_NQ, PUI_NQ._updateQuestList)
    PushUIAPI.RegisterEvent("SUPER_TRACKED_QUEST_CHANGED", PUI_NQ, PUI_NQ._updateQuestList)
	--PushUIAPI.RegisterEvent("QUEST_POI_UPDATE", PUI_NQ, PUI_NQ._updateQuestList)
	--PushUIAPI.RegisterEvent("ZONE_CHANGED_NEW_AREA", PUI_NQ, PUI_NQ._updateQuestList)
	--PushUIAPI.RegisterEvent("VARIABLES_LOADED", PUI_NQ, PUI_NQ._updateQuestList)
	--PushUIAPI.RegisterEvent("ZONE_CHANGED", PUI_NQ, PUI_NQ._updateQuestList)
end

-- Default to initialize the quest list
PushUIAPI.NormalQuests._initialize()


-- Scenario Quest
PushUIAPI.PUSHUIEVENT_SCENARIO_QUEST_START = "PUSHUIEVENT_SCENARIO_QUEST_START"
PushUIAPI.PUSHUIEVENT_SCENARIO_QUEST_UPDATE = "PUSHUIEVENT_SCENARIO_QUEST_UPDATE"
PushUIAPI.PUSHUIEVENT_SCENARIO_QUEST_COMPLETE = "PUSHUIEVENT_SCENARIO_QUEST_COMPLETE"

PushUIAPI.ScenarioQuest = {}
PushUIAPI.ScenarioQuest.quest = nil
PushUIAPI.ScenarioQuest._lastFireEvent = nil
PushUIAPI.ScenarioQuest._gainQuest = function()
    
    local _usually_has_scenario = (PushUIAPI.ScenarioQuest.quest ~= nil)

    PushUIAPI.ScenarioQuest.quest = nil
    local _1, _2, _3, _4, _5, _6, _7, _8, _9, _10 = C_Scenario.GetInfo()
    if not _1 or _1 == nil or 0 == _2 or 0 == _3 then
        if _usually_has_scenario then
            PushUIAPI.ScenarioQuest._lastFireEvent = PushUIAPI.PUSHUIEVENT_SCENARIO_QUEST_COMPLETE
        else
            PushUIAPI.ScenarioQuest._lastFireEvent = nil
        end
        return
    end

    -- Get Step Info
    local _name, _description, _numCriteria, _, _, _, _numSpells, _spellInfo, _weightedProgress = C_Scenario.GetStepInfo()
    local _s = {
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
        showCriteria = C_Scenario.ShouldShowCriteria(),
        stageInfo = {
            name = _name,
            description = _description,
            numCriteria = _numCriteria,
            numSpells = _numSpells,
            spellInfo = _spellInfo,
            weightedProgress = _weightedProgress,
        },
        criteriaList = {}
    }
    if _numCriteria ~= nil and _numCriteria > 0 then
        for i = 1, _numCriteria do
            -- criteriaString, criteriaType, completed, 
            -- quantity, totalQuantity, flags, assetID, 
            -- quantityString, criteriaID, duration, 
            -- elapsed, _, isWeightedProgress
            local _c1, _c2, _c3, _c4, _c5, _c6, _c7, _c8, _c9, _c10, _c11, _c12, _c13 = C_Scenario.GetCriteriaInfo(i)
            _criteria = {
                criteriaString = _c1,
                criteriaType = _c2,
                completed = _c3,
                quantity = _c4,
                totalQuantity = _c5,
                flags = _c6,
                assetID = _c7,
                quantityString = _c8,
                criteriaID = _c9,
                duration = _c10,
                elapsed = _c11,
                unknow = _c12,
                isWeightedProgress = _c13
            }
            _s.criteriaList[i] = _criteria
        end
    end

    if _usually_has_scenario then
        PushUIAPI.ScenarioQuest._lastFireEvent = PushUIAPI.PUSHUIEVENT_SCENARIO_QUEST_UPDATE
    else
        PushUIAPI.ScenarioQuest._lastFireEvent = PushUIAPI.PUSHUIEVENT_SCENARIO_QUEST_START
    end

    PushUIAPI.ScenarioQuest.quest = _s
end

PushUIAPI.ScenarioQuest._updateScenarioQuest = function(event, ...)
    PushUIAPI.ScenarioQuest._gainQuest()
    if not PushUIAPI.ScenarioQuest._lastFireEvent then return end
    -- Fire the event
    PushUIAPI:FirePUIEvent(PushUIAPI.ScenarioQuest._lastFireEvent, PushUIAPI.ScenarioQuest.quest)
end

PushUIAPI.ScenarioQuest._initialize = function()
    PushUIAPI.ScenarioQuest._gainQuest()

    PushUIAPI.RegisterEvent("CHALLENGE_MODE_START", PushUIAPI.ScenarioQuest, PushUIAPI.ScenarioQuest._updateScenarioQuest)
    PushUIAPI.RegisterEvent("SCENARIO_UPDATE", PushUIAPI.ScenarioQuest, PushUIAPI.ScenarioQuest._updateScenarioQuest)
    PushUIAPI.RegisterEvent("SCENARIO_CRITERIA_UPDATE", PushUIAPI.ScenarioQuest, PushUIAPI.ScenarioQuest._updateScenarioQuest)
    PushUIAPI.RegisterEvent("SCENARIO_SPELL_UPDATE", PushUIAPI.ScenarioQuest, PushUIAPI.ScenarioQuest._updateScenarioQuest)
    PushUIAPI.RegisterEvent("SCENARIO_COMPLETED", PushUIAPI.ScenarioQuest, PushUIAPI.ScenarioQuest._updateScenarioQuest)
    PushUIAPI.RegisterEvent("SCENARIO_CRITERIA_SHOW_STATE_UPDATE", PushUIAPI.ScenarioQuest, PushUIAPI.ScenarioQuest._updateScenarioQuest)

end

PushUIAPI.ScenarioQuest._initialize()


-- Challenge
PushUIAPI.PUSHUIEVENT_CHALLENGE_MODE_START = "PUSHUIEVENT_CHALLENGE_MODE_START"
PushUIAPI.PUSHUIEVENT_CHALLENGE_MODE_STOP = "PUSHUIEVENT_CHALLENGE_MODE_STOP"

PushUIAPI.ChallengeMode = {}
PushUIAPI.ChallengeMode.modeInfo = nil
PushUIAPI.ChallengeMode._gainModeInfo = function(...)
    PushUIAPI.ChallengeMode.modeInfo = nil
    for i = 1, select("#", ...) do
        local timerID = select(i, ...)
        local _, elapsed, _type = GetWorldElapsedTime(timerID);
        if _type == 0 then _type = LE_WORLD_ELAPSED_TIMER_TYPE_PROVING_GROUND end
        PushUIAPI.ChallengeMode.modeInfo = {
            elapsedTime = elapsed
        }
        if ( _type == LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE) then
            local _, _, _, _, _, _, _, mapID = GetInstanceInfo();
            if ( mapID ) then
                local _, _, _limit = C_ChallengeMode.GetMapInfo(mapID);
                local _level, _affixes, _wasEnergized = C_ChallengeMode.GetActiveKeystoneInfo()

                PushUIAPI.ChallengeMode.modeInfo.timeLimit = _limit
                PushUIAPI.ChallengeMode.modeInfo.level = _level
                PushUIAPI.ChallengeMode.modeInfo.affixes = _affixes
                PushUIAPI.ChallengeMode.modeInfo.wasEnergized = _wasEnergized
            end
        elseif ( _type == LE_WORLD_ELAPSED_TIMER_TYPE_PROVING_GROUND ) then
            local diffID, currWave, maxWave, duration = C_Scenario.GetProvingGroundsInfo()
            PushUIAPI.ChallengeMode.modeInfo.timeLimit = duration
            PushUIAPI.ChallengeMode.modeInfo.currentWave = currWave
            PushUIAPI.ChallengeMode.modeInfo.maxWave = maxWave
        end
    end
end
PushUIAPI.ChallengeMode._updateChallengeMode = function(event, ...)
    if event == "WORLD_STATE_TIMER_START" then
        PushUIAPI.ChallengeMode._gainModeInfo(GetWorldElapsedTimers())
        if PushUIAPI.ChallengeMode.modeInfo ~= nil then
            PushUIAPI:FirePUIEvent(PushUIAPI.PUSHUIEVENT_CHALLENGE_MODE_START, PushUIAPI.ChallengeMode.modeInfo)
        end
    else
        PushUIAPI.ChallengeMode.modeInfo = nil
        PushUIAPI:FirePUIEvent(PushUIAPI.PUSHUIEVENT_CHALLENGE_MODE_STOP)
    end
end

PushUIAPI.ChallengeMode._initialize = function()
    PushUIAPI.RegisterEvent("WORLD_STATE_TIMER_START", PushUIAPI.ChallengeMode, PushUIAPI.ChallengeMode._updateChallengeMode)
    PushUIAPI.RegisterEvent("WORLD_STATE_TIMER_STOP", PushUIAPI.ChallengeMode, PushUIAPI.ChallengeMode._updateChallengeMode)
end

PushUIAPI.ChallengeMode._initialize()


-- Push Chen
-- https://twitter.com/littlepush
--