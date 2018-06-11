--[[
	An analytical spring solution as a function of damping ratio and frequency.

	Adapted from
	https://gist.github.com/Fraktality/1033625223e13c01aa7144abe4aaf54d
]]

local Spring = {}
Spring.prototype = {}
Spring.__index = Spring.prototype

local pi = math.pi
local exp = math.exp
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt

function Spring.new(options)
	assert(typeof(options) == "table")

	local dampingRatio = options.dampingRatio
	local frequency = options.frequency
	local position = options.position

	assert(typeof(dampingRatio) == "number")
	assert(typeof(frequency) == "number")
	assert(typeof(position) == "number")

	assert(dampingRatio * frequency >= 0, "Expected dampingRatio * frequency >= 0")

	local self = {
		__dampingRatio = dampingRatio,
		__frequency = frequency, -- nominal frequency
		__goalPosition = position,
		__position = position,
		__velocity = 0,
	}

	setmetatable(self, Spring)

	return self
end

function Spring.prototype:setGoal(goalPosition)
	self.__goalPosition = goalPosition
end

function Spring.prototype:getValue()
	return self.__position
end

function Spring.prototype:step(dt)
	local d = self.__dampingRatio
	local f = self.__frequency * 2 * pi
	local g = self.__goalPosition
	local p = self.__position
	local v = self.__velocity

	local offset = p - g
	local decay = exp(-dt*d*f)

	-- Given:
	--   f^2*(x[dt] - g) + 2*d*f*x'[dt] + x''[dt] = 0,
	--   x[0] = p,
	--   x'[0] = v
	-- Solve for x[dt], x'[dt]

	if d == 1 then -- critically damped
		self.__position = (v*dt + offset*(f*dt + 1))*decay + g
		self.__velocity = (v - f*dt*(offset*f + v))*decay
	elseif d < 1 then -- underdamped
		local c = sqrt(1 - d^2)

		local i = cos(f*c*dt)
		local j = sin(f*c*dt)

		self.__position = (i*offset + j*(v + d*f*offset)/(f*c))*decay + g
		self.__velocity = (i*c*v - j*(v*d + f*offset))*decay/c
	elseif d > 1 then -- overdamped
		local c = sqrt(d*d - 1)

		local r1 = -f*(d - c)
		local r2 = -f*(d + c)

		local co2 = (v - r1*offset)/(2*f*c)
		local co1 = offset - co2

		local e1 = co1*exp(r1*dt)
		local e2 = co2*exp(r2*dt)

		self.__position = e1 + e2 + g
		self.__velocity = r1*e1 + r2*e2
	end
end

return Spring