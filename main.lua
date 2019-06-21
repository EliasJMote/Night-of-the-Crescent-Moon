-- Disable items not in use
function disableItems(text)
    for j in ipairs(items) do
        if(items[j]["text"] ~= text) then
            items[j]["enabled"] = false
        end
    end
end

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
                elseif(v.item == "Sword Hilt") then
                    for i in ipairs(items) do
                        if(v.item == items[i]["text"]) then
                            return
                        end
                    end
                    writeToTextDisplay(v.des)
                    table.insert(items, {text="Sword Hilt",command="S[w]ord Hilt",enabled=false})
                elseif(v.item == "Eye of Truth") then
                    for i in ipairs(items) do
                        if(v.item == items[i]["text"]) then
                            return
                        end
                    end
                    writeToTextDisplay(v.des)
                    table.insert(items, {text="Eye of Truth",command="[E]ye of Truth",enabled=false})
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
    numOfTimesPictureChecked = 0
    isAskingTheQuestion = false
    ending = {isGameEnding=false, number=1, state=1}
    
    ancientTowerTop = love.graphics.newImage("Ancient_Tower_Top.png")
    ancientTowerPainting = love.graphics.newImage("Ancient_Tower_Painting.png")
    
    -- Locations: Ancient Tower, Bedroom, Crystal Cave, Emerald Sea, Forest of Spirits, Forgotten Pit, Lost Hills
    curLocation = "Bedroom"
    coords = {x=0,y=0}
    keyTerms = {{text="Voice",command="[V]oice",term="Voice"},
                --{text="Eye of Truth",command="[E]ye of Truth",term="Eye_of_Truth"},
                --{text="Phase Amulet",command="P[h]ase Amulet",term="Phase_Amulet"},
                }
    items = {
                --{text="Eye of Truth",command="[E]ye of Truth",enabled=false},
                --{text="Sword Hilt",command="S[w]ord Hilt",enabled=false},
                --{text="Phase Amulet",command="P[h]ase Amulet",enabled=false},
            }
    
    keyTermMap = {
                    a="Abandoned_Tower",
                    e="Eye_of_Truth",
                    f="Forest",
                    g="Forgotten_Pit",
                    h="Phase_Amulet",
                    m="Emerald_Sea",
                    o="Lost_Hills",
                    r="Red_Prince",
                    t="Stone_Statue",
                    v="Voice",
                    w="Sword_Hilt"
                 }
    
    curTermToLearn = nil
    
    -- load item images
    lanternImg = {love.graphics.newImage("Lantern_1.png"), love.graphics.newImage("Lantern_2.png")}
    amuletImg = {love.graphics.newImage("Phase_Amulet_1.png"), love.graphics.newImage("Phase_Amulet_2.png")}
    eyeOfTruthImg = {love.graphics.newImage("Eye_of_Truth_1.png"), love.graphics.newImage("Eye_of_Truth_2.png")}
    swordHiltImg = {love.graphics.newImage("Sword_Hilt_1.png"), love.graphics.newImage("Sword_Hilt_2.png")}
    
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
                                                                                "covered top to bottom in dust, but is otherwise undamaged. The picture is of a lone dark",
                                                                                "road with a single star shining in the sky."
                                                                                --[["You step through, encountering a large ornate picture hanging on the wall. The antique is",
                                                                                "covered top to bottom in dust, but is otherwise undamaged. The picture is of the inside of a",
                                                                                "grand cathedral that has aged wretchedly. Blue candles sit melted in cast bronze holders, and",
                                                                                "an enormous pipe organ dominates the frame. The pipes reach for the heavens; however, many",
                                                                                "of them are smashed or twisted around in a horrific display of strange art. Stained glass windows",
                                                                                "sag with lengthy age, contorting images of priests and angels. A lone musical sheet sits on the",
                                                                                "organ, perfectly immaculate and pristine amidst the ruination. A sudden feeling of dread crawls",
                                                                                "up your spine and seems to choke your lungs."]]
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
                                                                    Abandoned_Tower={
                                                                                    text={"THE [RED PRINCE'S] OLD STRONGHOLD. AN ALTAR WAS BUILT ON TOP TO WORSHIP THE GHOST",
                                                                                        "OF A FAIRE MAIDEN."},
                                                                                    term={text="Red Prince",command="[R]ed Prince",term="Red_Prince"}
                                                                                    },
                                                                    Eye_of_Truth={
                                                                                    text={"THE EYE OF TRUTH..............IT SEES............THROUGH ILLUSIONS.",
                                                                                            "IT WAS CRAFTED......THROUGH DIVINE MAGIC.........BY SOOTHSAYER ASTREA.",
                                                                                        },
                                                                                    
                                                                                 },
                                                                    Emerald_Sea= {
                                                                                text={"THE EMERALD SEA...A WOMAN WHOSE FLESH TURNED TO STONE FROM AN ETERNITY OF WAITING."},
                                                                            },
                                                                    Lost_Hills= {
                                                                                    text={"DO NOT LOSE YOUR WAY IN THE LOST HILLS, OR YOU WILL NEVER ESCAPE."}
                                                                                },
                                                                    Phase_Amulet=  {
                                                                                        text={"A MYSTICAL AMULET......IT BRIDGES THE DIVIDE BETWEEN HERE AND THE VOID, THE SPACE",
                                                                                            "BETWEEN SPACES"
                                                                                             }
                                                                                    },
                                                                    Red_Prince= {
                                                                                    text={"THE RED PRINCE...?...!...? HE SOUGHT THE FISSURES BETWEEN WORLDS USING HIS PRECIOUS",
                                                                                        "AMULET. HIS ILLUSIONS ARE POWERFUL AND MANY.",
                                                                                        "A red eye seemingly appears in the corner of your vision momentarily."}
                                                                                },
                                                                    Sword_Hilt= {
                                                                                    text={"TRAVERSE THE [LOST HILLS] TO FIND THE SWORD HILT."},
                                                                                    term={text="Lost Hills", command="L[o]st Hills", term="Lost_Hills"}
                                                                                },
                                                                    Voice=  {
                                                                                text={"THE ASTRAL VOICE SPEAKS. YOU MUST FIND THE [SWORD HILT]."},
                                                                                term={text="Sword Hilt", command="S[w]ord Hilt", term="Sword_Hilt"}
                                                                            }
                                                                }
                                                }
                                    },
                    Dark_Road = {
                                    rooms = {{x=0,y=0}},
                                    roomImage = love.graphics.newImage("Emerald_Sea.png"),
                                    searDesc = {},
                                    walkDesc = {},
                                },
                    Emerald_Sea =   {
                                        rooms = {{x=0,y=0},{x=1,y=0},{x=2,y=0},{x=0,y=1},{x=1,y=1},{x=2,y=1},{x=0,y=2},{x=1,y=2},{x=2,y=2},{x=3,y=1},{x=4,y=1}},
                                        mapImage = love.graphics.newImage("Emerald_Sea_Map.png"),
                                        roomImage = love.graphics.newImage("Emerald_Sea.png"),
                                        searDesc = {
                                                        {x=0,y=0,conds={},des={"You leave the moonlit sea. Several paths sprawl before you in the dim moonlight.","Where do you wish to go?","[A]ncient Tower", "[C]rystal Cave", "[E]merald Sea", "[F]orest of Spirits", "[L]ost Hills", "F[o]rgotten Pit"}
                                                        },
                                                        {x=0,y=2,conds={},item="Phase Amulet",des={"After some digging effort, you find the phase amulet."}},
                                                    },
                                        walkDesc =  {
                                                        {
                                                            x=0,
                                                            y=0,
                                                            des=    {
                                                                        "You walk out and behold a serene sea that sparkles like turquoises in the moonlight. A",
                                                                        "lighthouse radiates with a haunting glow from a distance. The gentle lapping of ocean waves",
                                                                        "can be heard nearby. The sea air feels fresh and vibrant to the senses. You can hear the",
                                                                        "splash of an occasional fish that leaps up and kisses the edge of the sky."
                                                                    }
                                                        },
                                                        {   x=4,
                                                            y=1,
                                                            des=    {
                                                                        "You approach a stone statue of a woman gazing far off into the distance. She stands there with",
                                                                        "her arms crossed against her chest, as though she is waiting for something. The quality of the",
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
                                                                                text={"(No response)","The gentle waves of the [Emerald Sea] can be heard nearby"},
                                                                                term={text="Emerald Sea",command="E[m]erald Sea",term="Emerald_Sea"}
                                                                            },
                                                                    Emerald_Sea=    {
                                                                                text=   {
                                                                                            "(You hear a voice in your head)",
                                                                                            "Long did I wait for my betrothed to return from the war. Alas, I stood at this shore for years",
                                                                                            "without seeing him. Still, I will wait for him. My faith in my husband is unwavering, a mighty",
                                                                                            "foundation upon which our relationship was built. I shall stand here until the water devours",
                                                                                            "my body of stone, for he would traverse even the dark road for my sake."
                                                                                        },
                                                                                },
                                                                    Eye_of_Truth=   {
                                                                                        text=   {
                                                                                                    "(You hear a voice in your head)",
                                                                                                    "The eye of truth can pierce the veil of illusions."
                                                                                                },
                                                                                        --term={text="Forest",command="[F]orest"}
                                                                                    },
                                                                    Forgotten_Pit=  {
                                                                                    text={
                                                                                            "(You hear a voice in your head)",
                                                                                            "The Forgotten Pit is the festering cesspool of corpses of people who knew the truth about this",
                                                                                            "world. Violent men and women, who spat on their names, calling them worshippers of the mad",
                                                                                            "red prince and his dark arts, slaughtered those truth seekers, for these barbarians did not",
                                                                                            "want to change their worldviews. There may be some written records of these people buried",
                                                                                            "near the tar-drenched pit."
                                                                                        },
                                                                                    },
                                                                    Phase_Amulet=   {
                                                                                        text=   {
                                                                                                    "(You hear a voice in your head)",
                                                                                                    "The phase amulet allows one to step through a dimensional gate.",
                                                                                                    "Do not try to traverse a portal without the amulet..."
                                                                                                },
                                                                                    },
                                                                    Red_Prince= {
                                                                                    text=   {
                                                                                                "THE RED PRINCE, THE RED PRINCE, THE RED PRINCE, THE RED PRINCE, THE RED PRINCE",
                                                                                                "THE RED PRINCE, THE RED PRINCE, THE RED PRINCE, THE RED PRINCE, THE RED PRINCE",
                                                                                                "HIS POWER IS VAST! HIS ILLUSIONS ARE STRONG!",
                                                                                                "HE PUPPETS THE PRINCESS! HE PUPPETS THE PRINCESS!",
                                                                                                "(The sky rapidly flickers with lightning)",
                                                                                                "Out of the corner of your eye, you think you see a shadow figure momentarily."
                                                                                            }
                                                                                },
                                                                    Sword_Hilt= {
                                                                                    text=   {
                                                                                                "(You hear a voice in your head)",
                                                                                                "The astral blade was once whole. Bring the hilt to the altar if you wish to speak to the",
                                                                                                "being who calls your name. The blade will rejoin when its hilt is close."
                                                                                            },
                                                                                },
                                                                    Voice=  {
                                                                                text=   {
                                                                                            "(You hear a voice in your head)",
                                                                                            "A sweet tune dances to the symphonic thermals of the air. It is the spectral voice, the siren's",
                                                                                            "magnetic call that attracts. Fate has knocked on your door. Will you answer it?"
                                                                                        }
                                                                            }
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
                                                                    Abandoned_Tower={
                                                                                    text={  "The Abandoned Tower...recently, I've heard of thunderstorms that seem to appear out of",
                                                                                            "nowhere that center on that ancient bastion. Rumors abound of a mad prince who forced his",
                                                                                            "royal painters to devise all sorts of strange art. There may be a surviving painting or two",
                                                                                            "somewhere around there. I read an aged record once of astonished servants swearing that",
                                                                                            "they saw their [red prince] praying in front of the paintings, before stepping through them like",
                                                                                            "they were gates to other worlds. This is just hearsay, of course."
                                                                                        },
                                                                                        term={text="Red Prince",command="[R]ed Prince",term="Red_Prince"}
                                                                                    },
                                                                    Emerald_Sea={
                                                                                    text={"The Emerald Sea is a body of water to the east of here. They say a young woman used to stand",
                                                                                        "out there every night, following the light of the lighthouse to wait for her husband to return",
                                                                                        "from the war. She waited there so long that she eventually turned to stone...of course there",
                                                                                        "are others who claimed to have sculpted the [stone statue] that sits out there themselves as",
                                                                                        "homage to that story. Who's to say what is truth or fiction?"},
                                                                                    term={text="Stone Statue",command="S[t]one Statue",term="Stone_Statue"}
                                                                                },
                                                                    Eye_of_Truth=   {
                                                                                        text={"An ancient, powerful relic. Supposedly, it can see the truth amongst illusory magic."}
                                                                                    },
                                                                    Forest= {
                                                                                text={"This forest is a haven for those of us who wander the earth untethered by mortality.",
                                                                                        "The [Forgotten Pit] lies a ways south of here."
                                                                                    },
                                                                                    term={text="Forgotten Pit", command="For[g]otten Pit", term="Forgotten_Pit"}
                                                                            },
                                                                    Forgotten_Pit=  {
                                                                                    text={"A dumping place for those hated in life. Be careful wandering there, lest you fall into the pit",
                                                                                        "yourself."
                                                                                        }
                                                                                    },
                                                                    Lost_Hills= {
                                                                                    text={  "The Lost Hills is a dangerous land south of here that swallows up innocent travelers. Do not",
                                                                                            "think to traverse it without knowledge of the land."
                                                                                         }
                                                                                },
                                                                    Red_Prince= {
                                                                                    text={"The red prince...anyone who knew anything about him is dust as this point. I've only been dead",
                                                                                            "for twenty years myself. The red prince is probably eons past, a long dead noble. Not much is",
                                                                                            "known about him really. Books on him seem unsure if he was more man or beast. He was also",
                                                                                            "obsessed with long dead arts of magic - these days, there are no more magicians left in the",
                                                                                            "world. He just up and disappeared one evening, but the days up to his disappearance, he could",
                                                                                            "be heard babbling incoherently to himself and talking to his precious paintings."}
                                                                                },
                                                                    Stone_Statue={
                                                                                    text={  "I've heard of people claiming to hear the voice of the woman whispering to them from the",
                                                                                            "statue."
                                                                                         }
                                                                                 },
                                                                    Sword_Hilt= {text= {"A sword hilt? I once heard a story long ago of a jealous goblin who stole a priceless sword. The",
                                                                                        "sword, angry from being stolen by a lowly wretch, chose instead to split itself in half so that the",
                                                                                        "goblin couldn't use or sell the sword. Maybe the sword blade was picked up by someone?"
                                                                                       }
                                                                                },
                                                                    Voice=  {
                                                                                text=   {
                                                                                            "An ethereal voice...it might be coming from the [Abandoned Tower]. I've heard rumors of a",
                                                                                            "princess who was held against her will at the top of the tower. Every night, she would sing",
                                                                                            "about her woes to the night sky, hoping someone would come to her rescue. When someone",
                                                                                            "finally heard her voice and broke into the stronghold, she was found slain by a sword adorned",
                                                                                            "with eldritch runes. The strange thing though is that people still claim to hear her voice",
                                                                                            "from time to time, when the moon is right."
                                                                                        },
                                                                                term={text="Abandoned Tower",command="[A]bandoned Tower",term="Abandoned_Tower"}
                                                                            },
                                                                 }
                                                    }
                                        },
                    Forgotten_Pit = {
                                        rooms = {{x=0,y=0},{x=1,y=0},{x=2,y=0},{x=0,y=1},{x=2,y=1},{x=0,y=2},{x=1,y=2},{x=2,y=2}},
                                        mapImage = love.graphics.newImage("Forgotten_Pit_Map.png"),
                                        roomImage = love.graphics.newImage("Forgotten_Pit.png"),
                                        searDesc =  {
                                                        {x=0,y=0,conds={},des={"You leave the pit. Several paths sprawl before you in the dim moonlight.","Where do you wish to go?","[A]ncient Tower", "[C]rystal Cave", "[E]merald Sea", "[F]orest of Spirits", "[L]ost Hills", "F[o]rgotten Pit"}
                                                        },
                                                        {x=2,y=2,des=   {
                                                                            "Something is inscribed into the rock here. It reads:",
                                                                            "3E 2N 1E 3N 1W"
                                                                        }
                                                        },
                                                        {x=2,y=0,des=   {
                                                                            "Something is inscribed into the rock here. It reads:",
                                                                            "SEARCH THE EMERALD SEA FOR THE [PHASE AMULET]. IT ALONE CAN LEAD YOU TO THE RED",
                                                                            "PRINCE. HE IS TRAPPED WITHOUT HIS PRECIOUS TRINKET, BUT HE CONTROLS _____________",
                                                                            "AND ___________ (The words have faded from excessive wear by the elements)."
                                                                        }
                                                        },
                                                        {x=0,y=2,des=   {
                                                                            "Something is inscribed into the rock here. It reads:",
                                                                            "NOT ALL IS WHAT IT APPEARS TO BE. THE RED PRINCES' INFLUENCE STRETCHES FAR AND WIDE.",
                                                                            "THERE IS NO CORRECT ANSWER TO THE QUESTION. SEEK THE [EYE OF TRUTH]."
                                                                        }
                                                        },
                                                    },
                                        walkDesc =  {
                                                        {x=0,y=0,des=   {
                                                                            "You travel to a deep chasm in the earth. The pit is filled with a light-consuming tar. A horrifying",
                                                                            "stench wafts through the air, conjuring smells of death and decay. You can just make out the",
                                                                            "pearly bones of human skeletons that are stuck in the viscous fluid, clawing for life in vain. The",
                                                                            "dirt surrounding the pit is the color of reddish clay, and the environment is devoid of any flora",
                                                                            "or fauna."
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
                                        roomImage = love.graphics.newImage("Lost_Hills.png"),
                                        searDesc =  {
                                                        {x=0,y=0,conds={},des={"You somehow manage to leave the hills. Several paths sprawl before you in the dim moonlight.","Where do you wish to go?","[A]ncient Tower", "[C]rystal Cave", "[E]merald Sea", "[F]orest of Spirits", "[L]ost Hills", "F[o]rgotten Pit"}
                                                        },
                                                        {x=3,y=5,conds={},item="Sword Hilt",des={"After some digging effort, you find the broken sword"}},
                                                    },
                                        walkDesc =  {
                                                        {x=0,y=0,des=   {
                                                                            "You encounter a series of forboding, shadowy hills. Decaying trees and muck colored leaves lie",
                                                                            "about. The air is still and dry in the pale sliver of moonlight. You try to make your way through",
                                                                            "the winding land, but every so often, you lose your way, as if the hills themselves are shifting",
                                                                            "about when you aren't looking at them. Press [r] at anytime to leave."
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
        writeToTextDisplay({"You are in a small bedroom. Your unmade bed lies before you. A coyote howls in the distance.", 
                "An ethereal voice can be heard, calling your name from afar."})
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
                elseif(curLocation == "Ancient_Tower" and coords.x == 0 and coords.y == 1) then
                    love.graphics.draw(ancientTowerPainting, 30, 30)
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
            
            if(ending["state"] >= 23) then
                love.graphics.draw(titleScreen, 30, 30)
            end
        end
        
        -- draw map screen
        love.graphics.rectangle("line", 440, 20, 100, 150, 10)
        
        if(curLocation ~= "Lost_Hills" and curLocation ~= "Dark_Road") then
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
            local itemX = 580
            -- draw the lantern if the player has it
            if(items[i]["text"] == "Lantern") then
                
                -- if the lantern is turned on
                if(items[i]["enabled"]) then
                    love.graphics.draw(lanternImg[math.floor(timer/30) % 2 + 1], itemX, 50)
                else
                    love.graphics.draw(lanternImg[2], itemX, 50)
                end
            end
            
            -- draw the phase amulet if the player has it
            if(items[i]["text"] == "Phase Amulet") then
                
                -- if the lantern is turned on
                if(items[i]["enabled"]) then
                    love.graphics.draw(amuletImg[math.floor(timer/30) % 2 + 1], itemX, 80)
                else
                    love.graphics.draw(amuletImg[2], itemX, 80)
                end
            end
            
            -- draw the eye of truth if the player has it
            if(items[i]["text"] == "Eye of Truth") then
                
                -- if the lantern is turned on
                if(items[i]["enabled"]) then
                    love.graphics.draw(eyeOfTruthImg[2], itemX, 110)
                else
                    love.graphics.draw(eyeOfTruthImg[1], itemX, 110)
                end
            end
            
            -- draw the sword hilt if the player has it
            if(items[i]["text"] == "Sword Hilt") then
                
                love.graphics.draw(swordHiltImg[1], itemX, 140)
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
    end
end

function love.keypressed(key, scancode, isrepeat)
    
    -- if we are in the game
    if(state == "game") then
        
        -- Move player (write text output if in the lost hills)
        if (isAskingTheQuestion == false and ending["isGameEnding"] == false) then
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
        
        
            -- Search area or use activated item
            if(key == "return") then
                
                -- Move to the hub area from various locations
                -- Player must use lantern from the bedroom to leave
                if((curLocation == "Bedroom" and coords.x == 1 and coords.y == 1) 
                    or (curLocation ~= "Bedroom" and coords.x == 0 and coords.y == 0)) then
                    if(checkSearchableDescription()) then
                        curLocation = "Hub"
                        coords.x = 0
                        coords.y = 0
                    end
                    
                
                -- If player uses the sword hilt at the altar
                elseif(curLocation == "Ancient_Tower" and coords.x == 0) then
                    if(coords.y == 2) then
                        if(checkSearchableDescription()) then
                            writeToTextDisplay({
                                                    "The sword hilt joins the blade in the altar. Suddenly, a spectre appears wearing long flowing",
                                                    "robes, a priceless brooch, and a tiara inlaid with silver and emblazoned with precious jewels.",
                                                    "The voice speaks...\"It is you who found me, you who heard me voice. I have been trapped at",
                                                    "the top of this tower ever since I perished here long ago. Please, you must help me. The blade",
                                                    "you hold; it is a remnant of the mad red prince who imprisoned me here. I must destroy it so",
                                                    "that I may ascend to heaven.\" She requests that you hand the blade over to her. Do you give",
                                                    "her the blade?  [Y]es  [N]o"
                                                })
                            isAskingTheQuestion = true
                        end
                        
                    -- If player uses the phase amulet at the old painting
                    elseif(coords.y == 1) then
                        
                        if(checkSearchableDescription()) then
                            curLocation = "Dark_Road"
                            ending = {isGameEnding=true, number=3, state=1}
                        end
                    end
                    
                    -- If the old painting is checked too many times (more than 5), random chance for horrible fate
                    --[[numOfTimesPictureChecked = numOfTimesPictureChecked + 1
                    if(numOfTimesPictureChecked == 5) then
                        writeToTextDisplay({"You feel like something bad is about to happen."})
                    end]]
                    
                    
                elseif(curLocation == "Forgotten_Pit") then
                    if(coords.x == 2 and coords.y == 0) then
                        checkSearchableDescription()
                        if(addKeyTerm({text="Phase Amulet",command="P[h]ase Amulet",term="Phase_Amulet"})) then
                            writeToTextDisplay({"Learned key term: Phase Amulet"})
                        end
                    elseif(coords.x == 0 and coords.y == 2) then
                        checkSearchableDescription()
                        if(addKeyTerm({text="Eye of Truth",command="[E]ye of Truth",term="Eye_of_Truth"})) then
                            writeToTextDisplay({"Learned key term: Eye of Truth"})
                        end
                    else
                        checkSearchableDescription()
                    end
                    
                -- If place isn't special
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
                    
                    -- Every 5 words, skip a line
                    if(k % 5 == 0 and k ~= 0) then
                        writeToTextDisplay({t})
                        t = ""
                    end
                end
                
                -- Skip the last line if it is blank
                if(t ~= "") then
                    writeToTextDisplay({t})
                end
            end
            
            -- List inventory items for usage
            if(key == "i" and not isTalking and curLocation ~= "Hub") then
                isUsingItem = true
                
                writeToTextDisplay({"Select an item:"})
                for k,v in ipairs(items) do
                    if(v["command"] ~= nil) then
                        writeToTextDisplay({v["command"]})
                    end
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
            
            -- Leave the forgotten hills
            if(key == "r" and curLocation == "Lost_Hills" and not isTalking) then
                curLocation = "Hub"
                coords.x = 0
                coords.y = 0
                writeToTextDisplay({"You somehow manage to leave the hills. Several paths sprawl before you in the dim moonlight.","Where do you wish to go?","[A]ncient Tower", "[C]rystal Cave", "[E]merald Sea", "[F]orest of Spirits", "[L]ost Hills", "F[o]rgotten Pit"})
            end
                
            -- If the player is using an item
            if(isUsingItem) then
                for i in ipairs(items) do
                    if(key == "l" and items[i]["text"] == "Lantern") then
                        disableItems(items[i]["text"])
                        
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
                        disableItems(items[i]["text"])
                        
                        if(items[i]["enabled"]) then
                            items[i]["enabled"] = false
                            writeToTextDisplay({"You deactivate the phase amulet."})
                        else
                            items[i]["enabled"] = true
                            writeToTextDisplay({"You activate the phase amulet."})
                        end
                        isUsingItem = false
                        break
                        
                    elseif(key == "e" and items[i]["text"] == "Eye of Truth") then
                        disableItems(items[i]["text"])
                        
                        if(items[i]["enabled"]) then
                            items[i]["enabled"] = false
                            writeToTextDisplay({"The Eye of Truth returns to slumber."})
                        else
                            items[i]["enabled"] = true
                            writeToTextDisplay({"The Eye of Truth Awakens!"})
                        end
                        isUsingItem = false
                        break
                        
                    elseif(key == "w" and items[i]["text"] == "Sword Hilt") then
                        disableItems(items[i]["text"])
                        
                        if(items[i]["enabled"]) then
                            items[i]["enabled"] = false
                            writeToTextDisplay({"You put the sword hilt away into your scabbard."})
                        else
                            items[i]["enabled"] = true
                            writeToTextDisplay({"You pull the sword hilt out."})
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
            
        elseif (isAskingTheQuestion == true and ending["isGameEnding"] == false) then
            if(key == "y") then
                writeToTextDisplay({"The princess takes the ancient sword. Suddenly, a third red eye appears on her forehead.",
                                    "Before you can move, the princess stabs you through the stomach. Blood from the wound",
                                    "begins to pool onto the altar. As your consciousness fades, you hear the faintest sound of",
                                    "contorted laughter alongside pipe organs and a fiendish dirge."})
                ending["isGameEnding"] = true
                ending["number"] = 1
                
            elseif(key == "n") then
                writeToTextDisplay({"Hmm...curious. You don't seem to understand", "SINCE WHEN WERE YOU THE ONE IN CONTROL?"})
                ending["isGameEnding"] = true
                ending["number"] = 2
            end
        elseif(ending["isGameEnding"] == true) then
            if(key == "return") then
                
                if(ending["number"] <= 2) then
                    love.event.quit()
                end
                
                if(ending["number"] == 3) then
                    if(ending["state"] == 1) then
                        writeToTextDisplay({"The church dissolves before your eyes. A dark road lies in front of you."})
                    elseif(ending["state"] == 2) then
                        writeToTextDisplay({"A distant light is the only sight."})
                    elseif(ending["state"] == 3) then
                        writeToTextDisplay({"You feel a strange prescence."})
                    elseif(ending["state"] == 4) then
                        writeToTextDisplay({"\"A razor thin veil between this world and the next.\""})
                    elseif(ending["state"] == 5) then
                        writeToTextDisplay({"\"A cacophony of sound to usher in the forgotten.\""})
                    elseif(ending["state"] == 6) then
                        writeToTextDisplay({"\"The impetus of your fate, a voice sweet like the siren sailing across the void.\""})
                    elseif(ending["state"] == 7) then
                        writeToTextDisplay({"\"What knows your path, that dark road that leads to misery and solitude in the end?\""})
                    elseif(ending["state"] == 8) then
                        writeToTextDisplay({"\"MEMORIES OF THE LOST,\""})
                    elseif(ending["state"] == 9) then
                        writeToTextDisplay({"\"SHADOWE PEOPLE WHO WANDER THE DARKENED STREET.\""})
                    elseif(ending["state"] == 10) then
                        writeToTextDisplay({"\"WHAT ARE YOU RUNNING FROM?\""})
                    elseif(ending["state"] == 11) then
                        writeToTextDisplay({"\"WHERE ARE YOU GOING?\""})
                    elseif(ending["state"] == 12) then
                        writeToTextDisplay({"\"WHO GOES THERE?\""})
                    elseif(ending["state"] == 13) then
                        writeToTextDisplay({"[You cannot move]"})
                    elseif(ending["state"] == 14) then
                        writeToTextDisplay({"[You find the Eye of Truth. Light shines from its eye and illuminates all...]"})
                        disableItems("Eye of Truth")
                        table.insert(items, {text="Eye of Truth",command="[E]ye of Truth",enabled=true})
                    elseif(ending["state"] == 15) then
                        writeToTextDisplay({"\"THE EYE OF TRUTH..............IT SEES............\""})
                    elseif(ending["state"] == 16) then
                        writeToTextDisplay({"\"THROUGH ILLUSIONS. THE EYE...............................\""})
                    elseif(ending["state"] == 17) then
                        writeToTextDisplay({"\"THE EYEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE!!!!!!!!!!!!!!!\""})
                    elseif(ending["state"] == 18) then
                        writeToTextDisplay({"\"THE EYEEEE EEEYEEE THE EEEEYYYYEEEEYEY EEYYYYEY EYEYEYE YEY\""})
                    elseif(ending["state"] == 19) then
                        writeToTextDisplay({"\"...\""})
                    elseif(ending["state"] == 20) then
                        writeToTextDisplay({"\"?\""})
                    elseif(ending["state"] == 21) then
                        writeToTextDisplay({"[The world crumbles at your feet]"})
                    elseif(ending["state"] == 22) then
                        writeToTextDisplay({"[In a flash of light, you reappear in your bedroom.]"})
                    elseif(ending["state"] == 23) then
                        writeToTextDisplay({"Those people...the woman of stone...the knight of crystal...the spirit of the forest..."})
                    elseif(ending["state"] == 24) then
                        writeToTextDisplay({"the princess from the ether...the red prince, an inhabitant of carc____...what were they?"})
                    elseif(ending["state"] == 25) then
                        writeToTextDisplay({"Who were they?"})
                    elseif(ending["state"] == 26) then
                        writeToTextDisplay({"What were their paths?"})
                    elseif(ending["state"] == 27) then
                        writeToTextDisplay({"..."})
                    elseif(ending["state"] == 28) then
                        writeToTextDisplay({"WHAT IS YOUR PATH?"})
                    elseif(ending["state"] == 29) then
                        writeToTextDisplay({"WHERE WILL YOU GO?"})
                    elseif(ending["state"] == 30) then
                        writeToTextDisplay({"ON THIS NIGHT OF THE CRESCENT MOON..."})
                    elseif(ending["state"] == 31) then
                        writeToTextDisplay({"WHAT DARK ROAD LIT BY A MERE GLIMMER WILL YOU TAKE?"})
                    elseif(ending["state"] == 32) then
                        writeToTextDisplay({"THE RED PRINCE, CHILDE OF THE VOID..."})
                    elseif(ending["state"] == 33) then
                        writeToTextDisplay({"ON A FORGOTTEN ROAD BENEATH A SILVERY SKY..."})
                    elseif(ending["state"] == 34) then
                        writeToTextDisplay({"ALONGSIDE THE SHADOWE PEOPLE, HE SLEEPS..."})
                    elseif(ending["state"] == 35) then
                        writeToTextDisplay({"AND WAITS"})
                    elseif(ending["state"] == 36) then
                        writeToTextDisplay({"............."})
                    elseif(ending["state"] == 37) then
                        writeToTextDisplay({"The end"})
                    elseif(ending["state"] == 38) then
                        love.event.quit()
                    end
                end
                
                ending["state"] = ending["state"] + 1
            end
        end
    end
    
    -- Pause game
    --[[if(key == "p" and not isAskingTheQuestion) then
        if(state == "game") then
            state = "inventory"
        elseif(state == "inventory") then
            state = "game"
        end
    end]]
    

end