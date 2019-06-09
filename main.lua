function love.load()

    font = love.graphics.newFont("prstart.ttf")
    love.graphics.setFont(font)
    

    love.graphics.setColor(0, 255, 0, 1)
    love.graphics.setDefaultFilter("nearest", "nearest", 0)
    love.window.setMode(640 * 1, 360 * 1, {resizable = true})
    
    location = "Bedroom"
    coords = {x=0,y=0}
    scale = {}
    curText = "Night of the Crescent Moon Ver " .. gameVersion .. "\n\n\n\n\nA text adventure by Elias Mote\nCopyright (c) Roc Studios 2019"
    timer = 0
end

function love.update(dt)
    scale.x = love.graphics.getWidth()/640
    scale.y = love.graphics.getHeight()/360
    timer = timer + 1
end

function love.draw()
    -- scale the window
    love.graphics.scale(scale.x,scale.y)
    
    -- draw image screen
    love.graphics.rectangle("line", 20, 20, 300, 180, 10)
    
    -- draw inventory screen
    love.graphics.rectangle("line", 340, 20, 280 , 180, 10)
    
    -- draw text screen
    love.graphics.rectangle("line", 20, 220, 600 , 120, 10)
    
    -- draw inventory text
    love.graphics.printf("Inventory", 430, 30, love.graphics.getWidth()-30*scale.x, "left", 0)
    love.graphics.printf("Item 1", 350, 60, love.graphics.getWidth()-30*scale.x, "left", 0)
    
    -- draw game text
    love.graphics.printf(curText, 30 , 233 , love.graphics.getWidth()-30*scale.x, "left", 0)
    
    -- draw blinking cursor
    if(timer % 60 < 60 / 2) then
        love.graphics.rectangle("fill", 30 , 317 , 12 , 12)
    end
end