local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local playerUnitFrame = PushUIFrames.UnitFrame(PushUIAPI.PlayerHP, "player", PushUIAPI.PlayerAuras)
playerUnitFrame:set_archor("CENTER")
playerUnitFrame:set_archor_target(UIParent, "CENTER")
playerUnitFrame:set_position(-285, -72)
playerUnitFrame:layout({
    width = 200, 
    height = 40,
    borderColor = PushUIColor.black,
    borderAlpha = 1,
    backgroundColor = PushUIColor.black,
    backgroundAlpha = 0.4,

    healthBarColor = PushUIColor.lifeColorDynamic,
    healthBarHeight = 36,
    healthBarXPosition = 0,
    healthBarYPosition = -2,
    healthBarStyle = "h-l-r",

    nameSize = 24,
    nameXPosition = -20,
    nameYPosition = 10,
    nameFlag = "OUTLINE",
    nameAlign = "LEFT",
    nameColor = function(...) return PushUIColor.white end,
    nameMaxWidth = 140,

    percentageSize = 20,
    percentageXPosition = 120,
    percentageYPosition = 10,
    percentageFlag = "OUTLINE",
    percentageAlign = "RIGHT",
    percentageColor = function(...) return PushUIColor.white end,
    percentageMaxWidth = 100,

    maxHpSize = 12,
    maxHpXPosition = 120,
    maxHpYPosition = -34,
    maxHpMaxWidth = 100,
    maxHpFlag = "OUTLINE",
    maxHpAlign = "RIGHT",
    maxHpColor = function(...) return PushUIColor.white end
});
playerUnitFrame.healthBar:set_alpha(0.7)

playerUnitFrame:set_rightClickAction(function()
    ToggleDropDownMenu(1, nil, PlayerFrameDropDown, playerUnitFrame.hookbar.layer, 0, 0)
end)

PlayerFrame:SetScript("OnEvent", nil)
PlayerFrame:Hide()

-- Hide buff frame
BuffFrame:UnregisterEvent("UNIT_AURA")
BuffFrame:Hide()
TemporaryEnchantFrame:Hide()
