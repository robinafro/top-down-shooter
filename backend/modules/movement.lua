local module = {}

function module.init(shared)
    module.shared = shared

    -- shared.broadcast.player_movement = function()
    --     print("Broadcasting player movement")
    --     local players = {}

    --     for _, player in pairs(module.shared.players) do
    --         table.insert(players, {
    --             position = player.position,
    --         })
    --     end

    --     return players
    -- end
end

function module.player_movement(request)
    local authstring = request.data.authstring
    local position = request.data.position

    assert(type(authstring) == "string", "Authstring must be a string")
    assert(type(position) == "table", "Position must be a table")

    local player = module.shared.players[authstring]

    assert(player, "Player not found")

    player.position = position

    --// Return all player positions
    local players = {}

    for _, player in pairs(module.shared.players) do
        table.insert(players, {
            username = player.username,
            position = player.position,
        })
    end

    return players
end

return module
