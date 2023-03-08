--!strict
local Packages = script.Parent.Parent.Parent
local Otter = require(Packages.Otter)

local function randomSpringGoal()
	return Otter.spring(math.random() * 1000, {
		frequency = 1 + math.random() * 4,
		dampingRatio = 0.5 + math.random() * 0.5,
	})
end

return randomSpringGoal
