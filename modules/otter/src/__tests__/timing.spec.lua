local Packages = script.Parent.Parent.Parent
local JestGlobals = require(Packages.Dev.JestGlobals)

local it = JestGlobals.it
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local beforeAll = JestGlobals.beforeAll
local afterAll = JestGlobals.afterAll

local createSingleMotor, spring, AnimationStepSignal

describe("real time", function()
	beforeAll(function()
		jest.resetModules()
		createSingleMotor = require(script.Parent.Parent.createSingleMotor)
		spring = require(script.Parent.Parent.spring)
	end)

	it("should step through springs", function()
		local stepSpy, stepSpyFn = jest.fn()
		local completeSpy, completeSpyFn = jest.fn()

		local motor = createSingleMotor(0)
		motor:onStep(stepSpyFn)
		motor:onComplete(completeSpyFn)

		motor:setGoal(spring(1, {
			dampingRatio = 2,
			frequency = 5,
		}))

		expect(stepSpy).toHaveBeenCalledTimes(0)
		expect(completeSpy).toHaveBeenCalledTimes(0)

		task.wait(2)

		expect(stepSpy).toHaveBeenCalled()
		expect(completeSpy).toHaveBeenCalledTimes(1)

		motor:destroy()
	end)
end)

describe("mock timers", function()
	beforeAll(function()
		_G.__OTTER_MOCK_ANIMATION_STEP_SIGNAL__ = true
		jest.resetModules()
		createSingleMotor = require(script.Parent.Parent.createSingleMotor)
		spring = require(script.Parent.Parent.spring)
		AnimationStepSignal = require(script.Parent.Parent.AnimationStepSignal)
	end)

	afterAll(function()
		_G.__OTTER_MOCK_ANIMATION_STEP_SIGNAL__ = nil
		jest.resetModules()
	end)

	it("should step through springs", function()
		local stepSpy, stepSpyFn = jest.fn()
		local completeSpy, completeSpyFn = jest.fn()

		local motor = createSingleMotor(0)
		motor:onStep(stepSpyFn)
		motor:onComplete(completeSpyFn)

		motor:setGoal(spring(1, {
			dampingRatio = 2,
			frequency = 5,
		}))

		expect(stepSpy).toHaveBeenCalledTimes(0)
		expect(completeSpy).toHaveBeenCalledTimes(0)

		for _ = 1, 120 do
			AnimationStepSignal:Fire()
		end

		expect(stepSpy).toHaveBeenCalled()
		expect(completeSpy).toHaveBeenCalledTimes(1)

		motor:destroy()
	end)
end)
