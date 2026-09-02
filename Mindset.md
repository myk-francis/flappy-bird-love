# 🧠 The Game Developer’s Core Mindset: Architectural Engine Thinking

To build any game successfully without getting overwhelmed, you must think like a software architect. The secret to a scalable codebase isn't writing hyper-complex code—it is using a **mental framework** to break a chaotic, moving simulation into predictable, isolated puzzle pieces.

When you sit down to develop your next game (whether it is _Pac-Man_, a platformer, or a top-down RPG), you can apply this exact **4-Step Architectural Engine Thinking** to plan, structure, and build your project from scratch.

---

## 🧭 1. State Thinking: The Macro-Architecture

Before you code a single character moving, map out the **Life Cycle** of your game screens. A game is fundamentally a series of connected rooms. Players need to enter a room, perform actions, and leave.

### The Flappy Bird Approach

We built a **State Machine**. The engine's core loop (`main.lua`) only cares about the _active_ screen (`Menu`, `Countdown`, `Play`, or `GameOver`). It passes hardware events down, but it doesn't know or care how the bird jumps—it just tells the active state to update and draw.

### Applying this to a new game (e.g., Space Invaders)

You can instantly draft your state layout:

- `MenuState`: Displays the title screen and tracks a "Press Enter to Play" input trigger.
- `PlayState`: Spawns the alien ships, tracks player shooting, and handles active physics.
- `VictoryState`: Pauses calculations and rewards the player for clearing a wave.
- `GameOverState`: Freezes the canvas, displays final metrics, and tracks a restart shortcut.

> 💡 **Rule of Thumb:** If the rules of user input or rendering change entirely (e.g., hitting Spacebar starts a match vs. hitting Spacebar makes a character jump), those phases belong in **separate, isolated state files**.

---

## 📦 2. Entity Thinking: Data & Self-Containment

An entity is a single atomic object in your game world. The golden rule of object-oriented game development is **Isolation**. An entity should contain its own math, its own physics variables, and its own drawing layout. It should never reach out and modify other entities directly.

### The Flappy Bird Approach

The `Bird` tracks its own `x`, `y`, `width`, `height`, and `dy` (vertical velocity). It knows how to apply gravity to itself. It doesn't know that pipes exist. Similarly, an individual `Pipe` tracks its own position and scrolls left. It has no clue a bird is flying nearby.

### Applying this to a new game (e.g., Pac-Man)

- **Pac-Man Entity:** Tracks its current grid coordinate, its facing direction, and its current speed. It contains a self-contained `move()` calculation.
- **Ghost Entity:** Tracks its own color, its individual personality AI state (chase, scatter, or fright), and its coordinate metrics.

> 💡 **Rule of Thumb:** Keep entities blind to one another. Give them simple geometric footprints (like rectangles or circles). This allows you to use clean, high-performance algorithms like **AABB (Axis-Aligned Bounding Box)** to check for structural overlaps later without messy dependencies.

---

## 🎛️ 3. Manager Thinking: The Orchestrator

If entities are completely isolated and blind to each other, how do they interact? This is where a **Manager** layer comes in. Managers act like table-top game masters: they look down at the game board, schedule object spawns, perform memory cleanups, and evaluate collisions between pieces.

### The Flappy Bird Approach

We created `pipe_manager.lua`. Individual pipes don't know how many total obstacles exist, and they don't know where the player is. The Manager holds the data array (`self.pipes`), runs a delta-time clock to spawn new ones, loops **backward** to safely delete off-screen assets, and cross-references the bird's coordinates against the pipe coordinates to check for crashes.

### Applying this to a new game (e.g., Space Invaders)

- You wouldn't let individual alien ships check if a laser hit them. You would build an `EnemyFleetManager`.
- The manager tracks a grid array of 50 aliens. It updates their collective horizontal movement, randomly selects an alien to fire a projectile down, and checks if the player's laser entity overlaps any alien bounding box in its collection.

---

## ⏱️ 4. Time Thinking: Frame Rate Independence

The physical universe operates on real time (seconds). Computers operate on frame cycles (ticks). If you couple your game physics directly to the computer's CPU clock speeds, your game will break across different hardware systems.

### The Flappy Bird Approach

Every calculation involving motion used **Delta Time (`dt`)**. Instead of adding a flat pixel integer to position per frame cycle, we multiplied changes by time: `self.y = self.y + self.dy * dt`.

### Applying this to any future game

Never move an object by a fixed pixel integer per frame (e.g., `x = x + 5`). Always define your movement metrics in **pixels-per-second** (e.g., `SPEED = 300`) and multiply that speed value by `dt` inside your update loops. This ensures your game character travels at the exact same physical speed whether the player is running it on an old 30Hz office laptop or a 360Hz high-end gaming monitor.

---

## 🚀 Summary Structural Blueprint for Your Next Game

When you start your next project, follow this step-by-step development checklist based on our verified LÖVE architecture:

1. **Configure the Canvas:** Setup your aspect ratio and window dimensions in your engine's initial configs (`conf.lua`). Turn off texture filtering blurs if you want crisp pixel art.
2. **Build the State Machine:** Setup your skeleton state framework so you can instantly switch between blank text screens (`Menu` ⇄ `Play`).
3. **Code One Entity at a Time:** Create your player object. Give it position, dimensions, velocity trackers, and basic keyboard event listeners. Make sure you can move a placeholder box around a blank screen cleanly.
4. **Build the Spawners/Managers:** Create your obstacle or enemy classes. Setup a manager to generate them dynamically on timers, move them, and run memory-cleanup routines when they leave the screen limits.
5. **Add the Referee Rules:** Use the manager layer to check for box overlaps (collisions), and use a functional callback function to pass scores or triggers back up to the parent game state.
6. **Polish:** Swap out your basic colored placeholder blocks (`love.graphics.rectangle`) with actual sprite textures (`love.graphics.draw`) and add audio playback hooks.
