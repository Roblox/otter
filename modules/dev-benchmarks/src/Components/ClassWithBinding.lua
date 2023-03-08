--!strict
local Packages = script.Parent.Parent.Parent
local Otter = require(Packages.Otter)
local React = require(Packages.React)

local Buttons = require(script.Parent.Buttons)

local ClassWithBinding = React.Component:extend("ClassWithBinding")

function ClassWithBinding:init()
	local position, updatePosition = React.createBinding(0)

	self.position = position
	self.motor = Otter.createSingleMotor(0)

	self.motor:onStep(updatePosition)
	self.motor:onComplete(self.props.onComplete)
end

function ClassWithBinding:componentDidMount()
	self.motor:setGoal(self.props.goal)
end

function ClassWithBinding:render()
	return React.createElement("Frame", {
		Size = UDim2.new(0, 100, 0, 100),
		Position = self.position:map(function(value: number)
			local progress = value / self.props.stepCount
			return UDim2.new(progress, 0, progress, 0)
		end),
	}, React.createElement(Buttons))
end

return ClassWithBinding
