local vector2 = require("classes.vector2")
local color3 = require("classes.color3")

local class = require("class")
local player = require("classes.player")

local localplayer = class(player)

localplayer.aimVisualizerThickness = 1
localplayer.aimVisualizerLength = 1000

function localplayer:constructor(game)
    self.super.constructor(self, game)
    self.super = self
    
    self.visualizers = {
        aim = game:waitFor("objects"):create(),
    }

    self.visualizers.aim.color3 = color3(1, 0, 0)

    self.aimDirection = vector2()

    self.game = game

    self.movementRemote = game:waitFor("remotes"):get("player_movement")

    --// Login attributes
    self.username = ""
    self.authstring = ""
    self.ready = false

    local remote = self.game:waitFor("remotes"):get("login")

    remote.received:connect(function(response)
        if response.ok then
            print("Logged in as " .. response.data.username)

            self.username = response.data.username
            self.authstring = response.data.authstring
            self.ready = true

            print(self)
        else
            print("Failed to login: " .. response.data)
        end
    end)
end

function localplayer:update(dt)
    local x = (love.keyboard.isDown("d") and 1 or 0) + (love.keyboard.isDown("a") and -1 or 0)
    local y = (love.keyboard.isDown("s") and 1 or 0) + (love.keyboard.isDown("w") and -1 or 0)

    self:move(x, y, dt)

    local mousePosition = vector2(love.mouse.getX(), love.mouse.getY())
    local direction = (mousePosition - self.super.object.position):normalized()

    self.aimDirection = direction

    self.movementRemote:fire({
        authstring = self.authstring,
        position = {
            x = self.super.object.position.x,
            y = self.super.object.position.y,
        },
    })
end

function localplayer:draw()
    local visualizer = self.visualizers.aim

    local result = self.game:raycast({
        origin = self.super.object.position,
        direction = self.aimDirection,
        length = localplayer.aimVisualizerLength,
        filter = {self.super.object, self.visualizers.aim},
        filterType = "blacklist"
    })
    
    local startPos, endPos = self.super.object.position, self.super.object.position + self.aimDirection * localplayer.aimVisualizerLength

    if result.hit then
        endPos = result.intersection
    end

    visualizer.rotation = (startPos - endPos):angle()
    visualizer.position = (startPos + endPos) / 2
    visualizer.size = vector2((startPos - endPos):magnitude(), localplayer.aimVisualizerThickness)
end

function localplayer:login(username)
    local remote = self.game:waitFor("remotes"):get("login")

    remote:fire({
        username = username,
    })
end

return localplayer