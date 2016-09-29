local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

-- Size Setting --

-- Default Padding for all items
PushUISize.padding = 5

-- Default block height
PushUISize.blockNormalHeight = 150

-- Default block width
PushUISize.blockNormalWidth = 210

-- Tiny Button Width and Height
PushUISize.tinyButtonWidth = 5
PushUISize.tinyButtonHeight = (PushUISize.blockNormalHeight - PushUISize.padding) / 2

-- Default Action Button Size Info
PushUISize.actionButtonSize = 34
PushUISize.actionButtonPerLine = 12
PushUISize.actionButtonPadding = 2

-- Bottom Padding
PushUISize.screenBottomPadding = 25

-- Size Calculate
PushUISize.FormatWithPadding = function(count, size, padding, max)
    local _s = PushUISize.blockNormalWidth
    local _p = PushUISize.padding

    if size then _s = size end
    if padding then _p = padding end

    local _all = _p + (_s + _p) * count
    if not max then return _all end
    if _all <= max then 
        return _all
    else
        return max
    end
end

-- Color --
function PushUIColor.unpackColor(color_pack, alpha)
    local _r, _g, _b, _a = unpack(color_pack)
    if nil == _r then _r = 0 end
    if nil == _g then _g = 0 end
    if nil == _b then _b = 0 end
    if nil == _a then _a = 1 end
    if nil ~= alpha then _a = alpha end
    return _r, _g, _b, _a
end

PushUIColor.black = {0, 0, 0}
PushUIColor.white = {1, 1, 1}
PushUIColor.red = {0.89, 0.25, 0.20}
PushUIColor.blue = {0.26, 0.49, 0.91}
PushUIColor.green = {0.49, 0.82, 0.29}
PushUIColor.yellow = {0.82, 0.85, 0.46}
PushUIColor.orange = {0.84, 0.55, 0.17}
PushUIColor.gray = {0.4, 0.4, 0.4}
PushUIColor.darkgray = {0.2, 0.2, 0.2}
PushUIColor.silver = {0.8, 0.8, 0.8}
PushUIColor.cyan = {0.14, 0.16, 0.19}
PushUIColor.purple = {0.82, 0.47, 0.69}

-- Alpha for different statue
PushUIColor.alphaAvailable = 0.9
PushUIColor.alphaDim = 0.3

PushUIColor.classColor = {
    ["DEATHKNIGHT"] = {r = 0.77, g = 0.12, b = 0.23},
    ["DEMONHUNTER"] = {r = 0.64, g = 0.19, b = 0.79},
    ["DRUID"] = {r = 1, g = 0.49, b = 0.04},
    ["HUNTER"] = {r = 0.58, g = 0.86, b = 0.49},
    ["MAGE"] = {r = 0, g = 0.76, b = 1},
    ["MONK"] = {r = 0.0, g = 1.00 , b = 0.59},
    ["PALADIN"] = {r = 1, g = 0.22, b = 0.52},
    ["PRIEST"] = {r = 0.8, g = 0.87, b = .9},
    ["ROGUE"] = {r = 1, g = 0.91, b = 0.2},
    ["SHAMAN"] = {r = 0, g = 0.6, b = 0.6},
    ["WARLOCK"] = {r = 0.6, g = 0.47, b = 0.85},
    ["WARRIOR"] = {r = 0.9, g = 0.65, b = 0.45},
}
PushUIColor.getColorByClass = function(unit)
    local r, g, b = 1, 1, 1

    if UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        local _c = PushUIColor.classColor[class or "WARRIOR"]
        r, g, b = _c.r, _c.g, _c.b
    elseif (not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) or UnitIsDead(unit) then
        r, g, b = .6, .6, .6
    else
        r, g, b = unpack(PushUIColor.green)
    end
    return r, g, b
end

-- Life Color
PushUIColor.lifeColorDynamic = function(v, max, min)
    local _p = v / (max - min) * 100;
    local _r, _g, _b;
    if _p >= 70 then
        _r, _g, _b = unpack(PushUIColor.green)
    elseif _p >= 35 and _p < 70 then
        _r, _g, _b = unpack(PushUIColor.orange)
    else
        _r, _g, _b = unpack(PushUIColor.red)
    end
    return {_r, _g, _b, 1}
end

PushUIColor.__gradientDeltaGreen = PushUIColor.green[2] - PushUIColor.red[2]
PushUIColor.__gradientDeltaRed = PushUIColor.red[1] - PushUIColor.green[1]
PushUIColor.__gradientNormalBlue = 0.25
PushUIColor.lifeColorGradient = function(v, max, min)
	local _p = v / (max - min)
	local _r = PushUIColor.green[1] + PushUIColor.__gradientDeltaRed * (1 - _p)
	local _g = PushUIColor.red[2] + PushUIColor.__gradientDeltaGreen * _p
	return {_r, _g, PushUIColor.__gradientNormalBlue, 1}
end

PushUIColor.expColorDynamic = function(v, max, min)
    local restXP = GetXPExhaustion()
    if restXP then
        return {0.07, 0.42, 0.95, 1}
    else
        return {0.68, 0.47, 0.85, 1}
    end
end

PushUIColor.factionColors = {
    [1] = {170/255, 70/255, 70/255},
    [2] = {170/255, 70/255, 70/255},
    [3] = {170/255, 70/255, 70/255},
    [4] = {200/255, 180/255, 100/255},
    [5] = {75/255, 175/255, 75/255},
    [6] = {75/255, 175/255, 75/255},
    [7] = {75/255, 175/255, 75/255},
    [8] = {155/255, 255/255, 155/255}
}

PushUIColor.factionColorDynamic = function(v, max, min)
    local r = PushUIAPI.WatchedFactionInfo.rank
    return {PushUIColor.factionColors[r][1], PushUIColor.factionColors[r][2],
            PushUIColor.factionColors[r][3], 1}
end

-- Style --
PushUIStyle.TextureClean = "Interface\\ChatFrame\\ChatFrameBackground"
PushUIStyle.ColorfulTexture = function(texture, r, g, b, a)
    texture:SetTexture(PushUIStyle.TextureClean)
    texture:SetVertexColor(r, g, b, a)
end
PushUIStyle.BackdropSolid = {
    bgFile = PushUIStyle.TextureClean,
    edgeFile = PushUIStyle.TextureClean,
    tile = true,
    tileSize = 100,
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0}
}
PushUIStyle.BackdropHollow = {
    edgeFile = PushUIStyle.TextureClean,
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0}
}
PushUIStyle.BackdropOutline = {
    bgFile = PushUIStyle.TextureClean,
    edgeFile = PushUIStyle.TextureClean,
    tile = true,
    tileSize = 100,
    edgeSize = 1,
    insets = { left = -1, right = -1, top = -1, bottom = -1}
}

PushUIStyle.BackgroundFormat = function(
    frame, backdrop, bR, bG, bB, bA, bbR, bbG, bbB, bbA
)
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(bR, bG, bB, bA)
    frame:SetBackdropBorderColor(bbR, bbG, bbB, bbA)
end

PushUIStyle.BackgroundSolidFormat = function(
    frame, bR, bG, bB, bA, bbR, bbG, bbB, bbA
)
    frame:SetBackdrop(PushUIStyle.BackdropSolid)
    frame:SetBackdropColor(bR, bG, bB, bA)
    frame:SetBackdropBorderColor(bbR, bbG, bbB, bbA)
end
PushUIStyle.BackgroundHollowFormat = function(
    frame, bbR, bbG, bbB, bbA
)
    frame:SetBackdrop(PushUIStyle.BackdropHollow)
    frame:SetBackdropBorderColor(bbR, bbG, bbB, bbA)
end
PushUIStyle.BackgroundGradientFormat = function(
    frame, 
    bSR, bSG, bSB, bSA, 
    bER, bEG, bEB, bEA, 
    bbR, bbG, bbB, bbA
)
    local _t = frame:CreateTexture(nil, "BACKGROUND")
    _t:SetTexture(PushUIStyle.TextureClean)
    _t:SetAllPoints(frame)
    _t:SetGradientAlpha(
        "VERTICAL", 
        bER, bEG, bEB, bEA,
        bSR, bSG, bSB, bSA
        )
    frame.texture = _t

    PushUIStyle.BackgroundHollowFormat(frame, bbR, bbG, bbB, bbA)
end

PushUIStyle.BackgroundSolidColorPack = function(frame, bgColor, bdColor)
    local bgR, bgG, bgB = unpack(bgColor)
    local bdR, bdG, bdB = unpack(bdColor)
    PushUIStyle.BackgroundSolidFormat(
        frame,
        bgR, bgG, bgB, 1,
        bdR, bdG, bdB, 1
        )
end

PushUIStyle.BackgroundHollowColorPack = function(frame, bdColor)
    local bdR, bdG, bdB = unpack(bdColor)
    PushUIStyle.BackgroundHollowFormat(
        frame,
        bdR, bdG, bdB, 1
        )
end

PushUIStyle.BackgroundFormat1 = function(frame)
    PushUIStyle.BackgroundGradientFormat(
        frame,
        0.15625, 0.15625, 0.15625, 0.9,
        0, 0, 0, 0.9,
        0.535, 0.535, 0.535, 1
        )
end

PushUIStyle.BackgroundFormat2 = function(frame)
    PushUIStyle.BackgroundGradientFormat(
        frame,
        0.15625, 0.15625, 0.15625, 0.9,
        0, 0, 0, 0.9,
        0, 0, 0, 1
        )
end

PushUIStyle.BackgroundFormat3 = function(frame)
    PushUIStyle.BackgroundSolidFormat(
        frame,
        0.23046875, 0.23046875, 0.23046875, 0.9,
        0.53515625, 0.53515625, 0.53515625, 1
        )
end

PushUIStyle.BackgroundFormat4 = function(frame)
    PushUIStyle.BackgroundSolidFormat(
        frame,
        0.23046875, 0.23046875, 0.23046875, 0.6,
        0.53515625, 0.53515625, 0.53515625, 1
        )
end

PushUIStyle.BackgroundFormatColorAndBorder = function(frame, color, bgAlpha, border, bdAlpha)
    local r, g, b = unpack(color)
    local dr, dg, db = unpack(border)
    PushUIStyle.BackgroundSolidFormat(
        frame,
        r, g, b, bgAlpha,
        dr, dg, db, bdAlpha
        )
end

PushUIStyle.BackgroundFormatForProgressBar = function(frame)
    PushUIStyle.BackgroundFormat(frame, PushUIStyle.BackdropOutline, 
        0, 0, 0, 1, 0, 0, 0, 1)
end

PushUIStyle.BackgroundFormatFillRedBlackBorder = function(frame)
    PushUIStyle.BackgroundFormatColorAndBorder(frame, PushUIColor.red, 1, PushUIColor.black, 1)
end

PushUIStyle.BackgroundFormatFillBlueBlackBorder = function(frame)
    PushUIStyle.BackgroundFormatColorAndBorder(frame, PushUIColor.blue, 1, PushUIColor.black, 1)
end

PushUIStyle.BackgroundFormatFillGreenBlackBorder = function(frame)
    PushUIStyle.BackgroundFormatColorAndBorder(frame, PushUIColor.green, 1, PushUIColor.black, 1)
end

PushUIStyle.BackgroundFormatFillYellowBlackBorder = function(frame)
    PushUIStyle.BackgroundFormatColorAndBorder(frame, PushUIColor.yellow, 1, PushUIColor.black, 1)
end

PushUIStyle.BackgroundFormatFillGrayBlackBorder = function(frame)
    PushUIStyle.BackgroundFormatColorAndBorder(frame, PushUIColor.gray, 1, PushUIColor.black, 1)
end

PushUIStyle.BackgroundFormatFillOrangeBlackBorder = function(frame)
    PushUIStyle.BackgroundFormatColorAndBorder(frame, PushUIColor.orange, 1, PushUIColor.black, 1)
end

PushUIStyle.BackgroundFormatFillPurpleBlackBorder = function(frame)
    PushUIStyle.BackgroundFormatColorAndBorder(frame, PushUIColor.purple, 1, PushUIColor.black, 1)
end
-- Font
PushUIStyle.SetFontSize = function(text, size)
    local _text = text
    local _p, _s = _text:GetFont()
    if _p == nil then
        _p = "Fonts\\FRIZQT__.TTF"
    end
    _s = size
    _text:SetFont(_p, _s)
end
PushUIStyle.SetFontOutline = function(text, outline)
    outline = outline or "OUTLINE"
    local _p, _s, _f = text:GetFont()
    if _p == nil then
        _p = "Fonts\\FRIZQT__.TTF"
    end
    _f = outline
    text:SetFont(_p, _s, _f)
end
PushUIStyle.SetFontColor = function(text, ...)
    local _text = text
    _text:SetTextColor(...)
end

-- Hide Frame
PushUIStyle.HideFrame = function(f)
    f:SetScript("OnShow", f.Hide)
    f:Hide()
end

