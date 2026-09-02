-- src/bird.lua

local Bird = {}
Bird.__index = Bird

-- Class Constants (Tweak these to change the "feel" of your jump!)
local GRAVITY = 900          -- Downward acceleration rate
local JUMP_IMPULSE = -280    -- Velocity applied upward when flapping

function Bird.new(x, y)
    local instance = {
        x = x,
        y = y,
        -- 1. Load the image asset directly into the instance
        texture = gTextures["bird"],
        -- width = 34,          -- Approximated bounding box width
        -- height = 24,         -- Approximated bounding box height
        dy = 0               -- Velocity along the Y-axis (delta-y)
    }

     -- 2. Dynamically grab the width and height directly from the image file dimensions
    instance.width = instance.texture:getWidth()
    instance.height = instance.texture:getHeight()
    return setmetatable(instance, Bird)
end

-- Force the velocity upward
function Bird:flap()
    self.dy = JUMP_IMPULSE
end

function Bird:update(dt)
    -- 1. Apply gravity to vertical velocity
    self.dy = self.dy + GRAVITY * dt
    
    -- 2. Move bird position by current velocity
    self.y = self.y + self.dy * dt
    
    -- 3. Soft floor boundary (prevent falling forever off-screen)
    if self.y > 600 - self.height then
        self.y = 600 - self.height
        self.dy = 0
    end
    
    -- 4. Ceiling boundary (optional, stops bird from flying into orbit)
    if self.y < 0 then
        self.y = 0
        self.dy = 0
    end
end

function Bird:draw()
    -- Temporarily render a simple yellow rectangle until we use actual textures later
    -- love.graphics.setColor(1, 0.9, 0) -- Yellow color
    -- love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    -- love.graphics.setColor(1, 1, 1)    -- Always reset color back to white

    -- Parameters: texture, x, y, rotation (0), scaleX (1), scaleY (1)
    love.graphics.draw(self.texture, self.x, self.y)
end

return Bird
