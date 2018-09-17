local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TestEZ = require(ReplicatedStorage.Modules.TestEZ)

local Otter = ReplicatedStorage.Modules.Otter

TestEZ.TestBootstrap:run({ Otter }, TestEZ.Reporters.TextReporter)