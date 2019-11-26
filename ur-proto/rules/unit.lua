return function (ruleset)

  local Vec = require 'common.vec'
  local r = ruleset.record

  r:new_property('unit', { specname = "", hp, power = 1, range = 1, speed = 0, position = Vec() })

  function ruleset.define:new_unit(specname, initial_position)
    function self.when()
      return true
    end
    function self.apply()
      local e = ruleset:new_entity()
      local spec = require('database.units.' .. specname)
      r:set(e, 'named', { name = spec.name })
      r:set(e, 'unit', { specname = specname, hp = spec.max_hp, power = spec.power or 1,
                         range = spec.range or 1, speed = spec.speed or 0,
                         position = initial_position})
      return e
    end
  end

  function ruleset.define:get_appearance(e)
    function self.when()
      return r:is(e, 'unit')
    end
    function self.apply()
      local spec = require('database.units.' .. r:get(e, 'unit', 'specname'))
      return spec.appearance
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
      return r:get(e, 'unit', 'hp'), r:get(e, 'unit', 'spec').max_hp
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

  --[[
  function ruleset.define:is_dead(e)
    function self.when()
      return r:is(e, 'unit')
    end
    function self.apply()
      return e.toughness <= 0
    end
  end
  ]]

  function ruleset.define:get_description(e)
    function self.when()
      return r:is(e, 'unit')
    end
    function self.apply()
      return ("%s (%d/%d unit)"):format(e.name, e.power, e.range)
    end
  end

  function ruleset.define:move(e, all_units, dt)
    function self.when()
      return r:is(e, 'unit') and r:get(e, 'unit', 'speed') > 0
    end
    function self.apply()
      local spd = r:get(e, 'unit', 'speed')
      r:set(e, 'unit', { position = r:get(e, 'unit', 'position'):add(Vec(-spd, spd) * dt) })
    end
  end

end