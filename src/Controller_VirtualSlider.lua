-- A virtual analogue slider with a dead-zone at the center,
-- which activates wherever the user touches their finger
--
-- Arguments:
--     orientation - A unit vector that defines the orientation of the slider.
--                   For example orientation=vec2(1,0) creates a horizontal slider,
--                   orientation=vec2(0,1) creates a vertical slider. The slider
--                   can be given an arbitrary orientation; it does not have to be
--                   aligned with the x or y axis. For example, setting
--                   orientation=vec2(1,1):normalize() creates a diagonal slider.
--     radius - Distance from the center to the end of the slider (default = 100)
--     deadZoneRadius - Distance from the center to the end of the dead zone (default = 25)
--     moved(x) - Called when the slider is moved
--         x : float - in the range -1 to 1
--     pressed() - Called when the user starts using the slider (optional)
--     released() - Called when the user releases the slider (optional)

VirtualSlider = class(Controller)

function VirtualSlider:init(args)
    self.orientation = args.orientation or vec2(1,0)
    self.radius = args.radius or 100
    self.deadZoneRadius = args.deadZoneRadius or 25
    self.releasedCallback = args.released or doNothing
    self.movedCallback = args.moved or doNothing
    self.pressedCallback = args.pressed or doNothing
end

function VirtualSlider:touched(t)
    local pos = touchPos(t)
    
    if t.state == BEGAN and self.touchId == nil then
        self.touchId = t.id
        self.touchStart = pos
        self.sliderOffset = 0
        self.pressedCallback()
    elseif t.id == self.touchId then
        if t.state == MOVING then
            local v = pos - self.touchStart
            self.sliderOffset = clampAbs(project(v, self.orientation), self.radius)
            self.movedCallback(self:value())
        elseif t.state == ENDED or t.state == CANCELLED then
            self:reset()
            self.releasedCallback()
        end
    end
end

function VirtualSlider:reset()
    self.touchId = nil
    self.touchStart = nil
    self.sliderOffset = nil
end

function VirtualSlider:value()
    local range = self.radius - self.deadZoneRadius
    local amount = sign(self.sliderOffset) * math.max(math.abs(self.sliderOffset) - self.deadZoneRadius, 0)
    
    return amount/range
end

function VirtualSlider:draw()
    if self.touchId ~= nil then
        pushStyle()
        ellipseMode(RADIUS)
        strokeWidth(3)
        stroke(255, 255, 255, 255)
        lineCapMode(SQUARE)
        noFill()
        
        local function polarLine(orientation, fromRadius, toRadius)
            local from = orientation * fromRadius
            local to = orientation * toRadius
            line(from.x, from.y, to.x, to.y)
        end
        
        pushMatrix()
        translate(self.touchStart.x, self.touchStart.y)
        polarLine(self.orientation, self.deadZoneRadius, self.radius)
        polarLine(self.orientation, -self.deadZoneRadius, -self.radius)
        
        local sliderPos = self.orientation * self.sliderOffset
        translate(sliderPos.x, sliderPos.y)
        strokeWidth(1)
        ellipse(0, 0, 25, 25)
        
        popMatrix()
        
        popStyle()
    end
end
