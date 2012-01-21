-- Directs touch events among multiple controllers depending when
-- the touch started. The first controller gets events for the
-- first touch, the second for the second touch, and so on.
--
-- Inspired by the control mechanism in Jeff Minter's iOS games.
--
-- Examples:
--   - Combine a VirtualStick and a TapAction to control direction
--     and shooting (or jumping)
--   - Combine two VirtualSticks for a dual-stick shooter

Minter = class(Controller)
Prioritised = Minter
Prioritized = Minter -- for our American friends!

function Minter:init(...)
    self.controllers = {...}
    self.touchIds = {}
end

function Minter:draw()
    for _, controller in pairs(self.controllers) do
        controller:draw()
    end
end

function Minter:touched(t)
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
                
                if t.state == ENDED or t.state == CANCELLED then
                    self.touchIds[i] = nil
                end
                
                break
            end
        end
    end
end
