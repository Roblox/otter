--!strict
local Packages = script.Parent.Parent

local Otter = require(Packages.Otter)
local Roact = require(Packages.Roact)

local measureAndReport = require(script.Parent.measureAndReport)

local STEP_COUNT = 10000

local function createStepper(numSteps): Otter.Goal<any>
	local stepCount = 0

	local function step(_state, _dt)
		stepCount += 1

		return {
			value = stepCount,
			complete = stepCount >= numSteps,
		}
	end

	return {
		step = step,
	} :: any
end

export type Props = {
	stepCount: number,
	goal: Otter.Goal<any>,
	onComplete: () -> (),
}

local function runLegacyBenchmark(component)
	local complete = false
	local LocalPlayer = game:GetService("Players").LocalPlayer
	assert(LocalPlayer, "LocalPlayer not available")

	local container = Instance.new("ScreenGui")
	container.Parent = LocalPlayer.PlayerGui
	local handle = Roact.mount(
		Roact.createElement(component, {
			stepCount = STEP_COUNT,
			goal = createStepper(STEP_COUNT),
			onComplete = function()
				complete = true
			end,
		}),
		container
	)

	local AnimationStepSignal = Otter.__devAnimationStepSignal

	measureAndReport(function()
		while not complete do
			AnimationStepSignal:Fire()
		end
	end, STEP_COUNT)

	Roact.unmount(handle)
end

return runLegacyBenchmark
