local board = {}

board.settings = {
    colors = {
        player = "\27[33m",
        bot = "\27[33m",
        clear = "\27[0m"
    },
}

board.data = {
    player = {
        score = 0,
        pockets = { 4, 4, 4, 4, 4, 4 },
    },
    bot = {
        score = 0,
        pockets = { 4, 4, 4, 4, 4, 4 },
    },
    turn = 0, -- 0 = player, 1 = bot
}

function board.reset()
    board.player.score = 0
    board.bot.score = 0
    board.player.pockets = { 4, 4, 4, 4, 4, 4 }
    board.bot.pockets = { 4, 4, 4, 4, 4, 4 }

    board.update()
end

function board.update()
    os.execute("clear")

    local b = "+-------------------+-------------------+\n"
    b = b .. "|   Bot score: 00   |  Player score: 00 |\n"
    b = b .. string.rep("+----", 8)
    b = b .. "+\n"

    b = b .. "|    "
    b = b .. string.rep("| 00 ", 6)
    b = b .. "|    |\n"

    b = b .. "| 00 |"
    b = b .. string.rep("----+", 5)
    b = b .. "----| 00 |\n"

    b = b .. "|    "
    b = b .. string.rep("| 00 ", 6)
    b = b .. "|    |\n"

    b = b .. string.rep("+----", 8)
    b = b .. "+\n"

    b = b .. "     "
    for i = 1, 6, 1 do
        b = b .. "| #" .. tostring(i) .. " "
    end
    b = b .. "|\n"

    b = b .. "     "
    b = b .. string.rep("+----", 6)
    b = b .. '+\n'


    print(b)
end

local function getPlayerFromTurn()
    return board.data.turn == 0 and board.data.player or board.data.bot
end

function board.move(move)
    local turn = getPlayerFromTurn()

    move = tonumber(move)

    if not move then
        return
    end

    local pebbles = turn.pockets[move]

    if pebbles == 0 then
        return
    end

    for i = 0, pebbles, 1 do
        local pindex = (move + i) % (#turn.pockets + 1)
        local mindex = (#turn.pockets + 1) - pindex
        local side = (pindex / (#turn.pockets + 1)) % 2 == 1
        if pindex == 0 then
            if side == 1 then
                turn.score = turn.score + 1
            else
                turn.pockets[#turn] = turn.pockets[#turn] + 1
            end
            goto continue
        end

        if not side then
            mindex = mindex + #turn.pockets + 1
        end

        local pocket = turn.pockets[math.abs(pindex + i)]
        pocket = pocket + 1
        ::continue::
    end
end

return board
