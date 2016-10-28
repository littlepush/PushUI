local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local ttUnitFrame = PushUIFrames.UnitFrame(PushUIAPI.TargetTargetHP, "targettarget", nil)
ttUnitFrame:set_archor("CENTER")
ttUnitFrame:set_archor_target(UIParent, "CENTER")
ttUnitFrame:set_position(430, -112)
ttUnitFrame:layout({
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
    healthBarStyle = "h-r-l",

    nameSize = 13,
    nameXPosition = 82,
    nameYPosition = -1,
    nameFlag = "OUTLINE",
    nameAlign = "LEFT",
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
    maxHpAlign = "RIGHT",
    maxHpColor = function(...) return PushUIColor.white end
});
ttUnitFrame.healthBar:set_alpha(0.7)
