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
        width = 34,          -- Approximated bounding box width
        height = 24,         -- Approximated bounding box height
        dy = 0               -- Velocity along the Y-axis (delta-y)
    }
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
    love.graphics.setColor(1, 0.9, 0) -- Yellow color
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1)    -- Always reset color back to white
end

return Bird
