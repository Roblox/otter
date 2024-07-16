local Packages = script.Parent.Parent
local Roact = require(Packages._Workspace.ReactOtter.Dev.RoactCompat)

return {
	name = "React + Otter",
	storyRoots = { script.Parent.stories },
	-- RoactCompat is required for storybooks to work with Roact 17
	roact = Roact,
}
