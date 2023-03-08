local ClassWithBinding = require(script.Components.ClassWithBinding)
local ClassWithState = require(script.Components.ClassWithState)
local FunctionWithBinding = require(script.Components.FunctionWithBinding)
local FunctionWithState = require(script.Components.FunctionWithState)

local legacyClassWithBinding = require(script.Legacy.ClassWithBinding)
local legacyClassWithState = require(script.Legacy.ClassWithState)

local runBenchmark = require(script.runBenchmark)
local runLegacyBenchmark = require(script.runLegacyBenchmark)

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
	legacyClassWithState = function()
		runLegacyBenchmark(legacyClassWithState)
	end,
	legacyClassWithBinding = function()
		runLegacyBenchmark(legacyClassWithBinding)
	end,
	spring = require(script.Goals.spring),
	legacyWithSpring = require(script.Goals.LegacyWithSpring),
}
