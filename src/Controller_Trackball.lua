
Trackball = class(Controller)

function Trackball:init(args)
    self.touch = nil
    self.sensitivity = args.sensitivity or 1
    self.callback = args.moved
end

function Trackball:touched(t)
    if t.state == BEGAN then
        if self.touch == nil then
            self.touch = t.id
        end
    elseif t.id == self.touch then
        self.callback(vec2(t.deltaX, t.deltaY)*self.sensitivity)
        if t.state == ENDED or t.state == CANCELLED then
            self.touch = nil
        end
    end
end
