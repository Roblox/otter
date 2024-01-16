# Using Otter with React

## ReactOtter

React and Otter can be used together easily with the `ReactOtter` package exported from this repo. Install it instead of (or in addition to) the base Otter package:
```toml
[dependencies]
ReactOtter = "github.com/Roblox/otter@1.0"

# You'll only need this if you use Otter directly
Otter = "github.com/Roblox/otter@1.0"
```

## useAnimatedBinding
ReactOtter provides a React hook called `useAnimatedBinding`, a simple and expressive mechanism to drive Otter animations within React function components.

It accepts two arguments:

* `initialValue: number | { [string]: number }` - The starting value for the binding (similar to the value you'd pass to `React.useBinding` or the value you'd pass to `Otter.createSingleMotor`/`Otter.createGroupMotor`)
	* This can be either a single `number` value or a table that maps string keys to number values; `useAnimatedBinding` will automatically use the right representation under the hood
* `onComplete: nil | (number | { [string]: number }) -> ()` - An optional parameter that will be called each time an animated transition completes

The hook returns two values to use in your component:

* `value: React.Binding<number | { [string]: number }>` - a `React.Binding` object that will be updated with the motor's progress value at each step while it's running
* `setGoal: (ReactOtter.Goal) -> ()` - a function that can be used to provide new target values called `goal`s to the animated binding, akin to Otter's `Motor:setGoal(goal)`

Provide the binding to a property that you'd like to animate (or use `Binding:map` to transform its value) and use the `setGoal` function to trigger the animation.

### Example: Simple Usage

The `useAnimatedBinding` hook should be sufficient for most use cases of Otter in React components. In a simple case, it can be used to animate from one value to another. A silly example might look like:

```lua
local function ToggleTextSize()
	local toggled, setToggled = React.useState(false)
	local value, setGoal = ReactOtter.useAnimatedBinding(8)

	React.useEffect(function()
		setGoal(ReactOtter.spring(if toggled then 24 else 8))
	end, { toggled })

	return React.createElement("TextButton", {
		Text = "Hello",
		TextSize = value,
		Size = UDim2.new(0, 200, 0, 50),
		[React.Event.Activated] = function()
			setToggled(not toggled)
		end,
	})
end
```

### Example: Mapped Values

Most of the time, you won't want to use your animation value directly. Often you'll want to animate between two position or size values. Instead of needing our animation value to be the exact derived value we configure our elements with, we can use any arbitrary animation progress values (`0` and `1` is nice and simple) and use the `map` capability of bindings:

```lua
local function ExpandableFrame(props: Props)
	local expanded, setExpanded = React.useState(false)
	local height, setGoal = useAnimatedBinding(0)

	React.useEffect(function()
		setGoal(if expanded then 1 else 0)
	end, { expanded })

	return React.createElement(
		"Frame",
		{ Size = props.size },
		React.createElement("TextButton", {
			Text = if expanded then "Collapse" else "Expand"
			Size = UDim2.new(1, 0, 0, 40),
		}),
		React.createElement("Frame", {
			Position = UDim2.new(0, 0, 0, 40),
			-- Derive the UDim2 size value from the animation progress value
			Size = height:map(function(value)
				return UDim2.new(1, 0, value, -40 * value),
			end),
		}, props.content),
	)
end
```

### Example: Side Effects On Completion

In some cases, you may want to delay other side effects until an animation completes. In these scenarios, you can provide an `onComplete` callback as a second argument to `useAnimatedBinding`. Use this callback to update state/bindings, run passed-in callbacks, or trigger other side effects.

```lua
local function DisabledWhileAnimating()
	local enabled, setEnabled = React.useState(false)
	local translated, setTranslated = React.useState(false)
	local x, setGoal = ReactOtter.useAnimatedBinding(0, function()

		setEnabled(true)
	end)

	React.useEffect(function()
		setGoal(ReactOtter.spring(if translated then 1 else 0))
		setEnabled(false)
	end, { translated })

	return React.createElement(
		"Frame",
		{ Size = props.size },
		React.createElement("TextButton", {
			Active = enabled,
			Text = if enabled then "Click me" else "Don't click",
			Size = UDim2.new(0, 150, 0, 50),
			Position = x:map(function(value)
				return UDim2.new(value, -150 * value, 0.5, 0)
			end),
			[React.Event.Activated] = function()
				setTranslated(not translated)
			end,
		})
	)
end
```

### Example: Multiple Values

Sometimes, it may be preferable to animate several values at once rather than a single value. While you can typically map everything back to a single animation progress value (as shown in the [Mapped Values](#mapped-values) example), a table of separate values might be clearer.

In the example below, we want to animate the transparency of the panel that's fading in with a different spring configuration than what we're using to animate its scale:
```lua
local TRANSPARENCY_CONFIG = {
	dampingRatio = 1,
	frequency = 3,
}

local function FadeAndGrowIn(props)
	local visible, setVisible = React.useState(false)
	local animationState, setGoal = ReactOtter.useAnimatedBinding({
		transparency = 1,
		scale = 0.8,
	})

	React.useEffect(function()
		setGoal({
			transparency = ReactOtter.spring(
				if visible then 0 else 1,
				TRANSPARENCY_CONFIG
			),
			-- default spring config
			scale = ReactOtter.spring(if visible then 1 else 0.8),
		})
	end, { visible })

	return React.createElement(
		"Frame",
		{ Size = props.size },
		React.createElement("TextButton", {
			Text = if visible then "Hide" else "Show",
			Size = UDim2.new(0, 200, 0, 50),
			[React.Event.Activated] = function()
				setVisible(not visible)
			end,
		}),
		React.createElement("TextLabel", {
			Text = "Content",
			BackgroundTransparency = animationState:map(function(state)
				return state.transparency
			end),
			Size = animationState:map(function(state)
				return UDim2.new(1 * state.scale, 0, 0, 200 * state.scale)
			end),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 25),
		})
	)
end
```

## useMotor
In rare cases, you may need your React component to update values on _non_-React Instances in the DataModel. To do this, you can use a slightly more lower-level hook called `useMotor`.

!!! warning
	In most cases, it's preferable to use the binding semantics afforded by `useAnimatedBinding` to reduce boilerplate and keep your use cases simple and idiomatic. Only reach for `useMotor` if you need to animate something that can't accept a binding.

The `useMotor` hook accepts three arguments:

* `initialValue: number | { [string]: number }` - The starting value for the motor. This works exactly like the `initialValue` argument to `useAnimatedBinding`.
* `onStep: (number | { [string]: number }) -> ()` - A callback that fires on each step. The current value of the motor will be passed in, honoring the type of your `initialValue` just as `useAnimatedBinding` does.
* `onComplete: nil | (number | { [string]: number }) -> ()` - An optional parameter that will be called each time an animated transition completes. This works exactly like the `onComplete` argument to `useAnimatedBinding`.

It returns only a `setGoal` function, equivalent to the second return value from `useAnimatedBinding`.

