local socket = require("socket")
local serpent = require("lib.serpent")
local event = require("classes.event")
local uuid = require("uuid")
local class = require("class")

local remote = class()

--// Note: Not all errors are handled yet
remote.errors = {
    SerializationError = "Serialization error",
    DeserializationError = "Deserialization error",
    SendError = "Send error",
    ReceiveError = "Receive error",
    TimeoutError = "Timeout error",
    UnknownError = "Unknown error"
}

remote.ADDRESS = "localhost"
remote.PORT = 8000
remote.UPDATE_RATE = 0.1

function remote:constructor(channel)
    self.channel = channel

    self.udp = socket.udp()
    self.udp:settimeout(0)
    self.udp:setpeername(remote.ADDRESS, remote.PORT)

    self.received = event()

    self.last_received = 0
    self.last_transmitted = 0
end

function remote:listen()
    if socket.gettime() - self.last_received < remote.UPDATE_RATE then
        return
    end

    self.last_received = socket.gettime()

    local data = self.udp:receive() --// This will be a problem - if the first packet is not of the same channel, it will be ignored instead of being queued and processed in the other channel remote

    if data then
        local ok, deserialized = serpent.load(data)

        if not ok then
            return
        end

        if deserialized.channel ~= self.channel then
            return
        end

        self.received:fire(deserialized)
    end
end

function remote:fire(data)
    if socket.gettime() - self.last_transmitted < remote.UPDATE_RATE then
        return
    end

    self.last_transmitted = socket.gettime()

    local result = {
        ok = false,
        data = nil,
    }

    local success, errormessage = pcall(function()
        local serialized
        local data = {
            channel = self.channel,
            data = data,
            sent_at = socket.gettime(),
        }
        local success = pcall(function()
            serialized = serpent.dump(data)
        end)

        if not success then
            result.data = remote.errors.SerializationError
            return
        end

        self.udp:send(serialized)

        result.ok = true
    end)

    if not success then
        result.ok = false
        result.data = errormessage

        return result
    end

    return result
end

return remote