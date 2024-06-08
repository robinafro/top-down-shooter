local class = require("class")

local vector2 = require("classes.vector2")
local color3 = require("classes.color3")

local object = class()

function object:constructor()
    self.position = vector2()
    self.size = vector2(10, 10)
    self.rotation = 0

    self.color3 = color3()
end

function object:draw()
    love.graphics.setColor(self.color3.r, self.color3.g, self.color3.b)
    love.graphics.push()
    love.graphics.translate(self.position.x, self.position.y)
    love.graphics.rotate(self.rotation)
    love.graphics.rectangle("fill", -self.size.x/2, -self.size.y/2, self.size.x, self.size.y)
    love.graphics.pop()
end

return object