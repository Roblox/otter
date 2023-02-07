--!strict
local Packages = script.Parent.Parent.Parent
local JestGlobals = require(Packages.Dev.JestGlobals)

local it = JestGlobals.it
local describe = JestGlobals.describe
local expect = JestGlobals.expect

local spring = require(script.Parent.Parent.spring)

it("should have all expected APIs", function()
	expect(spring).toEqual(expect.any("function"))

	local s = spring(1, {
		dampingRatio = 0.1,
		frequency = 10,
		restingVelocityLimit = 0.1,
		restingPositionLimit = 0.01,
	})

	expect(s).toEqual(expect.any("table"))
	expect(s.step).toEqual(expect.any("function"))

	-- handle when spring lacks option table
	s = spring(1)

	expect(s).toEqual(expect.any("table"))
	expect(s.step).toEqual(expect.any("function"))
end)

it("should handle being still correctly", function()
	local s = spring(1, {
		dampingRatio = 0.1,
		frequency = 10,
		restingVelocityLimit = 0.1,
		restingPositionLimit = 0.01,
	})

	local state = s:step({
		value = 1,
		velocity = 0,
		complete = false,
	}, 1)

	expect(state.value).toBe(1)
	expect(state.velocity).toBe(0)
	expect(state.complete).toBe(true)
end)

it("should return not complete when in motion", function()
	local goal = spring(100, {
		dampingRatio = 0.1,
		frequency = 10,
	})

	local state = {
		value = 1,
		velocity = 0,
		complete = false,
	}

	state = goal:step(state, 1e-3)

	expect(state.value < 100).toBe(true)
	expect(state.velocity > 0).toBe(true)
	expect(state.complete).toBe(false)
end)

describe("should eventaully complete when", function()
	it("is critically damped", function()
		local s = spring(3, {
			dampingRatio = 1,
			frequency = 0.5,
		})

		local state = {
			value = 1,
			velocity = 0,
			complete = false,
		}

		while not state.complete do
			state = s:step(state, 0.5)
		end

		expect(state.complete).toBe(true)
		expect(state.value).toBe(3)
		expect(state.velocity).toBe(0)
	end)

	it("is over damped", function()
		local s = spring(3, {
			dampingRatio = 10,
			frequency = 0.5,
		})

		local state = {
			value = 1,
			velocity = 0,
			complete = false,
		}

		while not state.complete do
			state = s:step(state, 0.5)
		end

		expect(state.complete).toBe(true)
		expect(state.value).toBe(3)
		expect(state.velocity).toBe(0)
	end)

	it("is under damped", function()
		local s = spring(3, {
			dampingRatio = 0.1,
			frequency = 0.5,
		})

		local state = {
			value = 1,
			velocity = 0,
			complete = false,
		}

		while not state.complete do
			state = s:step(state, 0.5)
		end

		expect(state.complete).toBe(true)
		expect(state.value).toBe(3)
		expect(state.velocity).toBe(0)
	end)
end)

describe("should handle infinite time deltas when", function()
	-- TODO: This test is broken.
	it.skip("is critically damped", function()
		local s = spring(20, {
			dampingRatio = 1,
			frequency = 1,
		})

		local state = {
			value = -10,
			velocity = 0,
			complete = false,
		}
		state = s:step(state, math.huge)

		expect(state.complete).toBe(true)
		expect(state.value).toBe(20)
		expect(state.velocity).toBe(0)
	end)

	-- TODO: This test is broken.
	it.skip("is underdamped", function()
		local s = spring(20, {
			dampingRatio = 0.5,
			frequency = 1,
		})

		local state = {
			value = -10,
			velocity = 0,
			complete = false,
		}
		state = s:step(state, math.huge)

		expect(state.complete).toBe(true)
		expect(state.value).toBe(20)
		expect(state.velocity).toBe(0)
	end)

	it("is overdamped", function()
		local s = spring(20, {
			dampingRatio = 2,
			frequency = 1,
		})

		local state = {
			value = -10,
			velocity = 0,
			complete = false,
		}
		state = s:step(state, math.huge)

		expect(state.complete).toBe(true)
		expect(state.value).toBe(20)
		expect(state.velocity).toBe(0)
	end)
end)

it("should remain complete when completed", function()
	local s = spring(3, {
		dampingRatio = 1,
		frequency = 0.5,
	})

	local state = {
		value = 1,
		velocity = 0,
		complete = false,
	}

	while not state.complete do
		state = s:step(state, 0.5)
	end
	state = s:step(state, 0.5)

	expect(state.complete).toBe(true)
	expect(state.value).toBe(3)
	expect(state.velocity).toBe(0)
end)
