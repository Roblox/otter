local Packages = script.Parent.Parent.Parent
local ReactOtter = require(Packages._Workspace.ReactOtter.ReactOtter)
local React = require(Packages._Workspace.ReactOtter.React)

local TRANSPARENCY_CONFIG = {
	dampingRatio = 1,
	frequency = 3,
}

local function FadeAndGrowIn()
	local visible, setVisible = React.useState(false)
	local animationState, setGoal = ReactOtter.useAnimatedBinding({
		transparency = 1,
		scale = 0.8,
	})

	React.useEffect(function()
		setGoal({
			transparency = ReactOtter.spring(if visible then 0 else 1, TRANSPARENCY_CONFIG),
			scale = ReactOtter.spring(if visible then 1 else 0.8),
		})
	end, { visible })

	return React.createElement(
		"Frame",
		{
			Size = UDim2.new(1, 0, 0, 250),
			BackgroundTransparency = 1,
		},
		React.createElement("TextButton", {
			Text = if visible then "Hide" else "Show",
			Size = UDim2.new(0, 200, 0, 50),
			TextSize = 14,
			[React.Event.Activated] = function()
				setVisible(not visible)
			end,
		}),
		React.createElement("TextLabel", {
			Text = "Content",
			BackgroundTransparency = animationState:map(function(state)
				return state.transparency
			end),
			TextTransparency = animationState:map(function(state)
				return state.transparency
			end),
			Size = animationState:map(function(state)
				return UDim2.new(1 * state.scale, 0, 0, 200 * state.scale)
			end),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 25),
		})
	)
end

return {
	name = "Animate Value",
	summary = "A button that animates the size of its text when clicked",
	story = FadeAndGrowIn,
}
