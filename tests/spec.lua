local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TestEZ = require(ReplicatedStorage.Packages.Dev.TestEZ)

local results = TestEZ.TestBootstrap:run({
	ReplicatedStorage.Packages.Otter,
})

local success, ProcessService = pcall(game.GetService, game, "ProcessService")
if success and ProcessService then
	ProcessService:ExitAsync(results.failureCount == 0 and 0 or 1)
end

return nil
