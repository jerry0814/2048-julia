function move(line, direction)

    lineLen = length(line)

    nonZeroLine = line[line.>0]

    if direction > 0
        newLine = append!(nonZeroLine, zeros(Int64,lineLen - length(nonZeroLine)))
    elseif direction < 0
        newLine = append!(zeros(Int64, lineLen - length(nonZeroLine)), nonZeroLine)
    end

    return newLine
end


function merge(line)
    lineLen = length(line)
    for idx = 1:lineLen
        nextidx = idx + 1
        if nextidx <= lineLen
            if line[idx] == line[nextidx]

                line[idx] = line[idx]*2
                line[nextidx] = 0
            end
	end
    end
    return line
end


function testmove()
    println("testing move():")
    assert(move([0,0,2,2], 1) == [2,2,0,0])
    assert(move([0,2,0,2], -1) == [0,0,2,2])
    println("test pass")
end

function testmerge()

    println("testing merge():")
    assert(merge([0,2,2,0]) == [0,4,0,0])
    assert(merge([0,2,0,2]) == [0,2,0,2])
    assert(merge([4,4,8,8]) ==[8,0,16,0])
    println("test pass")
end


function gameboard(board)
    boardStr=""
    for rowIdx = 1:size(board,1)
        for colIdx = 1:size(board,2)
            temStr = @sprintf("%6d", board[rowIdx,colIdx])
            boardStr = string(boardStr, temStr)
        end
        boardStr = string(boardStr, "\n")
    end
    return boardStr
end

    
function moveMerge(line, direction)
    line = move(line, direction)
    line = merge(line)
    line = move(line,direction)
end

 
function testmovemerge()
    println("testing moveMerge()")
    assert(moveMerge([0,2,0,2],1)==[4,0,0,0])
    assert(moveMerge([0,2,0,0],-1)==[0,0,0,2])
    println("test pass")
end

 
function getLine(board,dim,index)
    if dim == 1
        return board[index,:] 
    elseif dim == 2
        return board[:,index] 
    end
end


function setLine(board,dim,index,line)
    if dim == 1
        board[index,:] = line
    elseif dim == 2
        board[:,index] = line 
    end
    return board
end


# 1:left -1:right 2:up -2:down
function boardMove(board, direction)
    newBoard = copy(board)
    for rowIdx=1:size(newBoard,abs(direction))

        line = getLine(newBoard, abs(direction), rowIdx)
        newLine = moveMerge(line, direction)

        newBoard = setLine(newBoard,abs(direction), rowIdx, newLine)
    end
    return newBoard
end


function Player(board)
    promptstr = "up:K, down:J, left:H, right:l, quit:q"
    println(promptstr)
    return chomp(readline())
end


function gameLoop(player::Function)
    board = initBoard()  

    while gameState(board) == "continue" 
        println(gameboard(board))
        input = player(board)
        
        if input == "H" || input == "h"
            moveDir = 1
        elseif input == "L" || input == "l"
            moveDir = -1
        elseif input == "K" || input == "k"
            moveDir = 2
        elseif input == "J" || input == "j"
            moveDir = -2
        elseif input == "Q" || input == "q"
            break
        end

        nextBoard = boardMove(board, moveDir)
        if !((nextBoard .== board) == trues(size(board)))
            nextBoard = addTile(nextBoard)  
        end
    
        if gameState(board) == "playerwin"
            println("Congrats! You Win!")
            break
        elseif gameState(board) == "playerlost"
            println("Good effor, but try again")
            break
        end
        board = nextBoard
    end
end


function initBoard(boardsize=4)
    board = zeros(Int64, boardsize, boardsize)
 
    for i = 1:3
        addTile(board)
    end 
    return board
end


function addTile(board)
    board1 = reshape(board,size(board,1)*size(board,2))
    index = find(board1.==0)
    ran_index = rand(1:length(index))    
    tile = push!(ones(Int64,9)*2,4)
    rand_tile = rand(1:length(tile))
    board1[index[ran_index]] = tile[rand_tile]
    board2 = reshape(board1, size(board))
    return board2 
end


function gameState(board)
    if max(board...) == 2048
        return "playerwin"
    elseif length(getLegalMove(board)) > 0
        return "continue"
    else
        return "playerlost"
    end
end


function getLegalMove(board)
    poss_move = [1,-1,2,-2]
    legalMoves = []

    for i in eachindex(poss_move)
        newBoard = boardMove(board, poss_move[i])
        if !(board == newBoard)
            append!(legalMoves, poss_move[i])
        end
    end
    return legalMoves
end


gameLoop(Player)
