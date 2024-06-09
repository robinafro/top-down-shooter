local socket = require "socket"
local serpent = require "serpent"
local lfs = require "lfs"

local Response = require "response"

local udp = socket.udp()

udp:settimeout(0)
udp:setsockname("localhost", 8000)

local BROADCAST_INTERVAL = 0.1
local lastBroadcast = socket.gettime()

local shared = {
    udp = udp,
    serpent = serpent,
    Response = Response,
    broadcast = {}, --// Put broaddcast functions here, they should return a table of the same format as they would normally return if it was a response to a request
}

local modules = {}
local moduleFiles = {}
local moduleDir = "modules"
for file in lfs.dir(moduleDir) do
    if file ~= "." and file ~= ".." then
        local fullPath = moduleDir .. "/" .. file
        local attr = lfs.attributes(fullPath)
        if attr.mode == "file" then
            table.insert(moduleFiles, file)
        end
    end
end
for _, file in ipairs(moduleFiles) do
    local moduleName = file:match("(.+)%..+")
    if moduleName then
        print("Loading module: " .. moduleName)
        local module = require("modules." .. moduleName)

        if module.init then
            module.init(shared)
        end

        for key, value in pairs(module) do
            if key ~= "init" and type(value) == "function" then
                print("Adding channel: " .. key)
                modules[key] = value
            end
        end
    end
end


while true do
    local data, ip, port = udp:receivefrom()
    if data then
        local ok, deserialized = serpent.load(data)

        if not ok then
            print("Deserialization error")
            goto continue
        end

        deserialized.ip = ip
        deserialized.port = port
        
        local response
        local success, err, moduleOutput
        local module = modules[deserialized.channel]

        if not module then
            response = Response.error("channel not found")
            goto respond
        end

        print("Received request: "..serpent.line(deserialized))

        success, err = pcall(function()
            moduleOutput = module(deserialized)
        end)

        if not success then
            response = Response.error("An error occurred while processing the request: " .. err)
            goto respond
        end

        response = Response.success(moduleOutput)

        ::respond::
        response.channel = deserialized.channel

        local serialized = serpent.dump(response)

        if moduleOutput then
            udp:sendto(serialized, ip, port)
        end
        
        ::continue::
    end

    if socket.gettime() - lastBroadcast > BROADCAST_INTERVAL then
        for channel, broadcastFnc in pairs(shared.broadcast) do
            local moduleOutput
            local success, err = pcall(function()
                moduleOutput = broadcastFnc()
            end)

            if not success then
                goto continue
            end
            
            local response = Response.success(moduleOutput)
            response.channel = channel

            local serialized = serpent.dump(response)

            for _, player in pairs(shared.players) do
                print("Broadcasting to: " .. player.username)
                udp:sendto(serialized, player.ip, player.port)
            end

            ::continue::
        end

        lastBroadcast = socket.gettime()
    end
end