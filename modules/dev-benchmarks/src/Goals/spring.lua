--!strict
local Packages = script.Parent.Parent.Parent
local Otter = require(Packages.Otter)

local measureAndReport = require(script.Parent.Parent.measureAndReport)

local randomSpringGoal = require(script.Parent.randomSpringGoal)

local STEP_COUNT = 10000

return function()
	local motor = Otter.createSingleMotor(0)

	motor:onComplete(function()
		motor:setGoal(randomSpringGoal())
	end)

	motor:setGoal(randomSpringGoal())

	local AnimationStepSignal = Otter.__devAnimationStepSignal

	measureAndReport(function()
		for _ = 1, STEP_COUNT do
			AnimationStepSignal:Fire()
		end
	end, STEP_COUNT)
end
