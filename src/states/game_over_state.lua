-- src/states/game_over_state.lua

local GameOverState = {}
GameOverState.__index = GameOverState

function GameOverState.new()
    local instance = {
        finalScore = 0
    }
    return setmetatable(instance, GameOverState)
end

function GameOverState:enter(params)
    -- Grab the scores package passed over through the state transition
    self.finalScore = params and params.score or 0
end

function GameOverState:update(dt)
    -- If they press enter or space, route them right back to the countdown loop
    if love.keyboard.wasPressed("return") or love.keyboard.wasPressed("space") then
        gStateMachine:change("countdown")
    end
end

function GameOverState:draw()
    -- Clear background sky
    love.graphics.clear(0.39, 0.58, 0.93)

    -- Render Game Over text blocks
    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.printf("GAME OVER", 0, 180, 400, "center")

    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.printf("Final Score: " .. tostring(self.finalScore), 0, 260, 400, "center")

    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.printf("Press ENTER to Try Again", 0, 340, 400, "center")
end

function GameOverState:exit()
end

return GameOverState
