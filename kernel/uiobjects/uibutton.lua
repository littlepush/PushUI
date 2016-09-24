local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIFrames.UIButton = PushUIAPI.inhiert(PushUIFrames.UIView)

function PushUIFrames.UIButton:c_str(parent)
    self.titleLabel = PushUIFrames.UILabel(self)
    -- self.icon = PushUIFrames.UIImage(self)
end
