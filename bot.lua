local board = require("board")
local util  = require("util")

local bot = {}

bot.settings = {
    level = 5, -- max
}


---
---Calculates the amount of pebbles that will be captured from index `x` of the current side. Pebbles that happen to land into the bank during a move will be counted.
---
---@private
---@param x integer
---@return integer
---@nodiscard
function bot.calccapture(x)
    local p = board.data.bot.pockets[x]
    return 1
end

function bot.move()
    -- Top moves
    -- 1) Get last pebble to land into bank while closest to bank
    -- 2) Land in empty pocket on other side to capture
    -- 3) Get pebble into bank
    -- 4) Random move
    --

    local data = board.data.bot
    local udata = board.data.user
    local pockets = board.settings.pockets
    local captures = {}

    for i = pockets, 1, -1 do
        local p = data.pockets[i]
        if udata.pockets[pockets - i + 1] == 0 then
            table.insert(captures, i)
        end
        if p + i == pockets + 1 then
            board.move(tostring(i))
            return
        end
    end

    if #captures > 0 then
        local m = {}
        for i = 1, #captures, 1 do
            m[i] = util.calccapture(i)
        end
        table.sort(m)
        board.move(tostring(m[1]))
        return
    end

    math.randomseed(os.time())
    while true do
        local move = math.random(1, pockets)
        if data.pockets[move] > 0 then
            board.move(tostring(move))
            return
        end
    end

end

return bot
