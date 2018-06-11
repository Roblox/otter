local RunService = game:GetService("RunService")

local Motion = {}
Motion.prototype = {}
Motion.__index = Motion.prototype

function Motion.new(options)
	assert(typeof(options) == "table")

	local kind = options.kind
	local callback = options.callback

	assert(typeof(kind) == "table")
	assert(typeof(callback) == "function")

	local self = {
		__kind = options.kind,
		__callback = options.callback,
		__connection = nil,
	}

	setmetatable(self, Motion)

	self.__connection = RunService.RenderStepped:Connect(function(dt)
		self.__kind:step(dt)
		self.__callback(self.__kind:getValue())
	end)

	return self
end

function Motion.prototype:setGoal(...)
	self.__kind:setGoal(...)
end

function Motion.prototype:destruct()
	if self.__connection == nil then
		error("Motion has already been destructed!", 2)
	end

	self.__connection:Disconnect()
	self.__connection = nil
end

return Motion