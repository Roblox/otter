local Root = script.Parent.OtterTest
local processServiceExists, ProcessService = pcall(function()
	return game:GetService("ProcessService")
end)

local Packages = Root.Packages
if not Packages then
	game:GetService("TestService"):Error("Invalid Package configuration. Try running `rotrieve install` to remedy.")
	ProcessService:ExitAsync(1)
end

-- FIXME: workspaces + jest 3.0 testing story still needs some work
local WorkspaceRoot = Packages._Workspace
local runCLI = require(WorkspaceRoot.Otter.Dev.Jest).runCLI

local status, result = runCLI(WorkspaceRoot, {}, { WorkspaceRoot }):awaitStatus()

if status == "Rejected" then
	print(result)
end

if status == "Resolved" and result.results.numFailedTestSuites == 0 and result.results.numFailedTests == 0 then
	if processServiceExists then
		ProcessService:ExitAsync(0)
	end
end

if processServiceExists then
	ProcessService:ExitAsync(1)
end
