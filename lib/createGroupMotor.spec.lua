return function()
	local validateMotor = require(script.Parent.validateMotor)

	local createGroupMotor = require(script.Parent.createGroupMotor)

	it("should be a valid motor", function()
		local motor = createGroupMotor({}, {})
		validateMotor(motor)
		motor:destroy()
	end)
end