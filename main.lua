-- Check if this location has a description by walking over it
function checkWalkableDescription()
    for k,v in ipairs(locations[curLocation]["walkDesc"]) do
        if(coords.x == v.x and coords.y == v.y) then
            writeToTextDisplay(v.des)
        end
    end
end

-- Check if this location has a description from searching
function checkSearchableDescription()
    for k,v in ipairs(locations[curLocation]["searDesc"]) do
        if(coords.x == v.x and coords.y == v.y) then
            writeToTextDisplay(v.des)
        end
    end
end

-- Write to the game's text display
function writeToTextDisplay(text)
    
    -- Reverse the text order
    --text = revArray(text)
    
    --print(#text)
    -- For each line in the text, insert them into the text display at the start in reverse order
    table.insert(curText, "\n")
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
    
    -- Locations: Ancient Tower, Bedroom, Crystal Cave, Emerald Sea, Forest of Spirits, Forgotten Pit, Lost Hills
    curLocation = "Bedroom"
    coords = {x=0,y=0}
    keyTerms = {"Eye of Truth", "Lantern"}
    
    -- Game locations and their information
    locations = {
                    Ancient_Tower =     {
                                            width = 1,
                                            height = 3,
                                            rooms = {{x=0,y=0},{x=0,y=1},{x=0,y=2},},
                                            --mapImage = love.graphics.newImage("Bedroom_Map.png"),
                                            searDesc = {},
                                            walkDesc = {{x=0,y=0,des=""},}
                                        },
                    Bedroom =   {
                                    width = 2,
                                    height = 2,
                                    rooms = {{x=0,y=0},{x=1,y=0},{x=0,y=1},{x=1,y=1}},
                                    mapImage = love.graphics.newImage("Bedroom_Map.png"),
                                    roomImage = love.graphics.newImage("Title Picture.png"),
                                    searDesc = {{x=1,y=1,conds={},des={"You step out of the open window. Several paths sprawl before you in the dim moonlight.","Where do you wish to go?","[A]ncient Tower", "[C]rystal Cave", "[E]merald Sea", "[F]orest of Fallen Spirits", "[L]ost Hills", "Forgotten [P]it"}}},
                                    walkDesc = {{x=0,y=0,des={"There is a bed in front of you"}},{x=1,y=1,des={"An open window sits in front of you. The curtain blows in the cold wind."}}}
                                },
                    Crystal_Cave = {},
                    Emerald_Sea = {},
                    Forest_Spirits = {},
                    Forgotten_Pit = {},
                    Graveyard = {},
                    Hub =   {
                                width = 1,
                                height = 1,
                                rooms = {{x=0,y=0}},
                                --mapImage = {},
                                searDesc = {},
                                walkDesc = {{x=0,y=0,des=""}},
                                roomImage = love.graphics.newImage("Hub.png"),
                            },
                    Lost_Hills = {},
                }
    notes = {}
    items = {}
    scale = {}
    curText = {"","","","","Night of the Crescent Moon Ver " .. gameVersion, "A text adventure by Elias Mote", "Testing done by Dred4170", "Copyright (c) Roc Studios 2019", "Press enter to start"}
    timer = 0
end

function love.update(dt)
    scale.x = love.graphics.getWidth()/640
    scale.y = love.graphics.getHeight()/360
    
    if(state == "title" or state == "game") then
        timer = timer + 1
    end
    if(state == "title" and love.keyboard.isDown("return")) then
        writeToTextDisplay({"You are in a small bedroom. Your unmade bed lies before you. A coyote howls in the distance. An", 
                "ethereal voice can be heard, calling your name from afar."})
        state = "game"
    end
end

function love.draw()
    
    -- scale the window
    love.graphics.scale(scale.x,scale.y)
    
    if(state == "game" or state == "title") then
    
        -- draw image screen
        love.graphics.rectangle("line", 20, 20, 400, 150, 10)
        
        if(state == "title") then
            love.graphics.draw(titleScreen, 50, 33)
        elseif(state == "game") then
            love.graphics.draw(locations[curLocation]["roomImage"], 50, 33)
        end
        
        -- draw auxilliary screen
        love.graphics.rectangle("line", 440, 20, 180 , 150, 10)
        
        -- draw coordinates
        love.graphics.print("Coords        " .. coords.x .. "," .. coords.y, 450, 150)
        
        if(isTalking == false) then
        
            -- draw map text
            love.graphics.print("Map", 520, 30)
            
            -- draw map
            if(curLocation == "Bedroom") then
                love.graphics.draw(locations[curLocation]["mapImage"], 450, 115)
            end
            
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
                checkWalkableDescription()
            end
        end
        
        if(key == "down") then
            if(checkIfRoomExists(curLocation, coords.x, coords.y-1)) then
                coords.y = coords.y - 1
                checkWalkableDescription()
            end
        end
        
        if(key == "left") then
            if(checkIfRoomExists(curLocation, coords.x-1, coords.y)) then
                coords.x = coords.x - 1
                checkWalkableDescription()
            end
        end
        
        if(key == "right") then
            if(checkIfRoomExists(curLocation, coords.x+1, coords.y)) then
                coords.x = coords.x + 1
                checkWalkableDescription()
            end
        end
        
            -- Search area
        if(key == "return") then
            checkSearchableDescription()
            if(curLocation == "Bedroom" and coords.x == 1 and coords.y == 1) then
                curLocation = "Hub"
                --writeToTextDisplay({"Several paths sprawl before you in the dim moonlight.","Where do you wish to go?","[A]ncient Tower", "[C]rystal Cave", "[E]merald Sea", "[F]orest of Fallen Spirits", "[L]ost Hills", "Forgotten [P]it"})
                coords.x = 0
                coords.y = 0
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