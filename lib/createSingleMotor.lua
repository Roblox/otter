local RunService = game:GetService("RunService")

local createSignal = require(script.Parent.createSignal)

local SingleMotor = {}
SingleMotor.prototype = {}
SingleMotor.__index = SingleMotor.prototype

local function createSingleMotor(initialValue, goal)
	local self = {
		__goal = goal,
		__state = {
			value = initialValue,
			complete = false,
		},
		__signal = createSignal(),
	}

	setmetatable(self, SingleMotor.prototype)

	return self
end

function SingleMotor.prototype:run()
	self.__connection = RunService.RenderStepped:Connect(function(dt)
		if self.__state.complete then
			return
		end

		self:step(dt)
	end)
end

function SingleMotor.prototype:stop()
	if self.__connection ~= nil then
		self.__connection:Destroy()
	end
end

function SingleMotor.prototype:step(dt)
	self.__state = self.__goal:step(self.__state, dt)

	self.__signal:fire(self.__state.value)
end

function SingleMotor.prototype:setGoal(goal)
	self.__goal = goal
	self.__state.complete = false
end

function SingleMotor.prototype:subscribe(callback)
	return self.__signal:subscribe(callback)
end

function SingleMotor.prototype:destroy()
	self:stop()
end

return createSingleMotor