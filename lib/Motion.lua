local RunService = game:GetService("RunService")

local Motion = {}
Motion.prototype = {}
Motion.__index = Motion.prototype

function Motion.new(options)
	assert(typeof(options) == "table")

	local kind = options.kind
	local callback = options.callback
	local onComplete = options.onComplete

	assert(typeof(kind) == "table")
	assert(typeof(callback) == "function")
	assert(typeof(onComplete) == "function" or onComplete == nil)

	local self = {
		__kind = options.kind,
		__callback = options.callback,
		__connection = nil,
		isComplete = false,
	}

	setmetatable(self, Motion)

	self.__connection = RunService.RenderStepped:Connect(function(dt)
		if self.isComplete then
			return
		end

		self.isComplete = self.__kind:step(dt)
		self.__callback(self.__kind:getValue())

		if self.isComplete and onComplete ~= nil then
			onComplete()
		end
	end)

	return self
end

function Motion.prototype:setGoal(...)
	self.isComplete = false
	self.__kind:setGoal(...)
end

function Motion.prototype:destroy()
	if self.__connection == nil then
		error("Motion has already been destroyed!", 2)
	end

	self.__connection:Disconnect()
	self.__connection = nil
end

return Motion