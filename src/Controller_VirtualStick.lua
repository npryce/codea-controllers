-- A virtual analogue joystick with a dead-zone at the center,
-- which activates wherever the user touches their finger
--
-- Arguments:
--     radius - radius of the stick (default = 100)
--     deadZoneRadius - radius of the stick's dead zone (default = 25)
--     moved(v) - Called when the stick is moved
--         v : vec2 - in the range vec2(-1,-1) and vec2(1,1)
--     pressed() - Called when the user starts using the stick (optional)
--     released() - Called when the user releases the stick (optional)

VirtualStick = class(Controller)

function VirtualStick:init(args)
    self.radius = args.radius or 100
    self.deadZoneRadius = args.deadZoneRadius or 25
    self.releasedCallback = args.released or doNothing
    self.steerCallback = args.moved or doNothing
    self.pressedCallback = args.pressed or doNothing
end

function VirtualStick:touched(t)
    local pos = touchPos(t)
    
    if t.state == BEGAN and self.touchId == nil then
        self.touchId = t.id
        self.touchStart = pos
        self.stickOffset = vec2(0, 0)
        self.pressedCallback()
    elseif t.id == self.touchId then
        if t.state == MOVING then
            self.stickOffset = clampLen(pos - self.touchStart, self.radius)
            self.steerCallback(self:vector())
        elseif t.state == ENDED or t.state == CANCELLED then
            self:reset()
            self.releasedCallback()
        end
    end
end

function VirtualStick:vector()
    local stickRange = self.radius - self.deadZoneRadius
    local stickAmount = math.max(self.stickOffset:len() - self.deadZoneRadius, 0)
    local stickDirection = self.stickOffset:normalize()
    
    return stickDirection * (stickAmount/stickRange)
end

function VirtualStick:reset()
    self.touchId = nil
    self.touchStart = nil
    self.stickOffset = nil
end

function VirtualStick:draw()
    if self.touchId ~= nil then
        pushStyle()
        ellipseMode(RADIUS)
        strokeWidth(1)
        stroke(255, 255, 255, 255)
        noFill()
        
        pushMatrix()
        translate(self.touchStart.x, self.touchStart.y)
        ellipse(0, 0, self.radius, self.radius)
        ellipse(0, 0, self.deadZoneRadius, self.deadZoneRadius)
        translate(self.stickOffset.x, self.stickOffset.y)
        ellipse(0, 0, 25, 25)
        popMatrix()
        
        popStyle()
    end
end
