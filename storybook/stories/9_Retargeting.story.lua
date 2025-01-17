local Packages = script.Parent.Parent.Parent
local ReactOtter = require(Packages._Workspace.ReactOtter.ReactOtter)
local React = require(Packages._Workspace.ReactOtter.React)

local function Point(props)
	return React.createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(199, 130, 255),
		BorderSizePixel = 0,
		Size = props.size or UDim2.fromOffset(10, 10),
		Position = props.position,
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 2,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
	})
end

local function Graph(props)
	return React.createElement("Frame", {
		Size = UDim2.new(0, 400, 0, 400),
		BackgroundTransparency = 0.8,
		LayoutOrder = 1,

		[React.Event.InputBegan] = function(rbx, input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local absolutePosition = input.Position
				local frameAbsolutePosition = rbx.AbsolutePosition

				local relativeX = absolutePosition.X - frameAbsolutePosition.X
				local relativeY = absolutePosition.Y - frameAbsolutePosition.Y

				if props.onGraphClick then
					props.onGraphClick(Vector2.new(relativeX, relativeY))
				end
			end
		end,
	}, {
		Point = React.createElement(Point, {
			position = props.currentPositionX,
			graphSize = props.graphSize,
			size = UDim2.fromOffset(20, 20),
		}),
	})
end

local function EasingFunction(props)
	local positionX, setGoalX = ReactOtter.useAnimatedBinding(0)
	local positionY, setGoalY = ReactOtter.useAnimatedBinding(0)
	local pathRef = React.useRef()
	local graphSize = 200

	local x1 = math.clamp(props.InX, 0, 1)
	local x2 = math.clamp(props.OutX, 0, 1)
	local y1 = props.InY
	local y2 = props.OutY

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
			Padding = UDim.new(0, 20),
		}),
		Spacer = React.createElement("Frame", {
			Size = UDim2.fromOffset(10, 20),
			BackgroundTransparency = 1,
		}),
		Graph = React.createElement(Graph, {
			pathRef = pathRef,
			graphSize = graphSize,
			onGraphClick = function(relativePosition)
				local easeConfig = {
					duration = props.duration,
					easingStyle = { x1, y1, x2, y2 },
				}

				setGoalX(ReactOtter.ease(relativePosition.X, easeConfig))
			end,
			currentPositionX = positionX:map(function(percentage: number)
				return UDim2.new(percentage / 400, 0, 0.5, 0)
			end),
		}),
		Label = React.createElement("TextButton", {
			Text = "Cubic Bezier",
			TextSize = 18,
			Size = UDim2.new(0, 200, 0, 50),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			[React.Event.Activated] = function()
				setToggled(function(prev)
					return not prev
				end)
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
				Position = positionX:map(function(percentage: number)
					return UDim2.new(percentage / 400, 0, 0.5, 0)
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
	name = "Cubic Bezier Easing",
	summary = "Implementation of cubic-bezier easing.",
	story = function(props)
		return React.createElement(EasingFunction, props.controls)
	end,
	controls = {
		InX = 0.2,
		InY = 0.0,
		OutX = 0.0,
		OutY = 1.0,
		duration = 1.0,
	},
}
