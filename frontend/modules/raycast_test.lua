local vector2 = require("classes.vector2")
local color3 = require("classes.color3")

return ({init = function(game)
    local whitelist = {}

    for i = 1, 10 do
        local object = game:waitFor("objects"):create()
        object.size = vector2(20, 20)
        object.position = vector2(love.math.random(0, love.graphics.getWidth()), love.math.random(0, love.graphics.getHeight()))
        object.color3 = color3(0, 0, 1)

        table.insert(whitelist, object)
    end
end})