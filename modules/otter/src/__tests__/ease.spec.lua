--!strict
local Packages = script.Parent.Parent.Parent
local JestGlobals = require(Packages.Dev.JestGlobals)

local it = JestGlobals.it
local describe = JestGlobals.describe
local expect = JestGlobals.expect

local ease = require(script.Parent.Parent.ease)

local EasingStyles = {
	Enum.EasingStyle.Linear,
	Enum.EasingStyle.Quad,
	Enum.EasingStyle.Cubic,
	Enum.EasingStyle.Quart,
	Enum.EasingStyle.Quint,
	Enum.EasingStyle.Sine,
	Enum.EasingStyle.Bounce,
	Enum.EasingStyle.Back,
	Enum.EasingStyle.Elastic,
}

local function testEaseFunction(easingStyle)
	local e = ease(1, {
		duration = 1,
		easingStyle = easingStyle,
	})

	expect(e).toEqual(expect.any("table"))
	expect(e.step).toEqual(expect.any("function"))

	-- Test a few steps
	local state = {
		value = 0,
		elapsed = 0,
		complete = false,
	}

	expect(state.value).toBeLessThanOrEqual(0)

	state = e.step(state, 0.1)
	if easingStyle == Enum.EasingStyle.Back then
		expect(state.value).toBeLessThanOrEqual(0)
	else
		expect(state.value).toBeGreaterThan(0)
	end
	expect(state.value).toBeLessThanOrEqual(1)
	expect(state.elapsed).toBe(0.1)
	expect(state.complete).toBe(false)

	state = e.step(state, 0.4)
	expect(state.value).toBeLessThanOrEqual(1)
	expect(state.elapsed).toBe(0.5)
	expect(state.complete).toBe(false)

	state = e.step(state, 0.5)
	-- Sine is a little imperfect here
	expect(state.value).toBeCloseTo(1)
	expect(state.elapsed).toBe(1)
	expect(state.complete).toBe(true)
end

describe("Easing functions", function()
	it("should have all expected APIs", function()
		expect(ease).toEqual(expect.any("function"))

		local e = ease(1, {
			duration = 1,
			easingStyle = Enum.EasingStyle.Linear,
		})

		expect(e).toEqual(expect.any("table"))
		expect(e.step).toEqual(expect.any("function"))
	end)

	for _, easingStyle in ipairs(EasingStyles) do
		it("should handle easing style: " .. tostring(easingStyle), function()
			testEaseFunction(easingStyle)
		end)
	end
end)
