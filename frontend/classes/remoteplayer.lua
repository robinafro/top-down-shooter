local class = require("class")
local player = require("classes.player")

local remoteplayer = class(player)

function remoteplayer:constructor(game)
    self.super.constructor(self, game)
    self.super = self

    self.username = ""
end

return remoteplayer