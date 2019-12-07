
local Wave = require 'model.wave'
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

local RULESETS = { 'unit', 'money'}

local rules = require 'ur-proto' (RULE_MODULES, RULESETS)

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
  self.wait_time = 0
  self.time_left = 0
  self.buyables = nil
  self.selected_unit = 0
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
  self:view('us'):remove('unit_selector')
  self:view('bg'):remove('buyables_cursor')
end

function PlayStageState:_load_view()
  self.battlefield = BattleField()
  self.atlas = SpriteAtlas()
  self.cursor = Cursor(self.battlefield, 'mouse')
  local _, right, top, _ = self.battlefield.bounds:get()
  self.stats = Stats(Vec(right + 16, top))
  self.money = rules:new_money()
  rules:set_money_amount(self.money, self.stage.starting_money)
  self.stats = Stats(Vec(right + 16, top), rules, self.money)
  self.wait_time = 3
  self.time_left = self.wait_time
  self.stats:set_time(self.time_left)
  self.unit_selector = UnitSelector(self.stage.buyables, Vec(600, 400), self.atlas)
  self.buyables_cursor = Cursor(self.unit_selector, 'keyboard')
  local pos = self.unit_selector:get_pos(1)
  self.buyables_cursor:set_pos(pos)
  self:view('bg'):add('battlefield', self.battlefield)
  self:view('fg'):add('atlas', self.atlas)
  self:view('bg'):add('cursor', self.cursor)
  self:view('hud'):add('stats', self.stats)
  self:view('us'):add('unit_selector', self.unit_selector)
  self:view('bg'):add('buyables_cursor', self.buyables_cursor)
end

function PlayStageState:_load_units()
  local pos = self.battlefield:tile_to_screen(-6, 6)
  local capital = self:_create_unit_at('capital', pos)
  self.player_units = {}
  self.player_units[capital] = true
  self.wave = Wave(self.stage.waves[1])
  self.max_wave = #self.stage.waves
  self.next_wave = 2
  self.wave:start()
  self.monsters = {}
  self.n_monsters = 0
  self.selected_unit = 1
  self.buyables = self.stage.buyables

end

function PlayStageState:_create_unit_at(specname, pos)
  local unit = rules:new_unit(specname, pos)
  self.atlas:add(unit, unit:get_position(), unit:get_appearance())
  return unit
end

function PlayStageState:on_keypressed(key)
  if key == 'down' or key == 's' then
    self.selected_unit = self.selected_unit % #self.buyables + 1
  elseif key == 'up' or key == 'w' then
    self.selected_unit = (self.selected_unit - 2)  % #self.buyables + 1
  end
  local pos = self.unit_selector:get_pos(self.selected_unit)
  self.buyables_cursor:set_pos(pos)
end

function PlayStageState:on_mousepressed(_, _, button)
  if button == 1 then
    if(rules:spend_money_amount(self.money, 10)) then
      local selected_unit = self.buyables[self.selected_unit]
      local new_unit = self:_create_unit_at(selected_unit, Vec(self.cursor:get_position()))
      self.player_units[new_unit] = true
    end
  end
end

function PlayStageState:update(dt)
  if self.time_left <= 0 then
    if self.n_monsters == 0 and self.wave:is_finish() then
      if self.next_wave > self.max_wave then
        self:push("end", {b = self.battlefield, atlas = self.atlas, visual = 'trophy'})
      else
        self.wave = Wave(self.stage.waves[self.next_wave])
        self.next_wave = self.next_wave + 1
        self.wave:start()
        self.time_left = self.wait_time
        self.stats:set_time(self.time_left)
        return
      end
    end
    self.wave:update(dt)
    local pending = self.wave:poll()
    while pending > 0 do
      if not self.wave:is_finish() then
        local rand = love.math.random
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
      unit:generate_money(self.money)
    end
    if not has_capital then
      self:push("end", {b = self.battlefield, atlas = self.atlas, visual = 'skull'})
    end
  else
    self.time_left = self.time_left - dt
    self.stats:set_time(self.time_left)
  end
end

function PlayStageState:resume()
  self:pop()
end

return PlayStageState
