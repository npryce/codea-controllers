-- Space Invaders style movement with a single VirtualSlider

function setup()
    pos = vec2(WIDTH/2, 100)
    maxVel = vec2(400,0)
    steer = 0
    
    controller = VirtualSlider {
        moved = function(n) steer = n end,
        released = function(n) steer = 0 end
    }
    
    controller:activate()
end



function draw()
    background(31, 33, 86, 255)
    
    pos = pos + steer*maxVel*DeltaTime
    
    rectMode(CORNERS)
    fill(255, 255, 255, 255)
    noStroke()
    
    pushMatrix()
    translate(pos.x, pos.y)
    rect(-20, 0, 20, 31)
    rect(-5, 29, 5, 40)
    popMatrix()
    
    controller:draw()
end
