local Packages = script.Parent.Parent.Parent
local JestGlobals = require(Packages.Dev.JestGlobals)

local it = JestGlobals.it
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local jest = JestGlobals.jest

local validateMotor = require(script.Parent.Parent.validateMotor)

local createSingleMotor = require(script.Parent.Parent.createSingleMotor)

local identityGoal = {
	step = function(state, _dt)
		return state
	end,
}

-- test motion object that completes after step has been called numSteps times
local function createStepper(numSteps)
	local stepCount = 0

	local function step(state, _dt)
		stepCount = stepCount + 1

		if stepCount >= numSteps then
			return {
				value = state.value,
				velocity = state.velocity,
				complete = true,
			}
		end

		return state
	end

	return setmetatable({
		step = step,
	}, {
		__index = function(_, key)
			error(("%q is not a valid member of stepper"):format(key))
		end,
	})
end

it("should be a valid motor", function()
	local motor = createSingleMotor(0)
	validateMotor(motor)
	motor:destroy()
end)

describe("onStep", function()
	it("should not be called initially", function()
		local motor = createSingleMotor(0)

		local spy, spyFn = jest.fn()
		motor:onStep(spyFn)

		motor:setGoal(createStepper(5))
		expect(spy).toHaveBeenCalledTimes(0)

		motor:destroy()
	end)
end)

it("should invoke subscribers with new values", function()
	local motor = createSingleMotor(8)
	motor:setGoal(identityGoal)

	local spy, spyFn = jest.fn()

	local disconnect = motor:onStep(spyFn)
	expect(spy).toHaveBeenCalledTimes(0)

	motor:step(1)
	expect(spy).toHaveBeenCalledTimes(1)
	expect(spy).toHaveBeenCalledWith(8)

	disconnect()

	motor:step(1)
	expect(spy).toHaveBeenCalledTimes(1)

	motor:destroy()
end)

describe("setGoal", function()
	it("should work as intended in onComplete callbacks", function()
		local motor = createSingleMotor(0)
		local spy, spyFn = jest.fn(function()
			motor:setGoal(createStepper(3))
		end)

		motor:onComplete(spyFn)
		motor:setGoal(createStepper(3))
		for _ = 1, 3 do
			motor:step(1)
		end
		expect(spy).toHaveBeenCalledTimes(1)
		--make sure the motor continues to run after calling setGoal in onComplete
		expect(motor.__running).toBe(true)

		for _ = 1, 3 do
			motor:step(1)
		end
		expect(spy).toHaveBeenCalledTimes(2)
		expect(motor.__running).toBe(true)

		motor:destroy()
	end)
end)

describe("onComplete should be called when", function()
	it("has completed its motion", function()
		local motor = createSingleMotor(0)
		motor:setGoal(createStepper(5))

		local spy, spyFn = jest.fn()

		motor:onComplete(spyFn)
		for _ = 1, 5 do
			motor:step(1)
		end
		expect(spy).toHaveBeenCalledTimes(1)

		motor:destroy()
	end)

	it("has restarted its motion", function()
		local motor = createSingleMotor(0)
		motor:setGoal(createStepper(5))

		local spy, spyFn = jest.fn()

		motor:onComplete(spyFn)
		expect(spy).toHaveBeenCalledTimes(0)

		for _ = 1, 5 do
			motor:step(1)
		end
		expect(spy).toHaveBeenCalledTimes(1)

		motor:setGoal(createStepper(5))
		for _ = 1, 5 do
			motor:step(1)
		end
		expect(spy).toHaveBeenCalledTimes(2)

		motor:destroy()
	end)
end)

describe("onComplete should not be called when", function()
	it("has not completed motion", function()
		local motor = createSingleMotor(0)
		motor:setGoal(createStepper(10))

		local spy, spyFn = jest.fn()

		motor:onComplete(spyFn)
		motor:step(1)
		expect(spy).toHaveBeenCalledTimes(0)

		motor:destroy()
	end)

	it("has been unsubscribed", function()
		local motor = createSingleMotor(0)
		motor:setGoal(createStepper(5))

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

	it("does not call step", function()
		local motor = createSingleMotor(0)
		motor:setGoal(createStepper(0))

		local spy, spyFn = jest.fn()

		motor:onComplete(spyFn)
		expect(spy).toHaveBeenCalledTimes(0)

		motor:destroy()
	end)

	it("is stopped in onStep", function()
		local motor = createSingleMotor(0)
		motor:setGoal(createStepper(1))

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
