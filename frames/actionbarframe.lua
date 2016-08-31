local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))
-- Create the frame
local PushUIFrameActionBarFrame = CreateFrame("Frame", "PushUIFrameActionBarFrame", UIParent)
PushUIFrames.AllFrames[#PushUIFrames.AllFrames + 1] = PushUIFrameActionBarFrame
--table.insert(PushUIFrames.AllFrames, PushUIFrameActionBarFrame)

PushUIFrameActionBarFrame.RestoreToDefault = function()
    local f = PushUIFrameActionBarFrame
    f:SetWidth(PushUISize.FormatWithPadding(
        PushUISize.actionButtonPerLine,
        PushUISize.actionButtonSize * PushUISize.Resolution.scale,
        PushUISize.actionButtonPadding * PushUISize.Resolution.scale
        ))
    f:SetHeight(PushUISize.FormatWithPadding(
        3, 
        PushUISize.actionButtonSize * PushUISize.Resolution.scale,
        PushUISize.actionButtonPadding * PushUISize.Resolution.scale
        ))    
    f:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, PushUISize.screenBottomPadding)
    PushUIConfig.ActionBarGridValidate = false
end

PushUIFrameActionBarFrame.ReSize = function()
    print("Resize for PushUIFrameActionBarFrame")

    local f = PushUIFrameActionBarFrame

    local col, row = unpack(PushUIConfig.ActionBarGrid)
    if not (row == #PushUIConfig.ActionBarGridLayout) then
        print("the setting of the action bar grid is not validate, restore to default")
        return f.RestoreToDefault()
    end

    local calculated_actions = {}
    for _,layout in pairs(PushUIConfig.ActionBarGridLayout) do
        if not (#layout == col) then
            print("the setting of the action bar grid is not valildate, restore to default")
            return f.RestoreToDefault()
        end    

        for _,btnId in pairs(layout) do
            repeat
                if btnId == "" then break end
                if not calculated_actions[btnId] then
                    calculated_actions[btnId] = 0
                end
                calculated_actions[btnId] = calculated_actions[btnId] + 1
            until true
        end
    end
    local min_size = 9999999
    for _,s in pairs(calculated_actions) do
        if s < min_size then min_size = s end
    end

    local p = PushUISize.actionButtonPadding
    local placed_actions = {}
    local _maxWidth = 0
    for r=1,row do
        local _last = ""
        local _scale = 0
        local _x = p
        for c=1,col do
            local bn = PushUIConfig.ActionBarGridLayout[r][c]

            -- Calculate the scale of the button
            if bn == _last then _scale = _scale + 1
            else _scale = 1 end

            -- If the layout item is the last of current button, then
            -- calculate the size of the button(width)
            if (c == col) or (not (bn == PushUIConfig.ActionBarGridLayout[r][c + 1])) then
                -- last one
                if not placed_actions[bn] then
                    local c = (_scale / min_size)
                    w = c * PushUISize.actionButtonSize + (c - 1) * p
                    placed_actions[bn] = {_x, 0, w, w}
                    _x = _x + w + p
                else
                    local x,y,w,h = unpack(placed_actions[bn])
                    _x = _x + w + p
                end
                _scale = 0
            end

            _last = bn
        end

        if _x > _maxWidth then
            _maxWidth = _x
        end
    end

    -- Get the height of each button
    local _maxHeight = 0
    for c=1,col do
        local _last = ""
        local _scale = 0
        local _y = p
        for r=1,row do
            local bn = PushUIConfig.ActionBarGridLayout[r][c]

            if bn == _last then _scale = _scale + 1
            else _scale = 1 end

            if (r == row) or (not (bn == PushUIConfig.ActionBarGridLayout[r + 1][c])) then
                -- last one
                local x,y,w,h = unpack(placed_actions[bn])
                local c = (_scale / min_size)
                h = c * PushUISize.actionButtonSize + (c - 1) * p
                y = _y
                placed_actions[bn] = {x,y,w,h}

                _y = _y + h + p
                _scale = 0
            end
            _last = bn
        end
        if _y > _maxHeight then
            _maxHeight = _y
        end
    end

    -- Save the cood
    PushUIConfig.ActionBarGridPlacedCood = placed_actions
    PushUIConfig.ActionBarGridValidate = true

    f:SetWidth(_maxWidth * PushUISize.Resolution.scale * PushUIConfig.ActionBarGridScale)
    f:SetHeight(_maxHeight * PushUISize.Resolution.scale * PushUIConfig.ActionBarGridScale)
    f:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, PushUISize.screenBottomPadding)
end

PushUIFrameActionBarFrame.Init = function(...)
    local f = PushUIFrameActionBarFrame
    PushUIConfig.skinType(f)
    f.ReSize()
end

PushUIFrameActionBarFrame.Init()
