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

local useMotor = require(script.Parent.Parent.useMotor)

type AnimationType = "Spring" | "Ease"
type AnimationTypes = { { animationType: AnimationType } }
local AnimationTypes: AnimationTypes = { { animationType = "Spring" }, { animationType = "Ease" } }

local goals = {
	Spring = {
		Otter.spring(20, {
			dampingRatio = 1,
			frequency = 3,
		}),
		Otter.spring(-10, {
			dampingRatio = 1,
			frequency = 3,
		}),
	},
	Ease = {
		Otter.ease(20, {
			duration = 1,
			easingStyle = Enum.EasingStyle.Linear,
		}),
		Otter.ease(-10, {
			duration = 1,
			easingStyle = Enum.EasingStyle.Linear,
		}),
	},
}

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
		onComplete: ((any) -> ())?,
		onStep: (any) -> (),
		goal: Otter.Goal<any>?,
	}
	local function Motor(props: Props)
		local setGoal = useMotor(props.initialValue, props.onStep, props.onComplete)

		React.useEffect(function()
			if props.goal then
				setGoal(props.goal)
			end
		end, { props.goal })

		return nil
	end

	it("should trigger a motor when the goal setter is called", function()
		local onStepSpy, onStepSpyFn = jest.fn()
		local onCompleteSpy, onCompleteSpyFn = jest.fn()
		local result = render(React.createElement(Motor, {
			initialValue = 10,
			onComplete = onCompleteSpyFn,
			onStep = onStepSpyFn,
		}))

		expect(onCompleteSpy).never.toHaveBeenCalled()
		expect(onStepSpy).never.toHaveBeenCalled()

		result.rerender(React.createElement(Motor, {
			initialValue = 10,
			onComplete = onCompleteSpyFn,
			onStep = onStepSpyFn,
			goal = Otter.spring(20, {
				dampingRatio = 1,
				frequency = 3,
			}),
		}))

		for _ = 1, 10 do
			Otter.__devAnimationStepSignal:Fire()
		end
		expect(onStepSpy).toHaveBeenCalledTimes(10)

		for _ = 1, 110 do
			Otter.__devAnimationStepSignal:Fire()
		end

		expect(onCompleteSpy).toHaveBeenCalled()
	end);

	(it.each :: (AnimationTypes) -> (string, any) -> ())(AnimationTypes)(
		"should re-start the motor when a new goal is called for an animation $animationType",
		function(args)
			local onCompleteSpy, onCompleteSpyFn = jest.fn()
			local onStepSpy, onStepSpyFn = jest.fn()
			local animations = goals[args.animationType]
			local result = render(React.createElement(Motor, {
				initialValue = 0,
				onComplete = onCompleteSpyFn,
				onStep = onStepSpyFn,
				goal = animations[1],
			}))

			expect(onCompleteSpy).never.toHaveBeenCalled()

			for _ = 1, 120 do
				Otter.__devAnimationStepSignal:Fire()
			end
			expect(onCompleteSpy).toHaveBeenCalledTimes(1)
			expect(onStepSpy).toHaveBeenCalled()

			local steps = #onStepSpy.mock.calls

			result.rerender(React.createElement(Motor, {
				initialValue = 0,
				onComplete = onCompleteSpyFn,
				onStep = onStepSpyFn,
				goal = animations[2],
			}))

			for _ = 1, 120 do
				Otter.__devAnimationStepSignal:Fire()
			end
			expect(onCompleteSpy).toHaveBeenCalledTimes(2)
			expect(#onStepSpy.mock.calls).toBeGreaterThan(steps)
		end
	)

	it("should not recreate the motor on re-render", function()
		local captureSetGoal = jest.fn()
		local function CaptureSetGoal(props)
			captureSetGoal(useMotor(props.initialValue, props.onStep))
			return nil
		end
		local result = render(React.createElement(CaptureSetGoal, {
			initialValue = 1,
			onStep = function() end,
		}))

		result.rerender(React.createElement(CaptureSetGoal, {
			initialValue = 99,
			onStep = function() end,
		}))

		expect(captureSetGoal.mock.calls[1][1]).toBe(captureSetGoal.mock.calls[2][1])
	end)

	it("should disconnect an onStep callback when a new one is provided", function()
		local onStepSpy1, onStepSpyFn1 = jest.fn()
		local onStepSpy2, onStepSpyFn2 = jest.fn()

		local result = render(React.createElement(Motor, {
			initialValue = 0,
			onStep = onStepSpyFn1,
			goal = Otter.instant(1),
		}))

		Otter.__devAnimationStepSignal:Fire()
		expect(onStepSpy1).toHaveBeenCalledTimes(1)
		expect(onStepSpy2).toHaveBeenCalledTimes(0)

		result.rerender(React.createElement(Motor, {
			initialValue = 0,
			onStep = onStepSpyFn2,
			goal = Otter.instant(20),
		}))

		Otter.__devAnimationStepSignal:Fire()
		expect(onStepSpy1).toHaveBeenCalledTimes(1)
		expect(onStepSpy2).toHaveBeenCalledTimes(1)
	end)
end)

describe("Multiple values", function()
	type Props = {
		initialValue: { [string]: number },
		onComplete: (() -> ())?,
		onStep: () -> (),
		goal: { [string]: Otter.Goal<any> }?,
	}
	local function GroupMotor(props: Props)
		local setGoal = useMotor(props.initialValue, props.onStep, props.onComplete)

		React.useEffect(function()
			if props.goal then
				setGoal(props.goal)
			end
		end, { props.goal })

		return nil
	end

	it("should trigger a motor when the goal setter is called", function()
		local onCompleteSpy, onCompleteSpyFn = jest.fn()
		local onStepSpy, onStepSpyFn = jest.fn()
		local result = render(React.createElement(GroupMotor, {
			initialValue = {
				label = 10,
				textSize = 8,
			},
			onComplete = onCompleteSpyFn,
			onStep = onStepSpyFn,
		}))

		Otter.__devAnimationStepSignal:Fire()
		expect(onCompleteSpy).never.toHaveBeenCalled()
		expect(onStepSpy).never.toHaveBeenCalled()

		local springConfig = {
			dampingRatio = 1,
			frequency = 3,
		}
		result.rerender(React.createElement(GroupMotor, {
			initialValue = {
				label = 10,
				textSize = 8,
			},
			onComplete = onCompleteSpyFn,
			onStep = onStepSpyFn,
			goal = {
				label = Otter.spring(20, springConfig),
				textSize = Otter.spring(14, springConfig),
			},
		}))

		for _ = 1, 10 do
			Otter.__devAnimationStepSignal:Fire()
		end
		expect(onCompleteSpy).never.toHaveBeenCalled()
		expect(onStepSpy).toHaveBeenCalledTimes(10)
		expect(onStepSpy).toHaveBeenLastCalledWith({
			label = expect.any("number"),
			textSize = expect.any("number"),
		})

		for _ = 1, 110 do
			Otter.__devAnimationStepSignal:Fire()
		end
		expect(onCompleteSpy).toHaveBeenCalled()
	end)
end)
