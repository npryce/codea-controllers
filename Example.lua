
Player = class()
Player.speed = 400

function Player:init(sprite, x, y)
    self.sprite = sprite
    self.pos = vec2(x, y)
    self.steer = vec2(0,0)
end

function Player:animate(dt)
    self.pos = self.pos + self.steer*self.speed*dt
end

function Player:draw()
    sprite(self.sprite, self.pos.x, self.pos.y)
end

function controllerFor(player)
    return VirtualStick {
        moved = function(v) player.steer = v end,
        released = function(v) player.steer = vec2(0,0) end
    }
end

function setup()
    player1 = Player("Planet Cute:Character Boy", WIDTH/2, HEIGHT/4)
    player2 = Player("Planet Cute:Character Pink Girl", WIDTH/2, 3*HEIGHT/4)
    
    controller = SplitScreen {
        top = controllerFor(player2),
        bottom = controllerFor(player1)
    }
    
    controller:activate()
end

function draw()
    background(131, 228, 73, 255)
    player1:animate(DeltaTime)
    player2:animate(DeltaTime)
        
    player1:draw()
    player2:draw()
    controller:draw()
end
