local board = require("board")

local bot = {}

bot.settings = {
    level = 5, -- max
}


---
---Calculates the amount of pebbles that will be captured from index `x` of the
---current side. Pebbles that happen to land into the bank during a move will be 
---counted. Returns the pocket index of the bot's side if a capture is possible.
---Returns `-1` if the capture is not feasible.
---
---@private
---@param x integer
---@return integer
---@nodiscard
function bot.calccapture(x)
    local pockets = board.settings.pockets
    local p = board.data.bot.pockets[x]
    local u = pockets - x + 1

    for i = 1, pockets, 1 do
        if p == ((pockets - i) + 1) + (pockets - u) then
            return p
        end
    end

    return -1
end


---
---Finds the best capture from a list of pockets that are able to land in an
---empty player pocket. Returns the index of the best capture that puts the bot
---in the best position possible. If a capture is found to capture 0 pebbles 
---(i.e. the pocket can land in an empty player pocket directly across from it 
---yeilding 0), `-1` is returned.
---
---@private
---@param x table Possible captures
---@param y table Corresponding pebble values
---@return integer
---@nodiscard
function bot.bestcapture(x, y)
    if #x ~= #y then return -1 end
    local m = 0
    local n = 1
    for i = 1, #x, 1 do
        if y[i] > m then
            m = y[i]
            n = x[i]
        end
    end
    return n
end


---
---Attempts to find the pocket index, on the bot's side, to land in pocket `x`
---of the player's side to capture. This function does not include if a capture
---includes pockets that are directly across from each other.
---
---@private
---@param x integer
---@return integer
---@nodiscard
function bot.findcapture(x)
    local pockets = board.settings.pockets
    local botpockets = board.data.bot.pockets

    for i = pockets, 1, -1 do
        if i + x == pockets + 1 then goto continue end
        local required = ((pockets - i) + 1) + x
        if botpockets[i] == required then
            return i
        end

        ::continue::
    end
    return -1
end

---
---Finds the best move on the board and moves.
---
---@public
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
        -- INFO: This is only checking for captures on the player side. In the
        -- future we need to be checking for captures that wrap around onto 
        -- the bot side. Then way into the future, a capture may be the best
        -- move.
        if udata.pockets[pockets - i + 1] == 0 then
            local cancapture = bot.findcapture(pockets - i + 1)
            if cancapture > -1 then
                table.insert(captures, cancapture)
            end
        end
        if p + i == pockets + 1 then
            board.move(tostring(i))
            return
        end
    end

    if #captures > 0 then
        local m = {}
        for i = 1, #captures, 1 do
            local peb = data.pockets[captures[i]]
            -- INFO: currently, this should only work if there isn't enough
            -- pebbles to wrap back around. This is a good starting equation
            -- to calculate which pocket a pebble will land in
            local ind = peb - (pockets - captures[i] + 1)
            table.insert(m, data.pockets[pockets - ind])
        end
        local c = bot.bestcapture(captures, m)
        if c > -1 then
            board.move(tostring(c))
            return
        end
    end

    math.randomseed(os.time())
    while true do
        local move = math.random(pockets)
        if data.pockets[move] > 0 then
            board.move(tostring(move))
            return
        end
    end

end

return bot
