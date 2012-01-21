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
        
        if t.state == ENDED or t.state == CANCELLED then
            self.touches[t.id] = nil
        end
    end
    
    controller:touched(t)
end

function SplitScreen:draw()
    self.split[1]:draw()
    self.split[2]:draw()
end
