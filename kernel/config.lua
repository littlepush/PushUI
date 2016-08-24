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
PushUIConfig.SkadaFrameHook.parent = PushUIConfig.LeftBottomFrame
PushUIConfig.SkadaFrameHook.displayOnLoad = false
PushUIConfig.SkadaFrameHook.barCount = 8

-- Minimap
PushUIConfig.MinimapFrameHook = {}
PushUIConfig.MinimapFrameHook.parent = PushUIConfig.RightBottomFrame
PushUIConfig.MinimapFrameHook.align = "right"
PushUIConfig.MinimapFrameHook.mustBeSquare = true
PushUIConfig.MinimapFrameHook.allowZoom = true

-- Objective Tracker
PushUIConfig.ObjectiveTrackerFrameHook = {}
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
        },
        {
            mode = PushUIFrames.Button,
            skin = PushUIStyle.BackgroundFormatFillRedBlackBorder,
            targets = {
                PushUIConfig.SkadaFrameHook
            },
            alwaysDisplay = true,
            action = "Toggle",
            seelcted = false,
            alwaysAction = true,
            binding = "ALT-V"
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
                PushUIConfig.ObjectiveTrackerFrameHook,
                PushUIConfig.MinimapFrameHook
            },
            alwaysDisplay = true,
            action = "Toggle",
            selected = true,
            alwaysAction = true,
            binding = "ALT-SHIFT-V"
        },
        {
            mode = PushUIFrames.Button,
            skin = PushUIStyle.BackgroundFormatFillPurpleBlackBorder,
            targets = {
                PushUIConfig.GridFrameHook
            },
            alwaysDisplay = true,
            action = "Toggle",
            alwaysAction = true,
            selected = false,
            binding = "ALT-SHIFT-V"
        }
    },
    groupleft = true,
    right = {
        {
            mode = PushUIFrames.ProgressBar,
            -- skin = dynamic
            targets = {
                PushUIAPI.UnitTarget
            },
            alwaysDisplay = false,
            action = nil,
            fillColor = {
                PushUIColor.lifeColorDynamic
            }
        }
    },
    groupright = false
}

-- UnitFrame Hook
PushUIConfig.UnitFrameHook = {}
PushUIConfig.UnitFrameHook.enable = true
PushUIConfig.UnitFrameHook.anchorTarget = UIParent
PushUIConfig.UnitFrameHook.anchorPoint = "CENTER"
PushUIConfig.UnitFrameHook.HookBar = {
    position = {
        x = -223.57, y = -72
    },
    size = {
        w = 200, h = 40
    }
}
PushUIConfig.UnitFrameHook.Name = {
    display = true,
    size = 14,
    color = function(value, min, max, class)
        return {1, 1, 1, 1}
    end,
    outline = "OUTLINE",   -- "OUTLINE"
    align = "RIGHT",
    fontName = "Fonts\\FRIZQT__.TTF",
    anchorPoint = "TOPRIGHT",   -- anchor to HookBar's TOPLEFT
    position = { x = -PushUISize.padding, y = -PushUISize.padding * 2 }
}
PushUIConfig.UnitFrameHook.LifeBar = {
    display = true,
    orientation = "HORIZONTAL",
    position = {
        x = 0, y = -35
    },
    size = {
        w = 200, h = 5
    },
    anchorPoint = "TOPLEFT",   -- anchor to HookBar's TOPLEFT
    fillColor = { PushUIColor.lifeColorDynamic },   -- To use default statusbar's api, must set this line
    background = function(frame)
        PushUIStyle.BackgroundSolidFormat(frame, 1, 1, 1, 0.2, 1, 1, 1, 0)
    end
}
PushUIConfig.UnitFrameHook.Percentage = {
    display = true,
    size = 24,
    color = function(value, max, min, class)
        return PushUIColor.lifeColorDynamic(value, max, min)
    end,
    outline = "OUTLINE",
    fontName = "Fonts\\FRIZQT__.TTF",
    --fontName = "MSBT Transformers",
    align = "LEFT",
    anchorPoint = "TOPLEFT",   -- anchor to HookBar's TOPLEFT
    position = { x = 0, y = -8 }
}
PushUIConfig.UnitFrameHook.HealthValue = {
    display = true,
    size = 14,
    color = function(value, max, min, class)
        return {1, 1, 1, 1}
    end,
    outline = "",   -- "OUTLINE"
    align = "RIGHT",
    fontName = "Fonts\\FRIZQT__.TTF",
    anchorPoint = "TOPRIGHT",   -- anchor to HookBar's TOPLEFT
    position = { x = -PushUISize.padding, y = -(PushUISize.padding * 3 + 14) }
}
PushUIConfig.UnitFrameHook.Auras = {
    display = true
    -- pending...
}
PushUIConfig.UnitFrameHook.PowerBar = {
    display = true
    -- pending...
}
PushUIConfig.UnitFrameHook.ResourceBar = {
    display = true
    -- pending...
}
