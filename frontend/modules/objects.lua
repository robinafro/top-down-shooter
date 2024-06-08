local object = require("classes.object")

return {init = function(game)
    game.objects = {
        _objects = {}
    }

    function game.objects:create()
        local object = object()

        table.insert(self._objects, object)

        return object
    end

    game.RunService:Connect("RenderStepped", function(dt)
        for _, object in ipairs(game.objects._objects) do
            object:draw()
        end
    end)
end}