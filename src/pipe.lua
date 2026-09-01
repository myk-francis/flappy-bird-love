-- src/pipe.lua

local Pipe = {}
Pipe.__index = Pipe

-- Class Constants
local SCROLL_SPEED = 120    -- Speed at which pipes scroll left (pixels per second)
local PIPE_WIDTH = 60       -- Horizontal thickness of our pipes

function Pipe.new(x, gapY, gapHeight)
    local instance = {
        x = x,
        gapY = gapY,             -- The center or top Y coordinate of our safe gap
        gapHeight = gapHeight,   -- How tall the opening is (e.g., 100 pixels)
        width = PIPE_WIDTH,
        toBeRemoved = false      -- Flag to clean up memory when it goes off-screen
    }
    return setmetatable(instance, Pipe)
end

function Pipe:update(dt)
    -- Move the pipe steadily to the left
    self.x = self.x - SCROLL_SPEED * dt
    
    -- If the pipe completely leaves the left edge of our 400px wide screen
    if self.x + self.width < 0 then
        self.toBeRemoved = true
    end
end

function Pipe:draw()
    -- Temporarily render green rectangles until we add graphics sprites later
    love.graphics.setColor(0.2, 0.7, 0.2) -- Green color
    
    -- 1. Render Top Pipe (From Y = 0 down to the top of the gap)
    love.graphics.rectangle("fill", self.x, 0, self.width, self.gapY)
    
    -- 2. Render Bottom Pipe (From bottom of the gap down to the bottom of the window)
    local bottomPipeY = self.gapY + self.gapHeight
    local bottomPipeHeight = 600 - bottomPipeY
    love.graphics.rectangle("fill", self.x, bottomPipeY, self.width, bottomPipeHeight)
    
    love.graphics.setColor(1, 1, 1) -- Reset renderer color
end

-- A helper function we will use later to check if the bird overlaps this pipe pair
function Pipe:collides(bird)
    -- Check collision with Top Pipe
    if bird.x < self.x + self.width and bird.x + bird.width > self.x then
        if bird.y < self.gapY or bird.y + bird.height > self.gapY + self.gapHeight then
            return true
        end
    end
    return false
end

return Pipe
