--!strict
local Packages = script.Parent.Parent.Parent
local Otter = require(Packages.Otter)
local React = require(Packages.React)

local JestGlobals = require(Packages.Dev.JestGlobals)
local it = JestGlobals.it
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local beforeAll = JestGlobals.beforeAll
local afterAll = JestGlobals.afterAll
local afterEach = JestGlobals.afterEach

local ReactTestingLibrary = require(Packages.Dev.ReactTestingLibrary)
local render = ReactTestingLibrary.render
local cleanup = ReactTestingLibrary.cleanup

local useAnimatedBinding = require(script.Parent.Parent.useAnimatedBinding)

type AnimationType = "Spring" | "Ease"
type AnimationTypes = { { animationType: AnimationType } }
local AnimationTypes: AnimationTypes = { { animationType = "Spring" }, { animationType = "Ease" } }

local goals = {
	Spring = Otter.spring(20, {
		dampingRatio = 1,
		frequency = 1,
	}),
	Ease = Otter.ease(20, {
		duration = 5,
		easingStyle = Enum.EasingStyle.Linear,
	}),
}

type EmptyGoalState = {}
local function createStepper(numSteps): Otter.Goal<EmptyGoalState>
	local stepCount = 0

	return {
		step = function(_state, _dt)
			stepCount = stepCount + 1

			return {
				value = stepCount,
				complete = stepCount >= numSteps,
			}
		end,
	}
end

local previousFakeTimersValue
beforeAll(function()
	previousFakeTimersValue = _G.__OTTER_MOCK_ANIMATION_STEP_SIGNAL__
	_G.__OTTER_MOCK_ANIMATION_STEP_SIGNAL__ = true
end)

afterAll(function()
	_G.__OTTER_MOCK_ANIMATION_STEP_SIGNAL__ = previousFakeTimersValue
end)

afterEach(function()
	cleanup()
end)

describe("Single value", function()
	type Props = {
		initialValue: number,
		onComplete: () -> (),
		goal: Otter.Goal<any>?,
	}
	local function AnimateTextValue(props: Props)
		local value, setGoal = useAnimatedBinding(props.initialValue, props.onComplete)

		React.useEffect(function()
			if props.goal then
				setGoal(props.goal)
			end
		end, { props.goal })

		return React.createElement("TextLabel", {
			Text = value:map(tostring),
		})
	end

	it("should trigger a motor when the goal setter is called", function()
		local onCompleteSpy, onCompleteSpyFn = jest.fn()
		local result = render(React.createElement(AnimateTextValue, {
			initialValue = 10,
			onComplete = onCompleteSpyFn,
		}))

		expect(onCompleteSpy).never.toHaveBeenCalled()
		assert(result.getByText("10"))

		result.rerender(React.createElement(AnimateTextValue, {
			initialValue = 10,
			onComplete = onCompleteSpyFn,
			goal = Otter.spring(20, {
				dampingRatio = 1,
				frequency = 3,
			}),
		}))

		for _ = 1, 120 do
			Otter.__devAnimationStepSignal:Fire()
		end

		expect(onCompleteSpy).toHaveBeenCalled()
		assert(result.getByText("20"))
	end)

	it("should update the binding once per step", function()
		local onCompleteSpy, onCompleteSpyFn = jest.fn()
		local stepper = createStepper(3)
		local stepSpy, stepSpyFn = jest.fn(stepper.step)
		stepper.step = stepSpyFn

		local result = render(React.createElement(AnimateTextValue, {
			initialValue = 0,
			onComplete = onCompleteSpyFn,
			goal = stepper,
		}))

		expect(onCompleteSpy).never.toHaveBeenCalled()
		assert(result.getByText("0"))

		for _ = 1, 3 do
			Otter.__devAnimationStepSignal:Fire()
		end

		expect(stepSpy).toHaveReturnedTimes(3)
		for i = 1, 3 do
			expect(stepSpy).toHaveNthReturnedWith(i, { value = i, complete = i == 3 })
		end
		expect(onCompleteSpy).toHaveBeenCalled()
	end)

	it("should re-start the motor when a new goal is called", function()
		local onCompleteSpy, onCompleteSpyFn = jest.fn()
		local result = render(React.createElement(AnimateTextValue, {
			initialValue = 0,
			onComplete = onCompleteSpyFn,
			goal = Otter.spring(10, {
				dampingRatio = 1,
				frequency = 3,
			}),
		}))

		expect(onCompleteSpy).never.toHaveBeenCalled()
		assert(result.getByText("0"))

		for _ = 1, 120 do
			Otter.__devAnimationStepSignal:Fire()
		end
		expect(onCompleteSpy).toHaveBeenCalledTimes(1)

		result.rerender(React.createElement(AnimateTextValue, {
			initialValue = 0,
			onComplete = onCompleteSpyFn,
			goal = Otter.spring(-10, {
				dampingRatio = 1,
				frequency = 3,
			}),
		}))

		for _ = 1, 120 do
			Otter.__devAnimationStepSignal:Fire()
		end
		expect(onCompleteSpy).toHaveBeenCalledTimes(2)
		assert(result.getByText("-10"))
	end);

	(it.each :: (AnimationTypes) -> (string, any) -> ())(AnimationTypes)(
		"should allow a new goal to be set while the motor is in motion to a $animationType goal",
		function(animationType)
			local onCompleteSpy, onCompleteSpyFn = jest.fn()
			local result = render(React.createElement(AnimateTextValue, {
				initialValue = 10,
				onComplete = onCompleteSpyFn,
				goal = goals[animationType],
			}))

			assert(result.getByText("10"))

			for _ = 1, 7 do
				Otter.__devAnimationStepSignal:Fire()
			end
			expect(onCompleteSpy).never.toHaveBeenCalled()

			result.rerender(React.createElement(AnimateTextValue, {
				initialValue = 10,
				onComplete = onCompleteSpyFn,
				goal = Otter.instant(99),
			}))

			Otter.__devAnimationStepSignal:Fire()
			assert(result.getByText("99"))
			expect(onCompleteSpy).toHaveBeenCalled()
		end
	)

	it("should not recreate the motor on re-render", function()
		local onCompleteSpy, onCompleteSpyFn = jest.fn()
		local result = render(React.createElement(AnimateTextValue, {
			initialValue = 1,
			onComplete = onCompleteSpyFn,
		}))

		expect(onCompleteSpy).never.toHaveBeenCalled()
		assert(result.getByText("1"))

		result.rerender(React.createElement(AnimateTextValue, {
			initialValue = 99,
			onComplete = onCompleteSpyFn,
		}))

		assert(result.getByText("1"))
		expect(result.queryByText("99")).toBeNil()
	end)

	it("should disconnect an onComplete callback when a new one is provided", function()
		local onCompleteSpy1, onCompleteSpyFn1 = jest.fn()
		local onCompleteSpy2, onCompleteSpyFn2 = jest.fn()

		local result = render(React.createElement(AnimateTextValue, {
			initialValue = 0,
			onComplete = onCompleteSpyFn1,
			goal = Otter.instant(1),
		}))

		for _ = 1, 3 do
			Otter.__devAnimationStepSignal:Fire()
		end
		assert(result.getByText("1"))
		expect(onCompleteSpy1).toHaveBeenCalledTimes(1)
		expect(onCompleteSpy2).toHaveBeenCalledTimes(0)

		result.rerender(React.createElement(AnimateTextValue, {
			initialValue = 0,
			onComplete = onCompleteSpyFn2,
			goal = Otter.instant(20),
		}))

		for _ = 1, 3 do
			Otter.__devAnimationStepSignal:Fire()
		end
		assert(result.getByText("20"))
		expect(onCompleteSpy1).toHaveBeenCalledTimes(1)
		expect(onCompleteSpy2).toHaveBeenCalledTimes(1)
	end)
end)

describe("Multiple values", function()
	type Props = {
		initialValue: { [string]: number },
		onComplete: () -> (),
		goal: { [string]: Otter.Goal<any> }?,
	}
	local function AnimateTextProps(props: Props)
		local value, setGoal = useAnimatedBinding(props.initialValue, props.onComplete)

		React.useEffect(function()
			if props.goal then
				setGoal(props.goal)
			end
		end, { props.goal })

		return React.createElement("TextLabel", {
			Text = value:map(function(state)
				return tostring(state.label)
			end),
			TextSize = value:map(function(state)
				return state.textSize
			end),
		})
	end

	it("should trigger a motor when the goal setter is called", function()
		local onCompleteSpy, onCompleteSpyFn = jest.fn()
		local result = render(React.createElement(AnimateTextProps, {
			initialValue = {
				label = 10,
				textSize = 8,
			},
			onComplete = onCompleteSpyFn,
		}))

		expect(onCompleteSpy).never.toHaveBeenCalled()
		local instance = result.getByText("10")
		expect(instance.TextSize).toBe(8)

		local springConfig = {
			dampingRatio = 1,
			frequency = 3,
		}
		result.rerender(React.createElement(AnimateTextProps, {
			initialValue = {
				label = 10,
				textSize = 8,
			},
			onComplete = onCompleteSpyFn,
			goal = {
				label = Otter.spring(20, springConfig),
				textSize = Otter.spring(14, springConfig),
			},
		}))

		for _ = 1, 120 do
			Otter.__devAnimationStepSignal:Fire()
		end

		expect(onCompleteSpy).toHaveBeenCalled()
		instance = result.getByText("20")
		expect(instance.TextSize).toBe(14)
	end)
end)
