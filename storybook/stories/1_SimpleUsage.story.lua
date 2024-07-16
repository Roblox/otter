local Packages = script.Parent.Parent.Parent
local ReactOtter = require(Packages._Workspace.ReactOtter.ReactOtter)
local React = require(Packages._Workspace.ReactOtter.React)

local function ToggleTextSize()
	local toggled, setToggled = React.useState(false)
	local value, setGoal = ReactOtter.useAnimatedBinding(8)

	React.useEffect(function()
		setGoal(ReactOtter.spring(if toggled then 24 else 8))
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
	name = "Animate Value",
	summary = "A button that animates the size of its text when clicked",
	story = ToggleTextSize,
}
