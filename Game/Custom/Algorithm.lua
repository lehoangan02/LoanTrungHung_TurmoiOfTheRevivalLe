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