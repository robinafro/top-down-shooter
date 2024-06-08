local vector2 = require("classes.vector2")
local class = require("class")

local RaycastResult = class()

function RaycastResult:constructor(intersection, object, distance)
    self.distance = distance
    self.intersection = intersection
    self.object = object
    self.hit = intersection ~= nil and object ~= nil
end

return {init = function(game)
    local objects = game:waitFor("objects")._objects

    function game:raycast(opts)
        local origin = opts.origin
        local direction = opts.direction
        local length = opts.length
        local filter = opts.filter or {}
        local filterType = opts.filterType or "blacklist"

        assert(origin, "origin is required")
        assert(direction, "direction is required")
        assert(length, "length is required")

        local closest, closestObject = nil, nil
        local closestDistance = math.huge

        local function checkIntersection(x1, y1, x2, y2, x3, y3, x4, y4)
            local den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
            if den == 0 then
                return nil
            end

            local t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den
            local u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / den

            if t >= 0 and t <= 1 and u >= 0 and u <= 1 then
                return vector2(x1 + t * (x2 - x1), y1 + t * (y2 - y1))
            end

            return nil
        end

        for _, object in ipairs(objects) do
            if filterType == "blacklist" then
                local found = false

                for _, filterObject in ipairs(filter) do
                    if object == filterObject then
                        found = true
                        break
                    end
                end

                if found then
                    goto continue
                end
            elseif filterType == "whitelist" then
                local found = false

                for _, filterObject in ipairs(filter) do
                    if object == filterObject then
                        found = true
                        break
                    end
                end

                if not found then
                    goto continue
                end
            end

            local x1, y1 = origin.x, origin.y
            local x2, y2 = origin.x + direction.x * length, origin.y + direction.y * length

            local halfSizeX = object.size.x / 2
            local halfSizeY = object.size.y / 2

            local edges = {
                {object.position.x - halfSizeX, object.position.y - halfSizeY, object.position.x + halfSizeX, object.position.y - halfSizeY}, -- Top edge
                {object.position.x + halfSizeX, object.position.y - halfSizeY, object.position.x + halfSizeX, object.position.y + halfSizeY}, -- Right edge
                {object.position.x - halfSizeX, object.position.y + halfSizeY, object.position.x + halfSizeX, object.position.y + halfSizeY}, -- Bottom edge
                {object.position.x - halfSizeX, object.position.y - halfSizeY, object.position.x - halfSizeX, object.position.y + halfSizeY} -- Left edge
            }

            for _, edge in ipairs(edges) do
                local intersection = checkIntersection(x1, y1, x2, y2, edge[1], edge[2], edge[3], edge[4])
                if intersection then
                    local distance = (origin - intersection):magnitude()
                    if distance < closestDistance then
                        closest = intersection
                        closestObject = object
                        closestDistance = distance
                    end
                end
            end

            ::continue::
        end

        return RaycastResult(closest, closestObject, closestDistance)
    end
end}