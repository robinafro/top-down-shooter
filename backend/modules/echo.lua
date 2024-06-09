return {
    echo = function(request)
        print("Received data from client:", request.data)

        for key, value in pairs(request.data) do
            print(key, value)
        end
        
        return request.data
    end
}