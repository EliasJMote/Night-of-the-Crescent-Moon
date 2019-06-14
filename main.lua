-- Check if this location has a description by walking over it
function checkWalkableDescription()
    for k,v in ipairs(locations[curLocation]["walkDesc"]) do
        if(coords.x == v.x and coords.y == v.y) then
            writeToTextDisplay(v.des)
            if(v.img ~= nil) then
                npcImg = v.img
                isTalking = true
            end
        end
        if(v.img == nil) then
            isTalking = false
            isSayingWord = false
            curTermToLearn = nil
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

function addKeyTerm(term)
    if(term == nil) then
        return false
    end
    
    -- Check if the key term is in the list already
    for k,v in ipairs(keyTerms) do
        if(v["text"] == term["text"]) then
            return false
        end
    end
    table.insert(keyTerms,term)
    return true
end

-- Write to the game's text display
function writeToTextDisplay(text)

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
    --keyTerms = {"Eye of Truth", "Lantern"}
    keyTerms = {}
    
    keyTermMap = {
                    f="forest",
                 }
    
    curTermToLearn = nil
    
    -- Game locations and their information
    locations = {
                    Ancient_Tower =     {
                                            rooms = {{x=0,y=0},{x=0,y=1},{x=0,y=2},},
                                            mapImage = love.graphics.newImage("Ancient_Tower_Map.png"),
                                            roomImage = love.graphics.newImage("Ancient_Tower.png"),
                                            searDesc = {{x=0,y=0,des={"You take the long road from the Ancient Tower back to the central Hub.","Several paths sprawl before you in the dim moonlight.","Where do you wish to go?","[A]ncient Tower", "[C]rystal Cave", "[E]merald Sea", "[F]orest of Spirits", "[L]ost Hills", "F[o]rgotten Pit"}}},
                                            walkDesc = {{x=0,y=0,des={"A crumbling tower stands before you."}}}
                                        },
                    Bedroom =   {
                                    rooms = {{x=0,y=0},{x=1,y=0},{x=0,y=1},{x=1,y=1}},
                                    mapImage = love.graphics.newImage("Bedroom_Map.png"),
                                    roomImage = love.graphics.newImage("Title Picture.png"),
                                    searDesc = {{x=1,y=1,conds={},des={"You step out of the open window. Several paths sprawl before you in the dim moonlight.","Where do you wish to go?","[A]ncient Tower", "[C]rystal Cave", "[E]merald Sea", "[F]orest of Spirits", "[L]ost Hills", "F[o]rgotten Pit"}}},
                                    walkDesc = {{x=0,y=0,des={"There is a bed in front of you"}},{x=1,y=1,des={"An open window sits in front of you. The curtain blows in the cold wind."}}}
                                },
                    Crystal_Cave = {},
                    Emerald_Sea = {},
                    Forest_of_Spirits = {
                                            rooms = {{x=0,y=0},{x=1,y=0},{x=2,y=0},{x=0,y=1},{x=1,y=1},{x=2,y=1},{x=0,y=2},{x=1,y=2},{x=2,y=2},},
                                            mapImage = love.graphics.newImage("Forest_of_Spirits_Map.png"),
                                            roomImage = love.graphics.newImage("Forest_of_Spirits.png"),
                                            searDesc =  {},
                                            walkDesc =  {
                                                            {
                                                                x=0,y=0,des={
                                                                                "You enter into a very relaxing and soothing forest overflowing with a thin mist. The spirits of the",
                                                                                "forest fly gracefully through the sky as small balls of light, conjuring a dazzling spectacle. The air",
                                                                                "is cool and crisp to the senses; your nose is filled with a fresh, earth scent. You feel at peace",
                                                                                "here, as though the sleeping remains of the fallen buried deep within the earth are protecting",
                                                                                "this area, creating a safe haven."
                                                                            }
                                                            },
                                                            {
                                                                x=2,y=2,des={
                                                                                "You approach one of the spirits of the forest."
                                                                            },
                                                                img = {love.graphics.newImage("Will_o_the_Wisp_1.png"),
                                                                    love.graphics.newImage("Will_o_the_Wisp_2.png"),
                                                                    love.graphics.newImage("Will_o_the_Wisp_3.png"),
                                                                    love.graphics.newImage("Will_o_the_Wisp_4.png"),
                                                                    love.graphics.newImage("Will_o_the_Wisp_5.png"),},
                                                            },
                                                        },
                                            npc =   {
                                                        x=2,
                                                        y=2,
                                                        dialogue=   {
                                                                        default={
                                                                                    text={"I am Cassandra, one of the spirits of the \"Forest\""},
                                                                                    term={text="forest",command="[F]orest"}
                                                                                },
                                                                        forest= {
                                                                                    text={"This forest is a haven for those of us who wander the earth untethered by mortality."},
                                                                                }
                                                                    }
                                                    }
                                        },
                    Forgotten_Pit = {},
                    Graveyard = {},
                    Hub =   {
                                rooms = {{x=0,y=0}},
                                mapImage = love.graphics.newImage("Hub_Map.png"),
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
            love.graphics.draw(titleScreen, 50-20, 33-3)
        elseif(state == "game") then
            if(isTalking == false) then
                love.graphics.draw(locations[curLocation]["roomImage"], 50-20, 33-3)
            else
                if(type(npcImg) == "table") then
                    love.graphics.draw(npcImg[math.floor(timer/20) % #npcImg + 1], 50-20, 33-3)
                else
                    love.graphics.draw(npcImg, 50-20, 33-3)
                end
            end
        end
        
        -- draw auxilliary screen
        love.graphics.rectangle("line", 440, 20, 180 , 150, 10)
        
        -- draw coordinates
        love.graphics.print("Coords        " .. coords.x .. "," .. coords.y, 450, 150)
        
        --if(isTalking == false) then
        
        -- draw map text
        love.graphics.print("Map", 520, 30)
        
        -- draw map
        --if(curLocation == "Bedroom") then
        love.graphics.draw(locations[curLocation]["mapImage"], 450, 115 - 16)
        --end
        
        -- draw coordinates indicator
        if(timer % 60 < 60 / 2) then
            love.graphics.rectangle("fill", 450 + 16 * coords.x, 131 - 16 * coords.y, 16, 16)
        end
        --else
            -- draw key terms text
            --love.graphics.print("Key Terms", 500, 30)
        --end
        
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
            if((curLocation == "Bedroom" and coords.x == 1 and coords.y == 1)
                or (curLocation == "Ancient_Tower" and coords.x == 0 and coords.y == 0)) then
                curLocation = "Hub"
                coords.x = 0
                coords.y = 0
            end
            if(isTalking) then
                writeToTextDisplay(locations[curLocation]["npc"]["dialogue"]["default"]["text"])
                curTermToLearn = locations[curLocation]["npc"]["dialogue"]["default"]["term"]
                writeToTextDisplay({"[S]ay","[L]earn"})
            end
        end
        
        if(isSayingWord and key ~= "p") then
            --if(string.match(key,'[a-z]')) then
            local term = keyTermMap[key]
            for k,v in ipairs(keyTerms) do
                if(v["text"] == term) then
                    if(locations[curLocation]["npc"]["dialogue"][term] ~= nil) then
                        writeToTextDisplay(locations[curLocation]["npc"]["dialogue"][term]["text"])
                    end
                end
            end
            --print(term)
        end
        
        if(key == "s") then
            if(isTalking) then
                isSayingWord = true
                curTermToLearn = nil
                writeToTextDisplay({"Select a word to say:"})
                for k,v in ipairs(keyTerms) do
                    writeToTextDisplay({v["command"]})
                end
            end
        end
        
        if(key == "l") then
            if(isTalking) then
                if(addKeyTerm(curTermToLearn)) then
                    writeToTextDisplay({"Learned key term: " .. curTermToLearn["text"]})
                end
            end
        end
        
        if(curLocation == "Hub") then
            if(key == "a") then
                curLocation = "Ancient_Tower"
                checkWalkableDescription()
            elseif(key == "f") then
                curLocation = "Forest_of_Spirits"
                checkWalkableDescription()
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