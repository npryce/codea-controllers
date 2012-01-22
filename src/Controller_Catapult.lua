-- A "catapult" style launcher. Drag on the screen to input the
-- direction and force of a launched projectile.
--
-- Callback: 
--     launcher(pos, vel)
--     pos : vec2  - the location where the user started dragging
--     drag : vec2 - the vector dragged, relative to pos

Catapult = class(Controller)

function Catapult:init(launcher)
    self.launcher = launcher
    self.touchEnds = {}
    self.touchStarts = {}
end

function Catapult:activate()
    touched = function(t)
        self:touched(t)
    end
end

function Catapult:touched(t)
    local pos = touchPos(t)
    
    if t.state == BEGAN then
        self.touchStarts[t.id] = pos
        self.touchEnds[t.id] = pos
    elseif t.state == MOVING then
        self.touchEnds[t.id] = pos
    elseif t.state == ENDED then
        local start = self.touchStarts[t.id]
        
        self.launcher(start, pos - start)
        
        self.touchStarts[t.id] = nil
        self.touchEnds[t.id] = nil
        
    elseif t.state == CANCELLED then
        self.touchStarts[t.id] = nil
        self.touchEnds[t.id] = nil
    end
end

function Catapult:draw()
    pushStyle()
    
    noFill()
    stroke(255, 255, 255, 255)
    ellipseMode(CENTER)
    lineCapMode(ROUND)
    
    for id, startPos in pairs(self.touchStarts) do
        local endPos = self.touchEnds[id]
        
        strokeWidth(1)
        ellipse(startPos.x, startPos.y, 48, 48)
        strokeWidth(4)
        line(startPos.x, startPos.y, endPos.x, endPos.y)
    end
    
    popStyle()
end
