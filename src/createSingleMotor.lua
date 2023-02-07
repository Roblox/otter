--!strict
local Packages = script.Parent.Parent
local RunService = game:GetService("RunService")

local createSignal = require(Packages.Signal).createSignal

local SingleMotor = {}
SingleMotor.prototype = {}
SingleMotor.__index = SingleMotor.prototype

local function createSingleMotor(initialValue: number)
	local onComplete, fireOnComplete = createSignal()
	local onStep, fireOnStep = createSignal()

	local self = {
		__goal = nil,
		__state = {
			value = initialValue,
			complete = true,
		},
		__onComplete = onComplete,
		__fireOnComplete = fireOnComplete,
		__onStep = onStep,
		__fireOnStep = fireOnStep,
		__running = false,
	}

	setmetatable(self, SingleMotor)

	return self
end

function SingleMotor.prototype:start()
	if self.__running then
		return
	end

	self.__connection = RunService.Heartbeat:Connect(function(dt)
		self:step(dt)
	end)

	self.__running = true
end

function SingleMotor.prototype:stop()
	if self.__connection ~= nil then
		self.__connection:Disconnect()
	end

	self.__running = false
end

function SingleMotor.prototype:step(dt)
	assert(typeof(dt) == "number")

	if self.__state.complete then
		return
	end

	if self.__goal == nil then
		return
	end

	local newState = self.__goal:step(self.__state, dt)

	if newState ~= nil then
		self.__state = newState
	end

	self.__fireOnStep(self.__state.value)

	if self.__state.complete and self.__running then
		self:stop()
		self.__fireOnComplete(self.__state.value)
	end
end

function SingleMotor.prototype:setGoal(goal)
	self.__goal = goal
	self.__state.complete = false
	self:start()
end

function SingleMotor.prototype:onStep(callback)
	assert(typeof(callback) == "function")

	local subscription = self.__onStep:subscribe(callback)

	return function()
		subscription:unsubscribe()
	end
end

function SingleMotor.prototype:onComplete(callback)
	assert(typeof(callback) == "function")

	local subscription = self.__onComplete:subscribe(callback)

	return function()
		subscription:unsubscribe()
	end
end

function SingleMotor.prototype:destroy()
	self:stop()
end

return createSingleMotor
