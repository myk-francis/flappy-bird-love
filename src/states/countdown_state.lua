-- src/states/countdown_state.lua

local CountdownState = {}
CountdownState.__index = CountdownState

function CountdownState.new()
    local instance = {
        timer = 0,
        counter = 3 -- Start counting down from 3
    }
    return setmetatable(instance, CountdownState)
end

function CountdownState:enter(params)
    self.timer = 0
    self.counter = 3
end

function CountdownState:update(dt)
    -- Increment timer by delta time
    self.timer = self.timer + dt

    -- Every 0.75 seconds, drop the counter down by 1
    if self.timer >= 0.75 then
        self.timer = 0
        self.counter = self.counter - 1

        -- Once we fall past 1, swap state directly to active play!
        if self.counter < 1 then
            gStateMachine:change("play")
        end
    end
end

function CountdownState:draw()
    -- Clear background so it matches our sky look
    love.graphics.clear(0.39, 0.58, 0.93)

    -- Display giant countdown numbers in the dead center
    love.graphics.setFont(love.graphics.newFont(48))
    love.graphics.printf(tostring(self.counter), 0, 240, 400, "center")
end

function CountdownState:exit()
    -- Reset state parameters cleanly for the next lifecycle call
end

return CountdownState
