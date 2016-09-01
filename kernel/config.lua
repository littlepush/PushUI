local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

-- Skin Style
--PushUIConfig.skinType = PushUIStyle.BackgroundFormat4
PushUIConfig.skinType = function(frame)
    PushUIStyle.BackgroundSolidFormat(
        frame,
        0.23046875, 0.23046875, 0.23046875, 0.45,
        0.53515625, 0.53515625, 0.53515625, 0.15
        )
end

PushUIConfig.actionButtonBorderColor = PushUIColor.gray

-- Auto Scale when UI Resolution Changed.
PushUIConfig.uiScaleAuto = true

-- Action Bar Layout
PushUIConfig.ActionBarGrid = {12, 3}
PushUIConfig.ActionBarGridScale = 0.95

-- A = ActionButton
-- MBL = MultiBarBottomLeftButton
-- MBR = MultiBarBottomRightButton
-- ML  = MultiBarLeftButton
-- MR  = MultiBarRightButton
PushUIConfig.ActionBarGridLayout = {
    {"MBR1", "MBR2", "MBR3", "MBR4", "MBR5", "MBR6", "MBR7", "MBR8", "MBR9", "MBR10", "MBR11", "MBR12"},
    {"MBL1", "MBL2", "MBL3", "MBL4", "MBL5", "MBL6", "MBL7", "MBL8", "MBL9", "MBL10", "MBL11", "MBL12"},
    {"A1", "A2", "A3", "A4", "A5", "A6", "A7", "A8", "A9", "A10", "A11", "A12"}
    -- {"ML1",  "ML2",  "ML3",  "A5", "A1", "A1", "A2", "A2", "A9",  "MR1",  "MR2",  "MR3" },
    -- {"ML4",  "ML5",  "ML6",  "A6", "A1", "A1", "A2", "A2", "A10", "MR4",  "MR5",  "MR6" },
    -- {"ML7",  "ML8",  "ML9",  "A7", "A3", "A3", "A4", "A4", "A11", "MR7",  "MR8",  "MR9" },
    -- {"ML10", "ML11", "ML12", "A8", "A3", "A3", "A4", "A4", "A12", "MR10", "MR11", "MR12"}
}
PushUIConfig.ActionBarGridPlacedCood = {}

PushUIConfig.ActionBarFontSize = 8

-- Left Bottom Frame
PushUIConfig.LeftBottomFrame = {}
-- PushUIConfig.LeftBottomFrame.HookFrame = nil
-- Right Bottom Frame
PushUIConfig.RightBottomFrame = {}
-- PushUIConfig.RightBottomFrame.HookFrame = nil

-- Chat Frame
PushUIConfig.ChatFrameHook = {}
PushUIConfig.ChatFrameHook.parent = PushUIConfig.LeftBottomFrame
PushUIConfig.ChatFrameHook.displayOnLoad = true

-- Skada Frame
PushUIConfig.SkadaFrameHook = {}
PushUIConfig.SkadaFrameHook.parent = PushUIConfig.RightBottomFrame
PushUIConfig.SkadaFrameHook.displayOnLoad = true
PushUIConfig.SkadaFrameHook.barCount = 8

-- Minimap
PushUIConfig.MinimapFrameHook = {}
PushUIConfig.MinimapFrameHook.parent = PushUIConfig.RightBottomFrame
PushUIConfig.MinimapFrameHook.align = "right"
PushUIConfig.MinimapFrameHook.mustBeSquare = true
PushUIConfig.MinimapFrameHook.allowZoom = true

-- Objective Tracker
PushUIConfig.ObjectiveTrackerFrameHook = {}
PushUIConfig.ObjectiveTrackerFrameHook.enable = false
PushUIConfig.ObjectiveTrackerFrameHook.parent = PushUIConfig.RightBottomFrame
PushUIConfig.ObjectiveTrackerFrameHook.align = "left"
PushUIConfig.ObjectiveTrackerFrameHook.wheelStep = 15
PushUIConfig.ObjectiveTrackerFrameHook.scrollside = -1   -- can be 1 or -1

-- Grid Tracker
PushUIConfig.GridFrameHook = {}
PushUIConfig.GridFrameHook.parent = PushUIConfig.RightBottomFrame


-- Scale
PushUIConfig.LeftBottomFrame.scale = 1.0

-- Stick to action bar
-- If false, will stick to the left bottom corner of screen
PushUIConfig.LeftBottomFrame.stickToActionBar = true

-- Distance to the stick side
PushUIConfig.LeftBottomFrame.stickPadding = 4

-- Block Count
PushUIConfig.LeftBottomFrame.blockCount = 2

-- Switcher
PushUIConfig.LeftBottomFrame.switchers = {
    left = {
        {
            mode = PushUIFrames.ProgressBar,
            skin = PushUIStyle.BackgroundFormatForProgressBar,
            targets = {
                PushUIAPI.UnitExp,
                PushUIAPI.WatchedFactionInfo
            },
            alwaysDisplay = false,
            action = nil,
            fillColor = {
                PushUIColor.expColorDynamic,
                PushUIColor.factionColorDynamic
            }
        }
    },
    groupleft = false,
    right = {
        {
            mode = PushUIFrames.Button,
            skin = PushUIStyle.BackgroundFormatFillBlueBlackBorder,
            targets = {
                PushUIConfig.ChatFrameHook
            },
            alwaysDisplay = true,
            action = "Toggle",
            selected = true,
            alwaysAction = true,-- true: selected = not selected, false: only active when selected == false
            binding = "ALT-V",
        }
    },
    groupright = true
}

-- Scale
PushUIConfig.RightBottomFrame.scale = 1.0

-- Stick to action bar
-- If false, will stick to the left bottom corner of screen
PushUIConfig.RightBottomFrame.stickToActionBar = true

-- Distance to the stick side
PushUIConfig.RightBottomFrame.stickPadding = 4

-- Block Count
PushUIConfig.RightBottomFrame.blockCount = 2
-- If display Switcher
PushUIConfig.RightBottomFrame.switchers = {
    left = {
        {
            mode = PushUIFrames.Button,
            skin = PushUIStyle.BackgroundFormatFillOrangeBlackBorder,
            targets = {
                PushUIConfig.MinimapFrameHook,
                PushUIConfig.SkadaFrameHook
            },
            alwaysDisplay = true,
            action = "Toggle",
            selected = true,
            alwaysAction = true,
            binding = "ALT-SHIFT-V"
        }
    },
    groupleft = true,
    right = {
        {
            mode = PushUIFrames.ProgressBar,
            skin = PushUIStyle.BackgroundFormatForProgressBar,
            targets = {
                PushUIAPI.Artifact
            },
            alwaysDisplay = false,
            action = nil,
            fillColor = {
                function(...)
                    return {unpack(PushUIColor.orange), 1}
                end
            }
        }
    },
    groupright = false
}

-- UnitFrame Hook
PushUIConfig.PlayerFrameHook = {
    enable = true,
    hookbar = {
        anchorTarget = UIParent,
        anchorPoint = "CENTER",
        displaySide = "CENTER",
        position = { x = -223.57, y = -72 },
        size = { w = 200, h = 40 }
    },
    lifebar = {
        orientation = "HORIZONTAL",
        position = { x = 0, y = -35 },
        size = { w = 200, h = 5 },
        anchorPoint = "TOPLEFT",
        reverse = false,
        fillColor = { PushUIColor.lifeColorDynamic },
        background = function(frame)
            PushUIStyle.BackgroundSolidFormat(frame, 1, 1, 1, 0.2, 1, 1, 1, 0)
        end
    },
    name = {
        size = 14,
        color = function(...) return {1, 1, 1} end,
        outline = "OUTLINE",
        align = "RIGHT",
        fontName = "Fonts\\ARIALN.TTF",
        anchorPoint = "TOPRIGHT", 
        displaySide = "TOPLEFT",
        position = { x = -PushUISize.padding, y = -PushUISize.padding * 2 }
    },
    percentage = {
        size = 30,
        color = PushUIColor.lifeColorDynamic,
        outline = "OUTLINE",
        fontName = "Interface\\AddOns\\PushUI\\media\\Bazooka.ttf",
        align = "LEFT",
        anchorPoint = "TOPLEFT",
        displaySide = "TOPLEFT",
        position = { x = 0, y = -2 }
    },
    healthvalue = {
        size = 14,
        color = function(...) return {1, 1, 1, 1} end,
        outline = "OUTLINE",   -- "OUTLINE"
        align = "RIGHT",
        fontName = "Interface\\AddOns\\PushUI\\media\\Bazooka.ttf",
        anchorPoint = "TOPRIGHT",
        displaySide = "TOPLEFT",
        position = { x = -PushUISize.padding, y = -(PushUISize.padding * 3 + 14) }
    },
    auras = {
        width = 200,
        size = { w = 30, h = 30 },
        anchorPoint = "TOPLEFT",
        displaySide = "BOTTOMLEFT",
        position = { x = 0, y = -10 }
    }
}

-- Target Frame
PushUIConfig.TargetFrameHook = {
    enable = true,
    hookbar = {
        anchorTarget = UIParent,
        anchorPoint = "CENTER",
        displaySide = "CENTER",
        position = { x = 223.57, y = -72 },
        size = { w = 200, h = 40 }
    },
    lifebar = {
        orientation = "HORIZONTAL",
        position = { x = 0, y = -35 },
        size = { w = 200, h = 5 },
        anchorPoint = "TOPLEFT",
        reverse = true,
        fillColor = { PushUIColor.lifeColorDynamic },
        background = function(frame)
            PushUIStyle.BackgroundSolidFormat(frame, 1, 1, 1, 0.2, 1, 1, 1, 0)
        end
    },
    name = {
        size = 14,
        color = function(...) return {1, 1, 1} end,
        outline = "OUTLINE",
        align = "LEFT",
        fontName = "Fonts\\ARIALN.TTF",
        anchorPoint = "TOPLEFT", 
        displaySide = "TOPRIGHT",
        position = { x = PushUISize.padding, y = -PushUISize.padding * 2 }
    },
    percentage = {
        size = 30,
        color = PushUIColor.lifeColorDynamic,
        outline = "OUTLINE",
        fontName = "Interface\\AddOns\\PushUI\\media\\Bazooka.ttf",
        align = "RIGHT",
        anchorPoint = "TOPRIGHT",
        displaySide = "TOPRIGHT",
        position = { x = 0, y = -2 }
    },
    healthvalue = {
        size = 14,
        color = function(...) return {1, 1, 1, 1} end,
        outline = "OUTLINE",   -- "OUTLINE"
        align = "LEFT",
        fontName = "Interface\\AddOns\\PushUI\\media\\Bazooka.ttf",
        anchorPoint = "TOPLEFT",
        displaySide = "TOPRIGHT",
        position = { x = PushUISize.padding, y = -(PushUISize.padding * 3 + 14) }
    },
    auras = {
        width = 200,
        size = { w = 30, h = 30 },
        anchorPoint = "TOPRIGHT",
        displaySide = "BOTTOMRIGHT",
        position = { x = 0, y = -10 }
    }
}

-- TargetTarget Frame
PushUIConfig.TargetTargetFrameHook = {
    enable = true,
    hookbar = {
        anchorTarget = nil,
        anchorPoint = "TOPLEFT",
        displaySide = "BOTTOMRIGHT",
        position = { x = 20, y = -10 },
        size = { w = 100, h = 20 }
    },
    lifebar = {
        orientation = "HORIZONTAL",
        position = { x = 0, y = -15 },
        size = { w = 100, h = 5 },
        anchorPoint = "TOPLEFT",
        reverse = true,
        fillColor = { PushUIColor.lifeColorDynamic },
        background = function(frame)
            PushUIStyle.BackgroundSolidFormat(frame, 1, 1, 1, 0.2, 1, 1, 1, 0)
        end
    },
    name = {
        size = 12,
        color = function(...) return {1, 1, 1} end,
        outline = "OUTLINE",
        align = "LEFT",
        fontName = "Fonts\\ARIALN.TTF",
        anchorPoint = "TOPLEFT", 
        displaySide = "TOPRIGHT",
        position = { x = PushUISize.padding, y = -PushUISize.padding * 2 }
    },
    percentage = {
        size = 12,
        color = PushUIColor.lifeColorDynamic,
        outline = "OUTLINE",
        fontName = "Interface\\AddOns\\PushUI\\media\\Bazooka.ttf",
        align = "RIGHT",
        anchorPoint = "TOPRIGHT",
        displaySide = "TOPRIGHT",
        position = { x = 0, y = -2 }
    }
}

-- Focus
PushUIConfig.FocusFrameHook = {
    enable = true,
    hookbar = {
        anchorTarget = nil,
        anchorPoint = "TOPRIGHT",
        displaySide = "BOTTOMLEFT",
        position = { x = -20, y = -10 },
        size = { w = 100, h = 20 }
    },
    lifebar = {
        orientation = "HORIZONTAL",
        position = { x = 0, y = -15 },
        size = { w = 100, h = 5 },
        anchorPoint = "TOPLEFT",
        reverse = false,
        fillColor = { PushUIColor.lifeColorDynamic },
        background = function(frame)
            PushUIStyle.BackgroundSolidFormat(frame, 1, 1, 1, 0.2, 1, 1, 1, 0)
        end
    },
    name = {
        size = 12,
        color = function(...) return {1, 1, 1} end,
        outline = "OUTLINE",
        align = "RIGHT",
        fontName = "Fonts\\ARIALN.TTF",
        anchorPoint = "TOPRIGHT", 
        displaySide = "TOPLEFT",
        position = { x = -PushUISize.padding, y = -PushUISize.padding * 2 }
    },
    percentage = {
        size = 12,
        color = PushUIColor.lifeColorDynamic,
        outline = "OUTLINE",
        fontName = "Interface\\AddOns\\PushUI\\media\\Bazooka.ttf",
        align = "LEFT",
        anchorPoint = "TOPLEFT",
        displaySide = "TOPLEFT",
        position = { x = 0, y = -2 }
    }
}

-- Pet
PushUIConfig.PetFrameHook = {
    enable = true,
    hookbar = {
        anchorTarget = nil,
        anchorPoint = "TOPLEFT",
        displaySide = "BOTTOMLEFT",
        position = { x = 0, y = -60 },
        size = { w = 100, h = 20 }
    },
    lifebar = {
        orientation = "HORIZONTAL",
        position = { x = 0, y = -15 },
        size = { w = 100, h = 5 },
        anchorPoint = "TOPLEFT",
        reverse = false,
        fillColor = { PushUIColor.lifeColorDynamic },
        background = function(frame)
            PushUIStyle.BackgroundSolidFormat(frame, 1, 1, 1, 0.2, 1, 1, 1, 0)
        end
    },
    name = {
        size = 12,
        color = function(...) return {1, 1, 1} end,
        outline = "OUTLINE",
        align = "RIGHT",
        fontName = "Fonts\\ARIALN.TTF",
        anchorPoint = "TOPRIGHT", 
        displaySide = "TOPLEFT",
        position = { x = -PushUISize.padding, y = -PushUISize.padding * 2 }
    },
    percentage = {
        size = 12,
        color = PushUIColor.lifeColorDynamic,
        outline = "OUTLINE",
        fontName = "Interface\\AddOns\\PushUI\\media\\Bazooka.ttf",
        align = "LEFT",
        anchorPoint = "TOPLEFT",
        displaySide = "TOPLEFT",
        position = { x = 0, y = -2 }
    }
}
