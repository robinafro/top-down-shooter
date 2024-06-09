local Response = {}

function Response.success(data)
    return {
        ok = true,
        data = data,
    }
end

function Response.error(message)
    return {
        ok = false,
        data = message,
    }
end

return Response