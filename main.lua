local board = require("board")
local bot   = require("bot")
local util  = require("util")

board.setup()

while board.checkactive() do
    board.update()

    io.write("> ")
    local move = io.read()
    if not board.move(move) then
        goto continue
    end

    if board.data.turn == 0 then
        goto continue
    end

    if not board.checkactive() then
        return
    end

    board.update()

    util.wait(1)

    ::botmove::
    bot.move()
    if board.data.turn == 1 then
        goto botmove
    end

    ::continue::
end
