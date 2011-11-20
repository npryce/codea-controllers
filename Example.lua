-- Moving a sprite with a VirtualStick

function setup()
    pos = vec2(WIDTH/2, HEIGHT/2)
    steer = vec2(0,0)
    speed = 400 -- pixels per second
        
    controller = VirtualStick {
        moved = function(v) steer = v end,
        released = function(v) steer = vec2(0,0) end
    }
    
    controller:activate()
end

function draw()
    background(131, 228, 73, 255)
    
    pos = pos + steer*speed*DeltaTime
    
    sprite("Planet Cute:Character Boy", pos.x, pos.y)
    controller:draw()
end
