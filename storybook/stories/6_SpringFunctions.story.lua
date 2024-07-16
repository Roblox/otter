local Packages = script.Parent.Parent.Parent
local ReactOtter = require(Packages._Workspace.ReactOtter.ReactOtter)
local React = require(Packages._Workspace.ReactOtter.React)

local function SpringFunction(props)
	local toggled, setToggled = React.useState(false)
	local value, setGoal = ReactOtter.useAnimatedBinding(0, function(value: number)
		-- print("Completed animation!", easingStyle)
	end)

	React.useEffect(function()
		setGoal(ReactOtter.spring(if toggled then 1 else 0, {
			damping = props.damping,
			stiffness = props.stiffness,
			mass = props.mass,
		}))
	end, { toggled })

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
	}, {
		ListLayout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 10),
		}),
		Label = React.createElement("TextButton", {
			Text = "Animate",
			TextSize = 18,
			Size = UDim2.new(0, 200, 0, 50),
			BackgroundColor3 = Color3.fromRGB(13, 160, 160),
			[React.Event.Activated] = function()
				setToggled(not toggled)
			end,
			LayoutOrder = 1,
		}),
		Progress = React.createElement("Frame", {
			Size = UDim2.new(0, 200, 0, 5),
			BackgroundColor3 = Color3.fromRGB(107, 69, 245),
			LayoutOrder = 2,
		}, {
			Indicator = React.createElement("Frame", {
				BackgroundColor3 = Color3.fromRGB(199, 130, 255),
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(14, 14),
				Position = value:map(function(percentage: number)
					return UDim2.new(percentage, 0, 0.5, 0)
				end),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ZIndex = 2,
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
			}),
		}),
	})
end

return {
	name = "Easing Functions",
	summary = "A frame that animates the background in based on a particular easing style when clicked",
	story = function(props)
		return SpringFunction(props.controls)
	end,
	controls = {
		damping = 20,
		stiffness = 400,
		mass = 1,
	},
}
