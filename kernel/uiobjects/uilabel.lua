local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIFrames.PUILabelLayer = PushUIAPI.inhiert()

function PushUIFrames.PUILabelLayer:c_str(parent)
    if parent then
        self._textfs = parent:object():CreateFontString()
    else
        print("Cannot create a label layer without basic layer")
    end
    self._padding = {l = 0, r = 0, t = 0, b = 0}
    self._bounds = {w = 0, h = 0}
    self._fontName = "Fonts\\ARIALN.TTF"
    self._fontSize = 14
    self._fontFlags = nil
    self._fontColor = PushUIColor.white
    self._maxLine = 1
    self._align = "LEFT"

    self._textfs:SetFont(self._fontName, self._fontSize, self._fontFlags)
    self._textfs:SetJustifyH(self._align)
    self._textfs:SetTextColor(PushUIColor.unpackColor(self._fontColor))
end

function PushUIFrames.PUILabelLayer:redraw()
    local _w = self._bounds.w
    if _w > 0 then _w = _w - self._padding.l - self._padding.r end
    local _h = self._bounds.h
    if _h > 0 then _h = _h - self._padding.t - self._padding.b end
    if _w < 0 then _w = 0 end
    if _h < 0 then _h = 0 end
    self._textfs:SetWidth(_w)
    self._textfs:SetHeight(_h)

    local _tw = self._textfs:GetWidth()
    local _th = self._textfs:GetHeight()
    self._textfs:SetWidth(_tw)
    self._textfs:SetHeight(_th)
    self.layer:SetWidth(_tw + self._padding.l + self._padding.r)
    self.layer:SetHeight(_th + self._padding.t + self._padding.b)

    self._textfs:ClearAllPoints()
    self._textfs:SetPoint("TOPLEFT", self.layer, "TOPLEFT", 
        self._padding.l, -self._padding.t)
end

-- Text
function PushUIFrames.PUILabelLayer:set_text(text)
    self._textfs:SetText(text)
    self:redraw()
end
function PushUIFrames.PUILabelLayer:text()
    return self._textfs:GetText()
end

-- Padding
function PushUIFrames.PUILabelLayer:set_padding(...)
    local l, r, t, b
    if select("#", ...) == 1 then
        -- Only one, set all to this
        local _p = select(1, ...)
        l, r, t, b = _p, _p, _p, _p
    elseif select("#", ...) == 2 then
        local _h = select(1, ...)
        local _v = select(2, ...)
        l, r = _h, _h
        t, b = _v, _v
    elseif select("#", ...) == 4 then
        l, r, t, b = ...
    end    
    self._padding.l = l
    self._padding.r = r
    self._padding.t = t
    self._padding.b = b
    self:redraw()
end
function PushUIFrames.PUILabelLayer:padding()
    return unpack(self._padding)
end

-- Bounds
function PushUIFrames.PUILabelLayer:set_bounds(w, h)
    self._bounds.w = w
    self._bounds.h = h
    self:redraw()
end
function PushUIFrames.PUILabelLayer:set_wbounds(w)
    if nil == w then w = 0 end
    self._bounds.w = w
    self:redraw()
end
function PushUIFrames.PUILabelLayer:set_width(w)
    self:set_wbounds(w)
end
function PushUIFrames.PUILabelLayer:set_hbounds(h)
    if nil == h then h = 0 end
    self._bounds.h = h
    self:redraw()
end
function PushUIFrames.PUILabelLayer:set_height(h)
    self:set_hbounds(h)
end
function PushUIFrames.PUILabelLayer:set_size(w, h)
    self:set_bounds(w, h)
end
function PushUIFrames.PUILabelLayer:bounds()
    return unpack(self._bounds)
end

-- Font Name
function PushUIFrames.PUILabelLayer:set_fontname(fname)
    if not fname then return end
    self._fontName = fname
    self._textfs:SetFont(self._fontName, self._fontSize, self._fontFlags)
    self:redraw()
end
function PushUIFrames.PUILabelLayer:fontname()
    return self._fontName
end

-- Font Size
function PushUIFrames.PUILabelLayer:set_fontsize(size)
    if size <= 0 then return end
    self._fontSize = size
    self._textfs:SetFont(self._fontName, self._fontSize, self._fontFlags)
    self:redraw()
end
function PushUIFrames.PUILabelLayer.fontsize()
    return self._fontSize
end

-- Font Flags
function PushUIFrames.PUILabelLayer:set_fontflag(flags)
    self._fontFlags = flags
    self._textfs:SetFont(self._fontName, self._fontSize, self._fontFlags)
    self:redraw()
end
function PushUIFrames.PUILabelLayer:fontfags()
    return self._fontFlags
end

-- Font Color
function PushUIFrames.PUILabelLayer:set_fontcolor(color)
    if not color then return color end
    self._fontColor = color
    self._textfs:SetTextColor(PushUIColor.unpackColor(color))
end
function PushUIFrames.PUILabelLayer.fontcolor()
    return self._fontColor
end

-- MaxLine
function PushUIFrames.PUILabelLayer:set_maxline(lines)
    if nil == lines or lines <= 0 then lines = 999 end
    self._maxLine = lines
    self._textfs:SetMaxLines(lines)
    self:redraw()
end
function PushUIFrames.PUILabelLayer:maxline()
    return self._maxLine
end

-- Align
function PushUIFrames.PUILabelLayer:set_align(align)
    if align ~= "LEFT" and align ~= "CENTER" and align ~= "RIGHT" then return end
    self._align = align
    self._textfs:SetJustifyH(align)
end
function PushUIFrames.PUILabelLayer:align()
    return self._align
end

-- UILabel
PushUIFrames.UILabel = PushUIAPI.inhiert(PushUIFrames.UIView)

function PushUIFrames.UILabel:c_str(parent)
    self.labellayer = PushUIFrames.PUILabelLayer(parent.layer)
end

function PushUIFrames.UILabel:redraw()
    self.super:redraw()
    self.labellayer:redraw()
end

-- by Push Chen
-- twitter: @littlepush
