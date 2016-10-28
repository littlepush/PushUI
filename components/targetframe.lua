local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local targetUnitFrame = PushUIFrames.UnitFrame(PushUIAPI.TargetHP, "target", PushUIAPI.TargetAuras)
targetUnitFrame:set_archor("CENTER")
targetUnitFrame:set_archor_target(UIParent, "CENTER")
targetUnitFrame:set_position(285, -72)
targetUnitFrame:layout({
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
    healthBarStyle = "h-r-l",

    nameSize = 24,
    nameXPosition = 80,
    nameYPosition = 10,
    nameFlag = "OUTLINE",
    nameAlign = "RIGHT",
    nameColor = function(...) return PushUIColor.white end,
    nameMaxWidth = 160,

    percentageSize = 20,
    percentageXPosition = -20,
    percentageYPosition = 10,
    percentageFlag = "OUTLINE",
    percentageAlign = "LEFT",
    percentageColor = function(...) return PushUIColor.white end,
    percentageMaxWidth = 80,

    maxHpSize = 12,
    maxHpXPosition = -20,
    maxHpYPosition = -34,
    maxHpMaxWidth = 100,
    maxHpFlag = "OUTLINE",
    maxHpAlign = "LEFT",
    maxHpColor = function(...) return PushUIColor.white end
});
targetUnitFrame.healthBar:set_alpha(0.7)

targetUnitFrame:set_rightClickAction(function()
    ToggleDropDownMenu(1, nil, TargetFrameDropDown, targetUnitFrame.hookbar.layer, 0, 0)
end)

TargetFrame:SetScript("OnEvent", nil)
TargetFrame:Hide()

for i = 1, 5 do
    local _btf = _G["Boss"..i.."TargetFrame"]
    _btf:SetScript("OnShow", _btf.Hide)
    _btf:Hide()
end

for i = 1, 4 do
    local _pmf = _G["PartyMemberFrame"..i]
    _pmf:SetScript("OnShow", _pmf.Hide)
    _pmf:Hide()
end
