
local Box = require 'common.box'
local Vec = require 'common.vec'
local UnitSelector = require 'common.class' ()

function UnitSelector:_init(units, center)
  local size = Vec(1, #units) * 32
  self.units = units
  self.bounds = Box.from_vec(center, size)
end

function UnitSelector:center()
  local b = self.bounds
  return (Vec(b.left, b.top) + Vec(b.right, b.bottom)) / 2
end

function UnitSelector:round_to_tile(pos)
  local center = self:center()
  local dist = pos - center
  local tile = ((dist + Vec(16, 16)) / 32):floor()
  tile:clamp(7, 7)
  return center + tile * 32
end

function UnitSelector:tile_to_screen(x, y)
  local center = self:center()
  return center + Vec(x, y):floor() * 32
end

function UnitSelector:draw()
  local g = love.graphics
  g.setColor(1, 1, 1)
  g.setLineWidth(4)
  g.rectangle('line', self.bounds:get_rectangle())
end

return UnitSelector
