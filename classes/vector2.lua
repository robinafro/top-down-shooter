local class = require("class")

local vector2 = class()

function vector2:constructor(x, y)
    self.x = x or 0
    self.y = y or 0
end

function vector2:magnitude()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

function vector2:normalized()
    local mag = self:magnitude()

    return vector2(self.x / mag, self.y / mag)
end

function vector2:angle()
    return math.atan2(self.y, self.x)
end

function vector2:cross(other)
    return self.x * other.y - self.y * other.x
end

function vector2:dot(other)
    return self.x * other.x + self.y * other.y
end

function vector2:__add(other)
    return vector2(self.x + other.x, self.y + other.y)
end

function vector2:__sub(other)
    return vector2(self.x - other.x, self.y - other.y)
end

function vector2:__mul(other)
    if type(other) == "number" then
        return vector2(self.x * other, self.y * other)
    else 
        return vector2(self.x * other.x, self.y * other.y)
    end
end

function vector2:__div(other)
    if type(other) == "number" then
        return vector2(self.x / other, self.y / other)
    else
        return vector2(self.x / other.x, self.y / other.y)
    end
end

function vector2:__eq(other)
    return self.x == other.x and self.y == other.y
end

return vector2