--!strict
local Packages = script.Parent.Parent

local Otter = require(Packages.Otter)
local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)

local function runFPSBenchmark(component, runServiceSignal: RBXScriptSignal, goal: number)
	local complete = false
	local LocalPlayer = game:GetService("Players").LocalPlayer
	assert(LocalPlayer, "LocalPlayer not available")

	local container = Instance.new("ScreenGui")
	container.Parent = LocalPlayer.PlayerGui
	local root = ReactRoblox.createLegacyRoot(container)

	root:render(React.createElement(component, {
		goal = goal,
		onComplete = function()
			complete = true
		end,
	}))
	-- even on a legacy root, effects still queue up for the next frame
	task.wait(0)

	local AnimationStepSignal = Otter.__devAnimationStepSignal
	local connection
	local frameCount = 0

	if _G.__OTTER_MOCK_ANIMATION_STEP_SIGNAL__ then
		--[[
			This looks a bit ridiculous, but we need to run benchmarks using the
			actual RunService implementations.
		]]
		connection = runServiceSignal:Connect(function(dt)
			AnimationStepSignal:Fire(dt)
			frameCount += 1
		end)
	end

	local startTime = os.clock()
	while not complete do
		task.wait()
	end
	local endTime = os.clock()

	if _G.__OTTER_MOCK_ANIMATION_STEP_SIGNAL__ then
		connection:Disconnect()
	end

	local timeElapsed = endTime - startTime
	local fps = frameCount / timeElapsed

	print(string.format("Metric %.3fms - %.3fµs", fps, frameCount))

	root:unmount()
end

return runFPSBenchmark
