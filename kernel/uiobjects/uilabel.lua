local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIFrames.UILabel = PushUIAPI.inhiert(PushUIFrames.UIView)

function PushUIFrames.UILabel:_resize()
    local _w = self._bounds.w
    if _w == 0 then _w = _w - self._padding.l - self._padding.r end
    local _h = self._bounds.h
    if _h == 0 then _h = _h - self._padding.t - self._padding.b end
    self._textfs:SetWidth(_w)
    self._textfs:SetHeight(_h)

    local _tw = self._textfs:GetWidth() + self._padding.l + self._padding.r
    local _th = self._textfs:GetHeight() + self._padding.t + self._padding.b
    self:set_size(_tw, _th)

    self._textfs:ClearAllPoints()
    self._textfs:SetPoint("TOPLEFT", self.layer, "TOPLEFT", 
        self._padding.l, self._padding.t)
end

-- Text
function PushUIFrames.UILabel:set_text(text)
    self._textfs:SetText(text)
    self:_resize()
end
function PushUIFrames.UILabel:text()
    return self._textfs:GetText()
end

-- Padding
function PushUIFrames.UILabel:set_padding(l, r, t, b)
    self._padding.l = l
    self._padding.r = r
    self._padding.t = t
    self._padding.b = b
    self:_resize()
end
function PushUIFrames.UILabel:padding()
    return unpack(self._padding)
end

-- Bounds
function PushUIFrames.UILabel:set_bounds(w, h)
    self._bounds.w = w
    self._bounds.h = h
    self:_resize()
end
function PushUIFrames.UILabel:set_wbounds(w)
    if nil == w then w = 0 end
    self._bounds.w = w
    self:_resize()
end
function PushUIFrames.UILabel:set_width(w)
    self:set_wbounds(w)
end
function PushUIFrames.UILabel:set_hbounds(h)
    if nil == h then h = 0 end
    self._bounds.h = h
    self:_resize()
end
function PushUIFrames.UILabel:set_height(h)
    self:set_hbounds(h)
end
function PushUIFrames.UILabel:set_size(w, h)
    self:set_bounds(w, h)
end
function PushUIFrames.UILabel:bounds()
    return unpack(self._bounds)
end

-- Font Name
function PushUIFrames.UILabel:set_fontname(fname)
    if not fname then return end
    self._fontName = fname
    self._textfs:SetFont(self._fontName, self._fontSize, self._fontFlags)
    self:_resize()
end
function PushUIFrames.UILabel:fontname()
    return self._fontName
end

-- Font Size
function PushUIFrames.UILabel:set_fontsize(size)
    if size <= 0 then return end
    self._fontSize = size
    self._textfs:SetFont(self._fontName, self._fontSize, self._fontFlags)
    self:_resize()
end
function PushUIFrames.UILabel.fontsize()
    return self._fontSize
end

-- Font Flags
function PushUIFrames.UILabel:set_fontflag(flags)
    self._fontFlags = flags
    self._textfs:SetFont(self._fontName, self._fontSize, self._fontFlags)
    self:_resize()
end
function PushUIFrames.UILabel:fontfags()
    return self._fontFlags
end

-- Font Color
function PushUIFrames.UILabel:set_fontcolor(color)
    if not color then return color end
    self._fontColor = color
    self._textfs:SetTextColor(PushUIColor.unpackColor(color))
end
function PushUIFrames.UILabel.fontcolor()
    return self._fontColor
end

-- MaxLine
function PushUIFrames.UILabel:set_maxline(lines)
    if nil == lines or lines <= 0 then lines = 999 end
    self._maxLine = lines
    self._textfs:SetMaxLines(lines)
    self:_resize()
end
function PushUIFrames.UILabel:maxline()
    return self._maxLine
end

-- Align
function PushUIFrames.UILabel:set_align(align)
    if align ~= "LEFT" and align ~= "CENTER" and align ~= "RIGHT" then return end
    self._align = align
    self._textfs:SetJustifyH(align)
end
function PushUIFrames.UILabel:align()
    return self._align
end

function PushUIFrames.UILabel:c_str(parent)
    self._textfs = self.layer:CreateFontString()
    self._padding = {l = 0, r = 0, t = 0, b = 0}
    self._bounds = {w = 0, h = 0}
    self._fontName = "Fonts\\ARIALN.TTF"
    self._fontSize = 14
    self._fontFlags = nil
    self._fontColor = PushUIColor.white
    self._maxLine = 1
    self._align = "LEFT"
    self:_resize()
end

-- by Push Chen
-- twitter: @littlepush
