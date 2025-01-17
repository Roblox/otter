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
		Size = UDim2.new(0, 200, 0, 200),
		BackgroundTransparency = 1.0,
		LayoutOrder = 1,
	}, {
		Path = React.createElement("Path2D", {
			ref = props.pathRef,
			Closed = true,
			Color3 = Color3.fromRGB(107, 69, 245),
			Thickness = 6,
			Visible = true,
		}),
		ControlPoint1 = React.createElement(Point, {
			position = UDim2.new(0, 0, 0, props.graphSize), -- Start at bottom-left
			graphSize = props.graphSize,
		}),
		ControlPoint2 = React.createElement(Point, {
			position = UDim2.new(0, props.graphSize, 0, 0), -- Start at top-right
			graphSize = props.graphSize,
		}),

		Point3 = React.createElement(Point, {
			position = props.currentPosition,
			graphSize = props.graphSize,
			size = UDim2.fromOffset(20, 20),
		}),
	})
end

local function EasingFunction(props)
	local toggled, setToggled = React.useState(false)
	local value, setGoal = ReactOtter.useAnimatedBinding(0)
	local pathRef = React.useRef()
	local graphSize = 200

	local x1 = math.clamp(props.InX, 0, 1)
	local x2 = math.clamp(props.OutX, 0, 1)
	local y1 = props.InY
	local y2 = props.OutY

	React.useEffect(function()
		local path = pathRef.current
		if path then
			local cx1 = x1 * graphSize
			local cy1 = 0 + (y1 * -graphSize) -- Start at parent y (0) and offset down

			local cx2 = -((1 - x2) * graphSize)
			local cy2 = graphSize + (y2 * -graphSize) -- Start at parent y (-100) and offset down

			local points = {
				-- First control point
				Path2DControlPoint.new(
					UDim2.new(0, 0, 0, graphSize), -- Position
					UDim2.new(0, 0, 0, 0), -- Left tangent
					UDim2.new(0, cx1, 0, cy1) -- Right tangent
				),
				-- Second control point
				Path2DControlPoint.new(
					UDim2.new(0, graphSize, 0, 0), -- Position
					UDim2.new(0, cx2, 0, cy2), -- Left tangent relative to (100,-100)
					UDim2.new(0, graphSize, 0, -graphSize) -- Right tangent at point's position
				),
			}
			path:SetControlPoints(points)
		end
	end, { x1, y1, x2, y2 })

	React.useEffect(function()
		setGoal(ReactOtter.ease(if toggled then 1 else 0, {
			duration = props.duration,
			easingStyle = { x1, y1, x2, y2 },
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
			Padding = UDim.new(0, 20),
		}),
		Spacer = React.createElement("Frame", {
			Size = UDim2.fromOffset(10, 20),
			BackgroundTransparency = 1,
		}),
		Graph = React.createElement(Graph, {
			pathRef = pathRef,
			graphSize = graphSize,
			currentPosition = value:map(function(percentage: number)
				if pathRef.current then
					local point = pathRef.current:GetPositionOnCurve(percentage)
					--print("Return type:", typeof(point), "Value:", point)  -- Debug the return value type
					if point then
						if typeof(point) == "UDim2" then
							return point
						elseif typeof(point) == "table" and point[1] then
							return UDim2.fromScale(point[1].X, point[1].Y)
						end
					end
				end
				return UDim2.new(0, 0, 0, 0)
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
