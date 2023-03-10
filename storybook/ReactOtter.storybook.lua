local Packages = script.Parent.Parent
local Roact = require(Packages._Workspace.ReactOtter.Dev.RoactCompat)

return {
	name = "React + Otter",
	storyRoots = { script.Parent.stories },
	roact = Roact,
}
