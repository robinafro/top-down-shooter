return ({init = function(game)
    local remote = require("classes.remote")

    game.remotes = {_by_channel = {}}

    function game.remotes:new(channel)
        local remote = remote(channel)

        game.RunService:Connect("Network", function()
            remote:listen()
        end)

        game.remotes._by_channel[channel] = remote

        return remote
    end

    function game.remotes:get(channel)
        local remote = game.remotes._by_channel[channel]

        if not remote then
            remote = game.remotes:new(channel)
        end

        return remote
    end
end})