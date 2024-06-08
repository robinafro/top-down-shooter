function LoadModules(game, dir)
    local runningModules = {}

    local modules = love.filesystem.getDirectoryItems(dir)

    for _, module in ipairs(modules) do
        local moduleName = module:sub(1, -5) -- remove the file extension (.lua)
        local module = require(dir .. "." .. moduleName)

        if module["init"] ~= nil then
            local co = coroutine.create(function()
                local success, error = pcall(function()
                    module.init(game)
                end)
                
                if not success then
                    print(error)
                end
            end)

            table.insert(runningModules, module)

            coroutine.resume(co)
        end
    end

    return runningModules
end

function love.load()
    game = require("game")
    game:init()

    local coreModules = LoadModules(game, "core")
    local runningModules = LoadModules(game, "modules")
end

function love.draw()
    local success, err = pcall(function()
        game.RunService:Trigger("RenderStepped")
    end)

    if not success then
        print(err)
    end
end

function love.update(dt)
    local success, err = pcall(function()
        game.RunService:Trigger("Stepped")

        game.RunService:Trigger("Heartbeat")
    end)

    if not success then
        print(err)
    end
end