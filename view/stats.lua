
local Stats = require 'common.class' ()

function Stats:_init(position, rules, money)
  self.time_left = 0
  self.rules = rules
  self.money = money
  self.position = position
  self.font = love.graphics.newFont('assets/fonts/VT323-Regular.ttf', 36)
  self.font:setFilter('nearest', 'nearest')
end

function Stats:set_time(time)
  self.time_left = time
end

function Stats:update(dt)
  if self.time_left > 0 then
    self.time_left = self.time_left - dt
  end
end

function Stats:draw()
  local g = love.graphics
  g.push()
  g.setFont(self.font)
  g.setColor(1, 1, 1)
  g.translate(self.position:get())
  g.print(("Gild %d"):format(self.rules:get_money_amount(self.money)))
  if self.time_left > 0 then
    g.print(("\nNext wave starting in... %d"):format(self.time_left))
  end
  g.translate(0, self.font:getHeight())
  g.pop()
end

return Stats

