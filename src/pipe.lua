-- src/pipe.lua

local Pipe = {}
Pipe.__index = Pipe

-- Class Constants
local SCROLL_SPEED = 120    -- Speed at which pipes scroll left (pixels per second)
local PIPE_WIDTH = 100      -- Horizontal thickness of our pipes

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
    -- Get base image dimensions from the global asset table
    local pipeImage = gTextures["pipe"]
    local imgWidth = pipeImage:getWidth()
    local imgHeight = pipeImage:getHeight()

    -- Calculate horizontal scale (Fixed to keep it 60px wide)
    local scaleX = gPipeScaleX

    -- 1. Render Top Pipe (Flipped upside down)
    local topPipeHeight = self.gapY
    local topScaleY = topPipeHeight / imgHeight
    
    love.graphics.draw(
        pipeImage, 
        self.x, 
        topPipeHeight, -- Position at the bottom of the top pipe section because it flips downward
        0, 
        scaleX, 
        -topScaleY     -- Negative Y scale flips the texture upside down
    )
    
    -- 2. Render Bottom Pipe (Right side up)
    local bottomPipeY = self.gapY + self.gapHeight
    local bottomPipeHeight = 600 - bottomPipeY
    local bottomScaleY = bottomPipeHeight / imgHeight
    
    love.graphics.draw(
        pipeImage, 
        self.x, 
        bottomPipeY, 
        0, 
        scaleX, 
        bottomScaleY   -- Standard scale stretches it straight down
    )
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
