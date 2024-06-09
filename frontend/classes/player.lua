local class = require("class")
local vector2 = require("classes.vector2")

local player = class()

player.width = 32
player.height = 32

function player:constructor(game)
    self.speed = 100
    print("Creating player")
    self.object = game:waitFor("objects"):create()
    self.object.size = vector2(self.width, self.height)
end

function player:move(x, y, dt)
    self.object.position.x = self.object.position.x + x * self.speed * dt
    self.object.position.y = self.object.position.y + y * self.speed * dt
end

function player:draw()
end

function player:update()
end

return player