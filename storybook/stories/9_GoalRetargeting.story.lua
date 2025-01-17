local Packages = script.Parent.Parent.Parent
local ReactOtter = require(Packages._Workspace.ReactOtter.ReactOtter)
local React = require(Packages._Workspace.ReactOtter.React)

local GRAPH_SIZE = 400

local function Point(props)
	return React.createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(199, 130, 255),
		BorderSizePixel = 0,
		Size = props.size or UDim2.fromOffset(20, 20),
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
		Size = UDim2.new(0, GRAPH_SIZE, 0, GRAPH_SIZE),
		BackgroundTransparency = 0.8,
		LayoutOrder = 1,

		[React.Event.InputBegan] = function(rbx, input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and props.onGraphClick then
				local absolutePosition = input.Position
				local frameAbsolutePosition = rbx.AbsolutePosition
				local relativePosition = Vector2.new(
					absolutePosition.X - frameAbsolutePosition.X,
					absolutePosition.Y - frameAbsolutePosition.Y
				)
				props.onGraphClick(relativePosition)
			end
		end,
	}, {
		Point = React.createElement(Point, {
			position = props.position,
			size = UDim2.fromOffset(40, 40),
		}),
	})
end

local function EasingFunction(props)
	local animationState, setGoal = ReactOtter.useAnimatedBinding({
		x = 200,
		y = 200,
	})

	local x1 = math.clamp(props.InX, 0, 1)
	local x2 = math.clamp(props.OutX, 0, 1)
	local y1 = props.InY
	local y2 = props.OutY

	local EASE_CONFIG = {
		duration = props.duration,
		easingStyle = { x1, y1, x2, y2 },
	}

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
			onGraphClick = function(relativePosition)
				setGoal({
					x = ReactOtter.ease(relativePosition.x, EASE_CONFIG),
					y = ReactOtter.ease(relativePosition.y, EASE_CONFIG),
				})
			end,
			position = animationState:map(function(state)
				return UDim2.new(state.x / GRAPH_SIZE, 0, state.y / GRAPH_SIZE, 0)
			end),
		}),
	})
end

return {
	name = "Goal Retargeting",
	summary = "Demonstration of goal retargeting mid-animation.",
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
