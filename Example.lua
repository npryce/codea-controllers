
function setup()
    local pos = vec2(WIDTH/2, HEIGHT/2)
    local steer = vec2(0,0)
    local speed = 400 -- pixels per second
        
    local controller = VirtualStick {
        moved = function(v) steer = v end,
        released = function(v) steer = vec2(0,0) end
    }
    
    controller:activate()
            
    function draw()
        background(131, 228, 73, 255)
        pos = pos + steer*speed*DeltaTime
        sprite("Planet Cute:Character Boy", pos.x, pos.y)
        controller:draw()
    end
end
