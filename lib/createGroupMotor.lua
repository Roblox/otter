local RunService = game:GetService("RunService")

local join = require(script.Parent.join)
local createSignal = require(script.Parent.createSignal)

local GroupMotor = {}
GroupMotor.prototype = {}
GroupMotor.__index = GroupMotor.prototype

local function createGroupMotor(initialValues, goals)
	assert(typeof(initialValues) == "table")
	assert(typeof(goals) == "table")

	local states = {}

	for key in pairs(goals) do
		local initialValue = initialValues[key]

		if initialValue == nil then
			local message = ("Missing initial value %q")
			error(message, 2)
		end

		states[key] = {
			value = initialValue,
			complete = false,
		}
	end

	local self = {
		__goals = goals,
		__states = states,
		__allComplete = false,
		__signal = createSignal(),
	}

	setmetatable(self, GroupMotor)

	return self
end

function GroupMotor.prototype:start()
	self.__connection = RunService.RenderStepped:Connect(function(dt)
		if self.__allComplete then
			return
		end

		self:step(dt)
	end)
end

function GroupMotor.prototype:stop()
	if self.__connection ~= nil then
		self.__connection:Destroy()
	end
end

function GroupMotor.prototype:step(dt)
	assert(typeof(dt) == "number")

	local allComplete = true
	local values = {}

	for key, goal in pairs(self.__goals) do
		local state = self.__states[key]

		if not state.complete then
			local newState = goal:step(state, dt)

			if newState == nil then
				newState = state
			else
				state = newState
			end

			if not newState.complete then
				allComplete = false
			end

			self.__states[key] = newState
		end

		values[key] = state.value
	end

	self.__allComplete = allComplete
	self.__signal:fire(values)
end

function GroupMotor.prototype:setGoal(goals)
	assert(typeof(goals) == "table")

	self.__goals = join(self.__goals, goals)

	for key in pairs(goals) do
		self.__states[key].complete = false
	end
	self.__allComplete = false
end

function GroupMotor.prototype:subscribe(callback)
	assert(typeof(callback) == "function")

	self.__signal:subscribe(callback)
end

function GroupMotor.prototype:destroy()
	self:stop()
end

return createGroupMotor