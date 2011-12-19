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

function clamp(x, min, max)
    return math.max(min, math.min(max, x))
end

function clampAbs(x, maxAbs)
    return clamp(x, -maxAbs, maxAbs)
end

function clampLen(vec, maxLen)
    return vec:normalize() * math.min(vec:len(), maxLen)
end

-- projects v onto the direction represented by the given unit vector
function project(v, unit)
    return v:dot(unit)
end

function sign(x)
    if x == 0 then
        return 0
    elseif x < 0 then
        return -1
    elseif x > 0 then
        return 1
    else
        return x -- x is NaN
    end
end

function doNothing()
end
