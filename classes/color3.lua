local class = require("class")

local color3 = class()

function color3:constructor(r, g, b)
    self.r = r or 1
    self.g = g or 1
    self.b = b or 1
end

function color3:__add(other)
    return color3(self.r + other.r, self.g + other.g, self.b + other.b)
end

function color3:__sub(other)
    return color3(self.r - other.r, self.g - other.g, self.b - other.b)
end

function color3:__mul(other)
    if type(other) == "number" then
        return color3(self.r * other, self.g * other, self.b * other)
    else 
        return color3(self.r * other.r, self.g * other.g, self.b * other.b)
    end
end

function color3:__div(other)
    if type(other) == "number" then
        return color3(self.r / other, self.g / other, self.b / other)
    else
        return color3(self.r / other.r, self.g / other.g, self.b / other.b)
    end
end

function color3:__eq(other)
    return self.r == other.r and self.g == other.g and self.b == other.b
end

return color3