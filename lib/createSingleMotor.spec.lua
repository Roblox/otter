return function()
	local validateMotor = require(script.Parent.validateMotor)

	local createSingleMotor = require(script.Parent.createSingleMotor)

	local goal = {
		step = function()
		end,
	}

	it("should be a valid motor", function()
		local motor = createSingleMotor(0, goal)
		validateMotor(motor)
		motor:destroy()
	end)
end