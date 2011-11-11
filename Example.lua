-- An example of using the controllers for shared-screen multiplayer.
-- Two players move and shoot, controlled by a virtual joystick and
-- tap-to-fire. Bottom of the screen controls player 1, top of the
-- screen controls player 2
-- 
-- No collision detection or any actual game play, just a demo of the
-- controller classes
--
-- Now, on to the code...


-- A very simple game engine

Collection = class()

function Collection:init()
    self.animations = {}
end

function Collection:add(animation)
    table.insert(self.animations, animation)
end

function Collection:each(func)
    local lastFrame = self.animations
    self.animations = {}
    
    for i, animation in pairs(lastFrame) do
        if animation:isAlive() then
            func(animation)
            if animation:isAlive() then
                self:add(animation)
            end
        end
    end
end

Animator = class(Collection)
function Animator:animate(dt)
    while dt > 0.1 do
        self:each(function (a) a:animate(0.1) end)
        dt = dt - 0.1
    end
    self:each(function (a) a:animate(dt) end)
end

Layer = class(Collection)
function Layer:draw()
    self:each(function (a) a:draw() end)
end

-- A player character

Chappy = class()

function Chappy:init(sprite, pos)
    self.sprite = sprite
    self.pos = pos
    self.vel = vec2(0, 0)
end

function Chappy:steer(velRatio)
    self.vel = velRatio*400
end

function Chappy:animate(dt)
    self.pos = self.pos + self.vel*dt
end

function Chappy:draw()
    sprite(self.sprite, self.pos.x, self.pos.y)
end

function Chappy:isAlive()
    return true
end


-- Particles

Particle = class()

function Particle:init(pos, vel, diameter, color, life, fader)
    self.diameter = diameter
    self.pos = pos
    self.vel = vel
    self.life = life
    self.age = 0.0
    self.color = color
    self.fader = fader or noFade
end

function Particle:isAlive()
    return self.age <= self.life
end

function Particle:animate(dt)
    self.pos = self.pos + (self.vel*dt)
    self.age = self.age + dt
end

function Particle:draw()
    ellipseMode(CENTER)
    noStroke()
    
    local c = self.fader(self.color,
         (self.life - self.age) / self.life)
    
    fill(c)
    stroke(c) -- work around noStroke bug
    
    ellipse(self.pos.x, self.pos.y, self.diameter, self.diameter)
end


-- Smoke trails

Trail = class()

function Trail:init(launcher, period, decoratedAnimation)
    self.decoratedAnimation = decoratedAnimation
    self.period = period
    self.launcher = launcher
    self.counter = 0.0
end

function Trail:animate(dt)
    self.decoratedAnimation:animate(dt)
    
    self.counter = self.counter + dt
    while self.counter > self.period do
        self.launcher(self.decoratedAnimation)
        self.counter = self.counter - self.period
    end
end

function Trail:draw()
    self.decoratedAnimation:draw()
end

function Trail:isAlive()
    return self.decoratedAnimation:isAlive()
end


-- Let's go!

function setup()
    animator = Animator()
    sprites = Layer()
    smoke = Layer()
    
    
    local player1 = Chappy("Planet Cute:Character Boy", vec2(WIDTH/2, HEIGHT/4))
    local player2 = Chappy("Planet Cute:Character Horn Girl", vec2(WIDTH/2, 3*HEIGHT/4))
    
    animator:add(player1)
    animator:add(player2)
    sprites:add(player1)
    sprites:add(player2)
    
    controller = SplitScreen(SPLIT_VERTICAL,
        controllerFor(player2, player1),
        controllerFor(player1, player2))
    
    controller:activate()
end

function controllerFor(player, opponent)
    return Minter(
            VirtualStick(100, 40, function(v) 
                player:steer(v) 
            end),
            TapAction(function() 
                launchRocket(player, opponent)
            end))
end

function draw()
    background(138, 223, 47, 255)
    
    animator:animate(DeltaTime)
    
    sprites:draw()
    smoke:draw()
    controller:draw()
end

function launchRocket(from, to)
    local dir = (to.pos-from.pos):normalize()
    local start = from.pos + 60*dir
    
    local rocket = Trail(launchSmoke, 0.025, 
        Particle(start, 400*dir, 32, color(255, 0, 0, 255), 2, scaleRGB))
    
    animator:add(rocket)
    sprites:add(rocket)
    
    sound(SOUND_SHOOT, 12)
end

function launchSmoke(source)
    local puff = Particle(
        source.pos,
        vec2(math.random(0,16),0):rotate(math.random(0,2*math.pi)),
        math.random(16,40),
        randomGrey(128, 160),
        2,
        fadeAlpha)
        
    animator:add(puff)
    smoke:add(puff)
end


-- Some utility functions

function randomGrey(min, max)
    local c = math.random(min, max)
    return color(c, c, c, 255)
end

function fadeAlpha(c, alphaMultiplier)
    return color(c.r, c.g, c.b, c.a*alphaMultiplier)
end

function noFade(c, mult)
    return c
end
