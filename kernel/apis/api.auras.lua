local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIAPI.Aura = {}
PushUIAPI.Aura.__index = PushUIAPI.Aura
function PushUIAPI.Aura.new(target, is_buff, index)
    if not target or nil == is_buff or nil == index then return nil end
    local _func = nil
    if is_buff then _func = UnitBuff else _func = UnitDebuff end
    local _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11 = _func(target, index)
    if not _1 then return nil end
    return setmetatable({
        name = _1,
        rank = _2,
        icon = _3,
        count = _4,
        debuffType = _5,
        duration = _6,
        expirationTime = _7,
        unitCaster = _8,
        isStealable = _9,
        shouldConsolidate = _10,
        spellId = _11,
        isbuff = is_buff
        }, 
        PushUIAPI.Aura)
end
setmetatable(PushUIAPI.Aura, {
    __call = function(_, ...) return PushUIAPI.Aura.new(...) end
    })

local function __pui_gainAuras(target, assets)
    assets._buff:clear()
    local i = 1
    repeat 
        local _a = PushUIAPI.Aura(target, true, i)
        if not _a then break end
        assets._buff.push_back(_a)
        i = i + 1
    until false

    assets._debuff:clear()
    i = 1
    repeat 
        local _a = PushUIAPI.Aura(target, false, i)
        if not _a then break end
        assets._debuff.push_back(_a)
        i = i + 1
    until false

    assets:set_current_value({buff = assets._buff, debuff = assets._debuff})
end

-- Auras For Player
PushUIAPI.PlayerAuras = PushUIAPI.Assets("UNIT_AURA")
PushUIAPI.PlayerAuras._buff = PushUIAPI.Array()
PushUIAPI.PlayerAuras._debuff = PushUIAPI.Array()
PushUIAPI.PlayerAuras:set_candisplay(true)  -- Always can display, but may be empty list
function PushUIAPI.PlayerAuras:UNIT_AURA(unit_id)
    if unit_id ~= "player" then return end
    __pui_gainAuras("player", self)
end
-- Initialize
__pui_gainAuras("player", PushUIAPI.PlayerAuras)

-- Auras For Target
PushUIAPI.TargetAuras = PushUIAPI.Assets("UNIT_AURA")
PushUIAPI.TargetAuras._buff = PushUIAPI.Array()
PushUIAPI.TargetAuras._debuff = PushUIAPI.Array()
-- Default is false
PushUIAPI.TargetAuras:set_candisplay(false)
PushUIAPI.TargetHP:add_displayChanged("PUSHUIAPI_TARGET_AURAS", function(can)
    PushUIAPI.TargetAuras:set_candisplay(can)
    if not can then return end
    __pui_gainAuras("target", PushUIAPI.TargetAuras)
end)
function PushUIAPI.TargetAuras:UNIT_AURA(unit_id)
    if not self:can_display() or unit_id ~= "target" then return end
    __pui_gainAuras("target", self)
end

-- by Push Chen
-- twitter: @littlepush
