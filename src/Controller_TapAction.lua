-- Fires a callback when the user touches the screen and when
-- they lift their finger again and ignores other touches in
-- the meantime
--
-- Arguments:
--
--     pressed(p) - callback when the user starts the touch (optional)
--     p : vec2 - the location of the touch
--
--     released(p) -- callback when the user ends the touch (optional)
--     p : vec2 - the location of the touch

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
    elseif t.state == CANCELLED then
        self.touchId = nil
    end
end
