--!strict
local ClassWithBinding = require(script.Components.ClassWithBinding)
local ClassWithState = require(script.Components.ClassWithState)
local FunctionWithBinding = require(script.Components.FunctionWithBinding)
local FunctionWithState = require(script.Components.FunctionWithState)
local Hook = require(script.Components.Hook)
local Scroller = require(script.Components.Scroller)
local Resizer = require(script.Components.Resizer)

local legacyClassWithBinding = require(script.Legacy.ClassWithBinding)
local legacyClassWithState = require(script.Legacy.ClassWithState)

local runBenchmark = require(script.runBenchmark)
local runLegacyBenchmark = require(script.runLegacyBenchmark)
local runFPSBenchmark = require(script.runFPSBenchmark)

local RunService = game:GetService("RunService")

return {
	classWithBinding = function()
		runBenchmark(ClassWithBinding)
	end,
	classWithState = function()
		runBenchmark(ClassWithState)
	end,
	functionWithBinding = function()
		runBenchmark(FunctionWithBinding)
	end,
	functionWithState = function()
		runBenchmark(FunctionWithState)
	end,
	useAnimatedBinding = function()
		runBenchmark(Hook)
	end,
	legacyClassWithState = function()
		runLegacyBenchmark(legacyClassWithState)
	end,
	legacyClassWithBinding = function()
		runLegacyBenchmark(legacyClassWithBinding)
	end,
	spring = require(script.Goals.spring),
	hookWithSpring = require(script.Goals.HookWithSpring),
	legacyWithSpring = require(script.Goals.LegacyWithSpring),
	heartbeatScrolling = function()
		runFPSBenchmark(Scroller, RunService.Heartbeat, 3800)
	end,
	renderSteppedScrolling = function()
		runFPSBenchmark(Scroller, RunService.RenderStepped, 3800)
	end,
	heartbeatResizing = function()
		runFPSBenchmark(Resizer, RunService.Heartbeat, 1000)
	end,
	renderSteppedResizing = function()
		runFPSBenchmark(Resizer, RunService.RenderStepped, 1000)
	end,
}
