-- src/states/menu_state.lua

local MenuState = {}
MenuState.__index = MenuState

function MenuState.new()
    return setmetatable({}, MenuState)
end

function MenuState:enter(params)
    -- This runs once right when the game transitions into the menu screen
    print("Welcome to the Menu Screen")
end

function MenuState:update(dt)
    -- Look for inputs to transition out of the menu
    if love.keyboard.wasPressed("space") or love.keyboard.wasPressed("return") then
        -- Transition to the countdown screen before jumping straight into gameplay
        gStateMachine:change("countdown")
    end
end

function MenuState:draw()
    -- 1. Draw a simple background color block
    love.graphics.clear(0.39, 0.58, 0.93) -- Sky blue color

    -- 2. Render Title Text
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf("FLAPPY BIRD", 0, 180, 400, "center")

    -- 3. Render Subtitle Flashing Prompt
    love.graphics.setFont(love.graphics.newFont(14))
    -- Use os.time or love.timer to make it blink subtly
    if math.floor(love.timer.getTime() * 2) % 2 == 0 then
        love.graphics.printf("Press SPACE to Start", 0, 320, 400, "center")
    end
end

function MenuState:exit()
    -- Clean up anything tracking specific to the menu if needed
end

return MenuState
