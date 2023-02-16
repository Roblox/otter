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

it("should take damping, stiffness and mass as parameters", function()
	local s = spring(1, {
		damping = 20,
		stiffness = 400,
		mass = 1,
	})

	expect(s).toEqual(expect.any("table"))
	expect(s.step).toEqual(expect.any("function"))
end)

it("create two similar springs with different set of params, steps should be similar", function()
	local s1 = spring(1, {
		dampingRatio = 0.5,
		frequency = 3.183,
	})

	local s2 = spring(1, {
		damping = 20,
		stiffness = 400,
		mass = 1,
	})

	local state = {
		value = 0,
		velocity = 0,
		complete = false,
	}
	local state_s1 = s1.step(state, 0.05)
	local state_s2 = s2.step(state, 0.05)

	expect(state_s1.value).toBeCloseTo(state_s2.value, 2)
	expect(state_s1.velocity).toBeCloseTo(state_s2.velocity, 2)
	expect(state_s1.complete).toBe(false)
	expect(state_s2.complete).toBe(false)

	state_s1 = s1.step(state, 0.5)
	state_s2 = s2.step(state, 0.5)

	expect(state_s1.value).toBeCloseTo(state_s2.value, 2)
	expect(state_s1.velocity).toBeCloseTo(state_s2.velocity, 2)
	expect(state_s1.complete).toBe(false)
	expect(state_s2.complete).toBe(false)

	state_s1 = s1.step(state_s1, 1)
	state_s2 = s2.step(state_s2, 1)

	expect(state_s1.value).toEqual(state_s2.value)
	expect(state_s1.velocity).toEqual(state_s2.velocity)
	expect(state_s1.complete).toBe(true)
	expect(state_s2.complete).toBe(true)
end)

it("should handle being still correctly", function()
	local s = spring(1, {
		dampingRatio = 0.1,
		frequency = 10,
		restingVelocityLimit = 0.1,
		restingPositionLimit = 0.01,
	})

	local state = s.step({
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
		velocity = 0 :: number?,
		complete = false,
	}

	state = goal.step(state, 1e-3)

	expect(state.value).toBeLessThan(100)
	expect(state.velocity).toBeGreaterThan(0)
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
			velocity = 0 :: number?,
			complete = false,
		}

		while not state.complete do
			state = s.step(state, 0.5)
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
			velocity = 0 :: number?,
			complete = false,
		}

		while not state.complete do
			state = s.step(state, 0.5)
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
			velocity = 0 :: number?,
			complete = false,
		}

		while not state.complete do
			state = s.step(state, 0.5)
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
			velocity = 0 :: number?,
			complete = false,
		}
		state = s.step(state, math.huge)

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
			velocity = 0 :: number?,
			complete = false,
		}
		state = s.step(state, math.huge)

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
			velocity = 0 :: number?,
			complete = false,
		}
		state = s.step(state, math.huge)

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
		velocity = 0 :: number?,
		complete = false,
	}

	while not state.complete do
		state = s.step(state, 0.5)
	end
	state = s.step(state, 0.5)

	expect(state.complete).toBe(true)
	expect(state.value).toBe(3)
	expect(state.velocity).toBe(0)
end)
