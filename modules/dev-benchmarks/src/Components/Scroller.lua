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

	local size = if props.level % 2 == 0 then UDim2.fromOffset(1 / 3, 1) else UDim2.fromOffset(1, 1 / 3)

	return React.createElement("Frame", {
		Size = props.Size,
		LayoutOrder = props.LayoutOrder,
	}, {
		layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = if (props.level :: number) % 2 == 0
				then Enum.FillDirection.Horizontal
				else Enum.FillDirection.Vertical,
		}),
		Child1 = React.createElement(ComplexChild, {
			level = props.level - 1,
			LayoutOrder = 1,
			Size = size,
		}),
		Child2 = React.createElement(ComplexChild, {
			level = props.level - 1,
			LayoutOrder = 2,
			Size = size,
		}),
		Child3 = React.createElement(ComplexChild, {
			level = props.level - 1,
			LayoutOrder = 3,
			Size = size,
		}),
	})
end

local function Scroller(props): React.ReactElement<any>
	local animationValue, setGoal = ReactOtter.useAnimatedBinding(0, props.onComplete)

	local children = React.useMemo(function()
		local c = {} :: { React.React_Node }
		for i = 1, 200 do
			table.insert(
				c,
				React.createElement(ComplexChild, {
					Size = UDim2.new(1, 0, 0, 200),
					key = `child_{i}`,
					LayoutOrder = i,
					level = 6,
				})
			)
		end
		return c
	end, {})

	React.useEffect(function()
		setGoal(
			ReactOtter.spring(
				props.goal,
				{ dampingRatio = 1, frequency = 0.3, restingVelocityLimit = 100, restingPositionLimit = 10 }
			)
		)
	end, { props.goal })

	return React.createElement(
		"ScrollingFrame",
		{
			Size = UDim2.new(1, 0, 0, 200),
			CanvasPosition = animationValue:map(function(value: number)
				return Vector2.new(0, value)
			end),
			CanvasSize = UDim2.new(1, 0, 0, 4000),
		},
		React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			key = "layout",
		}, children)
	)
end

return Scroller
