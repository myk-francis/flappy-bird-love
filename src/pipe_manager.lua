-- src/pipe_manager.lua

local Pipe = require("src/pipe")
local PipeManager = {}
PipeManager.__index = PipeManager

-- Class Constants
local SPAWN_INTERVAL = 3.0    -- Spawn a new pipe every 2 seconds
local GAP_HEIGHT = 120        -- Size of the opening the bird flies through

function PipeManager.new()
    local instance = {
        pipes = {},           -- Array list tracking all active pipe objects
        timer = 0             -- Accumulates delta time
    }
    return setmetatable(instance, PipeManager)
end

function PipeManager:update(dt, onScoreUp)
    -- 1. Progress spawning timer
    self.timer = self.timer + dt
    if self.timer >= SPAWN_INTERVAL then
        self.timer = 0
        
        -- Randomize the vertical position of the gap (between Y=50 and Y=430)
        local randomGapY = love.math.random(50, 430 - GAP_HEIGHT)
        
        -- Spawn a new pipe just past the right edge of our 400px window
        table.insert(self.pipes, Pipe.new(450, randomGapY, GAP_HEIGHT))
    end

    -- 2. Update all active pipes and filter out dead ones
    for i = #self.pipes, 1, -1 do
        local pipe = self.pipes[i]
        
        -- Check if bird passed the pipe for score tracking
        -- (If pipe doesn't have a 'scored' flag yet and bird passes its right edge)
        if not pipe.scored and gBird and gBird.x > pipe.x + pipe.width then
            pipe.scored = true
            if onScoreUp then onScoreUp() end -- Trigger score callback
        end

        pipe:update(dt)

        -- Memory Cleanup: Remove pipes flagged for deletion
        if pipe.toBeRemoved then
            table.remove(self.pipes, i)
        end
    end
end

function PipeManager:draw()
    -- Render every pipe currently tracked in the table
    for _, pipe in ipairs(self.pipes) do
        pipe:draw()
    end
end

-- Check if any existing pipe touches the bird
function PipeManager:checkCollisions(bird)
    for _, pipe in ipairs(self.pipes) do
        if pipe:collides(bird) then
            return true
        end
    end
    return false
end

-- Clear out all obstacles when restarting the game
function PipeManager:clear()
    self.pipes = {}
    self.timer = 0
end

return PipeManager
