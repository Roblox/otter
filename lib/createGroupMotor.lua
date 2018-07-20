local RunService = game:GetService("RunService")

local join = require(script.Parent.join)
local createSignal = require(script.Parent.createSignal)

local GroupMotor = {}
GroupMotor.prototype = {}
GroupMotor.__index = GroupMotor.prototype

local function createGroupMotor(initialValues, goals)
	local states = {}

	for key in pairs(goals) do
		local initialValue = initialValues[key]

		if initialValue == nil then
			local message = ("Missing initial value %q")
			error(message, 2)
		end

		states[key] = {
			position = initialValue,
			complete = false,
		}
	end

	local self = {
		__goals = goals,
		__states = states,
		__allComplete = false,
		__signal = createSignal(),
	}

	setmetatable(self, GroupMotor.prototype)

	return self
end

function GroupMotor.prototype:run()
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
	local allComplete = true

	for key, goal in pairs(self.__goals) do
		if not self.__states[key].complete then
			local newState = goal:step(self.__states[key], dt)

			if not newState.complete then
				allComplete = false
			end

			self.__states[key] = newState
		end
	end

	self.__allComplete = allComplete
	self.__signal:fire(self.__states)
end

function GroupMotor.prototype:setGoal(goals)
	self.__goals = join(self.__goals, goals)

	for key in pairs(goals) do
		self.__states[key].complete = false
	end
	self.__allComplete = false
end

function GroupMotor.prototype:subscribe(callback)
	self.__signal:subscribe(callback)
end

function GroupMotor.prototype:destroy()
	self:stop()
end

return createGroupMotor