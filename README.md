<h1 align="center">Roto</h1>
<div align="center">
<!-- Coming soon!
	<a href="https://travis-ci.org/Roblox/roto">
		<img src="https://api.travis-ci.org/Roblox/roto.svg?branch=master" alt="Travis-CI Build Status" />
	</a>
	<a href="https://coveralls.io/github/Roblox/roto?branch=master">
		<img src="https://coveralls.io/repos/github/Roblox/roto/badge.svg?branch=master" alt="Coveralls Coverage" />
	</a>
	<a href="https://roblox.github.io/roto">
		<img src="https://img.shields.io/badge/docs-website-green.svg" alt="Documentation" />
	</a>
-->
</div>

<div align="center">
	Declarative animation library for Roblox Lua using (but not limited to) springs.
</div>

<div>&nbsp;</div>

## Installation
*In progress*

## Usage
For each value that needs to be tweened, create a `Roto.Motion` object with a `kind` and `callback` parameter:

```lua
local object = Instance.new("Frame")
object.Size = UDim2.new(0, 50, 0, 50)

local motion = Roto.Motion.new({
	kind = Roto.Spring.new({
		dampingRatio = 1,
		frequency = 1,
		position = 0,
	}),
	callback = function(position)
		object.Position = UDim2.new(0, position, 0, 0)
	end,
})
```

The `Motion` object is in charge of stepping the motion driver (passed via `kind`) every frame and notifying you of the new value of the motion.

Right now, Roto only has the `Spring` driver, but in the future it could also include:

* `Instant`
* `Linear`
* Time-based tween curves
* Higher-order drivers for looping or inverting

Any object that satifies the correct interface can be used as a motion driver:

```
setGoal(...any)
getValue() -> number
step(dt: number)
```

Roto is *declarative*; just call `setGoal` to retarget an animation. In the case of springs, this preserves momentum, too:

```lua
motion:setGoal(100)
wait(0.5)
motion:setGoal(400)
```

When you're done, destructing the `Motion` object will stop it:

```lua
motion:destruct()
```

## License
Roact is available under the Apache 2.0 license. See [LICENSE](LICENSE) for details.