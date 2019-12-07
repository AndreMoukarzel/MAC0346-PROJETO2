
local State = require 'state'

local EndState = require 'common.class' (State)


function EndState:_init(stack)
  self:super(stack)
end

function EndState:enter(params)
  local center = params.b:tile_to_screen(0, 0)
  params.atlas:add("end", center, params.visual)
end

function EndState:on_keypressed(key)
  if key == 'escape' or key == 'return' then
    return self:pop()
  end
end

return EndState
