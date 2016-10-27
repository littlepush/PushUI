local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local focusUnitFrame = PushUIFrames.UnitFrame(PushUIAPI.FocusHP, "focus", nil)
focusUnitFrame:set_archor("CENTER")
focusUnitFrame:set_archor_target(UIParent, "CENTER")
focusUnitFrame:set_position(-430, -112)
focusUnitFrame:layout({
    width = 80, 
    height = 15,
    borderColor = PushUIColor.black,
    borderAlpha = 1,
    backgroundColor = PushUIColor.black,
    backgroundAlpha = 0.4,

    healthBarColor = PushUIColor.lifeColorDynamic,
    healthBarHeight = 11,
    healthBarXPosition = 0,
    healthBarYPosition = -2,
    healthBarStyle = "h-l-r",

    nameSize = 13,
    nameXPosition = -162,
    nameYPosition = -1,
    nameFlag = "OUTLINE",
    nameAlign = "RIGHT",
    nameColor = function(...) return PushUIColor.white end,
    nameMaxWidth = 160,

    percentageSize = 11,
    percentageXPosition = 0,
    percentageYPosition = -1    ,
    percentageFlag = "",
    percentageAlign = "CENTER",
    percentageColor = function(...) return PushUIColor.white end,
    percentageMaxWidth = 80,

    maxHpSize = 8,
    maxHpXPosition = 0,
    maxHpYPosition = -17,
    maxHpMaxWidth = 80,
    maxHpFlag = "OUTLINE",
    maxHpAlign = "LEFT",
    maxHpColor = function(...) return PushUIColor.white end
});
focusUnitFrame.healthBar:set_alpha(0.7)

FocusFrame:SetScript("OnEvent", nil)
FocusFrame:Hide()
