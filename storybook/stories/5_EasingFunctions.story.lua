local Packages = script.Parent.Parent.Parent
local ReactOtter = require(Packages._Workspace.ReactOtter.ReactOtter)
local React = require(Packages._Workspace.ReactOtter.React)
local Dash = require(Packages._Workspace.ReactOtter.Dash)

local function ToggleTextSize(easingStyle: Enum.EasingStyle)
	local toggled, setToggled = React.useState(false)
	local value, setGoal = ReactOtter.useAnimatedBinding(8, function(value: number)
		print("Completed animation!", easingStyle)
	end)

	React.useEffect(function()
		setGoal(ReactOtter.ease(if toggled then 24 else 8, {
			easingStyle = easingStyle,
		}))
	end, { toggled })

	return React.createElement("TextButton", {
		Text = "Hello",
		TextSize = value,
		Size = UDim2.new(0, 200, 0, 50),
		[React.Event.Activated] = function()
			setToggled(not toggled)
		end,
	})
end

return {
	name = "Easing Functions",
	summary = "A button that animates the size of its text when clicked based on a particular easing style",
	stories = Dash.map(Enum.EasingStyle:GetEnumItems(), function(easingStyle)
		return {
			name = easingStyle.Name,
			story = function(props)
				return ToggleTextSize(easingStyle)
			end,
		}
	end),
}
