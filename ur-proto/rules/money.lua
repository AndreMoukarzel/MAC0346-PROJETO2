return function (ruleset)

  local r = ruleset.record

  r:new_property('money', { amount = 1000 })

  function ruleset.define:new_money()
  	function self.when()
      return true
    end
    function self.apply()
    	local e = ruleset:new_entity()
    	r:set(e, 'money', { amount = 1000})
    	return e
    end
  end

  function ruleset.define:get_money_amount(e)
  	function self.when()
      return r:is(e, 'money')
    end
    function self.apply()
    	return r:get(e, 'money', 'amount')
    end
  end

  function ruleset.define:set_money_amount(e, value)
    function self.when()
      return r:is(e, 'money')
  	end
    function self.apply()
    	r:set(e, 'money', { amount = value })
    end
  end

  function ruleset.define:gain_money_amount(e, value)
    function self.when()
      return r:is(e, 'money')
  	end
    function self.apply()
      r:set(e, 'money', { amount = r:get(e, 'money', 'amount') + value})
      return true
    end
  end  

  function ruleset.define:spend_money_amount(e, value)
    function self.when()
      return r:get(e, 'money', 'amount') - value >= 0
  	end
    function self.apply()
      r:set(e, 'money', { amount = r:get(e, 'money', 'amount') - value})
      return true
    end
  end
end