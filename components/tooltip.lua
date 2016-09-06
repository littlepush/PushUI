local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

local tooltips = {
    "GameTooltip",
    "ItemRefTooltip",
    "ItemRefShoppingTooltip1",
    "ItemRefShoppingTooltip2",
    "ShoppingTooltip1",
    "ShoppingTooltip2",
    "WorldMapTooltip",
    "ChatMenu",
    "EmoteMenu",
    "LanguageMenu",
    "VoiceMacroMenu",
}

for i = 1, #tooltips do
    local _t = _G[tooltips[i]]
    _t:SetBackdrop(nil)

    local _bg = CreateFrame("Frame", nil, _t)
    _bg:SetPoint("TOPLEFT", 1, -1)
    _bg:SetPoint("BOTTOMRIGHT", -1, 1)
    _bg:SetFrameLevel(_t:GetFrameLevel() - 1)
    PushUIConfig.skinType(_bg)
end

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
    self:SetOwner(parent, "ANCHOR_NONE")
    self:SetPoint("BOTTOMRIGHT", _G[PushUIConfig.RightDockContainer.name], "TOPRIGHT", -5, 15)
end)

local _gtsb = _G["GameTooltipStatusBar"]
_gtsb:SetHeight(5)
_gtsb:ClearAllPoints()
_gtsb:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 1, -2)
_gtsb:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -1, -2)
_gtsb:SetStatusBarTexture(PushUIStyle.TextureClean)
PushUIStyle.BackgroundFormatForProgressBar(_gtsb)

local function __toHex(r, g, b)
    return string.format('|cff%02x%02x%02x', r * 255, g * 255, b * 255)
end
local function __getHexColorByClass(unit)
    local r, g, b = PushUIColor.getColorByClass(unit)
    return __toHex(r, g, b)
end
local classification = {
    worldboss = "",
    rareelite = "R+",
    elite = "+",
    rare = "R",
}

local function __onTooltipSetUnit(tip_data)
    local lines = tip_data:NumLines()
    local _, unit = tip_data:GetUnit()
    if not unit then return end

    local level = UnitLevel(unit) or ""
    local c = UnitClassification(unit)
    local unitName, unitRealm = UnitName(unit)

    if level and level == -1 then
        if c == "worldboss" then
            level = "|cffff0000Boss|r"
        else
            level = "|cffff0000??|r"
        end
    end

    local color = __getHexColorByClass(unit)

    if unitName then
        local name = UnitPVPName(unit) or unitName
        if unitRealm and unitRealm ~= "" then
            _G["GameTooltipTextLeft1"]:SetFormattedText(color.."%s - %s", name, unitRealm)
        else
            _G["GameTooltipTextLeft1"]:SetText(color..name)
        end
    end

    if UnitIsPlayer(unit) then
        local race = UnitRace(unit) or ""

        local guildName, guildRankName = GetGuildInfo(unit)

        if guildName then
            _G["GameTooltipTextLeft2"]:SetText(guildName)
        end

        local n = guildName and 3 or 2
        local class = UnitClass(unit)
        _G["GameTooltipTextLeft"..n]:SetFormattedText("%s %s "..color.."%s", level, race, class)

        if UnitIsPVP(unit) then
            _G["GameTooltipTextLeft"..n + 1]:SetFormattedText("%s (%s)", UnitFactionGroup(unit), PVP)
        end
    elseif UnitIsBattlePet(unit) then
        for i = 2, lines do
            local line = _G["GameTooltipTextLeft"..i]
            local text = line:GetText() or ""
            if text:find("%d") then
                line:SetFormattedText("%s %d %s", PET, UnitBattlePetLevel(unit), PET_TYPE_SUFFIX[UnitBattlePetType(unit)])
                break
            end
        end
    else
        local crType = UnitCreatureType(unit)

        for i = 2, lines do
            local line = _G["GameTooltipTextLeft"..i]
            local text = line:GetText() or ""
            if((level and text:find("^"..LEVEL)) or (crType and text:find("^"..crType))) then
                line:SetFormattedText("%s%s %s", level, classification[c] or "", crType or "")
                break
            end
        end
    end

    --[[ Target line ]]
    local tunit = unit.."target"
    if(UnitExists(tunit) and unit~="player") then
        local color = __getHexColorByClass(tunit)
        local text = ""

        if(UnitName(tunit)==UnitName("player")) then
            text = "T: > YOU <"
        else
            text = "T: "..UnitName(tunit)
        end

        tip_data:AddLine(color..text)
    end

    if msp and unitName then
        local fullName = UnitName("player") == unitName and unitName or (unitName.."-"..(unitRealm or GetRealmName():gsub("%s+", "")))

        if msp.char[fullName] then
            local cu = msp.char[fullName].field["CU"]
            if cu ~= nil and cu ~= "" then
                local len = cu:len()
                if len > 50 then
                    cu = format("%s-\n%s", cu:sub(1, 50), cu:sub(51, min(len, 100)))
                    if len > 100 then
                        cu = cu.."..."
                    end
                end

                GameTooltip:AddLine("|cffdddddd"..cu)
            end
        end
    end
end

GameTooltip:HookScript("OnTooltipSetUnit", __onTooltipSetUnit)
