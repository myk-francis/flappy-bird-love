-- src/states/play_state.lua

local Bird = require("src/bird")
local PipeManager = require("src/pipe_manager")

local PlayState = {}
PlayState.__index = PlayState

function PlayState.new()
    local instance = {
        bird = nil,
        pipeManager = nil,
        score = 0
    }
    return setmetatable(instance, PlayState)
end

function PlayState:enter(params)
    -- Initialize or reset game entities whenever entering the active play session
    self.bird = Bird.new(60, 250)
    self.pipeManager = PipeManager.new()
    self.score = 0
    
    -- Expose the active bird globally so the PipeManager can calculate score positions
    gBird = self.bird
end

function PlayState:update(dt)
    -- 1. Make the bird flap when Space is pressed
    if love.keyboard.wasPressed("space") then
        self.bird:flap()
    end

    -- 2. Update entities
    self.bird:update(dt)
    
    -- We pass an inline function callback to increment our score when a pipe is cleared
    self.pipeManager:update(dt, function()
        self.score = self.score + 1
    end)

    -- 3. Check for Game Over conditions (Hitting a pipe or smashing into the ground)
    local hitFloor = self.bird.y >= (600 - self.bird.height)
    if self.pipeManager:checkCollisions(self.bird) or hitFloor then
        -- Transition to Game Over state and pass our final score along as a parameter!
        gStateMachine:change("gameover", { score = self.score })
    end
end

function PlayState:draw()
    -- Clear background sky
    -- love.graphics.clear(0.39, 0.58, 0.93)

    -- Render the active obstacles and player character
    self.pipeManager:draw()
    self.bird:draw()

    -- Render HUD Score UI overlay
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.print("Score: " .. tostring(self.score), 15, 15)
end

function PlayState:exit()
    -- Clean up our global handle when leaving the active play state
    gBird = nil
end

return PlayState
