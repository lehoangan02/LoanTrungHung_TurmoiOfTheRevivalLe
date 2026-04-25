local InterpolationEnum = require("Game.Custom.InterpolationEnum")

local Algorithm = {}

function Algorithm:contains(arr, value)
    for _, v in ipairs(arr) do
        if v == value then
            return true
        end
    end
    return false
end

function IsTable(v)
    return type(v) == "table"
end

function IsArray(t)
    if type(t) ~= "table" then
        return false
    end

    local maxIndex = 0
    local count = 0

    for k, _ in pairs(t) do
        if type(k) ~= "number" or k < 1 or k % 1 ~= 0 then
            return false
        end
        if k > maxIndex then
            maxIndex = k
        end
        count = count + 1
    end

    return count == maxIndex
end

function GetEasingFunction(style, dir)
    if style == InterpolationEnum.InterpolationTypeEnum.Jump then 
        return function(t) return t >= 1 and t or 0 end
    elseif style == InterpolationEnum.InterpolationTypeEnum.Linear then
        return function(t) return t end
    elseif style == InterpolationEnum.InterpolationTypeEnum.EaseCubic then
        return dir == InterpolationEnum.InterpolationDirection.InOut and function(t) return t < 0.5 and 4*t^3 or (2 - (2 - t^3)) / 2 end
            or dir == InterpolationEnum.InterpolationDirection.In and function(t) return t^3 end
            or dir == InterpolationEnum.InterpolationDirection.Out and function(t) return 1 - (1 - t^3) end
    end
    return nil
end

function ComposeEasingFunctions(t, outStyle, inStyle)
    if t <= 0 then return 0 end
    if t >= 1 then return 1 end
    if t < 0.5 then
        local fn = GetEasingFunction(outStyle, InterpolationEnum.InterpolationDirection.In)
        if fn then return fn(t * 2) / 2 end
    else
        local fn = GetEasingFunction(inStyle, InterpolationEnum.InterpolationDirection.Out)
        if fn then return 0.5 + fn((t - 0.5) * 2) / 2 end
    end
end