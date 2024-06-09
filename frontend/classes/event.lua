local class = require("class")

local event = class()

function event:constructor()
    self.connections = {}
end

function event:connect(callback)
    table.insert(self.connections, callback)
end

function event:fire(...)
    for _, connection in ipairs(self.connections) do
        connection(...)
    end
end

return event