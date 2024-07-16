local Packages = script.Parent.Parent.Parent
local ReactOtter = require(Packages._Workspace.ReactOtter.ReactOtter)
local React = require(Packages._Workspace.ReactOtter.React)

local SPRING_CONFIG = {
	dampingRatio = 1,
	frequency = 3,
}

local function DisabledWhileAnimating()
	local enabled, setEnabled = React.useState(false)
	local translated, setTranslated = React.useState(false)
	local x, setGoal = ReactOtter.useAnimatedBinding(0, function()
		setEnabled(true)
	end)

	React.useEffect(function()
		setGoal(ReactOtter.spring(if translated then 1 else 0), SPRING_CONFIG)
		setEnabled(false)
	end, { translated })

	return React.createElement(
		"Frame",
		{
			Size = UDim2.new(1, 0, 0, 200),
			BackgroundTransparency = 1,
		},
		React.createElement("TextButton", {
			Text = if enabled then "Click me" else "don't click >:(",
			BackgroundColor3 = if enabled then Color3.new(0.6, 1, 0.6) else Color3.new(0.6, 0.6, 0.6),
			Active = enabled,
			TextSize = 16,
			Size = UDim2.new(0, 150, 0, 50),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = x:map(function(value)
				return UDim2.new(value, -150 * value, 0.5, 0)
			end),
			[React.Event.Activated] = function()
				setTranslated(not translated)
			end,
		})
	)
end

return {
	name = "On Complete",
	summary = "A button that becomes non-interactive while its animation is in-progress",
	story = DisabledWhileAnimating,
}
