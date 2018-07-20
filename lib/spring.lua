--[[
	An analytical spring solution as a function of damping ratio and frequency.

	Adapted from
	https://gist.github.com/Fraktality/1033625223e13c01aa7144abe4aaf54d
]]

local merge = require(script.Parent.merge)

local pi = math.pi
local exp = math.exp
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt

local RESTING_VELOCITY_LIMIT = 1e-7
local RESTING_POSITION_LIMIT = 1e-5

local function step(self, state, dt)
	local d = self.__dampingRatio
	local f = self.__frequency * 2 * pi
	local g = self.__goalPosition

	local p = state.value
	local v = state.velocity or 0

	local offset = p - g
	local decay = exp(-dt*d*f)

	-- Given:
	--   f^2*(x[dt] - g) + 2*d*f*x'[dt] + x''[dt] = 0,
	--   x[0] = p,
	--   x'[0] = v
	-- Solve for x[dt], x'[dt]

	if d == 1 then -- critically damped
		p = (v*dt + offset*(f*dt + 1))*decay + g
		v = (v - f*dt*(offset*f + v))*decay
	elseif d < 1 then -- underdamped
		local c = sqrt(1 - d^2)

		local i = cos(f*c*dt)
		local j = sin(f*c*dt)

		p = (i*offset + j*(v + d*f*offset)/(f*c))*decay + g
		v = (i*c*v - j*(v*d + f*offset))*decay/c
	elseif d > 1 then -- overdamped
		local c = sqrt(d*d - 1)

		local r1 = -f*(d - c)
		local r2 = -f*(d + c)

		local co2 = (v - r1*offset)/(2*f*c)
		local co1 = offset - co2

		local e1 = co1*exp(r1*dt)
		local e2 = co2*exp(r2*dt)

		p = e1 + e2 + g
		v = r1*e1 + r2*e2
	end

	local positionOffset = math.abs(p - self.__goalPosition)
	local velocityOffset = math.abs(v)

	local complete = velocityOffset < RESTING_VELOCITY_LIMIT and positionOffset < RESTING_POSITION_LIMIT

	return {
		value = p,
		complete = complete,

		velocity = v,
	}
end

local function spring(goalPosition, inputOptions)
	assert(typeof(goalPosition) == "number")

	local options = {
		dampingRatio = 1,
		frequency = 1,
	}

	if inputOptions ~= nil then
		assert(typeof(inputOptions) == "table")
		merge(options, inputOptions)
	end

	local dampingRatio = options.dampingRatio
	local frequency = options.frequency

	assert(typeof(dampingRatio) == "number")
	assert(typeof(frequency) == "number")

	assert(dampingRatio * frequency >= 0, "Expected dampingRatio * frequency >= 0")

	local self = {
		__dampingRatio = dampingRatio,
		__frequency = frequency, -- nominal frequency
		__goalPosition = goalPosition,
		step = step,
	}

	return self
end

return spring