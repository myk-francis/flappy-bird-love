-- conf.lua

function love.conf(t)
    t.window.title = "Flappy Bird - LÖVE" -- The title of your window
    t.window.width = 400                    -- Ideal mobile-like retro width
    t.window.height = 600                   -- Ideal mobile-like retro height
    t.window.vsync = 1                      -- Enables VSync to cap frame rate smoothly
    t.window.resizable = false              -- Keeps aspect ratio locked for easy coordinate calculations
    
    -- Optimize console logs for debugging (Optional)
    t.console = true                        -- Opens a separate terminal window alongside the game for print logs (Windows only)
end
