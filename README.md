## Flappy Bird Game with Love2D

Back to the basics of programming learning to build games using Lua and Love2D.

## Root Files

main.lua: The core entry point for LÖVE. It initializes the game, handles global inputs, and updates or draws your active state (menu, playing, game over).

conf.lua : The configuration file. Use this to set your window dimensions (e.g., a vertical retro layout like 400x600), window title, and vsync preferences.

## Source Files (src/)

bird.lua: A Lua class or table handling the bird’s physics. It manages gravity, velocity, jump impulses, animations, and collision bounding boxes.

pipe.lua: Represents an individual pipe pair (top and bottom). Tracks its horizontal position, movement speed, and exact gap position.

pipe_manager.lua: Handles spawning new pipes at timed intervals, moving them left across the screen, deleting them when they leave the screen, and managing collision checks against the bird.

## State Machine (src/states/)

menu_state.lua: Displays the title screen and waits for the player to press "Space" or click to start.

play_state.lua: Runs the actual game loop (spawning pipes, applying gravity, tracking score, and handling active collisions).

game_over_state.lua: Freezes the action, displays the final score/high score, and prompts the user to restart.
