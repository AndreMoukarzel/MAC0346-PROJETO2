
local Box = require 'common.box'
local Vec = require 'common.vec'
local UnitSelector = require 'common.class' ()

package.path = "lib/?.lua;lib/?/init.lua;" .. package.path

local RULE_MODULES = { 'rules' }

local RULESETS = { 'unit' }

local rules = require 'ur-proto' (RULE_MODULES, RULESETS)


function UnitSelector:_init(units, center, atlas)
  self.units = {}
  local size = Vec(1, #units) * 32
  for i, unit_name in pairs(units) do
    local pos = center + Vec(16, 32 * (i - 1)) - size/2
    local unit = rules:new_unit(unit_name, pos)
    atlas:add(unit, unit:get_position(), unit:get_appearance())
    self.units[i] = {name = unit_name, pos = pos}
  end
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
  tile:clamp(0, #self.units - 1)
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

function UnitSelector:get_pos(i)
  return self.units[i].pos
end

return UnitSelector
