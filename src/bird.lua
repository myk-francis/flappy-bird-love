-- src/bird.lua

local Bird = {}
Bird.__index = Bird

-- Class Constants (Tweak these to change the "feel" of your jump!)
local GRAVITY = 900          -- Downward acceleration rate
local JUMP_IMPULSE = -280    -- Velocity applied upward when flapping
local ANIMATION_SPEED = 0.15 -- Swap frames every 0.15 seconds

function Bird.new(x, y)
    local instance = {
        x = x,
        y = y,
        dy = 0,               -- Velocity along the Y-axis (delta-y)
        
        -- Dimensions (Match your asset size dynamically)
        width = gTextures["bird_up"]:getWidth(),
        height = gTextures["bird_up"]:getHeight(),

        -- Animation states
        frames = {
            gTextures["bird_up"],
            gTextures["bird_down"]
        },
        currentFrame = 1,
        animationTimer = 0
    }
    
    return setmetatable(instance, Bird)
end

-- Force the velocity upward and instantly snap wings down
function Bird:flap()
    self.dy = JUMP_IMPULSE
    self.currentFrame = 2    -- Snap to wing down position when flapping
    self.animationTimer = 0  -- Reset timer so the flap frames stay visible for a moment
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

    -- 5. Advance flying animation sequence over time
    self.animationTimer = self.animationTimer + dt
    if self.animationTimer >= ANIMATION_SPEED then
        self.animationTimer = 0
        -- Alternate between frame 1 and frame 2
        self.currentFrame = self.currentFrame == 1 and 2 or 1
    end
end

function Bird:draw()
    -- Render the active wing sprite frame from our table
    local activeSprite = self.frames[self.currentFrame]
    
    -- Parameters: texture, x, y, rotation (0), scaleX (1), scaleY (1)
    love.graphics.draw(activeSprite, self.x, self.y)
end

return Bird
