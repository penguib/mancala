local util = {}

---
---Formats a number in the format of `0X` if < 10, otherwise it returns the number in string form.
---
---@param x integer
---@return string
---@nodiscard
function util.formatnumber(x)
    if x < 10 then
        return "0"..tostring(x)
    end
    return tostring(x)
end

---
---Finds the next nearest multiple of `m` looking forward.
---If `x = 9, m = 5` -> 10 
---
---@param x integer
---@param m integer
---@return integer
---@nodiscard
function util.nearestmult(x, m)
    if x % m == 0 then
        return x
    end
    return (m - (x % m)) + x
end

---
---Pauses program execution for `x` seconds
---
---@param x integer
function util.wait(x)
    local s = tonumber(os.clock() + x)
    while (os.clock() < s) do end
end


return util
