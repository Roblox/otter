local Packages = script.Parent.Parent.Parent
local ReactOtter = require(Packages._Workspace.ReactOtter.ReactOtter)
local React = require(Packages._Workspace.ReactOtter.React)
local Dash = require(Packages._Workspace.ReactOtter.Dash)

local PROGRESS_TRANSPARENCY = 0.5
local OFFSET = 0.0001

local function ToggleTextSize(easingStyle: Enum.EasingStyle)
	local toggled, setToggled = React.useState(false)
	local value, setGoal = ReactOtter.useAnimatedBinding(0, function(value: number)
		print("Completed animation!", easingStyle)
	end)

	React.useEffect(function()
		setGoal(ReactOtter.ease(if toggled then 1 else 0, {
			duration = 2,
			easingStyle = easingStyle,
		}))
	end, { toggled })

	return React.createElement("TextButton", {
		Text = easingStyle.Name,
		TextSize = 22,
		Size = UDim2.new(0, 200, 0, 50),
		BackgroundColor3 = Color3.fromRGB(13, 160, 160),
		[React.Event.Activated] = function()
			setToggled(not toggled)
		end,
	}, {
		React.createElement("UIGradient", {
			Transparency = value:map(function(percentage: number)
				if percentage == 1 then
					return NumberSequence.new(0)
				elseif percentage == 0 then
					return NumberSequence.new(0.5)
				end

				local t1 = math.max(OFFSET, percentage - OFFSET)
				local t2 = percentage
				print(0, t1, t2, 1)

				local keypoints = {
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(t1, 0),
					NumberSequenceKeypoint.new(t2, PROGRESS_TRANSPARENCY),
					NumberSequenceKeypoint.new(1, PROGRESS_TRANSPARENCY),
				}

				table.sort(keypoints, function(a, b)
					return a.Time < b.Time
				end)
		
				return NumberSequence.new(keypoints)
			end),
		})
	})
end

return {
	name = "Easing Functions",
	summary = "A frame that animates the background in based on a particular easing style when clicked",
	stories = Dash.map(Enum.EasingStyle:GetEnumItems(), function(easingStyle)
		return {
			name = easingStyle.Name,
			story = function(props)
				return ToggleTextSize(easingStyle)
			end,
		}
	end),
}
