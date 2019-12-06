
local Wave = require 'common.class' ()

function Wave:_init(spawns)
  self.spawns = spawns
  self.delay = 3
  self.left = nil
  self.pending = 0
  self.current_monster = 1
end

function Wave:start()
  self.left = self.delay
end

function Wave:update(dt)
  self.left = self.left - dt
  if self.left <= 0 then
    self.left = self.left + self.delay
    self.pending = self.pending + 1
  end
end

function Wave:poll()
  local pending = self.pending
  self.pending = 0
  return pending
end

function Wave:is_finish()
  return self.current_monster == #self.spawns and self.spawns[self.current_monster][2] == 0
end

function Wave:initializing()
  return self.initial_wait_time > 0
end

function Wave:next_monster()
  if self.spawns[self.current_monster][2] == 0 then
    self.current_monster = self.current_monster + 1
  end
  self.spawns[self.current_monster][2] = self.spawns[self.current_monster][2] - 1
  return self.spawns[self.current_monster][1]
end
return Wave
