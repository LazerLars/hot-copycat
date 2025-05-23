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

debug_mode = false

developerMode = false
draw_hit_boxes = false

local pause_game = false


local image_path = {}

local images = {}

local grids = {}

local animations = {}

local sfx = {}

local chipping_states = {
    dragging = 1,
    soldering = 2,
    glueing = 3
}

local current_chipping_state = chipping_states.dragging

local scenes = {
    chipping = 'chipping',
    front_desk = 'front_desk',
    tutorial = 'turorial',
    splash = 'splash'
}

local tutorial_step = 1
local totorial_step_total = 5

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
    scaling = 6,
    scaling_baseline = 6,
    width = 7,
    height = 7,
    x_placement_span_min = 262,
    y_placement_span_min = 3,
    y_placement_span_max = 16,
    collision = false,
    dragging = false,
    glued = false,
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

local connectors_list = {} -- list to hold the connectors we need to solder the wire on

local wires_list = {}

-- list to hold positions of pins on the chip, so we can collision detect
local chip_pins_list = {}


local soldering_iron_settings = {
    x_offset = 0,
    y_offset = 16,
    scaling = 4
}
local glue_gun_settings = {
    x_offset = 0,
    y_offset = 3,
    scaling = 4
}

local current_chip_mod_status = {
    connectors_glued = 0,
    chip_glued = 0,
    wires_attached = 0,
    wires_soldered = 0,
}

local current_mod_complete = false

local allready_played_gz_music = false

local stats = {
    consoles_modded = 0,
    time = 0

}

local soldering_locations_list = {}

local glue_gun_locations_list = {}

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

local drag_icon_flag = false
local glue_gun_pressed_flag = false
local soldering_pressed_flag = false

local timer = 0

local splash_timer = 0

local mouse_x = 0
local mouse_y = 0

-- flag to detect if we drag a connector

local flag_dragging_chip = nil

local flag_dragging_connector = nil

local flag_dragging_wire = nil

function love.load()
    
    math.randomseed( os.time() )
    -- love.mouse.setVisible(false)
    love.mouse.setVisible(false)
    
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
    image_path.hand_drag = sprite_source .. "kenney_hand_drag.png"
    image_path.hand_normal = sprite_source .. "kenney_hand_normal.png"
    image_path.soldering_iron = sprite_source .. "soldering_iron.png"
    image_path.glue_gun = sprite_source .. "glue_gun.png"
    image_path.glue_gun_pressed = sprite_source .. "glue_gun_pressed.png"
    image_path.soldering_smoke_sprite_sheet = sprite_source .. "soldering_smoke-Sheet.png"
    image_path.glue_stain = sprite_source .. "glue_stain.png"
    image_path.soldering_stain = sprite_source .. "soldering_stain.png"
    
    
    image_path.tutorial_00 = sprite_source .. "tutorial_00.png"
    image_path.tutorial_01 = sprite_source .. "tutorial_01.png"
    image_path.tutorial_02 = sprite_source .. "tutorial_02.png"
    image_path.tutorial_03 = sprite_source .. "tutorial_03.png"
    image_path.tutorial_04 = sprite_source .. "tutorial_04.png"
    image_path.tutorial_05 = sprite_source .. "tutorial_05.png"
    image_path.tutorial_06 = sprite_source .. "tutorial_06.png"
    image_path.tutorial_07 = sprite_source .. "tutorial_07.png"
    image_path.tutorial_08 = sprite_source .. "tutorial_08.png"
    
    image_path.logo = sprite_source .. "splash screen_hot_copy_cat.png"
    image_path.skeleton = sprite_source .. "skeleton_frenjam.png"

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
    images.hand_drag = love.graphics.newImage(image_path.hand_drag)
    images.hand_normal = love.graphics.newImage(image_path.hand_normal)
    images.soldering_iron = love.graphics.newImage(image_path.soldering_iron)
    images.glue_gun = love.graphics.newImage(image_path.glue_gun)
    images.glue_gun_pressed = love.graphics.newImage(image_path.glue_gun_pressed)
    images.soldering_smoke_sprite_sheet = love.graphics.newImage(image_path.soldering_smoke_sprite_sheet)
    images.glue_stain = love.graphics.newImage(image_path.glue_stain)
    images.soldering_stain = love.graphics.newImage(image_path.soldering_stain)
    
    images.tutorial_00 = love.graphics.newImage(image_path.tutorial_00)
    images.tutorial_01 = love.graphics.newImage(image_path.tutorial_01)
    images.tutorial_02 = love.graphics.newImage(image_path.tutorial_02)
    images.tutorial_03 = love.graphics.newImage(image_path.tutorial_03)
    images.tutorial_04 = love.graphics.newImage(image_path.tutorial_04)
    images.tutorial_05 = love.graphics.newImage(image_path.tutorial_05)
    images.tutorial_06 = love.graphics.newImage(image_path.tutorial_06)
    images.tutorial_07 = love.graphics.newImage(image_path.tutorial_07)
    images.tutorial_08 = love.graphics.newImage(image_path.tutorial_08)
    
    images.logo = love.graphics.newImage(image_path.logo)
    images.skeleton = love.graphics.newImage(image_path.skeleton)
  
    -- grids
    grids.player_grid = anim8.newGrid(16, 16, images.player:getWidth(), images.player:getHeight())
    grids.soldering_smoke_grid = anim8.newGrid(16, 16, images.soldering_smoke_sprite_sheet:getWidth(), images.soldering_smoke_sprite_sheet:getHeight())
    -- grids.customers_grid = anim8.newGrid(16,16, images.customer_sprite_sheet, images.customer_sprite_sheet:getWidth(), images.customer_sprite_sheet:getHeight() )
    

    -- animations
    animations.player_idle_animation = anim8.newAnimation(grids.player_grid('1-5', 1), 0.3)
    animations.player_walk_animation = anim8.newAnimation(grids.player_grid('1-5', 2), 0.3)
    animations.soldering_smoke_animation = anim8.newAnimation(grids.soldering_smoke_grid('1-5', 1), 0.08)
    
    -- animations.customer_00_idle
    -- animations.customer_01_walk
    -- animations.customer_02_sleep
    -- move with tween
    -- move_bus = tween.new(2, bus, {x=bus.x_target,y=bus.y_target}, tween.easing.linear) -- how do i check that this is finished?
    player_move = tween.new(2, player, {x=player.x_target, y=player.y_target}, tween.easing.linear)

    -- LOAD SOUNDS
    sfx.soldering = love.audio.newSource("src/sfx/solderin_iron_sfx.wav", 'static')
    sfx.soldering:setLooping(true)
    sfx.glue = love.audio.newSource("src/sfx/glue.wav", 'static')
    sfx.blob = love.audio.newSource("src/sfx/blob.wav", 'static')
    sfx.music_loop = love.audio.newSource("src/sfx/drama_party.wav", 'static')
    sfx.music_loop:setLooping(true)
    sfx.music_loop:play()
    sfx.music_loop:setVolume(0.5)
    sfx.oh_yeah = love.audio.newSource("src/sfx/yey.mp3", 'static')

    -- sfx.glue:setLooping(true)
   
    
    -- sfx.idle:setVolume(0.3)
    
    -- set initial position of the buttons
    current_scene = scenes.chipping
    add_connector(images.connector_yellow_00)
    add_connector(images.connector_yellow_00)
    add_connector(images.connector_yellow_00)
    add_connector(images.connector_grey_00)
    add_connector(images.connector_grey_00)
    add_connector(images.connector_grey_00)

    -- add wires
    add_wire(1)
    add_wire(2)
    add_wire(3)
    add_wire(4)
    add_wire(5)
    add_wire(6)

    add_chip_pins()

    mouse_x = maid64.mouse.getX()
    mouse_y = maid64.mouse.getY()
    mouse.x = mouse_x
    mouse.y = mouse_y

    -- current_scene = scenes.tutorial
    current_scene = scenes.splash
end

function love.update(dt)
    
    if current_scene == scenes.splash then
        if splash_timer < 4 then
            splash_timer = splash_timer + dt
        else
            current_scene = scenes.tutorial
            tutorial_step = 1
        end
        
    end
    mouse_x = maid64.mouse.getX()
    mouse_y = maid64.mouse.getY()
    mouse.x = mouse_x
    mouse.y = mouse_y

    if pause_game == false then

        timer = timer + dt
        -- if current_scene == scenes.front_desk then
        --     local player_move_completed =  player_move:update(dt)
        --     if player_move_completed then
        --         player.player_state = player_states.idle
        --     end
        --     -- player_move = tween.new(1, player, {x=400, y=400}, tween.easing.inOutSine)
        --     mouse_x = maid64.mouse.getX()
        --     mouse_y = maid64.mouse.getY()
        --     if player.player_state == player_states.idle then
        --         animations.player_idle_animation:update(dt)
        --     end
        --     if player.player_state == player_states.walking then
        --         animations.player_walk_animation:update(dt)
        --         -- player_move = tween.new(5, player, {x=player.x_target, y=player.y_target}, tween.easing.inOutSine)
        --     end
        -- end
        if current_scene == scenes.tutorial then
            
        end
        if current_scene == scenes.chipping then
            stats.time = stats.time + dt
            
            calculate_progress_of_current_chip_mod()

            check_of_current_mod_is_complete()

            if debug_mode then
                print("we are in debug...")
            end
            
            if debug_mode then
                print(#soldering_locations_list)
                print("we are in debug...")
            end
            
            -- when we are in draggin state
            if current_chipping_state == chipping_states.dragging then
                -- check for glue chip collision
                for key, glue_stain in pairs(glue_gun_locations_list) do
                    local collision = collision_check(glue_stain, chip)
                    -- CHIP COLLISION with glue
                    -- check if we need to mark it as glued
                    if collision and chip.dragging == false then
                        chip.glued = true
                    end
                    -- check for connector collison
                    for key, connector in pairs(connectors_list) do
                        local collision = collision_check(connector, glue_stain)
                        -- CONNECTOR COLLISION with glue
                        -- check if we need to mark it as glued
                        if collision and connector.dragging == false then
                            connector.glued = true
                        end
                        
                    end
                end

                -- check if a wire is connected to the chip or a connector
                for key, wire in pairs(wires_list) do
                    if debug_mode then
                        print("we are in debug...")
                    end


                    local wire_start = wire.line_start
                    local wire_end = wire.line_end

                    wire_start.connected_pin = false
                    wire_end.connected_pin = false
                    -- create a local copy of the pin so we can add the chip.x and chip.y to the posision
                    for key, pin in pairs(chip_pins_list) do
                        pin.wire_connected = false

                        local this_pin = { 
                            x = chip.x + pin.x,
                            y = chip.y +  pin.y,
                            width = pin.width,
                            height = pin.height,
                            scaling = pin.scaling,
                            wire_connected = pin.wire_connected,
                            wire_soldered = pin.wire_soldered
                        }

                        local collision_start = collision_check(wire_start, this_pin)
                        local collision_end = collision_check(wire_end, this_pin)
                        if collision_start then
                            -- print("wire collision start")
                            wire_start.connected_pin = true
                            pin.wire_connected = true
        
                        end
                        if collision_end then
                            -- print("wire collision end")
                            wire_end.connected_pin = true
                            pin.wire_connected = true
                        end
                    end
                    
                    -- check if a wire is connected to a connector
                    wire_start.connected_connector = false
                    wire_end.connected_connector = false
                    for key, connector in pairs(connectors_list) do
                        connector.wire_connected = false

                        local collision_start = collision_check(wire_start, connector)
                        local collision_end = collision_check(wire_end, connector)
                        if collision_start then
                            -- print("connector collision start")
                            wire_start.connected_connector = true
                            connector.wire_connected = true
                        end
                        if collision_end then
                            -- print("connector collision end")
                            wire_end.connected_connector = true
                            connector.wire_connected = true
                        end
                    end
                    
                end             
                
                
                if debug_mode then
                    print("we are in debug...")
                end

                -- ensure we only move one objeect at a time
                -- move chip
                if flag_dragging_connector == nil and flag_dragging_wire == nil then
                    -- if not chip.glued then
                    move_chip_on_mouse_click()
                    -- end
                end
                
                -- move connector(s)
                if flag_dragging_chip == nil and flag_dragging_wire == nil then
                    move_connector_on_mouse_click()
                end
                
                -- move wire(s)
                if flag_dragging_chip == nil and flag_dragging_connector == nil then
                    move_wire_on_mouse_click()
                end
            end
            if current_chipping_state == chipping_states.soldering then
                animations.soldering_smoke_animation:update(dt)
                soldering_sfx()


            end

            if current_chipping_state == chipping_states.glueing then
                
            end

            
            -- check if the wire is soldered, if yes then we need to mark it so we cant move the wire anymore
            for key, solder in pairs(soldering_locations_list) do
                if debug_mode then
                    print("we are in debug...")
                end

                for key, wire in pairs(wires_list) do
                    if debug_mode then
                        print("we are in debug...")
                    end


                    local wire_start = wire.line_start
                    local wire_end = wire.line_end
                    
                    local collison_start = collision_check(solder, wire_start)
                    local collison_end = collision_check(solder, wire_end)

                    if collison_start and wire_start.connected_pin == true then
                        if chip.glued then
                            wire_start.soldered = true
                        end
                        -- print("SOLDER AND WIRE COLLISION START")
                    end
                    if collison_start and wire_start.connected_connector == true then
                        wire_start.soldered = true
                        -- print("SOLDER AND WIRE COLLISION START")
                    end
                    if collison_end and wire_end.connected_pin == true or collison_end and wire_end.connected_connector == true then
                        wire_end.soldered = true
                        -- print("SOLDER AND WIRE COLLISION END")
                    end
                end
            end
        end
    end

    if pause_game then
        
     -- we pause here
    end
end



function love.draw()
    
    maid64.start()--starts the maid64 process
    -- draw_mod_complete_screen()
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

        if current_scene == scenes.splash then
            love.graphics.setColor(223/255,221/255,181/255)
            love.graphics.rectangle('fill', 1,1, 1000, 1000)
            reset_color()
            love.graphics.draw(images.logo, 120,70)
            love.graphics.draw(images.skeleton, 165,240)

            
        end

        if current_scene == scenes.tutorial then
            if tutorial_step == 1 then
                
                love.graphics.print("Press '2' to go to glue mode", 1, 1)
                love.graphics.print("Press 'Left Mouse' to place glue on the circuit board", 1, 20)
                love.graphics.draw(images.tutorial_00, 1,70)
                love.graphics.print("NEXT 'Left Mouse'", 250, 150)
                love.graphics.print("SKIP TUTORIAL 'Right Mouse'", 250, 165)
            end
            if tutorial_step == 2 then
                love.graphics.print("Press '1' to go to drag mode", 1, 1)
                love.graphics.print("Press'n'hold 'Left Mouse' on the chip and drag on some glue", 1, 20)
                love.graphics.print("Release on top to glue to lock it", 1, 40)
                love.graphics.draw(images.tutorial_01, 1,70)
            end
            if tutorial_step == 3 then
                love.graphics.print("Place more glue", 1, 1)
                love.graphics.print("Drag connectors with 'Left Mouse' on some glue", 1, 20)
                love.graphics.print("Release on top to glue to lock it", 1, 40)
                love.graphics.draw(images.tutorial_03, 1,70)
            end
            if tutorial_step == 4 then
                love.graphics.print("Connect wires to chip pins and connectors", 1, 1)
                love.graphics.print("Repeat with 6 wires and 6 connectors", 1, 20)
                love.graphics.draw(images.tutorial_04, 1,70)
            end
            if tutorial_step == 5 then
                love.graphics.print("Connect 6 wires end to the chip pins", 1, 1)
                love.graphics.print("Connect the other end of the wire with a connector", 1, 20)
                love.graphics.draw(images.tutorial_05, 1,70, 0, 2, 2)
            end
            if tutorial_step == 6 then
                love.graphics.print("Press '3' to go to soldering mode", 1, 1)
                love.graphics.print("Press 'Left mouse' to solder", 1, 20)
                love.graphics.print("Solder each wire to each pin on the chip", 1, 40)
                love.graphics.print("Solder each wire to each connector", 1, 60)
                love.graphics.draw(images.tutorial_06, 1,80, 0, 2, 2)
            end
            if tutorial_step == 7 then
                love.graphics.print("Summary:", 1, 1)
                love.graphics.print("Glue the chip to the circuit board", 1, 20)
                love.graphics.print("Glue the connectors to the circuit board", 1, 40)
                love.graphics.print("Connect the wires with connectors and the chip pins", 1, 60)
                love.graphics.print("Solder each wire with a chip pin and a connector", 1, 80)
              
                love.graphics.draw(images.tutorial_08, 1,100, 0, 0.5, 0.5)
            end
            if tutorial_step == 8 then
                love.graphics.print("GZ you complete a mod", 1, 1)
                love.graphics.print("Press 'SPACE' to start a new mod", 1, 20)
              
                love.graphics.draw(images.tutorial_07, 1,80, 0, 2, 2)
            end
        end
        
        
        if current_scene == scenes.chipping then
            -- draw the progress of the current chip mod
            draw_stats_of_current_mod()
            -- draw the circuit board
            love.graphics.draw(images.circut_board_00, circut_board.x, circut_board.y, 0, circut_board.scaling, circut_board.scaling)


            -- DRAW GLUE STAIN IF ANY
            for key, glue_stain in pairs(glue_gun_locations_list) do
                love.graphics.draw(images.glue_stain, glue_stain.x, glue_stain.y, 0, 4, 4)
            end
    
            -- DRAW SOLDERING STAIN IF ANy
            for key, soldering_stain in pairs(soldering_locations_list) do
                love.graphics.draw(images.soldering_stain, soldering_stain.x, soldering_stain.y, 0, 4, 4)
            end

            -- draw the chip
            love.graphics.draw(images.chip_01, chip.x, chip.y, 0, chip.scaling, chip.scaling)

            -- draw all connectors
            for key, connector in pairs(connectors_list) do
                love.graphics.draw(connector.sprite, connector.x, connector.y, 0, connector.scaling, connector.scaling)
            end
            
            for key, wire in pairs(wires_list) do
                set_color_with_transparency(wire.color_numb)
                love.graphics.rectangle('line', wire.line_start.x, wire.line_start.y, wire.line_start.height, wire.line_start.width, 0, wire.line_start.scaling, wire.line_start.scaling)
                love.graphics.rectangle('line', wire.line_end.x, wire.line_end.y, wire.line_end.height, wire.line_end.width, 0, wire.line_end.scaling, wire.line_end.scaling)
                love.graphics.setLineWidth(wire.line_width)
                love.graphics.line(wire.line_start.x + wire.line_offset, wire.line_start.y + wire.line_offset, wire.line_end.x + wire.line_offset, wire.line_end.y + wire.line_offset)
                love.graphics.setLineWidth(1)
                reset_color()
            end
            

            -- draw selected items

            if current_chipping_state == chipping_states.dragging then
                if drag_icon_flag == true then
                    love.graphics.draw(images.hand_drag, mouse_x - 8, mouse_y)
                else
                    love.graphics.draw(images.hand_normal, mouse_x - 8, mouse_y)
                end
    
                
            end
            if current_chipping_state == chipping_states.soldering then
                love.graphics.draw(images.soldering_iron, mouse_x, mouse_y - (soldering_iron_settings.y_offset * soldering_iron_settings.scaling ) , 0, soldering_iron_settings.scaling, soldering_iron_settings.scaling)
                if soldering_pressed_flag then
                    animations.soldering_smoke_animation:draw(images.soldering_smoke_sprite_sheet, mouse_x, mouse_y - (soldering_iron_settings.y_offset * soldering_iron_settings.scaling ), 0, soldering_iron_settings.scaling, soldering_iron_settings.scaling)
                end
                
            end
            if current_chipping_state == chipping_states.glueing then
                if glue_gun_pressed_flag then
                    love.graphics.draw(images.glue_gun_pressed, mouse_x, mouse_y - (3 * 4), 0, 4,4)
                else
                    love.graphics.draw(images.glue_gun, mouse_x, mouse_y - (3 * 4), 0, 4,4)

                end
            end
            -- draw stats on the screen
            draw_score_and_time()
        end
        

        -- test glue stain
        -- love.graphics.draw(images.glue_stain, 200, 200, 0, 4, 4)
        -- love.graphics.draw(images.soldering_stain, 200, 200, 0, 4, 4)

        if developerMode == true then
    
            love.graphics.print(maid64.mouse.getX() ..  "," ..  maid64.mouse.getY(), 1,1)
            -- love.graphics.print("player state: " .. player.player_state, 1,16)
            -- love.graphics.print("x,y state: " .. player.x_target .. "," .. player.y_target, 1,32)
            
            -- love.graphics.print(math.floor(player.x-player.originX) ..  "," .. math.floor(player.y-player.originY), 1,58)
             --can also draw shapes and get mouse position
            -- love.graphics.rectangle("fill", maid64.mouse.getX(),  maid64.mouse.getY(), 1,1)
        end

        if current_mod_complete then
            draw_mod_complete_screen()
        end
        
        
        
        
    end
    
    if pause_game then
        local line_increment = 15
        local line_increment_base = 15
        
        love.graphics.print("Objective:", 1, 1) 
        love.graphics.print("Place glue on the circuit board ", 1, 1 + line_increment) 
        line_increment = line_increment + line_increment_base
        love.graphics.print("Drag and drop the connectors/chip on top of the glue", 1, 1 + line_increment) 
        line_increment = line_increment + line_increment_base
        love.graphics.print("Connect one end of each wire to the a pin on the chip", 1, 1 + line_increment) 
        line_increment = line_increment + line_increment_base
        love.graphics.print("Connect the other end of the wire to a connector", 1, 1 + line_increment) 
        line_increment = line_increment + line_increment_base
        love.graphics.print("Solder the wires to the connectors and chip pins", 1, 1 + line_increment) 
        line_increment = line_increment + line_increment_base
        line_increment = line_increment + line_increment_base
        
        love.graphics.print("Controls:", 1, 1 + line_increment) 
        line_increment = line_increment + line_increment_base
        love.graphics.print("'1' - Drag connectors and chip mode", 1, 1 + line_increment) 
        line_increment = line_increment + line_increment_base
        love.graphics.print("'Mouse 1' - click to drag elements", 1, 1 + line_increment) 
        line_increment = line_increment + line_increment_base
        love.graphics.print("'2' - Glue gun mode", 1, 1 + line_increment) 
        line_increment = line_increment + line_increment_base
        love.graphics.print("'Mouse 1' - To use glue gun", 1, 1 + line_increment) 
        line_increment = line_increment + line_increment_base
        love.graphics.print("'3' - Soldering mode", 1, 1 + line_increment) 
        line_increment = line_increment + line_increment_base
        love.graphics.print("'Mouse 1' - To solder wire", 1, 1 + line_increment) 
        line_increment = line_increment + line_increment_base
        love.graphics.print("'Backspace' - reset current mod scene, if you fucked up :)", 1, 1 + line_increment) 
        line_increment = line_increment + line_increment_base
        love.graphics.print("'M' - Mute/Unmute", 1, 1 + line_increment) 
        line_increment = line_increment + line_increment_base
        love.graphics.print("'T' - Start Tutorial", 1, 1 + line_increment) 
        line_increment = line_increment + line_increment_base
        
    end

    maid64.finish()--finishes the maid64 process
end

function love.resize(w, h)
    -- this is used to resize the screen correctly
    maid64.resize(w, h)
end


function love.keypressed(key)

    if key == "1" then
        current_chipping_state = chipping_states.dragging
        print("changing to dragging state: " .. current_chipping_state)
    end
    
    if key == "3" then
        current_chipping_state = chipping_states.soldering
        print("chaning to solderings state: " .. current_chipping_state)
    end

    if key == "2" then
        current_chipping_state = chipping_states.glueing
        print("changing to gluing state: " .. current_chipping_state)
    end
    if key == '.' then
        print("changing scene")
        if current_scene == scenes.chipping then
            current_scene = scenes.front_desk
        elseif current_scene == scenes.front_desk then
        current_scene = scenes.chipping
        end
    end

    if key == 'left' then
        if current_scene == scenes.tutorial then
            tutorial_step = tutorial_step -1
            if tutorial_step == 0 then
                tutorial_step = 8
            end
        end
    end
    if key == 'right' then
        if current_scene == scenes.tutorial then
                
            
            tutorial_step = tutorial_step + 1
            if tutorial_step > 8 then
                current_scene = scenes.chipping
                tutorial_step = 1
            end
        end
       
    end
    if key == "t" then
        if pause_game then
            current_scene = scenes.tutorial
            pause_game = false
        end
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

    if key == "backspace" then
        reset_console_mod()
    end

    if key == "m" then
        if sfx.music_loop:isPlaying() then
            sfx.music_loop:stop()
        else
            sfx.music_loop:play()
        end
    end

    if key == "space" then
        if current_mod_complete then
            reset_console_mod()
            stats.consoles_modded = stats.consoles_modded + 1
        end
    end
    if key == "-" then
        debug_mode = true
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
    
        if current_scene == scenes.splash then
            current_scene = scenes.tutorial
            tutorial_step = 0
        end
        if current_scene == scenes.tutorial then
            go_to_next_tutorial_step()
            if tutorial_step > 8 then
                current_scene = scenes.chipping
            end
        end
        drag_icon_flag = true
        glue_gun_pressed_flag = true
        soldering_pressed_flag = true

        if current_chipping_state == chipping_states.dragging then
            sfx.blob:play()
        end
        if current_chipping_state == chipping_states.glueing then
            add_glue_stain()
            sfx.glue:play()
        end

        if current_chipping_state == chipping_states.soldering then
            add_soldering_stain()
        end
    end
    if button == 2 then
        if current_scene == scenes.tutorial then
           current_scene = scenes.chipping
        end
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
        drag_icon_flag = false
        glue_gun_pressed_flag = false
        soldering_pressed_flag = false
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
    chip.glued = false
end

function move_chip_on_mouse_click()
    local chip_collsion = collision_check(mouse, chip)
          
            if love.mouse.isDown(1) and chip.glued == false then
                -- check if we can start dragging
                if chip.dragging == false and chip_collsion then
                    chip.dragging = true
                    chip.scaling = 8
                    flag_dragging_chip = chip 
                    -- offsets are used to enture the sprites stay accurate possitioned according to the mouse when its clicked
                    mouse.mouse_x_chip_off_set = mouse_x - chip.x
                    mouse.mouse_y_chip_off_set = mouse_y - chip.y
                end
            else
                -- Stop dragging when mouse released
                chip.dragging = false
                chip.scaling = chip.scaling_baseline
                flag_dragging_chip = nil  -- Reset the flag
                if chip_collsion and chip.glued == true and love.mouse.isDown(1) then
                    print("you cant move it its glued")
                end
            end

            -- move of chip allowed..
            if chip.dragging then
                -- offsets are used to enture the sprites stay accurate possitioned according to the mouse when its clicked
                chip.x = mouse_x - mouse.mouse_x_chip_off_set
                chip.y = mouse_y - mouse.mouse_y_chip_off_set
            end
end

function move_connector_on_mouse_click()
    
    -- LOOP THROUGH CONNECTORS, and allow the user to click and move it
    for key, connector in pairs(connectors_list) do
        -- check if the mouse click a connector, so we can move it
        local connector_collsion = collision_check(mouse, connector)

        if love.mouse.isDown(1) and connector.glued == false then
            -- Only start dragging if nothing else is being dragged
            if connector.dragging == false and connector_collsion and flag_dragging_connector == nil then -- flag_dragging_connector this makes us only able to select one connector at a time
                connector.dragging = true
                connector.scaling = 5 -- scale the size of the connector when clicked
                flag_dragging_connector = connector  -- Mark this one as being dragged, this makes us only able to select one connector at a time
                mouse.mouse_x_chip_off_set = mouse_x - connector.x -- create a offset so we can have the mouse being in the same place as we select the item when moving it
                mouse.mouse_y_chip_off_set = mouse_y - connector.y -- create a offset so we can have the mouse being in the same place as we select the item when moving it
            end
        else
            -- reset settings and scaling
            connector.dragging = false
            connector.scaling = 4
            -- tell the user you cant drag the item
            if connector_collsion and connector.glued == true and love.mouse.isDown(1) then
                print("you cant move it its glued")
            end
        end
        
        if connector.dragging then
            -- change the actual poisiton of the connector
            connector.x = mouse_x - mouse.mouse_x_chip_off_set
            connector.y = mouse_y - mouse.mouse_y_chip_off_set
        end
    end
    -- Reset dragging flag after the loop ends (on mouse release)
    if not love.mouse.isDown(1) then
        flag_dragging_connector = nil
    end
end

function move_wire_start_or_end_point_logic(wire)
    local mouse_wire_collision = collision_check(mouse, wire)

    if love.mouse.isDown(1) then
        if not wire.dragging and mouse_wire_collision and flag_dragging_wire == nil and wire.soldered == false then
            wire.dragging = true
            wire.scaling = 5
            flag_dragging_wire = wire -- This is now specific to the endpoint (start or end)
            mouse.mouse_x_chip_off_set = mouse_x - wire.x
            mouse.mouse_y_chip_off_set = mouse_y - wire.y
        end
    else
        wire.dragging = false
        wire.scaling = 2 -- back to normal
        if wire.soldered then
            print("the wire is soldered you cant move it")
        end
    end

    if wire.dragging then
        wire.x = mouse_x - mouse.mouse_x_chip_off_set
        wire.y = mouse_y - mouse.mouse_y_chip_off_set
    end
end

function move_wire_on_mouse_click()
    for key, wire in pairs(wires_list) do
        -- Important: only one endpoint can react at a time
        if flag_dragging_wire == wire.line_start or flag_dragging_wire == nil then
            move_wire_start_or_end_point_logic(wire.line_start)
        end

        if flag_dragging_wire == wire.line_end or flag_dragging_wire == nil then
            move_wire_start_or_end_point_logic(wire.line_end)
        end
    end

    if not love.mouse.isDown(1) then
        flag_dragging_wire = nil
    end
end

function add_connector(sprite)
    local connectors_length = #connectors_list
    local spacing_x = 25
    local connector = {
        x = 262,
        y = 70,
        scaling = 4,
        width = 4,
        height = 4,
        -- x_placement_span_min = 262,
        -- y_placement_span_min = 3,
        -- y_placement_span_max = 16,
        collision = false,
        dragging = false,
        glued = false,
        sprite = sprite,
        wire_connected = false,
        wire_soldered = false
    }
    if #connectors_list > 0 then
        connector.x = connector.x + (spacing_x * connectors_length)
    end

    table.insert(connectors_list, connector)
end

function reset_connectors()
    connectors_list  = {}

    add_connector(images.connector_yellow_00)
    add_connector(images.connector_yellow_00)
    add_connector(images.connector_yellow_00)
    add_connector(images.connector_grey_00)
    add_connector(images.connector_grey_00)
    add_connector(images.connector_grey_00)
end



function add_wire(color_numb)
    local wires_list_length = #wires_list
    local spacing_x = 25
    local x = 265
    local wire = {
        color_numb = color_numb,
        line_width = 4,
        line_offset = 5, -- this is used to offset the line to make the hit box more accurate
        line_start = {
            x = x,
            y = 115,
            scaling = 2,
            width = 10,
            height = 10,
            collision = false,
            dragging = false,
            placed = false,
            soldered = false,
            connected_pin = false,
            connected_connector = false,
        },
        line_end = {
            x = x,
            y = 250,
            scaling = 2,
            width = 10,
            height = 10,
            collision = false,
            dragging = false,
            placed = false,
            soldered = false,
            connected_pin = false,
            connected_connector = false,
        }
    }

    if wires_list_length> 0 then
        wire.line_start.x = wire.line_start.x + (spacing_x * wires_list_length)
        wire.line_end.x = wire.line_end.x + (spacing_x * wires_list_length)
    end

    table.insert(wires_list, wire)
end

function reset_wires()
    wires_list = {}

    add_wire(1)
    add_wire(2)
    add_wire(3)
    add_wire(4)
    add_wire(5)
    add_wire(6)
    
end

function set_color_with_transparency(color_numb)
    local transparency = 0.7
    if color_numb == 1 then
        love.graphics.setColor(241/255, 36/255, 17/255, transparency) -- red
    end
    if color_numb == 2 then
        love.graphics.setColor(255/255, 38,255, 116/255, transparency) -- pink
    end
    if color_numb == 3 then
        love.graphics.setColor(255/255, 209/255, 0, transparency) -- yellow
    end
    if color_numb == 4 then
        love.graphics.setColor(16/255, 210/255, 17/255, transparency) -- green
    end
    if color_numb == 5 then
        love.graphics.setColor(25/255, 134/255, 242/255, transparency) -- blue
    end
    if color_numb == 6 then
        love.graphics.setColor(195/255, 195/255, 195/255, transparency) -- grey
    end
end

function set_color(color_numb)
    local transparency = 1
    if color_numb == 1 then
        love.graphics.setColor(241/255, 36/255, 17/255, transparency) -- red
    end
    if color_numb == 2 then
        love.graphics.setColor(255/255, 38,255, 116/255, transparency) -- pink
    end
    if color_numb == 3 then
        love.graphics.setColor(255/255, 209/255, 0, transparency) -- yellow
    end
    if color_numb == 4 then
        love.graphics.setColor(16/255, 210/255, 17/255, transparency) -- green
    end
    if color_numb == 5 then
        love.graphics.setColor(25/255, 134/255, 242/255, transparency) -- blue
    end
    if color_numb == 6 then
        love.graphics.setColor(195/255, 195/255, 195/255, transparency) -- grey
    end
end

function reset_color()
    love.graphics.setColor(1,1,1)
end

function add_glue_stain()

    local glue_stain = {
        x = mouse_x, --+ (glue_gun_settings.x_offset * glue_gun_settings.scaling),
        y = mouse_y - 12, -- + (glue_gun_settings.y_offset * glue_gun_settings.scaling)
        scaling = 4,
        width = 4,
        height = 4
    }

    table.insert(glue_gun_locations_list, glue_stain)
end

function add_soldering_stain()

    local soldering_stain = {
        x = mouse_x, --+ (glue_gun_settings.x_offset * glue_gun_settings.scaling),
        y = mouse_y - 12, -- + (glue_gun_settings.y_offset * glue_gun_settings.scaling)
        scaling = 4,
        width = 4,
        height = 4
    }

    table.insert(soldering_locations_list, soldering_stain)
end

function soldering_sfx()
    if love.mouse.isDown(1) then
        sfx.soldering:play()
    else
        if sfx.soldering:isPlaying() then
            sfx.soldering:stop()
        end
    end
end


function add_chip_pins()
    local hitbox_pixels = 6
    local height_base = 6
    local scaling = 1
    -- 1
    local pin = {
        x = 7,
        y = 1,
        x_baseline = 2,
        y_baseline = 1,
        width = hitbox_pixels,
        height = hitbox_pixels,
        scaling = 1,
        wire_connected = false,
        wire_soldered = false
    }
    
    table.insert(chip_pins_list, pin)

    -- 2
    pin = {
        x = 19,
        y = 1,
        x_baseline = 4,
        y_baseline = 1,
        width = hitbox_pixels,
        height = hitbox_pixels,
        scaling = scaling,
        wire_connected = false,
        wire_soldered = false
    }
    
    table.insert(chip_pins_list, pin)

    -- 3
    pin = {
        x = 31,
        y = 1,
        x_baseline = 6,
        y_baseline = 1,
        width = hitbox_pixels,
        height = hitbox_pixels,
        scaling = scaling,
        wire_connected = false,
        wire_soldered = false
    }

    table.insert(chip_pins_list, pin)

    -- 4
    pin = {
        x = 7,
        y = 37,
        x_baseline = 2,
        y_baseline = 7,
        width = hitbox_pixels,
        height = hitbox_pixels,
        scaling = scaling,
        wire_connected = false,
        wire_soldered = false
    }

    table.insert(chip_pins_list, pin)

    -- 5
    pin = {
        x = 19,
        y = 37,
        x_baseline = 2,
        y_baseline = 7,
        width = hitbox_pixels,
        height = hitbox_pixels,
        scaling = scaling,
        wire_connected = false,
        wire_soldered = false
    }

    table.insert(chip_pins_list, pin)

    -- 6
    pin = {
        x = 31,
        y = 37,
        x_baseline = 2,
        y_baseline = 7,
        width = hitbox_pixels,
        height = hitbox_pixels,
        scaling = 1,
        wire_connected = false,
        wire_soldered = false
    }

    table.insert(chip_pins_list, pin)
end

function reset_current_mod_stats()
    current_chip_mod_status = {
        connectors_glued = 0,
        chip_glued = 0,
        wires_attached = 0,
        wires_soldered = 0,
    }
end

-- calculate how long the user is with the current mod
function calculate_progress_of_current_chip_mod()
    
    reset_current_mod_stats()
    if chip.glued then
        current_chip_mod_status.chip_glued = 1
    end
    for key, connector in pairs(connectors_list) do
        if connector.glued then
            current_chip_mod_status.connectors_glued = current_chip_mod_status.connectors_glued  + 1
        end
    end

    for key, wire in pairs(wires_list) do
        if wire.line_start.connected_pin then
            current_chip_mod_status.wires_attached = current_chip_mod_status.wires_attached  + 1
        end

        if wire.line_end.connected_pin then
            current_chip_mod_status.wires_attached = current_chip_mod_status.wires_attached  + 1
        end
        if wire.line_start.connected_connector then
            current_chip_mod_status.wires_attached = current_chip_mod_status.wires_attached  + 1
        end
        if wire.line_end.connected_connector then
            current_chip_mod_status.wires_attached = current_chip_mod_status.wires_attached  + 1
        end

        if wire.line_start.soldered then
            current_chip_mod_status.wires_soldered = current_chip_mod_status.wires_soldered  + 1
        end
        if wire.line_end.soldered then
            current_chip_mod_status.wires_soldered = current_chip_mod_status.wires_soldered  + 1
        end    
    end
    if current_chip_mod_status.wires_soldered  > 12 then
        current_chip_mod_status.wires_soldered = 12
    end

    if current_chip_mod_status.wires_attached  > 12 then
        current_chip_mod_status.wires_attached = 12
    end

end


function draw_mod_complete_screen()
    set_color(1)
    love.graphics.rectangle("fill", settings.sceenWidth/2 - 50, settings.screenHeight/2, 105, 20)
    reset_color()
    love.graphics.print("MOD COMPLETE", settings.sceenWidth/2 - 45, settings.screenHeight/2 + 5)
    set_color(3)
    love.graphics.rectangle("fill", settings.sceenWidth/2 - 155, settings.screenHeight/2 + 25, 305, 20)
    reset_color()
    love.graphics.print("CLICK '''SPACE''' TO MOD NEXT CONSOLE", settings.sceenWidth/2 - 150, settings.screenHeight/2 + 30)
    love.graphics.draw(images.skeleton, settings.sceenWidth/2,settings.screenHeight/2 -20)
end

function check_of_current_mod_is_complete()
    if current_chip_mod_status.connectors_glued == 6 and current_chip_mod_status.chip_glued == 1 and current_chip_mod_status.wires_attached == 12 and current_chip_mod_status.wires_soldered == 12 then
        current_mod_complete = true
    end

    if current_mod_complete and allready_played_gz_music == false then
        sfx.oh_yeah:play()
        allready_played_gz_music = true
    end
end

function reset_console_mod()
    reset_chip()
    reset_connectors()
    reset_wires()
    glue_gun_locations_list = {}
    chip_pins_list = {}
    add_chip_pins()
    reset_current_mod_stats()
    soldering_locations_list = {}
    glue_gun_locations_list = {}
    current_mod_complete = false
    allready_played_gz_music = false
end

function draw_score_and_time()
    set_color(1)
    love.graphics.rectangle("fill", 1,1, 255, 20)
    
    reset_color()
    love.graphics.print("CONSOLES MODDED: " .. stats.consoles_modded .. " Time: " .. string.format("%.2f", stats.time), 1, 5)
end

function draw_stats_of_current_mod()
    if pause_game == false then
        love.graphics.print("Connectors glued: " .. current_chip_mod_status.connectors_glued .. "/" .. 6, settings.sceenWidth-170, 1)
        love.graphics.print("chip glued: " .. current_chip_mod_status.chip_glued .. "/" .. 1, settings.sceenWidth-170, 15)
        love.graphics.print("wires attached: " .. current_chip_mod_status.wires_attached .. "/" .. 12, settings.sceenWidth-170, 30)
        love.graphics.print("wires soldered: " .. current_chip_mod_status.wires_soldered .. "/" .. 12, settings.sceenWidth-170, 45)    
    end
    
end


function go_to_next_tutorial_step()
    if current_scene == scenes.tutorial then
        tutorial_step = tutorial_step + 1
        print("next tutorial step: " .. tutorial_step)
    end
end


