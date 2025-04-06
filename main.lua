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
    scaleMuliplier = 2,
    sceenWidth = 480,
    screenHeight = 270
}

developerMode = true
draw_hit_boxes = false

local pause_game = false


local image_path = {}

local images = {}

local grids = {}

local animations = {}

local sfx = {}

local scenes = {
    chipping = 'chipping',
    front_desk = 'front_desk'
}

local current_scene = scenes.front_desk


local spawn_Settings = {

}

local player_states = {
    idle = 'idle',
    walking = 'walking'
}

local player = {
    x = 0,
    y = 0,
    x_target = 0,
    y_target = 0,
    move_completed = true,
    width = 16,
    height = 16,
    scaling = 5,
    facing_left = true,
    player_state = player_states.idle,
    distance_to_target = 0,
    collision = false
}

local circut_board = {
    x = 0,
    y = 0,
    width = 64,
    height = 64,
    scaling = 4
}

local chip = {
    x = 262,
    y = 7,
    scaling = 4,
    width = 7,
    height = 7,
    x_placement_span_min = 262,
    y_placement_span_min = 3,
    y_placement_span_max = 16,
    collision = false,
    dragging = false,
    placed = false

}

 -- draw chip placement box
 local chip_placemenet_area = {
    x = 115,
    y = 20,
    width = 125,
    height = 75
}

-- draw chip placement box
local wire_connector_placemenet_area_1 = {
    x = 75,
    y = 20,
    width = 20,
    height = 75
}

-- draw chip placement box
local wire_connector_placemenet_area_2 = {
    x = 75,
    y = 110,
    width = 165,
    height = 30
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
    width = 1, -- used to store the value of the width of the current ongoing selection
    height = 1, -- used to store the value of the height of the current on going selection
    scaling = 1, -- used in our collision function
    collision = false,
    mouse_x_chip_off_set = 0,
    mouse_y_chip_off_set = 0
}

local timer = 0

local mouse_x = 0
local mouse_y = 0


function love.load()
    
    math.randomseed( os.time() )
    -- love.mouse.setVisible(false)
    
    
    -- love.graphics.setBackgroundColor( 0/255, 135/255, 81/255) -- green
    -- love.graphics.setBackgroundColor( 227/255, 160/255, 102/255)
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
    local sprite_source = "src/sprites/"
    -- image_path.player = "src/sprites/player_16x16_sprite_sheet_16x16.png"
    image_path.player = sprite_source .. "player_16x16_sprite_sheet_16x16.png"
    image_path.chip_00 = sprite_source .. "chip_00.png"
    image_path.chip_01 = sprite_source .. "chip_01.png"
    image_path.console_closed = sprite_source ..  "console_closed_16x13_00.png"
    image_path.console_open = sprite_source .. "console_open_16x13_00.png"
    -- image_path.circut_board_00 = sprite_source .. "curciut board_64x64.png"
    image_path.circut_board_00 = sprite_source .. "circuit_board_02.png"
    image_path.customer_sprite_sheet = sprite_source .. "customer_16x16_00-Sheet.png"
    image_path.connector_yellow_00 = sprite_source .. "connector_yellow_00.png"
    image_path.connector_grey_00 = sprite_source .. "connector_grey_00.png"

    -- create the images  
    -- new_img = love.graphics.newImage
    images.player = love.graphics.newImage(image_path.player)
    images.chip_00 = love.graphics.newImage(image_path.chip_00)
    images.chip_01 = love.graphics.newImage(image_path.chip_01)
    images.console_closed = love.graphics.newImage(image_path.console_closed)
    images.console_open = love.graphics.newImage(image_path.console_open)
    images.circut_board_00 = love.graphics.newImage(image_path.circut_board_00)
    images.customer_sprite_sheet = love.graphics.newImage(image_path.customer_sprite_sheet)
    images.connector_yellow_00 = love.graphics.newImage(image_path.connector_yellow_00)
    images.connector_grey_00 = love.graphics.newImage(image_path.connector_grey_00)
  
    -- grids
    grids.player_grid = anim8.newGrid(16, 16, images.player:getWidth(), images.player:getHeight())
    -- grids.customers_grid = anim8.newGrid(16,16, images.customer_sprite_sheet, images.customer_sprite_sheet:getWidth(), images.customer_sprite_sheet:getHeight() )
    

    -- animations
    animations.player_idle_animation = anim8.newAnimation(grids.player_grid('1-5', 1), 0.3)
    animations.player_walk_animation = anim8.newAnimation(grids.player_grid('1-5', 2), 0.3)

    -- animations.customer_00_idle
    -- animations.customer_01_walk
    -- animations.customer_02_sleep
    -- move with tween
    -- move_bus = tween.new(2, bus, {x=bus.x_target,y=bus.y_target}, tween.easing.linear) -- how do i check that this is finished?
    player_move = tween.new(2, player, {x=player.x_target, y=player.y_target}, tween.easing.linear)

    -- LOAD SOUNDS
    -- sfx.driving = love.audio.newSource("src/sfx/sfx_drive_short.wav", 'static')
    -- sfx.driving:setLooping(true)
    -- sfx.idle = love.audio.newSource("src/sfx/sfx_bus_idle.wav", 'static')
    
    -- sfx.idle:setVolume(0.3)
    

    -- sfx.idle:play()
    
    -- set initial position of the buttons
    current_scene = scenes.chipping

    mouse_x = maid64.mouse.getX()
    mouse_y = maid64.mouse.getY()
    mouse.x = mouse_x
    mouse.y = mouse_y
end

function love.update(dt)
    mouse_x = maid64.mouse.getX()
    mouse_y = maid64.mouse.getY()
    mouse.x = mouse_x
    mouse.y = mouse_y

    if pause_game == false then

        timer = timer + dt
        if current_scene == scenes.front_desk then
            local player_move_completed =  player_move:update(dt)
            if player_move_completed then
                player.player_state = player_states.idle
            end
            -- player_move = tween.new(1, player, {x=400, y=400}, tween.easing.inOutSine)
            mouse_x = maid64.mouse.getX()
            mouse_y = maid64.mouse.getY()
            if player.player_state == player_states.idle then
                animations.player_idle_animation:update(dt)
            end
            if player.player_state == player_states.walking then
                animations.player_walk_animation:update(dt)
                -- player_move = tween.new(5, player, {x=player.x_target, y=player.y_target}, tween.easing.inOutSine)
            end
        end

        if current_scene == scenes.chipping then
            local chip_collsion = collision_check(mouse, chip)
          
            if love.mouse.isDown(1) then
                -- check if we can start dragging
                if chip.dragging == false and chip_collsion then
                    chip.dragging = true
                    chip.scaling = 5
                    -- offsets are used to enture the sprites stay accurate possitioned according to the mouse when its clicked
                    mouse.mouse_x_chip_off_set = mouse_x - chip.x
                    mouse.mouse_y_chip_off_set = mouse_y - chip.y
                end
            else
                -- Stop dragging when mouse released
                chip.dragging = false
                chip.scaling = 4
            end

            -- move of chip allowed..
            if chip.dragging then
                -- offsets are used to enture the sprites stay accurate possitioned according to the mouse when its clicked
                chip.x = mouse_x - mouse.mouse_x_chip_off_set
                chip.y = mouse_y - mouse.mouse_y_chip_off_set
            end
        end
      
        
        if love.mouse.isDown(1) then
            -- ..
        end	


        -- player.distance_to_target = calculate_distance_between_two_targets(player.x, bus.y, player.x_target, player.y_target)
        
    end

    if pause_game then
        local a = 1
     -- we pause here
    end
end



function love.draw()
    
    maid64.start()--starts the maid64 process
    
    love.graphics.setLineStyle('rough')



  
    
    if pause_game == false then
        if current_scene == scenes.front_desk then
            if player.player_state == player_states.idle then
                if player.facing_left then
                    animations.player_idle_animation:draw(images.player, player.x, player.y, 0, player.scaling, player.scaling)
                else
                    animations.player_idle_animation:draw(images.player, player.x, player.y, 0, -player.scaling, player.scaling, player.width, 0)
                end
            end
            if player.player_state == player_states.walking then
                if player.facing_left then
                animations.player_walk_animation:draw(images.player, player.x, player.y, 0, player.scaling, player.scaling)
            else
                animations.player_walk_animation:draw(images.player, player.x, player.y, 0, -player.scaling, player.scaling, player.width, 0)
            end
            end 
        end
        
        
        if current_scene == scenes.chipping then
            love.graphics.draw(images.circut_board_00, circut_board.x, circut_board.y, 0, circut_board.scaling, circut_board.scaling)
            love.graphics.draw(images.chip_01, chip.x, chip.y, 0, chip.scaling, chip.scaling)
        end


        if developerMode == true then
    
            love.graphics.print(maid64.mouse.getX() ..  "," ..  maid64.mouse.getY(), 1,1)
            -- love.graphics.print("player state: " .. player.player_state, 1,16)
            -- love.graphics.print("x,y state: " .. player.x_target .. "," .. player.y_target, 1,32)
            
            -- love.graphics.print(math.floor(player.x-player.originX) ..  "," .. math.floor(player.y-player.originY), 1,58)
             --can also draw shapes and get mouse position
            -- love.graphics.rectangle("fill", maid64.mouse.getX(),  maid64.mouse.getY(), 1,1)
        end

        --draw place where we can place our chip        
        love.graphics.rectangle('line', chip_placemenet_area.x, chip_placemenet_area.y, chip_placemenet_area.width, chip_placemenet_area.height )
        
        -- draw connector area 1
        love.graphics.rectangle('line', wire_connector_placemenet_area_1.x, wire_connector_placemenet_area_1.y, wire_connector_placemenet_area_1.width, wire_connector_placemenet_area_1.height )
        
        love.graphics.draw( images.connector_yellow_00,  wire_connector_placemenet_area_1.x + 1, wire_connector_placemenet_area_1.y + 5, 0, 4, 4)

        love.graphics.draw( images.connector_grey_00,  wire_connector_placemenet_area_1.x + 1, wire_connector_placemenet_area_1.y + 30, 0, 4, 4)
        
        love.graphics.draw( images.connector_yellow_00,  wire_connector_placemenet_area_1.x + 1, wire_connector_placemenet_area_1.y + 55, 0, 4, 4)

        -- love.graphics.rectangle('fill', wire_connector_placemenet_area_1.x + 5, wire_connector_placemenet_area_1.y + 5, 4*2,4*2)

        -- love.graphics.rectangle('fill', wire_connector_placemenet_area_1.x + 5, wire_connector_placemenet_area_1.y + 20, 4*2,4*2)

        -- love.graphics.rectangle('fill', wire_connector_placemenet_area_1.x + 5, wire_connector_placemenet_area_1.y + 35, 4*2,4*2)
        
        -- draw connector area 2
        
        love.graphics.rectangle('line', wire_connector_placemenet_area_2.x, wire_connector_placemenet_area_2.y, wire_connector_placemenet_area_2.width, wire_connector_placemenet_area_2.height )
        love.graphics.draw( images.connector_yellow_00,  wire_connector_placemenet_area_2.x + 5, wire_connector_placemenet_area_2.y + 5, 0, 4, 4)

        love.graphics.draw( images.connector_grey_00,  wire_connector_placemenet_area_2.x + 30, wire_connector_placemenet_area_2.y + 5, 0, 4, 4)
        
        love.graphics.draw( images.connector_yellow_00,  wire_connector_placemenet_area_2.x + 55, wire_connector_placemenet_area_2.y + 5, 0, 4, 4)
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
    if key == '.' then
        print("changing scene")
        if current_scene == scenes.chipping then
            current_scene = scenes.front_desk
        elseif current_scene == scenes.front_desk then
        current_scene = scenes.chipping
        end
    end

    if key == 'left' then
        player.facing_left = true
    end
    if key == 'right' then
        player.facing_left = false
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

    if key == "," then
        reset_chip()
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

    if button == 2 then
        player.player_state = player_states.walking
        player.x_target = mouse_x
        player.y_target = mouse_y
        player_move = tween.new(2, player, {x=player.x_target, y=player.y_target}, tween.easing.inOutSine)
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

function reset_chip()
    chip.x = 262
    chip.y = 7
    chip.scaling = 4
    chip.width = 7
    chip.height = 7
    chip.x_placement_span_min = 262
    chip.y_placement_span_min = 3
    chip.y_placement_span_max = 16
    chip.collision = false
    chip.dragging = false
    chip.placed = false
end


