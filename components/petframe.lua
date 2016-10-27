local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local petUnitFrame = PushUIFrames.UnitFrame(PushUIAPI.PlayerPetHP, "pet", nil)
petUnitFrame:set_archor("CENTER")
petUnitFrame:set_archor_target(UIParent, "CENTER")
petUnitFrame:set_position(-430, -142)
petUnitFrame:layout({
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
petUnitFrame.healthBar:set_alpha(0.7)
