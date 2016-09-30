local 
    PushUISize, PushUIColor, 
    PushUIStyle, PushUIAPI, 
    PushUIConfig, PushUIFrames = unpack(select(2, ...))

PushUIFrames.__countByType = PushUIAPI.Map()
PushUIFrames.__objectPoolByType = PushUIAPI.Map()

function __generateNewObjectNameByType(type)
    if PushUIFrames.__countByType:contains(type) == false then
        PushUIFrames.__countByType:set(type, 0)
    end
    local _count = PushUIFrames.__countByType:object(type)
    _count = _count + 1
    local _name = "PushUI_"..type.."_Name_".._count
    PushUIFrames.__countByType:set(type, _count)
    return _name
end

function __generateNewObjectByType(type)
    if not type then return nil end
    if PushUIFrames.__objectPoolByType:contains(type) == false then
        local _objPool = PushUIAPI.Pool(function()
            local _objectName = __generateNewObjectNameByType(type)
            local _obj = CreateFrame(type, _objectName)
            _obj.uiname = _objectName

            _obj:SetBackdrop({
                bgFile = PushUIStyle.TextureClean,
                edgeFile = PushUIStyle.TextureClean,
                tile = true,
                tileSize = 1,
                edgeSize = 1,
                insets = { left = 0, right = 0, top = 0, bottom = 0 }
                })
            return _obj
        end)
        PushUIFrames.__objectPoolByType:set(type, _objPool)
    end
    return PushUIFrames.__objectPoolByType:object(type):get()
end

function __destroyObjectOfType(type, obj)
    PushUIFrames.__objectPoolByType:object(type):release(obj)
end

-- by Push Chen
-- twitter: @littlepush

