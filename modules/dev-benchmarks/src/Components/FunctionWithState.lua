--!strict
local Packages = script.Parent.Parent.Parent
local Otter = require(Packages.Otter)
local React = require(Packages.React)

local Buttons = require(script.Parent.Buttons)

local function FunctionWithState(props)
	local value, setValue = React.useState(0)
	local motor = React.useRef(nil :: Otter.SingleMotor?)
	if not motor.current then
		local newMotor = Otter.createSingleMotor(0)

		newMotor:onStep(setValue)
		newMotor:onComplete(props.onComplete)

		motor.current = newMotor
	end

	React.useEffect(function()
		assert(motor.current, "type checking")
		motor.current:setGoal(props.goal)
	end, { props.goal })

	local progress = value / props.stepCount

	return React.createElement("Frame", {
		Size = UDim2.new(0, 100, 0, 100),
		Position = UDim2.new(progress, 0, progress, 0),
	}, React.createElement(Buttons))
end

return FunctionWithState
