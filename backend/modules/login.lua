function genuuid()
    return ("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", function(c)
        local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format("%x", v)
    end)
end

local module = {}

function module.init(shared)
    module.shared = shared

    shared.players = {} --// Key: authstring, Value: player
end

function module.login(request)
    local username = request.data.username

    assert(type(username) == "string", "Username must be a string")

    local function isTaken(username)
        for _, player in pairs(module.shared.players) do
            if player.username == username then
                return true
            end
        end
        return false
    end

    --// Find if anybody is already logged in with this username
    while isTaken(username) do
        username = username .. math.random(1, 100)
    end

    local authstring = genuuid()

    local player = {
        ip = request.ip,
        port = request.port,
        
        username = username,
        authstring = authstring,
        position = {x = 0, y = 0},
    }

    module.shared.players[authstring] = player

    return {
        username = username,
        authstring = authstring,
    }
end

return module