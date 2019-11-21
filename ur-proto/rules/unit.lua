return function (ruleset)

  local r = ruleset.record

  r:new_property('unit', { power = 1, range = 1, speed = 0 })

  function ruleset.define:new_creature(name, power, range, speed)
    function self.when()
      return true
    end
    function self.apply()
      local e = ruleset:new_entity()
      r:set(e, 'named', { name = name })
      r:set(e, 'creature', { power = power, range = range, speed = speed or 0 })
      return e
    end
  end

  function ruleset.define:get_power(e)
    function self.when()
      return r:is(e, 'creature')
    end
    function self.apply()
      return r:get(e, 'creature', 'power')
    end
  end

  function ruleset.define:get_range(e)
    function self.when()
      return r:is(e, 'creature')
    end
    function self.apply()
      return r:get(e, 'creature', 'range')
    end
  end

  --[[
  function ruleset.define:is_dead(e)
    function self.when()
      return r:is(e, 'creature')
    end
    function self.apply()
      return e.toughness <= 0
    end
  end
  ]]

  function ruleset.define:get_description(e)
    function self.when()
      return r:is(e, 'creature')
    end
    function self.apply()
      return ("%s (%d/%d creature)"):format(e.name, e.power, e.range)
    end
  end

end
