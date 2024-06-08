local localplayer = require("classes.localplayer")

return {init = function(game)
    game.players = {}

    --// Create a local player
    local player = localplayer(game)

    table.insert(game.players, player)

    game.RunService:Connect("Stepped", function(dt)
        for _, player in ipairs(game.players) do
            player:update(dt)
        end
    end)

    game.RunService:Connect("RenderStepped", function()
        for _, player in ipairs(game.players) do
            player:draw()
        end
    end)
end}