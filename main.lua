game_state = "menu"
local sound = love.audio.newSource("boomSound.wav", "stream")
local loseGame = love.audio.newSource("loseSound.wav", "stream")
local addSound = love.audio.newSource("addSound.wav", "stream")
local frames = {}
local currentFrame = 1
local frameDuration = 0.1
local frameTimer = 0
local boom = false

function love.load()
    font = love.graphics.newFont(24)

    -- Ustawienia menu
    menuButtons = {
        {text = "Start", action = function() game_state = "game" end},
    }
    selectedButton = 1
    points = 0
    love.graphics.setFont(love.graphics.newFont(20))
    blocks = {}
    block_to_stop = {}
    squareSize = 50
    speed = 200
    number_of_blocks = 0
    number_blocks_on_level = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    canCreateBlock = true
    genBlocks = true
    addNewBlock()
    
    for i = 1, 6 do
        frames[i] = love.graphics.newImage("img" .. i .. ".png")  -- Wczytaj obrazy klatek (zmień nazwę pliku)
    end
    
end

function love.mousepressed(x, y, button, istouch, presses)
    for i, btn in ipairs(menuButtons) do
        if button == 1 and x > 200 and x < 200 + love.graphics.getFont():getWidth(btn.text) and y > 200 + i * 40 and y < 200 + (i + 1) * 40 then
            btn.action()
        end
    end
end

function addNewBlock()
    if canCreateBlock == false then
      return
    end
    type_of_blocks = {{50, 50}, {100, 50}, {150, 50}, {100, 100}, {50, 150}, {100, 100}, {300, 300}, {400, 400}}
    random_type = math.random(1, #type_of_blocks)

    local block1_sizeX, block1_sizeY = type_of_blocks[random_type][1], type_of_blocks[random_type][2]

    if block1_sizeX == 400 and block1_sizeY == 400 then
      -- "L"-shaped block
        local start_x = 100
        local start_y = 0

        local blockSize = squareSize

        -- Add three blocks horizontally
        for i = 1, 3 do
            table.insert(blocks, {
                x = start_x + (i - 1) * blockSize,
                y = start_y,
                sizeX = blockSize,
                sizeY = blockSize,
                speed = speed,
                canMove = true,
                id = number_of_blocks,
                level = -1
            })
        end

        table.insert(blocks, {
            x = start_x,
            y = start_y - blockSize,
            sizeX = blockSize,
            sizeY = blockSize,
            speed = speed,
            canMove = true,
            id = number_of_blocks,
            level = -1
        })
      return
    end
    if block1_sizeX == 300 and block1_sizeY == 300 then
        -- "L"-shaped block
        local start_x = 100
        local start_y = 0

        local blockSize = squareSize

        -- Add three blocks horizontally
        for i = 1, 3 do
            table.insert(blocks, {
                x = start_x + (i - 1) * blockSize,
                y = start_y,
                sizeX = blockSize,
                sizeY = blockSize,
                speed = speed,
                canMove = true,
                id = number_of_blocks,
                level = -1
            })
        end

        -- Add one block above the second block (forming an "L" shape)
        table.insert(blocks, {
            x = start_x + blockSize,
            y = start_y - blockSize,
            sizeX = blockSize,
            sizeY = blockSize,
            speed = speed,
            canMove = true,
            id = number_of_blocks,
            level = -1
        })
      return
    end
    local horizontal = block1_sizeX / 50
    local vertical = block1_sizeY / 50
    
    local start_x = 100
    local start_y = 0

    for i = 1, vertical do
        for j = 1, horizontal do
            table.insert(blocks, {
                x = start_x + (j - 1) * squareSize,
                y = start_y + (i - 1) * squareSize,
                sizeX = squareSize,
                sizeY = squareSize,
                speed = speed,
                canMove = true,
                id = number_of_blocks,
                level = -1
            })
        end
    end
    number_of_blocks = number_of_blocks + 1
end

function stopAllNeighbourBlocks(id)
    for _, block in ipairs(blocks) do
        if block.id == id then
            table.insert(block_to_stop, block)
        end
    end
end

function game(dt)
      for i, block in ipairs(blocks) do
        if block.canMove then
            block.y = block.y + block.speed * dt

            if block.y + block.sizeY > love.graphics.getHeight() then
                block.y = love.graphics.getHeight() - block.sizeY
                updateLevel()
                stopAllNeighbourBlocks(block.id)
                addSound:play()
                checkLose()
                break
            end

            for j = 1, #blocks do
                if j ~= i then
                    local otherBlock = blocks[j]
                    if otherBlock.speed == 0 and checkCollision(block, otherBlock) then
                        block.y = otherBlock.y - block.sizeY
                        updateLevel()
                        stopAllNeighbourBlocks(block.id)
                        addSound:play()
                        checkLose()
                        break
                    end
                end
            end
        end
    end
    checkLose()
    for _, block in ipairs(block_to_stop) do
        block.speed = 0
        block.canMove = false
        block.level = getLevel(block.y)
        number_blocks_on_level[block.level] = number_blocks_on_level[block.level] + 1
    end
    
    
    local inMove = false
    for _, block in ipairs(blocks) do
      if block.canMove == true then
        inMove = true
        break
      end
    end
    if inMove == false then
      genBlocks = true
    end
    
    if #block_to_stop >= 1 and genBlocks == true then
        addNewBlock()
    end
    
    
    block_to_stop = {}
    checkIsFull()
end

function menu()
  
end

function love.update(dt)
  frameTimer = frameTimer + dt

    if frameTimer >= frameDuration then
        frameTimer = frameTimer - frameDuration

        currentFrame = currentFrame + 1
        if currentFrame > #frames then
            currentFrame = 1 
        end
    end
  if game_state == "menu" then
    menu()
  end
  if game_state == "game" then
    game(dt)
  end
end

function updateLevel()
  number_blocks_on_level = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
  for _, block in ipairs(blocks) do
    if block.level ~= -1 and block.canMove == false and block.speed == 0 then
      number_blocks_on_level[block.level] = number_blocks_on_level[block.level] + 1
    end
  end
end

function checkLose()
  if number_blocks_on_level[10] > 0 then
    showAlert = true
    alertMessage = "Game Over. Points: " .. tostring(points)
    loseGame:play()
    for _, block in ipairs(blocks) do
      table.remove(blocks, _)
      genBlocks = false
      inMove = true
    end
  end
end

function checkIsFull()
    local level = 0
    for _, amount in ipairs(number_blocks_on_level) do
        level = level + 1
        if amount >= 16 then
            local i = #blocks
            genBlocks = false
            while i > 0 do
                local block = blocks[i]
                if block.level == level and level ~= 11 then
                    --number_blocks_on_level[block.level] = number_blocks_on_level[block.level] - 1
                    sound:play()
                    boom = true
                    table.remove(blocks, i)
                elseif block.level > level then
                  --number_blocks_on_level[block.level] = number_blocks_on_level[block.level] - 1
                  block.speed = 250
                  block.canMove = true
                  points = points + 10
                end
                i = i - 1
            end
        end
    end
end

function getLevel(y)
    local rangeWidth = 45
    y = math.floor(y)
    if y <= 560 and y >= 560 - rangeWidth then
        return 1
    end
    if y <= 535 and y >= 535 - rangeWidth then
        return 2
    end
    if y <= 460 and y >= 460 - rangeWidth then
        return 3
    end
    if y <= 410 and y >= 410 - rangeWidth then
        return 4
    end
    if y <= 360 and y >= 360 - rangeWidth then
        return 5
    end
    if y <= 310 and y >= 310 - rangeWidth then
        return 6
    end
    if y <= 260 and y >= 260 - rangeWidth then
        return 7
    end
    if y <= 210 and y >= 210 - rangeWidth then
        return 8
    end
    if y <= 160 and y >= 160 - rangeWidth then
        return 9
    end
    if y <= 110 and y >= 110 - rangeWidth then
      return 10
    end
    if y == 361 then
      return 5
    end
    return 11
end


function checkCollision(blockA, blockB)
    local margin = 5

    return blockA.x < blockB.x + blockB.sizeX - margin and
           blockA.x + blockA.sizeX - margin > blockB.x and
           blockA.y < blockB.y + blockB.sizeY - margin and
           blockA.y + blockA.sizeY - margin > blockB.y and
           blockB.speed == 0
end

function saveGame()
    local data = ""

    for _, block in ipairs(blocks) do
        local blockData = string.format("%f,%f,%f,%f,%f,%s,%d,%d\n",
            block.x, block.y, block.sizeX, block.sizeY, block.speed, tostring(block.canMove), block.id, block.level)
        data = data .. blockData
    end

    local success, message = love.filesystem.write("save.txt", data)

    if success then
        print("Game saved successfully!")
    else
        print("Failed to save game:", message)
    end

end

function love.quit()
    saveGame()
end


function loadGame()
    local contents, size = love.filesystem.read("save.txt")
    if contents then
        blocks = {} -- Wyczyść aktualne bloki, aby wczytać nowe dane

        for line in contents:gmatch("[^\r\n]+") do
            local blockData = {}
            for value in line:gmatch("[^,]+") do
                table.insert(blockData, value)
            end

            if #blockData == 8 then
                local block = {
                    x = tonumber(blockData[1]),
                    y = tonumber(blockData[2]),
                    sizeX = tonumber(blockData[3]),
                    sizeY = tonumber(blockData[4]),
                    speed = tonumber(blockData[5]),
                    canMove = blockData[6] == "true",
                    id = tonumber(blockData[7]),
                    level = tonumber(blockData[8])
                }

                table.insert(blocks, block)
            else
                print("Nieprawidłowa liczba danych w linii:", line)
            end
        end

        print("Pomyślnie wczytano grę!")
    else
        print("Nie udało się wczytać pliku save.txt.")
    end
end

function love.keypressed(key)
    if key == "s" then
        saveGame()
    elseif key == "l" then
        loadGame()
    elseif key == "space" then
        rotateBlockClockwise(blocks)
    end
    
    for _, block in ipairs(blocks) do
        if block.canMove then
            local canMoveLeft = true
            local canMoveRight = true

            for _, otherBlock in ipairs(blocks) do
                if otherBlock ~= block and not otherBlock.canMove then
                    if otherBlock.x + otherBlock.sizeX == block.x and 
                       otherBlock.y + otherBlock.sizeY > block.y and 
                       otherBlock.y < block.y + block.sizeY then
                        canMoveLeft = false
                    end
                    if otherBlock.x == block.x + block.sizeX and 
                       otherBlock.y + otherBlock.sizeY > block.y and 
                       otherBlock.y < block.y + block.sizeY then
                        canMoveRight = false
                    end
                end
            end
            
            if key == "left" and canMoveLeft then
                block.x = block.x - block.sizeX
            elseif key == "right" and canMoveRight then
                block.x = block.x + block.sizeX 
            end
        end
    end
end


function rotateBlockClockwise(blockGroup)
    if #blockGroup == 0 then
        return
    end

    local minX, minY, maxX, maxY = nil, nil, nil, nil

    for _, block in ipairs(blockGroup) do
        if block.speed ~= 0 and block.canMove then
            if minX == nil or block.x < minX then
                minX = block.x
            end
            if minY == nil or block.y < minY then
                minY = block.y
            end
            if maxX == nil or (block.x + block.sizeX) > maxX then
                maxX = block.x + block.sizeX
            end
            if maxY == nil or (block.y + block.sizeY) > maxY then
                maxY = block.y + block.sizeY
            end
        end
    end

    if minX == nil or minY == nil or maxX == nil or maxY == nil then
        return
    end

    local centerX = (minX + maxX) / 2
    local centerY = (minY + maxY) / 2

    for _, block in ipairs(blockGroup) do
        if block.speed ~= 0 and block.canMove then
            local relativeX = block.x + block.sizeX / 2 - centerX
            local relativeY = block.y + block.sizeY / 2 - centerY

            local rotatedX = -relativeY
            local rotatedY = relativeX

            block.x = centerX + rotatedX - block.sizeX / 2
            block.y = centerY + rotatedY - block.sizeY / 2
        end
    end
    
    local number_blocks_in_move = 0
    for _, block in ipairs(blockGroup) do
      if block.canMove == true then
        number_blocks_in_move = number_blocks_in_move + 1
      end
    end
    
    if number_blocks_in_move == 2 or number_blocks_in_move == 4 then
      for _, block in ipairs(blockGroup) do
        if block.canMove == true then
          block.x = block.x + 25
        end
      end
    end
end

function drawGame()
    local yOffset = 100
    love.graphics.setColor(1, 0, 0)
    love.graphics.line(0, yOffset, love.graphics.getWidth(), yOffset)
    love.graphics.setColor(0.4, 0.6, 0.8)
    love.graphics.setLineWidth(1)
    for _, block in ipairs(blocks) do
        love.graphics.setColor(0, 0, 0)
        
        -- Dodaj obramowanie wokół klocka
        love.graphics.rectangle("line", block.x, block.y, block.sizeX, block.sizeY)
        
        love.graphics.setColor(0.4, 0.6, 0.8)
        love.graphics.rectangle("fill", block.x + 1, block.y + 1, block.sizeX - 2, block.sizeY - 2)
    end
    if boom == true then
      love.graphics.draw(frames[currentFrame], 20, 0)
      boom = false
    end
    
    local caption = "Points: " .. tostring(points)
    local font = love.graphics.getFont()

    local textWidth = font:getWidth(caption)
    local textHeight = font:getHeight()

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    love.graphics.setColor(255, 255, 255)

    love.graphics.print(caption, screenWidth - textWidth, 0)
    
    if showAlert then
        love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
        love.graphics.rectangle("fill", 100, 200, 600, 200)

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(alertMessage, 100, 250, 600, "center")
    end
    
end

function drawMenu()
    love.graphics.setFont(font)
    for i, button in ipairs(menuButtons) do
        if i == selectedButton then
            love.graphics.setColor(255, 0, 0)  -- Kolor zaznaczonego przycisku
        else
            love.graphics.setColor(255, 255, 255)  -- Kolor niezaznaczonego przycisku
        end

        love.graphics.print(button.text, 200, 200 + i * 40)
    end
end

function love.draw()
  if game_state == "game" then
    drawGame()
  end
  
  if game_state == "menu" then
    drawMenu()
  end
  
  if game_state == "load" then
    drawGame()
  end
end
