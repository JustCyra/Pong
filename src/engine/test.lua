Engine = require "src.engine.main"

local last_time = os.time()
local loops = 0

Engine.load()
while true do
    Engine.update(0)
    Engine.draw()

    loops = loops + 1
    if last_time ~= os.time() then
        last_time = os.time()
        print('FPS: ' .. loops)
        loops = 0
    end
end