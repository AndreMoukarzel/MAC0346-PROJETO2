
local Wave = require 'model.wave'
local Unit = require 'model.unit'
local Vec = require 'common.vec'
local Cursor = require 'view.cursor'
local SpriteAtlas = require 'view.sprite_atlas'
local BattleField = require 'view.battlefield'
local UnitSelector = require 'view.unit_selector'
local Stats = require 'view.stats'
local State = require 'state'

local PlayStageState = require 'common.class' (State)
package.path = "lib/?.lua;lib/?/init.lua;" .. package.path

local RULE_MODULES = { 'rules' }

local RULESETS = { 'unit' }

local rules = require 'ur-proto' (RULE_MODULES, RULESETS)

local wait_time = 3

function PlayStageState:_init(stack)
  self:super(stack)
  self.stage = nil
  self.cursor = nil
  self.atlas = nil
  self.battlefield = nil
  self.player_units = nil
  self.wave = nil
  self.stats = nil
  self.monsters = nil
  self.max_wave = nil
  self.next_wave = nil
  self.n_monsters = nil
end

function PlayStageState:enter(params)
  self.stage = params.stage
  self:_load_view()
  self:_load_units()
end

function PlayStageState:leave()
  self:view('bg'):remove('battlefield')
  self:view('fg'):remove('atlas')
  self:view('bg'):remove('cursor')
  self:view('hud'):remove('stats')
end

function PlayStageState:_load_view()
  self.battlefield = BattleField()
  self.atlas = SpriteAtlas()
  self.cursor = Cursor(self.battlefield)
  local _, right, top, _ = self.battlefield.bounds:get()
  self.stats = Stats(Vec(right + 16, top))
  self.unit_selector = UnitSelector(self.stage.buyables, Vec(600, 400), self.atlas)
  self:view('bg'):add('battlefield', self.battlefield)
  self:view('fg'):add('atlas', self.atlas)
  self:view('bg'):add('cursor', self.cursor)
  self:view('hud'):add('stats', self.stats)
  self:view('us'):add('unit_selector', self.unit_selector)
end

function PlayStageState:_load_units()
  local pos = self.battlefield:tile_to_screen(-6, 6)
  local capital = self:_create_unit_at('capital', pos)
  self.player_units = {}
  self.player_units[capital] = true
  self.wave = Wave(self.stage.waves[1])
  self.max_wave = #self.stage.waves
  self.next_wave = 2
  self.wave:start(wait_time)
  self.stats:set_time(wait_time)
  self.monsters = {}
  self.n_monsters = 0
end

function PlayStageState:_create_unit_at(specname, pos)
  local unit = rules:new_unit(specname, pos)
  self.atlas:add(unit, unit:get_position(), unit:get_appearance())
  return unit
end

function PlayStageState:on_mousepressed(_, _, button)
  if button == 1 then
    local warrior = self:_create_unit_at('warrior', Vec(self.cursor:get_position()))
    self.player_units[warrior] = true
  end
end

function PlayStageState:update(dt)
  self.wave:update(dt)
  self.stats:update(dt)
  local pending = self.wave:poll()
  local rand = love.math.random
  if self.n_monsters == 0 and self.wave:is_finish() then
    if self.next_wave > self.max_wave then
      self:push("win", {self.battlefield, self.atlas})
    end
    self.wave = Wave(self.stage.waves[self.next_wave])
    self.wave:start(wait_time)
    self.stats:set_time(wait_time)
    self.next_wave = self.next_wave + 1
  end
  while pending > 0 do
    if not self.wave:is_finish() and not self.wave:initializing() then
      local x, y = rand(5, 7), -rand(5, 7)
      local pos = self.battlefield:tile_to_screen(x, y)
      local monster = self:_create_unit_at(self.wave:next_monster(), pos)
      self.monsters[monster] = true
      self.n_monsters = self.n_monsters + 1
    end
    pending = pending - 1
  end
  for monster in pairs(self.monsters) do
    monster:move(self.monsters, self.player_units, dt)
    local attacking_units = monster:in_range_of(self.player_units)
    for unit in pairs(attacking_units) do
      monster:damage(unit:get_power() * dt)
    end
    if monster:is_dead() then
      self.monsters[monster] = nil
      self.atlas:remove(monster)
      self.n_monsters = self.n_monsters - 1
    end
  end

  local has_capital = false
  for unit in pairs(self.player_units) do
    local attacking_monsters = unit:in_range_of(self.monsters)
    for monster in pairs(attacking_monsters) do
      unit:damage(monster:get_power() * dt)
    end
    if unit:is_dead() then
      self.player_units[unit] = nil
      self.atlas:remove(unit)
    end
    if unit:get_name() == "Capital" then
      has_capital = true
    end
  end
  if not has_capital then
    self:pop()
  end
end

function PlayStageState:resume(params)
  if params == 'win' then
    self:pop()
  end
end

return PlayStageState
