------------------------------------------------------------
-- Base class for controllers
--
-- Controllers translate touch events into callbacks to functions
-- that do something in the app. (Model/View/Controller style).
--
-- Controllers can draw a representation of their current state on
-- the screen, but you can choose not to.
--
-- A controller can be installed as the global handler for touch
-- events by calling its activate() method

Controller = class()

function Controller:activate()
    touched = function(t)
        self:touched(t)
    end
end

function Controller:draw()
    -- nothing
end

-- Utility functions

function touchPos(t)
    return vec2(t.x, t.y)
end

function limitLen(vec, maxLen)
    return vec:normalize() * math.min(vec:len(), maxLen)
end

function doNothing()
end

------------------------------------------------------------
-- A virtual analogue joystick with a dead-zone at the center
--
-- -- Arguments:
--     width - radius of the stick (default = 100)
--     deadZoneWidth - radius of the stick's dead zone (default = 40)
--     moved(v) - Called when the stick is moved
--         v : vec2 - in the range vec2(-1,-1) and vec2(1,1)
--     pressed() - Called when the user starts using the stick (optional)
--     released() - Called when the user releases the stick (optional)

VirtualStick = class(Controller)

function VirtualStick:init(args)
    self.radius = args.radius or 100
    self.deadZoneRadius = args.deadZoneRadius or 40
    self.releasedCallback = args.released or doNothing
    self.steerCallback = args.moved or doNothing
    self.pressedCallback = args.pressed or doNothing
    self.touchId = nil
    self.touchStart = nil
    self.stickOffset = nil
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
            self.stickOffset = limitLen(pos - self.touchStart, self.radius)
            self.steerCallback(self:vector())
        elseif t.state == ENDED then
            self:reset()
            self.releasedCallback()
        end
    end
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
        ellipse(0, 0, 40, 40)
        popMatrix()
        
        popStyle()
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
    self.touchEnd = nil
end


------------------------------------------------------------
-- Fires a callback when the user touches the screen and when
-- they lift their finger again and ignores other touches in
-- the meantime
--
-- Arguments:
--
--     pressed(p) - callback when the user starts the touch (optional)
--     p : vec2 - the location of the touch
--
--     released(p) -- callback when the user ends the touch (optional)
--     p : vec2 - the location of the touch

TapAction = class(Controller)

function TapAction:init(args)
    self.actionCallback = args.pressed or doNothing
    self.stopCallback = args.released or doNothing
    self.touchId = nil
end

function TapAction:touched(t)
    if t.state == BEGAN and self.touchId == nil then
        self.touchId = t.id
        self.actionCallback(touchPos(t))
    elseif t.state == ENDED and t.id == self.touchId then
        self.touchId = nil
        self.stopCallback(touchPos(t))
    end
end


------------------------------------------------------------
-- Directs touch events among multiple controllers depending when
-- the touch started. The first controller gets events for the
-- first touch, the second for the second touch, and so on.
--
-- Inspired by the control mechanism in Jeff Minter's iOS games.
--
-- Examples:
--   - Combine a VirtualStick and a TapAction to control direction
--     and shooting (or jumping)
--   - Combine two VirtualSticks for a dual-stick shooter

Prioritised = class(Controller)
Prioritized = Prioritised -- for our American friends!
Minter = Prioritised -- backwards compatability

function Prioritised:init(...)
    self.controllers = {...}
    self.touchIds = {}
end

function Prioritised:draw()
    for _, controller in pairs(self.controllers) do
        controller:draw()
    end
end

function Prioritised:touched(t)
    if t.state == BEGAN then
        for i, controller in ipairs(self.controllers) do
            if self.touchIds[i] == nil then
                self.touchIds[i] = t.id
                controller:touched(t)
                break
            end
        end
    else
        for i, controller in ipairs(self.controllers) do
            if self.touchIds[i] == t.id then
                controller:touched(t)
                
                if t.state == ENDED then
                    self.touchIds[i] = nil
                end
                
                break
            end
        end
    end
end


------------------------------------------------------------
-- A "catapult" style launcher. Drag on the screen to input the
-- direction and force of a launched projectile.
--
-- Callback: 
--     launcher(pos, vel)
--     pos : vec2  - the location where the user started dragging
--     drag : vec2 - the vector dragged, relative to pos

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


------------------------------------------------------------
-- Splits the screen horizontally or vertically, directing input 
-- that starts in one side to one controller and input that 
-- on the other side to the other controller.
-- 
-- This can be used to implement shared-screen multiplayer games.
--
-- The constructor argument is a table. If it contains the fields
-- left and right, the screen is split horizontally, If it 
-- contains the fields top and bottom it is split vertically.

SplitScreen = class(Controller)

function SplitScreen:init(split)
    if split.top ~= nil then
        self.split = {split.bottom, split.top}
        self.orientation = function(v) return v.y end
    else
        self.split = {split.left, split.right}
        self.orientation = function(v) return v.x end
    end
    self.touches = {}
end

function SplitScreen:touched(t)
    local controller
    
    if t.state == BEGAN then
        local extent = self.orientation(vec2(WIDTH,HEIGHT))
        local coord = self.orientation(t)

        if coord < extent/2 then
            controller = self.split[1]
        else 
            controller = self.split[2]
        end
        
        self.touches[t.id] = controller
    else
        controller = self.touches[t.id]
        
        if t.state == ENDED then
            self.touches[t.id] = nil
        end
    end
    
    controller:touched(t)
end

function SplitScreen:draw()
    self.split[1]:draw()
    self.split[2]:draw()
end
