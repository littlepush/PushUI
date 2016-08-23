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
PushUIColor.black = {0, 0, 0}
PushUIColor.white = {1, 1, 1}
PushUIColor.red = {0.89, 0.25, 0.20}
PushUIColor.blue = {0.26, 0.49, 0.91}
PushUIColor.green = {0.49, 0.82, 0.29}
PushUIColor.yellow = {0.82, 0.85, 0.46}
PushUIColor.orange = {0.84, 0.55, 0.17}
PushUIColor.gray = {0.4, 0.4, 0.4}
PushUIColor.cyan = {0.14, 0.16, 0.19}
PushUIColor.purple = {0.82, 0.47, 0.69}

-- Alpha for different statue
PushUIColor.alphaAvailable = 0.9
PushUIColor.alphaDim = 0.3

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
    local _p, _s, _f = _text:GetFont()
    _s = size
    _text:SetFont(_p, _s, _f)
end
PushUIStyle.SetFontOutline = function(text, outline)
    outline = outline or "OUTLINE"
    local _p, _s, _f = text:GetFont()
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

