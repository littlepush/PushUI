local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIFrames.UIButton = PushUIAPI.inhiert(PushUIFrames.UIView)

function PushUIFrames.UIButton:c_str(parent)
    self._icon = self.layer:CreateTexture()
    self._label = self.layer:CreateFontString()
    self._colors = {
        normal = PushUIColor.lightgray,
        highlight = PushUIColor.highlightgray,
        selected = PushUIColor.highlightgray,
        disabled = PushUIColor.disablegray
    }
    self._borderColors = {
        normal = PushUIColor.lightborder,
        highlight = PushUIColor.highlightborder,
        selected = PushUIColor.highlightborder,
        disabled = PushUIColor.disableborder
    }
    self._selected = false

end

-- Push Chen
