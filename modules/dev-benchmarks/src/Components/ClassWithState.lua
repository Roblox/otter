--!strict
local Packages = script.Parent.Parent.Parent
local Otter = require(Packages.Otter)
local React = require(Packages.React)

local Buttons = require(script.Parent.Buttons)

local ClassWithState = React.Component:extend("ClassWithState")

function ClassWithState:init()
	self:setState({
		position = UDim2.new(0, 0, 0, 0),
	})

	self.motor = Otter.createSingleMotor(0)

	self.motor:onStep(function(value: number)
		self:setState(function()
			local progress = value / self.props.stepCount
			return {
				position = UDim2.new(progress, 0, progress, 0),
			}
		end)
	end)
	self.motor:onComplete(self.props.onComplete)
end

function ClassWithState:componentDidMount()
	self.motor:setGoal(self.props.goal)
end

function ClassWithState:render()
	return React.createElement("Frame", {
		Size = UDim2.new(0, 100, 0, 100),
		Position = self.state.position,
	}, React.createElement(Buttons))
end

return ClassWithState
