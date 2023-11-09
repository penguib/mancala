local util = require "util"
---@class Board
---@field settings table Configuration of the board. Settings are all set to the default as in a real game.
---@field data table A table that holds all data for the player and the bot. Keeps track of score, pockets, and turn.
---@field user table Table within the data table that holds the player's pocket data and score.
---@field bot table Table within the data table that holds the bot's pocket data and score.
local board = {}

board.settings = {
    colors = {
        user = "\27[33m",
        bot = "\27[34m",
        clear = "\27[0m"
    },
    pocketval = 4,
    pockets = 6,
    movedelay = 1,
}

---@alias player table
board.data = {
    user = {
        score = 0,
        pockets = {},
    },
    bot = {
        score = 0,
        pockets = {},
    },
    turn = 0, -- 0 = user, 1 = bot
    active = true,
}

---
---Sets the board to the default values.
---
function board.setup()
    for _ = 1, board.settings.pockets, 1 do
        table.insert(board.data.user.pockets, board.settings.pocketval)
        table.insert(board.data.bot.pockets, board.settings.pocketval)
    end
end

---
---Resets the board to the default values and redraws the board.
---
function board.reset()
    board.user.score = 0
    board.bot.score = 0
    board.setup()
    board.update()
end

---
---Updates and draws the board with the data according to `board.data`. 
---
function board.update()
    os.execute("clear")
    local settings = board.settings
    local data = board.data
    local colors = settings.colors

    local b = "+-------------------+-------------------+\n"
    b = b .. "|   Bot score: 00   |  Player score: 00 |\n"
    b = b .. string.rep("+----", settings.pockets + 2)
    b = b .. "+\n"

    b = b .. "|    "
    for i = #data.bot.pockets, 1, -1 do
        b = b .. "| " .. colors.bot .. util.formatnumber(data.bot.pockets[i]) .. colors.clear .. " "
    end
    b = b .. "|    |\n"

    b = b .. "| " .. colors.bot .. util.formatnumber(data.bot.score) .. colors.clear .. " |"
    b = b .. string.rep("----+", settings.pockets - 1)
    b = b .. "----| " .. colors.user .. util.formatnumber(data.user.score) .. colors.clear  .. " |\n"

    b = b .. "|    "
    for i = 1, #data.user.pockets, 1 do
        b = b .. "| " .. colors.user .. util.formatnumber(data.user.pockets[i]) .. colors.clear .. " "
    end
    b = b .. "|    |\n"

    b = b .. string.rep("+----", settings.pockets + 2)
    b = b .. "+\n"

    b = b .. "     "
    for i = 1, settings.pockets, 1 do
        b = b .. "| #" .. tostring(i) .. " "
    end
    b = b .. "|\n"

    b = b .. "     "
    b = b .. string.rep("+----", settings.pockets)
    b = b .. '+\n'


    print(b)
end

---
---Grabs the data table of either the bot or the player with the `board.data.turn` variable.
---
---@private
---@return player
---@nodiscard
function board.getPlayerFromTurn()
    return board.data.turn == 0 and board.data.user or board.data.bot
end

---
---Grabs the data table of the bot or the player with the `board.data.turn` variable inverted.
---
---@private
---@return player
---@nodiscard
function board.otherside()
    return board.data.turn == 1 and board.data.user or board.data.bot
end

---
---Checks if all pebbles have been captured and sets the active setting accordingly.
---
---@return boolean
---@nodiscard
function board.checkactive()
    local a = board.getPlayerFromTurn()
    local b = board.otherside()
    for i = 1, board.settings.pockets, 1 do
        if a.pockets[i] > 0 then return true end
        if b.pockets[board.settings.pockets - i + 1] > 0 then return true end
    end
    return false
end

---
---Picks up and moves the pebbles from the given pocket `m`. Returns false if there was a problem with the move.
---
---@param m string
---@return boolean
---@nodiscard
function board.move(m)
    local turn = board.getPlayerFromTurn()
    local other = board.otherside()
    local move = tonumber(m)
    local pocketsize = #turn.pockets

    if not move then
        return false
    end

    local pebbles = turn.pockets[move]

    if pebbles == 0 then
        return false
    end

    turn.pockets[move] = 0

    local jumps = 0;
    local anotherturn = false
    for i = 1, pebbles, 1 do
        local pindex = (move + i + jumps) % (pocketsize + 1)
        local nm = util.nearestmult(move + i, pocketsize + 1)
        local side = (nm / (pocketsize + 1)) % 2 == 1

        if pindex == 0 then
            if side then
                turn.score = turn.score + 1
                if i == pebbles then
                    anotherturn = true
                end
            else
                turn.pockets[1] = turn.pockets[1] + 1
                -- other.pockets[1] = other.pockets[1] + 1
                jumps = jumps + 1
            end
            goto continue
        end

        --definitely need to extract this into a function
        if not side then
            other.pockets[pindex] = other.pockets[pindex] + 1
            if i == pebbles and other.pockets[pindex] - 1 == 0 then
                local o = board.settings.pockets - pindex + 1
                if turn.pockets[o] > 0 then
                    turn.score = turn.score + other.pockets[o] + 1
                    other.pockets[pindex] = 0
                    turn.pockets[o] = 0
                end
            end
            goto continue
        end

        turn.pockets[pindex] = turn.pockets[pindex] + 1

        if i == pebbles and turn.pockets[pindex] - 1 == 0 then
            local o = board.settings.pockets - pindex + 1
            if other.pockets[o] > 0 then
                turn.score = turn.score + other.pockets[o] + 1
                turn.pockets[pindex] = 0
                other.pockets[o] = 0
            end
        end

        ::continue::
        util.wait(board.settings.movedelay)
        board.update()
    end

    if not anotherturn then
        board.data.turn = 1 - board.data.turn
    end

    return true
end

return board
