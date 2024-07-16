--!strict
local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local function Buttons(_)
	return Roact.createFragment({
		Left = Roact.createElement("TextButton", {
			Text = "Example",
			Size = UDim2.fromScale(0.5, 1),
		}),
		Right = Roact.createElement("TextButton", {
			Text = "Buttons",
			Size = UDim2.fromScale(0.5, 1),
			Position = UDim2.fromScale(0.5, 0),
		}),
	})
end

return Buttons
