-- Write to the game's text display
function writeToTextDisplay(text)
    
    -- Reverse the text order
    --text = revArray(text)
    
    --print(#text)
    -- For each line in the text, insert them into the text display at the start in reverse order
    for k,v in ipairs(text) do
        table.insert(curText, v)
    end
    
    -- Truncate the display text until there are only 7 text lines
    while(#curText > 9) do
        table.remove(curText,1)
    end
        
end

-- check if a room exists before moving into it
function checkIfRoomExists(curLocation, x, y)
    for k,v in ipairs(locations[curLocation]["rooms"]) do
        if(v.x == x and v.y == y) then
            return true
        end
    end
    return false
end



function love.load()

    --font = love.graphics.newFont("prstart.ttf")
    --love.graphics.setFont(font)
    
    love.graphics.setColor(0, 255, 0, 1)
    love.graphics.setDefaultFilter("nearest", "nearest", 0)
    love.window.setMode(love.graphics.getWidth(), love.graphics.getHeight(), {resizable = true})
    
    titleScreen = love.graphics.newImage("Title Picture.png")
    state = "title"
    isTalking = false
    curLocation = "Bedroom"
    coords = {x=0,y=0}
    locations = {
                    Bedroom =   {
                                    width = 2,
                                    height = 2,
                                    rooms = {{x=0,y=0},{x=1,y=0},{x=0,y=1},{x=1,y=1}},
                                    mapImage = love.graphics.newImage("Bedroom_Map.png"),
                                    descriptions = {{x=0,y=0,des="There is a bed in front of you"},}
                                },
                }
    items = {}
    scale = {}
    --curText = {"Night of the Crescent Moon Ver " .. gameVersion .. ", "A text adventure by Elias Mote", "Copyright (c) Roc Studios 2019"}
    curText = {"","","","","","Night of the Crescent Moon Ver " .. gameVersion, "A text adventure by Elias Mote", "Copyright (c) Roc Studios 2019",""}
    timer = 0
end

function love.update(dt)
    scale.x = love.graphics.getWidth()/640
    scale.y = love.graphics.getHeight()/360
    
    if(state == "title" or state == "game") then
        timer = timer + 1
    end
    if(state == "title" and (timer == 60 * 3 or love.keyboard.isDown("return"))) then
        writeToTextDisplay({"You are in a bedroom"})
        state = "game"
    end
end

function love.draw()
    
    -- scale the window
    love.graphics.scale(scale.x,scale.y)
    
    if(state == "game" or state == "title") then
    
        -- draw image screen
        love.graphics.rectangle("line", 20, 20, 400, 150, 10)
        love.graphics.draw(titleScreen, 40, 25)
        
        -- draw auxilliary screen
        love.graphics.rectangle("line", 440, 20, 180 , 150, 10)
        
        -- draw coordinates
        love.graphics.print("Coords        " .. coords.x .. "," .. coords.y, 450, 150)
        
        if(isTalking == false) then
        
            -- draw map text
            love.graphics.print("Map", 520, 30)
            
            -- draw map
            love.graphics.draw(locations[curLocation]["mapImage"], 450, 115)
            
            -- draw coordinates indicator
            if(timer % 60 < 60 / 2) then
                love.graphics.rectangle("fill", 450 + 16 * coords.x, 131 - 16 * coords.y, 16, 16)
            end
        else
            -- draw key terms text
            love.graphics.print("Key Terms", 500, 30)
        end
        
        -- draw text screen
        love.graphics.rectangle("line", 20, 190, 600 , 150, 10)
        
        -- draw text
        for k,v in ipairs(curText) do
            love.graphics.print(v, 30, 186 + 13 * k)
        end
        
        -- draw blinking cursor
        if(timer % 60 < 60 / 2) then
            love.graphics.rectangle("fill", 30 , 317 , 8 , 12)
        end
        
    elseif(state == "inventory") then
        -- draw inventory screen
        love.graphics.rectangle("line", 20, 20, 600, 150, 10)
        
        -- draw inventory text
        love.graphics.print("Inventory", 280, 30)
        
        -- draw key terms screen
        love.graphics.rectangle("line", 20, 190, 600, 150, 10)
        
        -- draw key terms text
        love.graphics.print("Key terms", 280, 200)
        
        -- draw items
        for i in ipairs(items) do
            love.graphics.print(items[i], 60, 60)
        end
    end
end

function love.keypressed(key, scancode, isrepeat)
    
    if(state == "game") then
        -- Move player
        if(key == "up") then
            if(checkIfRoomExists(curLocation, coords.x, coords.y+1)) then
                coords.y = coords.y + 1
            end
        end
        
        if(key == "down") then
            if(checkIfRoomExists(curLocation, coords.x, coords.y-1)) then
                coords.y = coords.y - 1
            end
        end
        
        if(key == "left") then
            if(checkIfRoomExists(curLocation, coords.x-1, coords.y)) then
                coords.x = coords.x - 1
            end
        end
        
        if(key == "right") then
            if(checkIfRoomExists(curLocation, coords.x+1, coords.y)) then
                coords.x = coords.x + 1
            end
        end
    end
    -- Pause game
    if(key == "p") then
        if(state == "game") then
            state = "inventory"
        elseif(state == "inventory") then
            state = "game"
        end
    end
end