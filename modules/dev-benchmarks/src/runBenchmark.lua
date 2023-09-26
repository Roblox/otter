--!strict
local Packages = script.Parent.Parent

local Otter = require(Packages.Otter)
local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)

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

local function runBenchmark(component)
	local complete = false
	local LocalPlayer = game:GetService("Players").LocalPlayer
	assert(LocalPlayer, "LocalPlayer not available")

	local container = Instance.new("ScreenGui")
	container.Parent = LocalPlayer.PlayerGui
	local root = ReactRoblox.createLegacyRoot(container)

	root:render(React.createElement(component, {
		stepCount = STEP_COUNT,
		goal = createStepper(STEP_COUNT),
		onComplete = function()
			complete = true
		end,
	}))
	-- even on a legacy root, effects still queue up for the next frame
	task.wait(0)

	local AnimationStepSignal = Otter.__devAnimationStepSignal
	measureAndReport(function()
		while not complete do
			AnimationStepSignal:Fire()
		end
	end, STEP_COUNT)

	root:unmount()
end

return runBenchmark
