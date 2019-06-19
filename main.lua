-- Check if this location has a description by walking over it
function checkWalkableDescription()
    numOfTimesPictureChecked = 0
    isUsingItem = false
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
    
    isUsingItem = false
    
    -- Serach the spot
    for k,v in ipairs(locations[curLocation]["searDesc"]) do
        if(coords.x == v.x and coords.y == v.y) then
            if(v.cond ~= nil) then
                for i in ipairs(items) do
                    if(items[i]["text"] == v.cond and items[i]["enabled"]) then
                        writeToTextDisplay(v.des)
                        return true
                    end
                end
                if(v.cond == "Lantern") then
                    writeToTextDisplay({"It's too dark!"})
                elseif(v.cond == "Phase Amulet") then
                    writeToTextDisplay({"The painting sits there."})
                elseif(v.cond == "Sword Hilt") then
                    writeToTextDisplay({"Half of a sword blade is embedded into the altar. It seems to be missing a hilt..."})
                --elseif(v.cond == "
                end
                return false
            else
                if(v.item == "Lantern") then
                    for i in ipairs(items) do
                        if(v.item == items[i]["text"]) then
                            return
                        end
                    end
                    writeToTextDisplay(v.des)
                    table.insert(items, {text="Lantern",command="[L]antern",enabled=false})
                elseif(v.item == "Phase Amulet") then
                    for i in ipairs(items) do
                        if(v.item == items[i]["text"]) then
                            return
                        end
                    end
                    writeToTextDisplay(v.des)
                    table.insert(items, {text="Phase Amulet",command="P[h]ase Amulet",enabled=false})
                else
                    writeToTextDisplay(v.des)
                    return true
                end
            end
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
    
    love.graphics.setColor(0, 255, 0, 1)
    love.graphics.setDefaultFilter("nearest", "nearest", 0)
    love.window.setMode(love.graphics.getWidth(), love.graphics.getHeight(), {resizable = true})
    
    titleScreen = love.graphics.newImage("Title Picture.png")
    state = "title"
    isTalking = false
    isUsingItem = false
    eyeOfTruthOn = false
    numOfTimesPictureChecked = 0
    
    ancientTowerTop = love.graphics.newImage("Ancient_Tower_Top.png")
    
    -- Locations: Ancient Tower, Bedroom, Crystal Cave, Emerald Sea, Forest of Spirits, Forgotten Pit, Lost Hills
    curLocation = "Bedroom"
    coords = {x=0,y=0}
    keyTerms = {{text="Voice",command="[V]oice",term="Voice"},
                --{text="Eye of Truth",command="[E]ye of Truth",term="Eye_of_Truth"},
                --{text="Phase Pendant",command="P[h]ase Pendant",term="Phase_Pendant"},
                }
    items = {
                --{text="Eye of Truth",command="[E]ye of Truth",enabled=false},
                --{text="Phase Pendant",command="P[h]ase Pendant",enabled=false},
                --{text="Sword Hilt",command="[S]word Hilt",enabled=false},
            }
    
    keyTermMap = {
                    e="Eye_of_Truth",
                    f="Forest",
                    h="Phase_Pendant",
                    o="Lost_Hills",
                    v="Voice",
                    w="Sword_Hilt"
                 }
    
    curTermToLearn = nil
    
    lanternImg = {love.graphics.newImage("Lantern_1.png"), love.graphics.newImage("Lantern_2.png")}
    
    -- Game locations and their information
    locations = {
                    Ancient_Tower =     {
                                            rooms = {{x=0,y=0},{x=0,y=1},{x=0,y=2},},
                                            mapImage = love.graphics.newImage("Ancient_Tower_Map.png"),
                                            roomImage = love.graphics.newImage("Ancient_Tower.png"),
                                            searDesc =  {
                                                            {x=0,y=0,des={"You take the long road from the Ancient Tower back to the central Hub.","Several paths sprawl before you in the dim moonlight.","Where do you wish to go?","[A]ncient Tower", "[C]rystal Cave", "[E]merald Sea", "[F]orest of Spirits", "[L]ost Hills", "F[o]rgotten Pit"}
                                                            },
                                                            {x=0,y=1,cond="Phase Amulet",des={"You step through the painting into another world"}},
                                                            {x=0,y=2,cond="Sword Hilt",des={"You plunge the sword hilt into the altar."}},
                                                        },
                                                        
                                            walkDesc =  {
                                                            {
                                                                x=0,y=0,des={
                                                                                "A crumbling abandoned tower stands before you. Black, forboding clouds blanket the bleak sky.",
                                                                                "The stone tower is thick with wet, mossy vegetation. A heavy wooden door with steel",
                                                                                "reinforcements stands in your way. The thick door ring is engraved with the head of a dragon.",
                                                                                "The knocker is aged with rust, suggesting it hasn't seen an outsider in some time.",
                                                                            }
                                                            },
                                                            {
                                                                x=0,y=1,des={
                                                                                "You step through, encountering a large ornate picture hanging on the wall. The antique is",
                                                                                "covered top to bottom in dust, but is otherwise undamaged. The picture is of the inside of a",
                                                                                "grand cathedral that has aged wretchedly. Blue candles sit melted in cast bronze holders, and",
                                                                                "an enormous pipe organ dominates the frame. The pipes reach for the heavens; however, many",
                                                                                "of them are smashed or twisted around in a horrific display of strange art. Stained glass windows",
                                                                                "sag with lengthy age, contorting images of priests and angels. A lone musical sheet sits on the",
                                                                                "organ, perfectly immaculate and pristine amidst the ruination. A sudden feeling of dread crawls",
                                                                                "up your spine and seems to choke your lungs."
                                                                            }
                                                            },
                                                            {
                                                                x=0,y=2,des={
                                                                                "You climb a stone staircase and reach an opening at the top of the tower. An altar sits quietly at",
                                                                                "the surface. Its surface is glossy like obsidian and covered with finely spun cloth. The blade of a",
                                                                                "sword is embedded into the altar. Eldritch glowing runes adorn the cold steel. A shaft of violet",
                                                                                "light parts the clouds in the sky and coats the altar in a spectral beauty.",
                                                                            }
                                                            },
                                                        }
                                        },
                    Bedroom =   {
                                    rooms = {{x=0,y=0},{x=1,y=0},{x=0,y=1},{x=1,y=1}},
                                    mapImage = love.graphics.newImage("Bedroom_Map.png"),
                                    roomImage = love.graphics.newImage("Title Picture.png"),
                                    searDesc =  {
                                                    {x=0,y=0,item="Lantern",des={"You find a lantern underneath your bed"}
                                                    },
                                                    {x=1,y=1,cond="Lantern",des={"You step out of the open window. Several paths sprawl before you in the dim moonlight.","Where do you wish to go?","[A]ncient Tower", "[C]rystal Cave", "[E]merald Sea", "[F]orest of Spirits", "[L]ost Hills", "F[o]rgotten Pit"}
                                                    },
                                                },
                                    walkDesc =  {
                                                    {x=0,y=0,des=   {
                                                                        "You are in a small bedroom. Your unmade bed lies before you. A coyote howls in the distance. An", 
                                                                        "ethereal voice can be heard, calling your name from afar."
                                                                    }
                                                    },
                                                    {x=1,y=1,des={"An open window sits in front of you. The curtain blows in the cold wind."}}}
                                },
                    Crystal_Cave =  {
                                        rooms = {{x=0,y=0},{x=1,y=0},{x=2,y=0},{x=0,y=1},{x=1,y=1},{x=2,y=1},{x=0,y=2},{x=1,y=2},{x=2,y=2},{x=1,y=3}},
                                        mapImage = love.graphics.newImage("Crystal_Cave_Map.png"),
                                        roomImage = love.graphics.newImage("Crystal_Cave.png"),
                                        searDesc = {{x=0,y=0,conds={},des={"You exit the scintillating cave. Several paths sprawl before you in the dim moonlight.","Where do you wish to go?","[A]ncient Tower", "[C]rystal Cave", "[E]merald Sea", "[F]orest of Spirits", "[L]ost Hills", "F[o]rgotten Pit"}}},
                                        walkDesc =  {
                                                        {x=0,y=0,des={"You step into a glistening cave filled with multifaceted crystals jutting outwards in every",
                                                    "direction. A spectrum of light dances along the walls in a dazzling display of iridescent beauty.",
                                                    "You marvel at this delight to the eyes, a sight that is too incredible to convey with simple words."}},
                                                        {
                                                            x=1,
                                                            y=3,
                                                            des={
                                                                    "Your gaze moves across a jumble of crystals that seem scattered about. It takes you a moment",
                                                                    "to realize that the crystals form a humanoid shape. From the looks of it, the crystals seem to",
                                                                    "form a sort of plate armor for a knight. After you realize this, the knight turns its featureless",
                                                                    "multifaceted face towards you slowly, creating a harsh grinding sound in the process. It seems",
                                                                    "to regard you carefully, but without facial expressions, you can't tell for sure",
                                                                },
                                                            img = love.graphics.newImage("Crystal_Knight.png"),
                                                        },
                                                    },
                                        npc =   {
                                                    x=1,
                                                    y=3,
                                                    dialogue=   {
                                                                    default={
                                                                                text={"..."},
                                                                            },
                                                                    Eye_of_Truth={
                                                                                    text={"THE EYE OF TRUTH..............IT SEES............THROUGH ILLUSIONS. THE EYE...............................",
                                                                                        "THE EYEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE!!!!!!!!!!!!!!! THE EYEEEE EEEYEEE THE",
                                                                                        "EEEEYYYYEEEEYEYE",
                                                                                        "",
                                                                                        "?"}
                                                                                 },
                                                                    Forest= {
                                                                                text={"THE FOREST HIDES A SECRET BURIED IN THE EARTH."},
                                                                            },
                                                                    Lost_Hills= {
                                                                                    text={"DO NOT LOSE YOUR WAY IN THE LOST HILLS, OR YOU WILL NEVER ESCAPE."}
                                                                                },
                                                                    Phase_Pendant=  {
                                                                                        text={"A razor thin veil between this world and the next.",
                                                                                              "A cacophony of sound to usher in the forgotten.",
                                                                                              "The impetus of your fate, a voice sweet like the siren sailing across the void.",
                                                                                              "What knows your path, that dark road that leads to misery and solitude in the end?",
                                                                                              "MEMORIES OF THE LOST, SHADOWE PEOPLE AT THE END OF THE DARKENED STREET.",
                                                                                              "WHAT ARE YOU RUNNING FROM? WHERE ARE YOU GOING? WHO GOES THERE?"
                                                                                             }
                                                                                    },
                                                                    Sword_Hilt= {
                                                                                    text={"TRAVERSE THE \"LOST HILLS\" TO FIND THE SWORD HILT."},
                                                                                    term={text="Lost Hills", command="L[o]st Hills", term="Lost_Hills"}
                                                                                },
                                                                    Voice=  {
                                                                                text={"THE ASTRAL VOICE SPEAKS. YOU MUST FIND THE \"SWORD HILT\"."},
                                                                                term={text="Sword Hilt", command="S[w]ord Hilt", term="Sword_Hilt"}
                                                                            }
                                                                }
                                                }
                                    },
                    Emerald_Sea =   {
                                        rooms = {{x=0,y=0},{x=1,y=0},{x=2,y=0},{x=0,y=1},{x=1,y=1},{x=2,y=1},{x=0,y=2},{x=1,y=2},{x=2,y=2},{x=3,y=1},{x=4,y=1}},
                                        mapImage = love.graphics.newImage("Emerald_Sea_Map.png"),
                                        roomImage = love.graphics.newImage("Emerald_Sea.png"),
                                        searDesc = {{x=0,y=0,conds={},des={"You leave the moonlit sea. Several paths sprawl before you in the dim moonlight.","Where do you wish to go?","[A]ncient Tower", "[C]rystal Cave", "[E]merald Sea", "[F]orest of Spirits", "[L]ost Hills", "F[o]rgotten Pit"}}},
                                        walkDesc =  {
                                                        {x=0,y=0,des=   {
                                                                            "You walk out and behold a serene sea that sparkles like turquoises in the moonlight. A lighthouse",
                                                                            "radiates with a haunting glow from a distance. The gentle lapping of ocean waves can be heard",
                                                                            "nearby."
                                                                        }
                                                        },
                                                        {   x=4,
                                                            y=1,
                                                            des={
                                                                    "You approach a stone statue of a woman gazing far off into the distance. She stands there with",
                                                                    "her arms folded against her chest, as though she is waiting for something. The quality of the",
                                                                    "craftsmanship is impeccable, almost as if the woman was alive just a few moments before...",
                                                                },
                                                            img = love.graphics.newImage("Stone_Statue.png"),
                                                        }
                                                    },
                                        npc =   {
                                                    x=4,
                                                    y=1,
                                                    dialogue=   {
                                                                    default={
                                                                                text={"(No response)"},
                                                                                --term={text="Forest",command="[F]orest"}
                                                                            },
                                                                }
                                                }
                                    },
                    Forest_of_Spirits = {
                                            rooms = {{x=0,y=0},{x=1,y=0},{x=2,y=0},{x=0,y=1},{x=1,y=1},{x=2,y=1},{x=0,y=2},{x=1,y=2},{x=2,y=2},},
                                            mapImage = love.graphics.newImage("Forest_of_Spirits_Map.png"),
                                            roomImage = love.graphics.newImage("Forest_of_Spirits.png"),
                                            searDesc = {{x=0,y=0,conds={},des={"You exit the peaceful forest. Several paths sprawl before you in the dim moonlight.","Where do you wish to go?","[A]ncient Tower", "[C]rystal Cave", "[E]merald Sea", "[F]orest of Spirits", "[L]ost Hills", "F[o]rgotten Pit"}}},
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
                                                        dialogue={
                                                                    default={
                                                                                text={"I am Cassandra, one of the spirits of the \"Forest\"."},
                                                                                term={text="Forest",command="[F]orest",term="Forest"}
                                                                            },
                                                                    Forest= {
                                                                                text={"This forest is a haven for those of us who wander the earth untethered by mortality."},
                                                                            },
                                                                    Lost_Hills= {
                                                                                    text={  "The Lost Hills is a dangerous land south of here that swallows up innocent travelers. Do not",
                                                                                            "think to traverse it without knowledge of the land or some kind of magic."
                                                                                         }
                                                                                },
                                                                    Sword_Hilt= {text= {"A sword hilt? I once heard a story long ago of a jealous goblin who stole a priceless sword. The",
                                                                                        "sword, angry from being stolen by a lowly wretch, chose instead to split itself in half so that the",
                                                                                        "goblin couldn't use or sell the sword. Maybe the sword blade was picked up by someone?"
                                                                                       }
                                                                                }
                                                                 }
                                                    }
                                        },
                    Forgotten_Pit = {
                                        rooms = {{x=0,y=0},{x=1,y=0},{x=2,y=0},{x=0,y=1},{x=2,y=1},{x=0,y=2},{x=1,y=2},{x=2,y=2}},
                                        mapImage = love.graphics.newImage("Forgotten_Pit_Map.png"),
                                        roomImage = love.graphics.newImage("Emerald_Sea.png"),
                                        searDesc = {{x=0,y=0,conds={},des={"You leave the pit. Several paths sprawl before you in the dim moonlight.","Where do you wish to go?","[A]ncient Tower", "[C]rystal Cave", "[E]merald Sea", "[F]orest of Spirits", "[L]ost Hills", "F[o]rgotten Pit"}}},
                                        walkDesc =  {
                                                        {x=0,y=0,des=   {
                                                                            "You travel to a deep chasm in the earth."
                                                                        }
                                                        },
                                                    },
                                    },
                    Hub =   {
                                rooms = {{x=0,y=0}},
                                mapImage = love.graphics.newImage("Hub_Map.png"),
                                searDesc = {},
                                walkDesc = {{x=0,y=0,des=""}},
                                roomImage = love.graphics.newImage("Hub.png"),
                            },
                    Lost_Hills = {
                                        rooms = {{x=0,y=0},{x=1,y=0},{x=2,y=0},{x=3,y=0},{x=3,y=1},{x=3,y=2},{x=4,y=2},{x=4,y=3},{x=4,y=4},{x=4,y=5},{x=3,y=5}},
                                        mapImage = love.graphics.newImage("Hub_Map.png"),
                                        roomImage = love.graphics.newImage("Emerald_Sea.png"),
                                        searDesc =  {
                                                        {x=0,y=0,conds={},des={"You somehow manage to leave the hills. Several paths sprawl before you in the dim moonlight.","Where do you wish to go?","[A]ncient Tower", "[C]rystal Cave", "[E]merald Sea", "[F]orest of Spirits", "[L]ost Hills", "F[o]rgotten Pit"}
                                                        },
                                                        {x=3,y=5,conds={},item="Phase Amulet",des={"After some digging effort, you find the phase amulet."}},
                                                    },
                                        walkDesc =  {
                                                        {x=0,y=0,des=   {
                                                                            "You encounter a series of forboding, shadowy hills. Decaying trees and muck colored leaves lie",
                                                                            "about. The air is still and dry in the pale sliver of moonlight. You try to make your way through",
                                                                            "the winding land, but every so often, you lose your way, as if the hills themselves are shifting",
                                                                            "about when you aren't looking at them. Press [enter] to leave."
                                                                        }
                                                        },
                                                        {x=4,y=5,des=   {"You trip over the bones of a goblin. They have been picked clean by the monstrous vultures that",
                                                                        "inhabit this area. It seems like the hand was clutching something at one point. The other hand",
                                                                        "has been crushed into powder."}
                                                        },
                                                        {x=3,y=5,des=   {"The ground seems soft here."}
                                                        },
                                                    },
                                    },
                }
    notes = {}
    items = {}
    scale = {}
    curText = {"","","","","Night of the Crescent Moon Ver " .. gameVersion, "A text adventure by Elias Mote", "Testing done by Dred4170", "Copyright (c) Roc Studios 2019", "Press [enter] to start"}
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
    
    -- draw the game or title screen
    if(state == "game" or state == "title") then
    
        -- draw image screen
        love.graphics.rectangle("line", 20, 20, 400, 150, 10)
        
        -- draw the title screen
        if(state == "title") then
            love.graphics.draw(titleScreen, 30, 30)
            
        -- draw the game screen
        elseif(state == "game") then
            if(isTalking == false) then
                if(curLocation == "Ancient_Tower" and coords.x == 0 and coords.y == 2) then
                    love.graphics.draw(ancientTowerTop, 30, 30)
                else
                    love.graphics.draw(locations[curLocation]["roomImage"], 30, 30)
                end
            else
                if(type(npcImg) == "table") then
                    love.graphics.draw(npcImg[math.floor(timer/20) % #npcImg + 1], 30, 30)
                else
                    love.graphics.draw(npcImg, 30, 30)
                end
            end
        end
        
        -- draw map screen
        love.graphics.rectangle("line", 440, 20, 100, 150, 10)
        
        if(curLocation ~= "Lost_Hills" or eyeOfTruthOn) then
            -- draw coordinates
            love.graphics.print("Coords   " .. coords.x .. "," .. coords.y, 450, 150)
            
            
            -- draw map text
            love.graphics.print("Map", 480, 30)
            
            -- draw map
            love.graphics.draw(locations[curLocation]["mapImage"], 450, 115 - 32)
            
            -- draw coordinates indicator
            if(timer % 60 < 60 / 2) then
                love.graphics.rectangle("fill", 450 + 16 * coords.x, 131 - 16 * coords.y, 16, 16)
            end
        end
        
        -- draw item screen
        love.graphics.rectangle("line", 560, 20, 60, 150, 10)
        
        -- draw item text
        love.graphics.print("[I]tems", 568, 30)
        
        -- draw items
        for i in ipairs(items) do
            
            -- draw the lantern if the player has it
            if(items[i]["text"] == "Lantern") then
                
                -- if the lantern is turned on
                if(items[i]["enabled"]) then
                    love.graphics.draw(lanternImg[math.floor(timer/30) % 2 + 1], 580, 50)
                else
                    love.graphics.draw(lanternImg[2], 580, 50)
                end
            end
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
        
    -- if the game is on the inventory screen
    elseif(state == "inventory") then
        -- draw inventory screen
        love.graphics.rectangle("line", 20, 20, 600, 150, 10)
        
        -- draw inventory text
        love.graphics.print("Inventory", 280, 30)
        
        -- draw key terms screen
        love.graphics.rectangle("line", 20, 190, 600, 150, 10)
        
        -- draw key terms text
        love.graphics.print("Key terms", 280, 200)
        for i in ipairs(keyTerms) do
            love.graphics.print(keyTerms[i]["text"], 40, 220 + (i-1) * 20)
        end
        
        -- draw items text
        for i in ipairs(items) do
            love.graphics.print(items[i]["text"], 40, 60 + (i-1) * 20)
        end
    end
end

function love.keypressed(key, scancode, isrepeat)
    
    -- if we are in the game
    if(state == "game") then
        
        -- Move player (write text output if in the lost hills)
        if(key == "up") then
            if(curLocation == "Lost_Hills") then
                writeToTextDisplay({"You move north"})
            end
            if(checkIfRoomExists(curLocation, coords.x, coords.y+1)) then
                coords.y = coords.y + 1
                checkWalkableDescription()
            end
        end
        
        if(key == "down") then
            if(curLocation == "Lost_Hills") then
                writeToTextDisplay({"You move south"})
            end
            
            if(checkIfRoomExists(curLocation, coords.x, coords.y-1)) then
                coords.y = coords.y - 1
                checkWalkableDescription()
            end
        end
        
        if(key == "left") then
            if(curLocation == "Lost_Hills") then
                writeToTextDisplay({"You move west"})
            end
            
            if(checkIfRoomExists(curLocation, coords.x-1, coords.y)) then
                coords.x = coords.x - 1
                checkWalkableDescription()
            end
        end
        
        if(key == "right") then
            if(curLocation == "Lost_Hills") then
                writeToTextDisplay({"You move east"})
            end
            
            if(checkIfRoomExists(curLocation, coords.x+1, coords.y)) then
                coords.x = coords.x + 1
                checkWalkableDescription()
            end
        end
        
        -- Search area
        if(key == "return") then
            
            -- If the old painting is checked too many times (more than 5), random chance for horrible fate
            if(curLocation == "Ancient_Tower" and coords.x == 0 and coords.y == 1) then
                numOfTimesPictureChecked = numOfTimesPictureChecked + 1
                if(numOfTimesPictureChecked == 5) then
                    writeToTextDisplay({"You feel like something bad is about to happen."})
                end
            end
            
            -- Move to the hub area
            if((curLocation == "Bedroom" and coords.x == 1 and coords.y == 1) 
                or (curLocation ~= "Bedroom" and coords.x == 0 and coords.y == 0)) then
                if(checkSearchableDescription()) then
                    curLocation = "Hub"
                    coords.x = 0
                    coords.y = 0
                end
            else
                checkSearchableDescription()
            end
            
            -- If the phase amulet has been searched for, move to the left of the entrance
            if(curLocation == "Lost_Hills" and coords.x == 3 and coords.y == 5) then
                coords.x = -1
                coords.y = 0
            end

            -- If the player presses enter during dialogue, the npc should say default dialogue
            if(isTalking) then
                isSayingWord = false
                writeToTextDisplay(locations[curLocation]["npc"]["dialogue"]["default"]["text"])
                curTermToLearn = locations[curLocation]["npc"]["dialogue"]["default"]["term"]
                writeToTextDisplay({"[S]ay","[L]earn"})
            end
        end
        
        -- if the player is saying a key term
        if(isTalking and isSayingWord and key ~= "p") then
            --if(string.match(key,'[a-z]')) then
            local term = keyTermMap[key]
            for k,v in ipairs(keyTerms) do
                if(v["term"] == term or v["text"] == term) then
                    if(locations[curLocation]["npc"]["dialogue"][term] ~= nil) then
                        writeToTextDisplay(locations[curLocation]["npc"]["dialogue"][term]["text"])
                        curTermToLearn = locations[curLocation]["npc"]["dialogue"][term]["term"]
                        isSayingWord = false
                        writeToTextDisplay({"[S]ay","[L]earn"})
                    else
                        writeToTextDisplay({"?"})
                        writeToTextDisplay({"[S]ay","[L]earn"})
                    end
                end
            end
        end
        
        -- while the player is talking to an npc, tell the player to say a word
        if(isTalking and key == "s") then
            isSayingWord = true
            curTermToLearn = nil
            writeToTextDisplay({"Select a word to say:"})
            local t = ""
            for k,v in ipairs(keyTerms) do
                t = t .. v["command"] .. "   "
            end
            writeToTextDisplay({t})
        end
        
        -- List inventory items for usage
        if(key == "i" and not isTalking and curLocation ~= "Hub") then
            isUsingItem = true
            --if not (isUsingItem) then
            writeToTextDisplay({"Select an item:"})
            for k,v in ipairs(items) do
                writeToTextDisplay({v["command"]})
            end
        end
            
        -- Learning a word
        if(key == "l" and curLocation ~= "Hub") then
            
            -- If the player is talking to an npc
            if(isTalking) then
                
                -- Learn a keyword if the player hasn't learned it yet
                if(addKeyTerm(curTermToLearn)) then
                    writeToTextDisplay({"Learned key term: " .. curTermToLearn["text"]})
                    writeToTextDisplay({"[S]ay"})
                end
                
            end
        end
            
        -- If the player is using an item
        if(isUsingItem) then
            for i in ipairs(items) do
                if(key == "l" and items[i]["text"] == "Lantern") then
                    if(items[i]["enabled"]) then
                        items[i]["enabled"] = false
                        writeToTextDisplay({"You turned the lantern off."})
                    else
                        items[i]["enabled"] = true
                        writeToTextDisplay({"You turned the lantern on."})
                    end
                    isUsingItem = false
                    break
                    
                elseif(key == "h" and items[i]["text"] == "Phase Amulet") then
                    if(items[i]["enabled"]) then
                        items[i]["enabled"] = false
                        writeToTextDisplay({"You deactivate the phase amulet."})
                    else
                        items[i]["enabled"] = true
                        writeToTextDisplay({"You activate the phase amulet."})
                    end
                    isUsingItem = false
                    break
                end
            end
        end
        
        -- Travel to each area from the hub
        if(curLocation == "Hub") then
            if(key == "a") then
                curLocation = "Ancient_Tower"
            elseif(key == "c") then
                curLocation = "Crystal_Cave"
            elseif(key == "e") then
                curLocation = "Emerald_Sea"
            elseif(key == "f") then
                curLocation = "Forest_of_Spirits"
            elseif(key == "l") then
                curLocation = "Lost_Hills"
            elseif(key == "o") then
                curLocation = "Forgotten_Pit"
            end
            
            if(curLocation ~= "Hub") then
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