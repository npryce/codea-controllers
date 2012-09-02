-- Forwards each touch event to all the controllers in the table
-- passed to the constructor

All = class(Controller)

function All:init(controllers)
    self.controllers = controllers
end

function All:touched(t)
    for _, c in pairs(self.controllers) do
        c:touched(t)
    end
end

function All:draw()
    for _, c in pairs(self.controllers) do
        c:draw()
    end
end
