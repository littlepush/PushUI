local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIFrames.UIImage = PushUIAPI.inhiert(PushUIFrames.UIView)

function PushUIFrames.UIImage:c_str(parent)
    self.imageLayer = self.layer:CreateTexture()
    self.imageLayer:SetAllPoints(self.layer)

    self.imageLayer:SetNonBlocking(true)
    self._hasImage = false;
end

function PushUIFrames.UIImage:set_image(image_texture)
    self._hasImage = (image_texture ~= nil)
    self.imageLayer:SetTexture(image_texture)
end
function PushUIFrames.UIImage:image()
    return self.imageLayer:GetTexture()
end

function PushUIFrames.UIImage:set_cropSize(l, r, t, b)
    self.imageLayer:SetTexCoord(l, r, t, b)
end

function PushUIFrames.UIImage:has_image()
    return self._hasImage
end

-- Push Chen
