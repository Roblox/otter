--!strict
--[[
    Ease functions for creating smooth animations.
    
    Provides different easing functions like linear, quadratic, cubic, quartic, quintic, and more.
    Inspired by Robert Penner's easing functions.
    Supports Roblox EasingStyle.
]]

local types = require(script.Parent.types)
type State = types.State
type Goal<T> = types.Goal<T>

export type EasingStyle = Enum.EasingStyle

export type EaseOptions = {
	duration: number,
	easingStyle: EasingStyle,
}

type EaseState = {
	elapsed: number?,
}

local function linear(t: number): number
	return t
end

local function easeInQuad(t: number): number
	return t * t
end

--[[
local function easeOutQuad(t: number): number
    return t * (2 - t)
end

local function easeInOutQuad(t: number): number
    return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t
end
]]

local function easeInCubic(t: number): number
	return t * t * t
end

--[[
local function easeOutCubic(t: number): number
    return (t - 1) * (t - 1) * (t - 1) + 1
end

local function easeInOutCubic(t: number): number
    return t < 0.5 and 4 * t * t * t or (t - 1) * (2 * t - 2) * (2 * t - 2) + 1
end
]]

local function easeInQuart(t: number): number
	return t * t * t * t
end

--[[
local function easeOutQuart(t: number): number
    return 1 - (t - 1) * (t - 1) * (t - 1) * (t - 1)
end

local function easeInOutQuart(t: number): number
    return t < 0.5 and 8 * t * t * t * t or 1 - 8 * (t - 1) * (t - 1) * (t - 1) * (t - 1)
end
]]

local function easeInQuint(t: number): number
	return t * t * t * t * t
end

--[[
local function easeOutQuint(t: number): number
    return 1 + (t - 1) * (t - 1) * (t - 1) * (t - 1) * (t - 1)
end

local function easeInOutQuint(t: number): number
    return t < 0.5 and 16 * t * t * t * t * t or 1 + 16 * (t - 1) * (t - 1) * (t - 1) * (t - 1) * (t - 1)
end
]]

local function easeInSine(t: number): number
	return 1 - math.cos((t * math.pi) / 2)
end

--[[
local function easeOutSine(t: number): number
    return math.sin((t * math.pi) / 2)
end

local function easeInOutSine(t: number): number
    return -(math.cos(math.pi * t) - 1) / 2
end
]]

local function easeInElastic(t: number): number
	return t == 0 and 0 or t == 1 and 1 or -math.pow(2, 10 * t - 10) * math.sin((t * 10 - 10.75) * ((2 * math.pi) / 3))
end

--[[
local function easeOutElastic(t: number): number
    return t == 0 and 0 or t == 1 and 1 or math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * ((2 * math.pi) / 3)) + 1
end

local function easeInOutElastic(t: number): number
    return t == 0 and 0 or t == 1 and 1 or t < 0.5 and -(math.pow(2, 20 * t - 10) * math.sin((20 * t - 11.125) * ((2 * math.pi) / 4.5))) / 2 or (math.pow(2, -20 * t + 10) * math.sin((20 * t - 11.125) * ((2 * math.pi) / 4.5))) / 2 + 1
end
]]

local function easeInBack(t: number): number
	local c1 = 1.70158
	local c3 = c1 + 1
	return c3 * t * t * t - c1 * t * t
end

--[[
local function easeOutBack(t: number): number
    local c1 = 1.70158
    local c3 = c1 + 1
    return 1 + c3 * (t - 1) * (t - 1) * (t - 1) + c1 * (t - 1) * (t - 1)
end

local function easeInOutBack(t: number): number
    local c1 = 1.70158
    local c2 = c1 * 1.525
    return t < 0.5 and (math.pow(2 * t, 2) * ((c2 + 1) * 2 * t - c2)) / 2 or (math.pow(2 * t - 2, 2) * ((c2 + 1) * (t * 2 - 2) + c2) + 2) / 2
end
]]

local function easeOutBounce(t: number): number
	local n1 = 7.5625
	local d1 = 2.75

	if t < 1 / d1 then
		return n1 * t * t
	elseif t < 2 / d1 then
		return n1 * (t - 1.5 / d1) * (t - 1.5 / d1) + 0.75
	elseif t < 2.5 / d1 then
		return n1 * (t - 2.25 / d1) * (t - 2.25 / d1) + 0.9375
	else
		return n1 * (t - 2.625 / d1) * (t - 2.625 / d1) + 0.984375
	end
end

local function easeInBounce(t: number): number
	return 1 - easeOutBounce(1 - t)
end

--[[
local function easeInOutBounce(t: number): number
    return t < 0.5 and (1 - easeOutBounce(1 - 2 * t)) / 2 or (1 + easeOutBounce(2 * t - 1)) / 2
end
]]

local easingFunctions = {
	[Enum.EasingStyle.Linear] = linear,
	[Enum.EasingStyle.Quad] = easeInQuad,
	[Enum.EasingStyle.Cubic] = easeInCubic,
	[Enum.EasingStyle.Quart] = easeInQuart,
	[Enum.EasingStyle.Quint] = easeInQuint,
	[Enum.EasingStyle.Sine] = easeInSine,
	[Enum.EasingStyle.Bounce] = easeInBounce,
	[Enum.EasingStyle.Back] = easeInBack,
	[Enum.EasingStyle.Elastic] = easeInElastic,
}

local function ease(goalPosition: number, inputOptions: EaseOptions?): Goal<EaseState>
	local options = {
		duration = 1,
		easingStyle = Enum.EasingStyle.Linear,
	}

	if inputOptions then
		for key, value in pairs(inputOptions) do
			options[key] = value
		end
	end

	local duration = options.duration
	local easingStyle = options.easingStyle
	local easingFunction = easingFunctions[easingStyle]

	local function step(state: State & EaseState, dt: number): State & EaseState
		local elapsed = (state.elapsed or 0) + dt
		local t = math.min(elapsed / duration, 1)
		local easedT = easingFunction(t)

		local value = goalPosition * easedT
		local complete = elapsed >= duration

		return {
			value = value,
			elapsed = elapsed,
			complete = complete,
		}
	end

	return {
		step = step,
	}
end

return ease
