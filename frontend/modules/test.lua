local player = require("classes.player")
local localplayer = require("classes.localplayer")
local remoteplayer = require("classes.remoteplayer")

return {init = function(game)
    --// test whether they will share the same super (it shouldnt be the same object)

    local localplayer = localplayer(game)
    local remoteplayer = remoteplayer(game)

    print(localplayer.super == remoteplayer.super) -- true; why?

    --// fix
end}