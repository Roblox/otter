--!strict
local types = require(script.Parent.Parent.types)
type Goal = types.Goal

-- test motion object that completes after step has been called numSteps times
local function createStepper(numSteps: number): Goal
	local stepCount = 0

	local function step(state, _dt)
		stepCount = stepCount + 1

		if stepCount >= numSteps then
			return {
				initialValue = state.initialValue,
				goal = state.goal,
				value = state.value,
				velocity = state.velocity,
				elapsed = state.elapsed,
				complete = true,
			}
		end

		return state
	end

	return setmetatable({
		step = step,
	}, {
		__index = function(_, key)
			error(("%q is not a valid member of stepper"):format(key))
		end,
	}) :: any
end

return createStepper
