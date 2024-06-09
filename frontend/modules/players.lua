local localplayer = require("classes.localplayer")
local remoteplayer = require("classes.remoteplayer")
local vector2 = require("classes.vector2")

function getPlayerByUsername(players, username)
    for _, player in ipairs(players) do
        if player.username == username then
            return player
        end
    end
end

return {init = function(game)
    game.players = {}

    --// Create a local player
    local localplayer = localplayer(game)

    table.insert(game.players, localplayer)

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

    game.localplayer = localplayer

    --// Login the local player
    localplayer:login("John Doe")

    local movementRemote = game:waitFor("remotes"):get("player_movement")

    movementRemote.received:connect(function(response)
        for _, playerData in pairs(response.data) do
            print(playerData.username, playerData.position.x, playerData.position.y)

            local player = getPlayerByUsername(game.players, playerData.username)

            if player then
                print(player.super == localplayer.super)
                if playerData.username ~= localplayer.username then
                    -- player.super.object.position = vector2()
                    player.super.object.position = vector2(playerData.position.x, playerData.position.y)
                end
            else
                --// Create a new player
                local newPlayer = remoteplayer(game)

                newPlayer.username = playerData.username
                newPlayer.super.object.position = vector2(playerData.position.x, playerData.position.y)

                table.insert(game.players, newPlayer)
            end
        end
    end)
end}