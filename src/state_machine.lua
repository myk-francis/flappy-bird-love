-- src/state_machine.lua

StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine.new(states)
    local instance = {
        -- A table mapping string names (like "play") to state instances
        states = states or {}, 
        current = nil
    }
    return setmetatable(instance, StateMachine)
end

-- Swap out the old state for a new one
function StateMachine:change(stateName, enterParams)
    if self.current and self.current.exit then
        self.current:exit()
    end
    
    self.current = self.states[stateName]
    
    if self.current and self.current.enter then
        self.current:enter(enterParams)
    end
end

-- Forward engine loops to the active state
function StateMachine:update(dt)
    if self.current and self.current.update then
        self.current:update(dt)
    end
end

function StateMachine:draw()
    if self.current and self.current.draw then
        self.current:draw()
    end
end

return StateMachine
