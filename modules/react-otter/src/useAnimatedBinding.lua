--!strict
local Packages = script.Parent.Parent
local Otter = require(Packages.Otter)
local React = require(Packages.React)

-- FIXME: React should export this type
type Binding<T> = any

type Motor<G, V> = Otter.Motor<G, V>
type SetGoal<G> = (G) -> ()
type Callback<T> = (T) -> ()

type ValueGroup = { [string]: number }

local function useAnimatedBinding<V, G>(initialValue: V, onComplete: Callback<V>?): (Binding<V>, SetGoal<G>)
	local value, setValue = React.useBinding(initialValue)

	-- Initialize the motor and bound setGoal functions only once
	local motor = React.useRef(nil :: Motor<G, V>?)
	local boundSetGoal = React.useRef(nil :: SetGoal<G>?)

	if not motor.current then
		local newMotor: Motor<G, V>
		if typeof(initialValue) == "number" then
			newMotor = Otter.createSingleMotor(initialValue) :: any
		else
			newMotor = Otter.createGroupMotor((initialValue :: any) :: ValueGroup) :: any
		end
		newMotor:onStep(setValue)

		boundSetGoal.current = function(goal)
			newMotor:setGoal(goal)
		end
		motor.current = newMotor
	end

	-- If we're given a new `onComplete` function, unsubscribe the old one
	-- and subscribe the new one
	React.useEffect(function(): (() -> ())?
		if motor.current and onComplete then
			return (motor.current :: Motor<G, V>):onComplete(onComplete)
		end
		return nil
	end, { onComplete })

	-- Clean up the motor when we're done
	React.useEffect(function()
		return function()
			if motor.current then
				motor.current:destroy()
				motor.current = nil
			end
		end
	end, { motor.current })

	return value, boundSetGoal.current :: SetGoal<G>
end

return useAnimatedBinding
