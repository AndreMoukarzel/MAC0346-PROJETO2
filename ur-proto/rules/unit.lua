return function (ruleset)

  local Vec = require 'common.vec'
  local r = ruleset.record

  r:new_property('unit', { appearance = "", max_hp = 1, hp = 1, power = 1, range = 1, speed = 0,
                           position = Vec() })

  function ruleset.define:new_unit(specname, initial_position)
    function self.when()
      return true
    end
    function self.apply()
      local e = ruleset:new_entity()
      local spec = require('database.units.' .. specname)
      r:set(e, 'named', { name = spec.name })
      r:set(e, 'unit', { appearance = spec.appearance, max_hp = spec.max_hp, hp = spec.max_hp,
                         power = spec.power or 1, range = spec.range or 1, speed = spec.speed or 0,
                         position = initial_position})
      return e
    end
  end

  function ruleset.define:get_name(e)
    function self.when()
      return r:is(e, 'named')
    end
    function self.apply()
      return r:get(e, 'named', 'name')
    end
  end

  function ruleset.define:get_appearance(e)
    function self.when()
      return r:is(e, 'unit')
    end
    function self.apply()
      return r:get(e, 'unit', 'appearance')
    end
  end

  function ruleset.define:get_power(e)
    function self.when()
      return r:is(e, 'unit')
    end
    function self.apply()
      return r:get(e, 'unit', 'power')
    end
  end

  function ruleset.define:get_range(e)
    function self.when()
      return r:is(e, 'unit')
    end
    function self.apply()
      return r:get(e, 'unit', 'range')
    end
  end

  function ruleset.define:get_hp(e)
    function self.when()
      return r:is(e, 'unit')
    end
    function self.apply()
      return r:get(e, 'unit', 'hp'), r:get(e, 'unit', 'max_hp')
    end
  end

  function ruleset.define:get_position(e)
    function self.when()
      return r:is(e, 'unit')
    end
    function self.apply()
      return r:get(e, 'unit', 'position')
    end
  end

  function ruleset.define:get_description(e)
    function self.when()
      return r:is(e, 'unit')
    end
    function self.apply()
      return ("%s (%d/%d unit)"):format(e.name, e.power, e.range)
    end
  end

  function ruleset.define:move(e, monsters, player_units, dt)
    function self.when()
      return r:is(e, 'unit') and r:get(e, 'unit', 'speed') > 0
    end
    function self.apply()
      local spd = r:get(e, 'unit', 'speed')
      local target = Vec(-7, -7)
      for unit in pairs(player_units) do
        if unit:get_name() == "Capital" then
          target = unit:get_position()
          break
        end
      end
      local movement = (target - e:get_position()):normalized() * spd * dt
      r:set(e, 'unit', { position = r:get(e, 'unit', 'position'):add(movement) })
    end
  end

  function ruleset.define:damage(e, damage)
    function self.when()
      return r:is(e, 'unit')
    end
    function self.apply()
      current_hp = r:get(e, 'unit', 'hp')
      r:set(e, 'unit', { hp = math.max(0, current_hp - damage) })
    end
  end

  function ruleset.define:in_range_of(e, player_units)
    function self.when()
      return r:is(e, 'unit')
    end
    function self.apply()
      local in_range_units = {}
      for unit in pairs(player_units) do
        local range = unit:get_range() * 32
        if (unit:get_position() - e:get_position()):length() <= range then
          in_range_units[unit] = true
        end
      end
      return in_range_units
    end
  end

  function ruleset.define:is_dead(e)
    function self.when()
      return r:is(e, 'unit')
    end
    function self.apply()
      return r:get(e, 'unit', 'hp') == 0
    end
  end

end
