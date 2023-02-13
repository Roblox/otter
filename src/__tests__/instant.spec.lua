--!strict
local Packages = script.Parent.Parent.Parent
local JestGlobals = require(Packages.Dev.JestGlobals)

local it = JestGlobals.it
local expect = JestGlobals.expect

local instant = require(script.Parent.Parent.instant)

it("should have the expected APIs", function()
	local goal = instant(5)

	expect(goal).toEqual(expect.any("table"))
	expect(goal.step).toEqual(expect.any("function"))
end)

it("should immediately complete", function()
	local state = {
		value = 5,
		complete = false,
	}

	local goal = instant(10)
	state = goal.step(state, 1e-3)

	expect(state.value).toBe(10)
	expect(state.complete).toBe(true)
end)

it("should remove extra values from state", function()
	local state = {
		value = 5,
		complete = false,

		velocity = 7,
		somethingElse = {},
	} :: any

	local goal = instant(10)
	state = goal.step(state, 1e-3)

	expect(state.velocity).never.toBeDefined()
	expect(state.somethingElse).never.toBeDefined()
end)
