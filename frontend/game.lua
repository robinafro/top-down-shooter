local game = {}

function game.init()end

function game:waitFor(name)
    repeat
        self.RunService:Wait()
    until self[name]

    return self[name]
end

return game