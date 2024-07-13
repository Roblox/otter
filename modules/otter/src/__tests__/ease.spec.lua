--!strict
local Packages = script.Parent.Parent.Parent
local Dash = require(Packages.Dev.Dash)
local JestGlobals = require(Packages.Dev.JestGlobals)

local it = JestGlobals.it
local describe = JestGlobals.describe
local expect = JestGlobals.expect

local ease = require(script.Parent.Parent.ease)

local testCases = Dash.map(Enum.EasingStyle:GetEnumItems(), function(easingStyle)
	return {
		easingStyle = easingStyle
	}
end)

describe("Easing functions", function()
	it.each(testCases)("should handle easing style $easingStyle", function(args)
		local easingStyle = args.name
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
		-- Resets to 0 for next run...
		expect(state.elapsed).toBe(0)
		expect(state.complete).toBe(true)
	end)
end)
