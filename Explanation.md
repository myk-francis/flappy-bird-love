# The Complete Object-Oriented Game Architecture Guide: LÖVE & Lua

This reference document breaks down the Object-Oriented Programming (OOP) concepts, structural math, and system loops used to build our Flappy Bird game architecture in LÖVE (Love2D).

---

## 🛠️ Section 1: Object-Oriented Programming & Metatables (`src/state_machine.lua`)

Because Lua lacks built-in keywords like `class`, `public`, or `new` found in traditional OOP languages, it utilizes a powerful system called **Metatables** to handle structural blueprints and class generation.

### The Class Definition Blueprint

```lua
StateMachine = {}
StateMachine.__index = StateMachine
```

- **`StateMachine = {}`**: This initializes a standard, empty table. In Lua, this table serves as our **Class definition** (the master blueprint). This specific table acts as the container holding all the methods that individual state machines will share (e.g., `change`, `update`, `draw`).
- **`StateMachine.__index = StateMachine`**: This is the core mechanism of Lua OOP. `__index` acts as a lookup fallback tool. It tells Lua: _"If an individual copy (an instance) of this class tries to call a method it doesn't explicitly contain on its own table, look inside the parent `StateMachine` blueprint to find and execute it."_ Without this declaration, instances cannot share methods from the blueprint.

### The Constructor Mechanism

```lua
function StateMachine.new(states)
    local instance = {
        states = states or {},
        current = nil
    }
    return setmetatable(instance, StateMachine)
end
```

- **`local instance = { ... }`**: This represents the instantiation phase where an individual **Object (Instance)** table is born. Every individual instance contains its own unique internal dataset:
  - **`states`**: A key-value lookup table map storing the individual screen profiles we provide.
  - **`current`**: Starts as `nil` because no state screen is active during initialization.
- **`return setmetatable(instance, StateMachine)`**: This operation binds the unique `instance` table to the parent `StateMachine` blueprint ruleset. The instance maintains its own localized, custom variables while dynamically inheriting execution behaviors directly from the parent class.

### The State Transition Traffic Controller

```lua
function StateMachine:change(stateName, enterParams)
    if self.current and self.current.exit then
        self.current:exit()
    end

    self.current = self.states[stateName]

    if self.current and self.current.enter then
        self.current:enter(enterParams)
    end
end
```

- **The Colon Syntax (`:`)**: Declaring methods with a colon automatically passes a hidden contextual reference argument variable named **`self`** straight into the scope execution block. `self` refers directly to whichever specific instance object is running the method right now.
- **The Exit Clean up**: Before swapping to a new layout, the manager checks `if self.current and self.current.exit then`. If an active screen is running, it fires its localized `exit()` routine. This gives the dying phase a chance to perform garbage collection, stop ambient audio, or save persistent records.
- **The Target Pointer Swap**: `self.current = self.states[stateName]` explicitly replaces the active screen handle pointer with the new targeted state lookup value passed down via the `stateName` parameter string.
- **The Setup Phase (`enterParams`)**: Once the new state mounts, it invokes `enter(enterParams)`. This allows you to pass custom payload dictionaries between completely separate states (e.g., passing the numerical game score from the running `PlayState` straight into the `GameOverState`).

---

## 📄 Section 2: The Core Framework Hub (`main.lua`)

`main.lua` serves as the initial landing runway for LÖVE. It intercepts low-level operating system events, addresses hardware scaling metrics, and forwards lifecycle ticks straight into the state manager.

### Crisp Pixel Art Scaling Filter

```lua
love.graphics.setDefaultFilter("nearest", "nearest")
```

- **Why we use it**: By default, graphics cards process scaled geometric elements or image files using linear blending to smoothly interpolate resolutions. This introduces visual blur into low-resolution assets. Setting this to `"nearest"` invokes **Nearest-Neighbor pixel mapping**, which forces textures to scale up into sharp, hard-edged retro shapes.

### The Pseudo-Random Number Seeding

```lua
love.math.setRandomSeed(os.time())
```

- **Why we use it**: Digital computers execute deterministic pseudo-random mathematical equations derived from an initial value called a seed. Providing the exact same seed generates identical patterns every run. Passing `os.time()` updates the calculation seed using the current Unix Epoch clock timestamp in seconds, ensuring dynamic obstacle variance on every individual application launch.

### Frame-Buffered Discrete Keyboard Engine

```lua
love.keyboard.keysPressed = {}

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key] or false
end
```

- **The Problem**: Framework systems check inputs continuously via boolean query loops. If you check for inputs within an active frame rate, holding down a key down for a fraction of a second registers across multiple game update frames.
- **The Solution**: We create an empty table buffer tracking `love.keyboard.keysPressed`. When the computer hardware detects a key strike event down, `love.keypressed(key)` logs that explicit string name as a index key matching a value of `true`.
- The state scripts use `love.keyboard.wasPressed(key)` to query the buffered input dictionary table directly.

```lua
function love.update(dt)
    gStateMachine:update(dt)
    love.keyboard.keysPressed = {}
end
```

- **The Clean up**: At the absolute conclusion of the frame update cycle, `love.keyboard.keysPressed` is wiped clear back to `{}`. This establishes a clean slate for the following frame, meaning a key down notification is only valid for the exact structural frame slice it occurred on.

### Understanding Framerate Independence via Delta Time (`dt`)

```lua
function love.update(dt)
    gStateMachine:update(dt)
end
```

- **What is `dt`?**: Delta Time represents the fractional duration (measured in seconds) that elapsed between the start of the previous update frame and the current execution frame (e.g., approximately `0.016` seconds for a steady 60 frames per second loop refresh rate).
- **Why we use it**: If you add speed values straight to an entity's positional coordinates every single frame, a high-end computer running at 240 FPS will update the value four times faster than an office machine running at 60 FPS. By passing down `dt` and multiplying speed values by it, your physics formulas translate from _"pixels per frame"_ into _"pixels per second"_, ensuring identical object trajectory behavior regardless of engine framerate performance.

---

## 🐦 Section 3: Kinetic Motion & Physics Equations (`src/bird.lua`)

This file is explicitly dedicated to structural vectors, downward environmental acceleration calculation, and rigid space boundary clamping.

### Spatial Trajectory Vector Calculus

```lua
local GRAVITY = 900
local JUMP_IMPULSE = -280
```

- **Coordinate Mapping**: In LÖVE's drawing viewport coordinate plane, **Y = 0 represents the ceiling boundary**, and value sums increase positively as you step lower toward the floor vector.
- **Constants Setup**: `GRAVITY = 900` accelerates components downward over time. To push the entity upward against this force, we assign a negative index vector value to `JUMP_IMPULSE`.

### Vertical Velocity Calculations

```lua
function Bird:update(dt)
    self.dy = self.dy + GRAVITY * dt
    self.y = self.y + self.dy * dt
```

- **Velocity Tracking**: `self.dy` measures vertical linear momentum velocity along the Y-axis.
- **Line 1 (Acceleration)**: We calculate the current frame's gravity influence by scaling our constant value (`GRAVITY * dt`) and adding it onto the bird's vertical velocity (`self.dy`). This generates acceleration, meaning the bird drops faster the longer it stays airborne without jumping.
- **Line 2 (Translation)**: We take the final target velocity speed calculation, scale it down cleanly via time scale (`self.dy * dt`), and apply that change directly to the entity's positional coordinate point variable (`self.y`).

### Rigid Collision Bound Clamping

```lua
if self.y > 600 - self.height then
    self.y = 600 - self.height
    self.dy = 0
end
```

- **The logic**: To prevent the box character from passing beyond our configured resolution height bound of `600`, we calculate its baseline edge boundary limits. If the coordinate slips too low, we forcefully clamp its positional coordinate directly to the baseline threshold (`600 - self.height`) and immediately halt momentum vectors by resetting velocity `self.dy` back to zero.

### Drawing Context Painting Cleanup

```lua
function Bird:draw()
    love.graphics.setColor(1, 0.9, 0)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1)
end
```

State Machine Drawing Canvas: LÖVE executes drawing instructions sequentially using a centralized global context state machine. Changing the fill palette color to yellow via love.graphics.setColor(1, 0.9, 0) alters the system's brush tool color. You must call love.graphics.setColor(1, 1, 1) to reset the context back to neutral white, or all subsequent rendering calls for other elements will remain tinted yellow.🪵

Section 4: Inverse Box Coordinate Rendering (src/pipe.lua)Instead of maintaining separate logic profiles for upper and lower pillars, this class measures a single horizontal position and tracks structural metrics around a safe opening.

Mathematical Spatial Setuplua function Pipe.new(x, gapY, gapHeight) local instance = { x = x, gapY = gapY, gapHeight = gapHeight, width = PIPE_WIDTH, toBeRemoved = false } return setmetatable(instance, Pipe) end gapY: Stores the absolute vertical coordinate value where the top of the safe open window gap resides.gapHeight: Measures the total vertical thickness clearance height of the safe zone opening window.

Geometric Structural Drawinglua -- Top Pipe Draw love.graphics.rectangle("fill", self.x, 0, self.width, self.gapY) The math: The top pipe starts drawing from the ceiling of the application window (Y = 0) and extends down exactly until its height equals the top boundary edge of our gap coordinate (self.gapY).lua -- Bottom Pipe Draw local bottomPipeY = self.gapY + self.gapHeight local bottomPipeHeight = 600 - bottomPipeY love.graphics.rectangle("fill", self.x, bottomPipeY, self.width, bottomPipeHeight) The math: The lower pipe starts drawing right where the gap space ends. Its initial layout position bottomPipeY equals self.gapY + self.gapHeight. To ensure the shape base extends completely to the floor of our 600px canvas window, we subtract the starting coordinate value from our total space height value to find the remaining height (600 - bottomPipeY).

AABB (Axis-Aligned Bounding Box) Overlap Checklua function Pipe:collides(bird) if bird.x < self.x + self.width and bird.x + bird.width > self.x then if bird.y < self.gapY or bird.y + bird.height > self.gapY + self.gapHeight then return true end end return false end This function utilizes the two-dimensional AABB algorithm to scan for intersecting box bounds:Horizontal Filtering Step: It evaluates if any part of the bird's horizontal body lines up within the pipe column's footprint. If the bird hasn't reached the obstacle column or has cleared it entirely, this checks out as false and exits immediately.Vertical Boundary Overlap Check: If the bird is inside the column's horizontal range, it checks if its top edge is higher than the safe gap (bird.y < self.gapY) or if its bottom edge is lower than the safe floor (bird.y + bird.height > self.gapY + self.gapHeight). If either condition is met, a collision has occurred, returning a value of true.🎛️ Section 5: Array Collections Management & Memory Optimization (src/pipe_manager.lua)The Pipe Manager is an organizational collection layer responsible for handling multiple obstacle pairs, scheduling spawning triggers, and managing clean up.

The Reverse Deletion Array Loop Method

`luafor i = #self.pipes, 1, -1 dolocal pipe = self.pipes[i]pipe:update(dt)if pipe.toBeRemoved thentable.remove(self.pipes, i)endend`

The Shift Bug: When executing a standard incremental array loop (1 to #table), calling Lua's internal table.remove() utility shifts all subsequent items down by one index position to fill the empty slot. If you delete index 3 on loop cycle 3, index 4 instantly becomes index 3. On the very next tick, the loop pointer increments to index 4—completely skipping the item that just shifted down!The Solution: Looping backward (#self.pipes down to 1 with an increment step of -1) ensures that deletions only cause items that have already been processed by the loop to shift position. This prevents the deletion process from breaking index positions or skipping elements.

The Decoupled Score Event Callbacklua if not pipe.scored and gBird and gBird.x > pipe.x + pipe.width then pipe.scored = true if onScoreUp then onScoreUp() end end Design Pattern Principle: To prevent the low-level pipe_manager.lua file from tightly binding into scoring mechanics, high scores, or display configurations, it uses a functional programming style Callback.The manager's only job is to detect the physical crossing event. Once verified, it executes an anonymous, abstract callback function pointer passed down to it from the state layer (onScoreUp()). This allows the parent state to handle scoring metrics, sound effects, or visual updates independently of the underlying physics module.
