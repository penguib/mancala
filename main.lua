local board = require("board")

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

    ::botmove::

    io.write("# ")
    local bmove = io.read()
    if not board.move(bmove) then
        goto botmove
    end

    if board.data.turn == 1 then
        goto botmove
    end

    ::continue::
end
