--!strict
local Packages = script.Parent.Parent.Parent
local React = require(Packages.React)
local ReactOtter = require(Packages.ReactOtter)

local function ComplexChild(props: { LayoutOrder: number, level: number, Size: UDim2 }): React.ReactElement<any>
	if props.level == 1 then
		return React.createElement("TextLabel", {
			Text = "a",
			Size = props.Size,
			LayoutOrder = props.LayoutOrder,
		})
	end

	local children = React.useMemo(function()
		local grid = {} :: { [string]: React.React_Node? }

		grid["layout"] = React.createElement("UIGridLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirectionMaxCells = 3,
			FillDirection = Enum.FillDirection.Horizontal,
			CellSize = UDim2.fromScale(1 / 3, 1 / 3),
			CellPadding = UDim2.fromOffset(0, 0),
		})
		for i = 1, 9 do
			grid[`Child{i}`] = React.createElement(ComplexChild, {
				LayoutOrder = i,
				level = props.level - 1,
				Size = UDim2.new(1, 0, 1, 0),
			})
		end
		return grid
	end, {})

	return React.createElement("Frame", {
		Size = props.Size,
		LayoutOrder = props.LayoutOrder,
	}, children)
end

local function Resizer(props)
	local animationValue, setGoal = ReactOtter.useAnimatedBinding(0, props.onComplete)

	React.useEffect(function()
		setGoal(
			ReactOtter.spring(
				props.goal,
				{ dampingRatio = 1, frequency = 0.1, restingVelocityLimit = 100, restingPositionLimit = 10 }
			)
		)
	end, { props.goal })

	return React.createElement(
		"Frame",
		{
			Size = animationValue:map(function(sideLength)
				return UDim2.fromOffset(sideLength, sideLength)
			end),
		},
		React.createElement(ComplexChild, {
			key = "ComplexChild",
			Size = UDim2.new(1, 0, 1, 0),
			level = 5,
			LayoutOrder = 0,
		})
	)
end

return Resizer
