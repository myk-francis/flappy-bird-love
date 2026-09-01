-- main.lua

-- 1. Import dependencies
local StateMachine = require("src/state_machine")
local MenuState = require("src/states/menu_state")
local CountdownState = require("src/states/countdown_state")
local PlayState = require("src/states/play_state")
local GameOverState = require("src/states/game_over_state")

function love.load()
    -- Render pixel shapes crisply without anti-aliasing blur
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- Seed the random number generator so gaps aren't identical every execution
    love.math.setRandomSeed(os.time())

    -- 2. Define our custom keyboard lookup table
    love.keyboard.keysPressed = {}

    -- 3. Initialize State Machine with real state instances
    gStateMachine = StateMachine.new({
        ["menu"] = MenuState.new(),
        ["countdown"] = CountdownState.new(),
        ["play"] = PlayState.new(),
        ["gameover"] = GameOverState.new()
    })
    
    -- Start the application on the Menu Screen
    gStateMachine:change("menu")
end

-- 4. Global Input Listeners
function love.keypressed(key)
    -- Record that this key was tapped down during this specific frame
    love.keyboard.keysPressed[key] = true

    -- Global hotkey: Emergency close game by holding Left Shift + Escape
    if key == "escape" and love.keyboard.isDown("lshift") then
        love.event.quit()
    end
end

-- Custom helper method injected directly into LÖVE's keyboard library namespace
function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key] or false
end

function love.update(dt)
    -- Tick frame calculations down into whatever state is currently active
    gStateMachine:update(dt)
    
    -- CRITICAL: Clear the input table at the absolute end of the frame cycle 
    -- so keys don't register as "pressed" repeatedly on subsequent frames.
    love.keyboard.keysPressed = {}
end

function love.draw()
    -- Render whatever visual instructions the current active state defines
    gStateMachine:draw()
end
