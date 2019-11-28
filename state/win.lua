
local State = require 'state'

local WinState = require 'common.class' (State)


function WinState:_init(stack)
  self:super(stack)
end

function WinState:enter(params)
  local center = params[1]:tile_to_screen(0, 0)
  params[2]:add("victory", center, "trophy")
end

function WinState:on_keypressed(key)
  if key == 'escape' or key == 'enter' then
    return self:pop("win")
  end
end

return WinState
