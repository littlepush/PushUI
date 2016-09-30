local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIFrames.UIProgressBar = PushUIAPI.inhiert(PushUIFrames.UIView)

PushUIFrames.UIProgressBar.StyleVBT = "v-b-t"
PushUIFrames.UIProgressBar.StyleVTB = "v-t-b"
PushUIFrames.UIProgressBar.StyleHLR = "h-l-r"
PushUIFrames.UIProgressBar.StyleHRL = "h-r-l"

function PushUIFrames.UIProgressBar:c_str(parent)
    self._pblayer = PushUIFrames.UIView(self)
    self._pblayer:set_borderColor(PushUIColor.black, 0)
    -- self._pblabel = PushUIFrames.UILabel(self)

    self._min = 0
    self._max = 100
    self._value = 50
    self._pblayer:set_position(0, 0)
    -- self._pblabel:set_position(0, 0)
    -- self._pblabel:set_align("CENTER")

    self._direction = "v-b-t"   -- v-t-b, h-l-r, h-r-l
end

function PushUIFrames.UIProgressBar:redraw()
    self._pblayer:set_size(self:size())
    -- self._pblabel:set_size(self:size())

    local _rate = self._value / (self._max - self._min)

    print("Direction is: "..self._direction)
    if self._direction == "v-b-t" then
        self._pblayer:set_height(self:height() * _rate)
        self._pblayer:set_position(0, -self:height() * (1 - _rate))
    elseif self._direction == "v-t-b" then
        self._pblayer:set_height(self:height() * _rate)
        self._pblayer:set_position(0, 0)
    elseif self._direction == "h-l-r" then
        self._pblayer:set_width(self:width() * _rate)
        self._pblayer:set_position(0, 0)
    elseif self._direction == "h-r-l" then
        self._pblayer:set_width(self:width() * _rate)
        self._pblayer:set_position(self:width() * (1 - _rate), 0)
    end
end

function PushUIFrames.UIProgressBar:set_max(max)
    self._max = max
    self:redraw()
end

function PushUIFrames.UIProgressBar:set_min(min)
    self._min = min 
    self:redraw()
end

function PushUIFrames.UIProgressBar:set_value(value)
    self._value = value
    self:redraw()
end

function PushUIFrames.UIProgressBar:set_barColor(color_pack, alpha)
    self._pblayer:set_backgroundColor(color_pack, alpha)
end

function PushUIFrames.UIProgressBar:set_style(style)
    self._direction = style 
    self:redraw()
end

-- function PushUIFrames.UIProgressBar:label()
--     return self._pblabel
-- end

-- function PushUIFrames.UIProgressBar:set_tiptext(text)
--     self._pblabel:set_text(text)
-- end

-- Push Chen
