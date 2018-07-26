return function()
	local validateMotor = require(script.Parent.validateMotor)

	local createSingleMotor = require(script.Parent.createSingleMotor)

	local identityGoal = {
		step = function(self, state, dt)
			return state
		end,
	}

	it("should be a valid motor", function()
		local motor = createSingleMotor(0, identityGoal)
		validateMotor(motor)
		motor:destroy()
	end)

	it("should invoke subscribers with new values", function()
		local motor = createSingleMotor(8, identityGoal)

		local callCount = 0
		local value
		local valuesLength
		local disconnect = motor:subscribe(function(...)
			callCount = callCount + 1
			value = (...)
			valuesLength = select("#", ...)
		end)

		expect(callCount).to.equal(0)

		motor:step(1)

		expect(callCount).to.equal(1)
		expect(valuesLength).to.equal(1)
		expect(value).to.equal(8)

		disconnect()

		motor:step(1)

		expect(callCount).to.equal(1)
	end)
end