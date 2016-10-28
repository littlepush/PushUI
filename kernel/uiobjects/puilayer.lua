local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIFrames.__uiaDispatcher = PushUIAPI.Dispatcher()
function __globalMouseWrapper_onDown(layer, btn)
    PushUIFrames.__uiaDispatcher:fire_event("PUIEventMouseDown", btn)
end
function __globalMouseWrapper_onUp(layer, btn)
    PushUIFrames.__uiaDispatcher:fire_event("PUIEventMouseUp", btn)
end
function __globalMouseWrapper_onWheel(layer, zoom)
    PushUIFrames.__uiaDispatcher:fire_event("PUIEventMouseWheel", zoom)
end
function __globalMouseWrapper_onMove(x, y)
    PushUIFrames.__uiaDispatcher:fire_event("PUIEventMouseMove", x, y)
end

-- Get global mouse move event
PushUIFrames._hiddenMainFrame = CreateFrame("Frame", "PushUIHiddenMainFrame")
PushUIFrames._hiddenMainFrame:SetScript("OnUpdate", function(...)
    __globalMouseWrapper_onMove(GetCursorPosition())
end)

-- basic layer
PushUIFrames.PUILayer = PushUIAPI.inhiert()

function PushUIFrames.PUILayer:c_str(parent, ...)
    self._internalLayer = __generateNewObjectByType("Frame")
    self._internalLayer.wrapper = self
    self.id = self._internalLayer.uiname

    -- Children and Parent
    self._sublayers = PushUIAPI.Array()
    self._parentLayer = parent

    if parent then
        if parent._internalLayer then
            self._internalLayer:SetParent(parent._internalLayer) 
        elseif parent.layer then
            self._internalLayer:SetParent(parent.layer)
        else
            self._internalLayer:SetParent(parent)
        end
    end

    -- The layer does not support user interactive
    self._userInteractive = false;
    -- But the layer should redirect the mouse event
    self._internalLayer:EnableMouse(true)
    self._internalLayer:EnableMouseWheel(true)

    self._internalLayer:SetScript("OnMouseDown", function(il, btn)
        __globalMouseWrapper_onDown(il.wrapper, btn)
    end)
    self._internalLayer:SetScript("OnMouseUp", function(il, btn)
        __globalMouseWrapper_onUp(il.wrapper, btn)
    end)
    self._internalLayer:SetScript("OnMouseWheel", function(il, zoom)
        __globalMouseWrapper_onWheel(il.wrapper, zoom)
    end)
end

function PushUIFrames.PUILayer:type()
    return "PUILayer"
end

function PushUIFrames.PUILayer:object() 
    return self._internalLayer 
end

-- Push Chen
