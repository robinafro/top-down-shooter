uuid = require("uuid")

RunService = {}
RunService.__index = RunService

RunService.Paused = false

--// User functions

function RunService:Connect(event, func)
    local id = uuid()
    self.Events[event].Functions[id] = func

    return id
end

function RunService:Disconnect(event, id)
    if not self.Events[event].Functions[id] then
        return false
    end

    self.Events[event].Functions[id] = nil

    return true
end

function RunService:Delay(seconds, func)
    if not func or not seconds then return end

    local start = love.timer.getTime()
    
    local id
    id = self:Connect("Heartbeat", function()
        if love.timer.getTime() - start < seconds then
            return
        end

        self:Disconnect("Heartbeat", id)
        func()
    end)
end

function RunService:Wait(seconds)
    if not seconds then seconds = 0 end
    
    local start = love.timer.getTime()
    local co = coroutine.running()
    local id

    assert(co, "RunService:Wait() must be called from a coroutine")

    id = self:Connect("Heartbeat", function()
        if love.timer.getTime() - start < seconds then
            return
        end
        
        self:Disconnect("Heartbeat", id)
        coroutine.resume(co)
    end)

    coroutine.yield()
end

function RunService:GetDelta(event)
    return self.Events[event].Delta
end

--// System functions

function RunService.new()
    local self = setmetatable({}, RunService)

    self.Events = {
        RenderStepped = {Delta = 0, Last = 0, Async = false, NoPause = true, Functions = {}}, --// Run before rendering
        Stepped = {Delta = 0, Last = 0, Async = false, Functions = {}}, --// Run before physics
        Heartbeat = {Delta = 0, Last = 0, Async = true, Functions = {}}, --// Run after frame done
        Network = {Delta = 0, Last = 0, Async = true, Functions = {}},
        Restart = {Delta = 0, Last = 0, Async = false, Functions = {}}
    }

    return self
end

function RunService:Reset()
    for event, _ in pairs(self.Events) do
        for id, _ in pairs(self.Events[event].Functions) do
            self:Disconnect(event, id)
        end
    end
end

function RunService:TogglePause()
    self.Paused = not self.Paused
end

function RunService:Trigger(event)
    self:SetDelta(event)

    local eventObj = self.Events[event]
    
    if self.Paused and not eventObj.NoPause then
        return
    end

    for _, func in pairs(eventObj.Functions) do
        if eventObj.Async then
            coroutine.wrap(func)(eventObj.Delta)
        else
            func(eventObj.Delta)
        end
    end
end

function RunService:SetDelta(event)
    local time = love.timer.getTime()

    local function set(ev)
        self.Events[ev].Delta = (time - self.Events[ev].Last)-- * (love.keyboard.isDown("lshift") and 10 or 1)
        self.Events[ev].Last = time
    end
    
    if event then
        set(event)
    else
        for ev, _ in pairs(self.Events) do
            set(ev)
        end
    end
end

return {init = function(game)
    game.RunService = RunService.new()
end}