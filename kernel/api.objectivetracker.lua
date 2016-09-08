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
			end
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
		end
		if _containsInNewList == false then
			-- Find a finished quest
			_puiCmptlist.PushBack(_oq)
		end
	end

    -- Replace the vector with new 
    PushUIAPI.NormalQuests.queueList = _qlist
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
	--PushUIAPI.RegisterEvent("QUEST_POI_UPDATE", PUI_NQ, PUI_NQ._updateQuestList)
	--PushUIAPI.RegisterEvent("ZONE_CHANGED_NEW_AREA", PUI_NQ, PUI_NQ._updateQuestList)
	--PushUIAPI.RegisterEvent("VARIABLES_LOADED", PUI_NQ, PUI_NQ._updateQuestList)
	--PushUIAPI.RegisterEvent("ZONE_CHANGED", PUI_NQ, PUI_NQ._updateQuestList)
	--PushUIAPI.RegisterEvent("SUPER_TRACKED_QUEST_CHANGED", PUI_NQ, PUI_NQ._updateQuestList)
end

-- Default to initialize the quest list
PushUIAPI.NormalQuests._initialize()


-- Scenario Quest




-- Push Chen
-- https://twitter.com/littlepush
--
