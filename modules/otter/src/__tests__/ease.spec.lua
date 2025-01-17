local Packages = script.Parent.Parent.Parent
local JestGlobals = require(Packages.Dev.JestGlobals)

local it = JestGlobals.it
local describe = JestGlobals.describe
local expect = JestGlobals.expect

local ease = require(script.Parent.Parent.ease)

describe("Easing functions", function()
	it.each(Enum.EasingStyle:GetEnumItems())("should handle easing style $easingStyle", function(easingStyle)
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

describe("cubicBezier", function()
	it("should create a valid easing function", function()
		local e = ease(1, {
			duration = 1,
			easingStyle = { 0.2, 0, 0, 1 },
		})

		expect(e).toEqual(expect.any("table"))
		expect(e.step).toEqual(expect.any("function"))
	end)

	it("should use default easingStyle when no options provided", function()
		local e = ease(1)

		local state = {
			value = 0,
			elapsed = 0,
			complete = false,
		}

		state = e.step(state, 0.5)
		expect(state.value).toBeGreaterThan(0)
		expect(state.value).toBeLessThan(1)
	end)

	describe("step function", function()
		it("should handle basic animation steps", function()
			local e = ease(1, {
				duration = 1,
				easingStyle = { 0.2, 0, 0, 1 },
			})

			local state = {
				value = 0,
				elapsed = 0,
				complete = false,
			}

			-- Test initial state
			expect(state.value).toBe(0)

			-- Test midway through animation
			state = e.step(state, 0.5)
			expect(state.value).toBeGreaterThan(0)
			expect(state.value).toBeLessThan(1)
			expect(state.elapsed).toBe(0.5)
			expect(state.complete).toBe(false)

			-- Test completion
			state = e.step(state, 0.5)
			expect(state.value).toBeCloseTo(1)
			expect(state.elapsed).toBe(0)
			expect(state.complete).toBe(true)
		end)

		it("should handle zero duration", function()
			local e = ease(1, {
				duration = 0,
				easingStyle = { 0.2, 0, 0, 1 },
			})

			local state = {
				value = 0,
				elapsed = 0,
				complete = false,
			}

			state = e.step(state, 0.1)
			expect(state.value).toBe(1)
			expect(state.complete).toBe(true)
		end)

		it("should handle different control points", function()
			local testCases = {
				{ 0.4, 0, 0.6, 1 }, -- Ease in-out
				{ 0, 0, 1, 1 }, -- Linear
				{ 0.25, 0.1, 0.25, 1.0 }, -- Ease out
				{ 0.42, 0, 1.0, 1.0 }, -- Ease in
			}

			for _, controlPoints in ipairs(testCases) do
				local e = ease(1, {
					duration = 1,
					easingStyle = controlPoints,
				})

				local state = {
					value = 0,
					elapsed = 0,
					complete = false,
				}

				state = e.step(state, 0.5)
				expect(state.value).toBeGreaterThan(0)
				expect(state.value).toBeLessThan(1)
			end
		end)
	end)

	describe("edge cases", function()
		it("should handle same start and end easingStyle", function()
			local e = ease(1, {
				duration = 1,
				easingStyle = { 0.2, 0, 0, 1 },
			})

			local state = {
				value = 1,
				elapsed = 0,
				complete = false,
			}

			state = e.step(state, 0.5)
			expect(state.complete).toBe(true)
			expect(state.value).toBe(1)
		end)

		it("should handle very small time steps", function()
			local e = ease(1, {
				duration = 1,
				easingStyle = { 0.2, 0, 0, 1 },
			})

			local state = {
				value = 0,
				elapsed = 0,
				complete = false,
			}

			state = e.step(state, 0.001)
			expect(state.value).toBeGreaterThan(0)
			expect(state.elapsed).toBe(0.001)
		end)
	end)
end)
