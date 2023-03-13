local Otter = require(script.Parent.Otter)
local useAnimatedBinding = require(script.useAnimatedBinding)

export type Goal = Otter.Goal<any>
export type SpringOptions = Otter.SpringOptions

return {
	useAnimatedBinding = useAnimatedBinding,
	spring = Otter.spring,
	instant = Otter.instant,
}
