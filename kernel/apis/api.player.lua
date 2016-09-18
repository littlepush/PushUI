local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

-- Exp & Faction
PushUIAPI.PlayerExp = PushUIAPI.Assets("PLAYER_LEVEL_UP", "PLAYER_XP_UPDATE", "UPDATE_EXHAUSTION")
-- Initialize
PushUIAPI.PlayerExp:set_candisplay((UnitLevel("player") ~= MAX_PLAYER_LEVEL))
PushUIAPI.PlayerExp:set_current_value({xp = UnitXP("player"), max_xp = UnitXPMax("player")})

-- On Event
function PushUIAPI.PlayerExp:PLAYER_LEVEL_UP()
    self:set_current_value({xp = UnitXP("player"), max_xp = UnitXPMax("player")})
    if UnitLevel("player") == MAX_PLAYER_LEVEL then
        self:set_candisplay(false)
    end
end
function PushUIAPI.PlayerExp:PLAYER_XP_UPDATE()
    self:set_current_value({xp = UnitXP("player"), max_xp = UnitXPMax("player")})
end
function PushUIAPI.PlayerExp:UPDATE_EXHAUSTION()
    self:set_current_value({xp = UnitXP("player"), max_xp = UnitXPMax("player")})
end

-- Faction Info
PushUIAPI.FactionInfo = PushUIAPI.Assets("UPDATE_FACTION", "CHAT_MSG_COMBAT_FACTION_CHANGE")
-- Initialize
function PushUIAPI.FactionInfo:get_current_faction()
    local _name, _rank, _minrep, _maxrep, _value = GetWatchedFactionInfo()
    if not _name then return nil end
    return {
        name = _name,
        rank = _rank,
        minRep = _minrep,
        maxRep = _maxrep,
        value = _value
    }
end
PushUIAPI.FactionInfo._tempFaction = PushUIAPI.FactionInfo:get_current_faction()
PushUIAPI.FactionInfo:set_candisplay( (nil ~= PushUIAPI.FactionInfo._tempFaction) )
if not PushUIAPI.FactionInfo._tempFaction then
    PushUIAPI.FactionInfo:set_current_value(PushUIAPI.FactionInfo._tempFaction)
end
function PushUIAPI.FactionInfo:UPDATE_FACTION()
    PushUIAPI.FactionInfo._tempFaction = PushUIAPI.FactionInfo:get_current_faction()
    self:set_candisplay(PushUIAPI.FactionInfo._tempFaction ~= nil)
    if _tempFaction then
        PushUIAPI.FactionInfo:set_current_value(PushUIAPI.FactionInfo._tempFaction)
    end
end
function PushUIAPI.FactionInfo:CHAT_MSG_COMBAT_FACTION_CHANGE()
    if not self:can_display() then return end
    PushUIAPI.FactionInfo._tempFaction = PushUIAPI.FactionInfo:get_current_faction()
    PushUIAPI.FactionInfo:set_current_value(PushUIAPI.FactionInfo._tempFaction)
end

-- Unit Info
PushUIAPI.PlayerHP = PushUIAPI.Assets("UNIT_HEALTH")
PushUIAPI.PlayerHP:set_candisplay(true)
PushUIAPI.PlayerHP:set_current_value({hp = UnitHealth("player"), max_hp = UnitHealthMax("player")})
function PushUIAPI.PlayerHP:UNIT_HEALTH()
    PushUIAPI.PlayerHP:set_current_value({hp = UnitHealth("player"), max_hp = UnitHealthMax("player")})
end

-- Artifact 
PushUIAPI.Artifact = PushUIAPI.Assets("ARTIFACT_XP_UPDATE")
local _hasArtifact = HasArtifactEquipped()
local function __gatherAritfactInfo()
    local _, _, _name, _, totalXP, pointsSpent, _, _, _, _, _, _ = C_ArtifactUI.GetEquippedArtifactInfo();
    local numPoints = 0;
    local xpForNextPoint = C_ArtifactUI.GetCostForPointAtRank(pointsSpent);
    while totalXP >= xpForNextPoint and xpForNextPoint > 0 do
        totalXP = totalXP - xpForNextPoint;

        pointsSpent = pointsSpent + 1;
        numPoints = numPoints + 1;

        xpForNextPoint = C_ArtifactUI.GetCostForPointAtRank(pointsSpent);
    end
    return {
        name = _name,
        value = totalXP,
        maxValue = xpForNextPoint
    }
end
PushUIAPI.Artifact:set_candisplay(_hasArtifact)
if _hasArtifact then
    local _artifact = __gatherAritfactInfo()
    PushUIAPI.Artifact:set_current_value(_artifact)
end
function PushUIAPI.Artifact:ARTIFACT_XP_UPDATE()
    local _artifact = __gatherAritfactInfo()
    PushUIAPI.Artifact:set_current_value(_artifact)
end

-- Get Pet Info
PushUIAPI.PlayerPetHP = PushUIAPI.Assets("UNIT_PET", "UNIT_HEALTH")
local _hasPet = UnitExists("pet")
PushUIAPI.PlayerPetHP:set_candisplay(_hasPet)
if _hasPet then
    PushUIAPI.PlayerPetHP:set_current_value({hp = UnitHealth("pet"), max_hp = UnitHealthMax("pet")})
end
function PushUIAPI.PlayerPetHP:UNIT_PET(unit_id)
    if unit_id ~= "player" then return end
    local _has_pet = UnitExists("pet")
    self:set_candisplay(_has_pet)

    if _has_pet then
        PushUIAPI.PlayerPetHP:set_current_value({hp = UnitHealth("pet"), max_hp = UnitHealthMax("pet")})
    end
end
function PushUIAPI.PlayerPetHP:UNIT_HEALTH(unit_id)
    if not self:can_display() or unit_id ~= "pet" then return end
    PushUIAPI.PlayerPetHP:set_current_value({hp = UnitHealth("pet"), max_hp = UnitHealthMax("pet")})
end

-- by Push Chen
-- twitter: @littlepush
