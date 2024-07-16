--!strict
local Packages = script.Parent.Parent.Parent
local Otter = require(Packages.Otter)
local Roact = require(Packages.Roact)

local Buttons = require(script.Parent.Buttons)

local ClassWithBinding = Roact.Component:extend("ClassWithBinding")

function ClassWithBinding:init()
	local position, updatePosition = Roact.createBinding(0)

	self.position = position
	self.motor = Otter.createSingleMotor(0)

	self.motor:onStep(updatePosition)
	self.motor:onComplete(self.props.onComplete)
end

function ClassWithBinding:didMount()
	self.motor:setGoal(self.props.goal)
end

function ClassWithBinding:render()
	return Roact.createElement("Frame", {
		Size = UDim2.new(0, 100, 0, 100),
		Position = self.position:map(function(value: number)
			local progress = value / self.props.stepCount
			return UDim2.new(progress, 0, progress, 0)
		end),
	}, Roact.createElement(Buttons))
end

return ClassWithBinding
