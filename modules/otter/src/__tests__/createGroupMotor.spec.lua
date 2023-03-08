--!strict
local Packages = script.Parent.Parent.Parent
local JestGlobals = require(Packages.Dev.JestGlobals)

local it = JestGlobals.it
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local jest = JestGlobals.jest

local createStepper = require(script.Parent.createStepper)
local validateMotor = require(script.Parent.validateMotor)

local createGroupMotor = require(script.Parent.Parent.createGroupMotor)

it("should be a valid motor", function()
	local motor = createGroupMotor({})
	validateMotor(motor)
	motor:destroy()
end)

describe("onStep", function()
	it("should not be called initially", function()
		local motor = createGroupMotor({
			x = 0,
		})

		local spy, spyFn = jest.fn()

		motor:onStep(spyFn)
		motor:setGoal({
			x = createStepper(5),
		})
		expect(spy).toHaveBeenCalledTimes(0)

		motor:destroy()
	end)
end)

describe("setGoal", function()
	it("should work as intended in onComplete callbacks", function()
		local motor = createGroupMotor({
			x = 0,
		})

		local spy, spyFn = jest.fn(function()
			motor:setGoal({ x = createStepper(3) })
		end)

		motor:onComplete(spyFn)
		motor:setGoal({ x = createStepper(3) })
		for _ = 1, 3 do
			motor:step(1)
		end
		expect(spy).toHaveBeenCalledTimes(1)
		--make sure the motor continues to run after calling setGoal in onComplete
		expect((motor :: any).__running).toBe(true)

		for _ = 1, 3 do
			motor:step(1)
		end
		expect(spy).toHaveBeenCalledTimes(2)
		expect((motor :: any).__running).toBe(true)

		motor:destroy()
	end)
end)

describe("onComplete should be called when", function()
	it("has completed its motion", function()
		local motor = createGroupMotor({
			x = 0,
		})
		motor:setGoal({
			x = createStepper(5),
		})

		local spy, spyFn = jest.fn()

		motor:onComplete(spyFn)
		for _ = 1, 5 do
			motor:step(1)
		end
		expect(spy).toHaveBeenCalledTimes(1)

		motor:destroy()
	end)

	it("has multiple attributes in motion", function()
		local motor = createGroupMotor({
			x = 0,
			y = 10,
		})
		motor:setGoal({
			x = createStepper(2),
			y = createStepper(5),
		})

		local spy, spyFn = jest.fn()

		motor:onComplete(spyFn)
		for _ = 1, 2 do
			motor:step(1)
		end
		expect(spy).toHaveBeenCalledTimes(0)

		for _ = 1, 3 do
			motor:step(1)
		end
		expect(spy).toHaveBeenCalledTimes(1)

		motor:destroy()
	end)

	it("has restarted its motion", function()
		local motor = createGroupMotor({
			x = 0,
		})
		motor:setGoal({
			x = createStepper(3),
		})

		local spy, spyFn = jest.fn()

		motor:onComplete(spyFn)
		for _ = 1, 3 do
			motor:step(1)
		end
		expect(spy).toHaveBeenCalledTimes(1)

		motor:setGoal({
			x = createStepper(3),
		})
		for _ = 1, 3 do
			motor:step(1)
		end
		expect(spy).toHaveBeenCalledTimes(2)

		motor:destroy()
	end)
end)

describe("onComplete should not be called when", function()
	it("has no goals set", function()
		local motor = createGroupMotor({
			x = 2,
		})

		local spy, spyFn = jest.fn()
		motor:onComplete(spyFn)

		for _ = 1, 3 do
			motor:step(1)
		end
		expect(spy).toHaveBeenCalledTimes(0)

		motor:destroy()
	end)

	it("has been unsubscribed", function()
		local motor = createGroupMotor({
			x = 0,
		})
		motor:setGoal({
			x = createStepper(5),
		})

		local spy, spyFn = jest.fn()

		local unsubscribe = motor:onComplete(spyFn)
		for _ = 1, 3 do
			motor:step(1)
		end
		unsubscribe()
		for _ = 1, 2 do
			motor:step(1)
		end
		expect(spy).toHaveBeenCalledTimes(0)

		motor:destroy()
	end)

	it("has not completed motion", function()
		local motor = createGroupMotor({
			x = 0,
		})
		motor:setGoal({
			x = createStepper(2),
		})

		local spy, spyFn = jest.fn()

		motor:onComplete(spyFn)
		motor:step(1)
		expect(spy).toHaveBeenCalledTimes(0)

		motor:destroy()
	end)

	it("has one non-completed motion", function()
		local motor = createGroupMotor({
			x = 0,
			y = 0,
		})
		motor:setGoal({
			x = createStepper(0),
			y = createStepper(2),
		})

		local spy, spyFn = jest.fn()

		motor:onComplete(spyFn)
		motor:step(1)
		expect(spy).toHaveBeenCalledTimes(0)

		motor:destroy()
	end)

	it("does not call step", function()
		local motor = createGroupMotor({
			x = 0,
		})
		motor:setGoal({
			x = createStepper(0),
		})

		local spy, spyFn = jest.fn()

		motor:onComplete(spyFn)
		expect(spy).toHaveBeenCalledTimes(0)

		motor:destroy()
	end)

	it("is stopped in onStep", function()
		local motor = createGroupMotor({
			x = 0,
		})
		motor:setGoal({
			x = createStepper(1),
		})

		local spy, spyFn = jest.fn()

		motor:onComplete(spyFn)
		motor:onStep(function()
			motor:stop()
		end)
		motor:step(1)
		expect(spy).toHaveBeenCalledTimes(0)

		motor:destroy()
	end)
end)
