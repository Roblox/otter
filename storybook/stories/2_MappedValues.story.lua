local Packages = script.Parent.Parent.Parent
local ReactOtter = require(Packages._Workspace.ReactOtter.ReactOtter)
local React = require(Packages._Workspace.ReactOtter.React)

local function ExpandableFrame(props)
	local expanded, setExpanded = React.useState(false)
	local height, setGoal = ReactOtter.useAnimatedBinding(0)

	React.useEffect(function()
		setGoal(ReactOtter.spring(if expanded then 1 else 0))
	end, { expanded })

	return React.createElement(
		"Frame",
		{ Size = props.size },
		React.createElement("TextButton", {
			Text = if expanded then "Collapse" else "Expand",
			TextSize = 16,
			Size = UDim2.new(1, 0, 0, 40),
			[React.Event.Activated] = function()
				setExpanded(not expanded)
			end,
		}),
		React.createElement("Frame", {
			ClipsDescendants = true,
			Position = UDim2.new(0, 0, 0, 40),
			Size = height:map(function(value)
				return UDim2.new(1, 0, value, -40 * value)
			end),
		}, props.content)
	)
end

return {
	name = "Expandable Frame",
	summary = "A container with a clickable header that expands and collapses the contents",
	story = function(props)
		return React.createElement(ExpandableFrame, {
			size = UDim2.new(1, 0, 0, 300),
			content = React.createElement("TextLabel", {
				BackgroundColor3 = Color3.new(0.8, 0.8, 0.8),
				Size = UDim2.fromScale(1, 1),
				TextSize = 14,
				Text = "Here is some long text\n\n\n\n with newlines\n\n and whatnot, idk\n\n",
			}),
		})
	end,
}
