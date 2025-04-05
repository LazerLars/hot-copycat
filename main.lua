if arg[2] == "debug" then
    require("lldebugger").start()
end
local maid64 = require "src/libs/maid64"
local anim8 = require 'src/libs/anim8'
local tween = require 'src/libs/tween'

-- recommended screen sizes
---+--------------+-------------+------+-----+-----+-----+-----+-----+-----+-----+
-- | scale factor | desktop res | 1    | 2   | 3   | 4   | 5   | 6   | 8   | 10  |
-- +--------------+-------------+------+-----+-----+-----+-----+-----+-----+-----+
-- | width        | 1920        | 1920 | 960 | 640 | 480 | 384 | 320 | 240 | 192 |
-- | height       | 1080        | 1080 | 540 | 360 | 270 | 216 | 180 | 135 | 108 |
-- +--------------+-------------+------+-----+-----+-----+-----+-----+-----+-----+
local settings = {
    fullscreen = false,
    scaleMuliplier = 1,
    sceenWidth = 800,
    screenHeight = 600
}

developerMode = true
draw_hit_boxes = false

local pause_game = false


local image_path = {}

local images = {}

local grids = {}

local animations = {}

local sfx = {}



local spawn_Settings = {

}

local player = {
    x = 0,
    y = 0,
    x_target = 0,
    y_target = 0,
    width = 24,
    height = 12,
    scaling = 2,
    facing_left = true,
    -- player_state = bus_states.idleing,
    distance_to_target = 0,
    collision = false
}

local enemies = {

}

local stats = {
}


local mouse = {
    x = 0,
    y = 0,
    x_current = 0,
    y_current = 0,
    width = 0, -- used to store the value of the width of the current ongoing selection
    height = 0, -- used to store the value of the height of the current on going selection
    scaling = 1 -- used in our collision function
}

local timer = 0

local mouse_x = 0
local mouse_y = 0


function love.load()
    
    math.randomseed( os.time() )
    -- love.mouse.setVisible(false)
    
    
    -- love.graphics.setBackgroundColor( 0/255, 135/255, 81/255) -- green
    love.graphics.setBackgroundColor( 227/255, 160/255, 102/255)
    love.window.setTitle( 'Hot Copycat' )
    --optional settings for window
    love.window.setMode(settings.sceenWidth*settings.scaleMuliplier, settings.screenHeight*settings.scaleMuliplier, {resizable=true, vsync=false, minwidth=200, minheight=200})
    love.graphics.setDefaultFilter("nearest", "nearest")
    --initilizing maid64 for use and set to 64x64 mode 
    --can take 2 parameters x and y if needed for example maid64.setup(64,32)
    maid64.setup(settings.sceenWidth, settings.screenHeight)

    font = love.graphics.newFont('src/fonts/pico-8-mono.ttf', 8)
    -- font = love.graphics.newFont('src/fonts/PressStart2P-Regular.ttf', 8)
    --font:setFilter('nearest', 'nearest')

    love.graphics.setFont(font)

    -- path to images
    -- image_path.watermelon_cursor = "src/sprites/cursor_watermelon.png"
    
    
    -- create the images
    -- images.watermelon_cursor = love.graphics.newImage(image_path.watermelon_cursor)
  
    -- grids  
    -- grids.bus_idle_grid = anim8.newGrid(24, 12, images.bus_idle_sheet:getWidth(), images.bus_idle_sheet:getHeight())

    -- animations
    -- animations.bus_idle_animation = anim8.newAnimation(grids.bus_idle_grid('1-3',1), 0.1)

    -- move with tween
    -- move_bus = tween.new(2, bus, {x=bus.x_target,y=bus.y_target}, tween.easing.linear) -- how do i check that this is finished?
    

    -- LOAD SOUNDS
    -- sfx.driving = love.audio.newSource("src/sfx/sfx_drive_short.wav", 'static')
    -- sfx.driving:setLooping(true)
    -- sfx.idle = love.audio.newSource("src/sfx/sfx_bus_idle.wav", 'static')
    
    -- sfx.idle:setVolume(0.3)
    

    -- sfx.idle:play()
    
    -- set initial position of the buttons
    
end

function love.update(dt)
    if pause_game == false then

        timer = timer + dt
      
    
        mouse_x = maid64.mouse.getX()
        mouse_y = maid64.mouse.getY()

        -- animations.bus_idle_animation:update(dt)
        -- animations.bus_driving_animation:update(dt)
        if love.mouse.isDown(1) then
            local test = 1
        end	


        -- bus.distance_to_target = calculate_distance_between_two_targets(bus.x, bus.y, bus.x_target, bus.y_target)

        -- local move_bus_complete = move_bus:update(dt)
        
    end

    if pause_game then
     -- we pause here
    end
end



function love.draw()
    
    maid64.start()--starts the maid64 process
    
    love.graphics.setLineStyle('rough')



    if developerMode == true then
    
        love.graphics.print(maid64.mouse.getX() ..  "," ..  maid64.mouse.getY(), 1,1)
        -- love.graphics.print(math.floor(player.x-player.originX) ..  "," .. math.floor(player.y-player.originY), 1,58)
         --can also draw shapes and get mouse position
        -- love.graphics.rectangle("fill", maid64.mouse.getX(),  maid64.mouse.getY(), 1,1)
    end
    

    
    if pause_game then

    end



    maid64.finish()--finishes the maid64 process
end

function love.resize(w, h)
    -- this is used to resize the screen correctly
    maid64.resize(w, h)
end


function love.keypressed(key)
    if key == 'e' then
      
    end

    if key == "escape" then
        if pause_game == false then
            print("pause game")
            pause_game = true
        else
            print("resume game")
            pause_game = false
        end
    end

    -- toggle fullscreen
    if key == 'f11' then
        if settings.fullscreen == false then
            love.window.setFullscreen(true, "desktop")
            settings.fullscreen = true
        else
            love.window.setMode(settings.sceenWidth*settings.scaleMuliplier, settings.screenHeight*settings.scaleMuliplier, {resizable=true, vsync=false, minwidth=200, minheight=200})
            maid64.setup(settings.sceenWidth, settings.screenHeight)
            settings.fullscreen = false
        end 
    end
end

function love.mousepressed(x, y, button, istouch)
    -- when the leftm mouse  is pressed, we want to save the initial click x,y position
    if button == 1 then -- Versions prior to 0.10.0 use the MouseConstant 'l'
      --...
    end
    if button == 2 then
     
        if mouse_x < player.x then
            player.facing_left = true
        else
            player.facing_left = false
        end
    end
 end

 function love.mousereleased(x, y, button)
    -- when the left mouse is released we want to reset the mouse selection so we can stop drawing the square on the screen
    if button == 1 then
        -- ...
    end
 end



-- make a copy of a table
function copy_table(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v  -- Copy each value
    end
    return copy
end

-- make a copy of nested tables
function deep_copy(t)
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = deep_copy(v)
        else
            copy[k] = v
        end
    end
    return copy
end


-- Function to calculate the distance to the target
function calculate_distance_between_two_targets(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end


function collision_check(object_a, object_b)

    -- Adjusted edges of object a
    local a_left = object_a.x
    local a_right = object_a.x + object_a.width * object_a.scaling
    local a_top = object_a.y
    local a_bottom = object_a.y + object_a.height * object_a.scaling

    -- Adjusted edges of object b
    local b_left = object_b.x
    local b_right = object_b.x + object_b.width * object_b.scaling
    local b_top = object_b.y
    local b_bottom = object_b.y + object_b.height * object_b.scaling

    -- Check if the rectangles overlap
    local isColliding = a_right > b_left and
                        a_left < b_right and
                        a_bottom > b_top and
                        a_top < b_bottom

    return isColliding
end




