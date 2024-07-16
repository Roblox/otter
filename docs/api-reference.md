## ReactOtter

### useAnimatedBinding
```lua
type ValueType = number | { [string]: number }
type GoalType = Otter.Goal<any> | { [string]: Otter.Goal<any> }

ReactOtter.useAnimatedBinding<ValueType, GoalType>(
	initialValue: ValueType,
	onComplete: nil | (ValueType) -> ()
): (
	binding: React.Binding<ValueType>,
	setGoal: (GoalType) -> ()
)
```
A React hook that provides a simple and expressive mechanism to drive Otter animations within React function components.

If the initial value provided is a number, the hook will use a [Single Motor](#ottercreatesinglemotor) under the hood; if it's a table of values, it will use a [Group Motor](#ottercreategroupmotor).

The returned `binding` can be used to provide values to properties to your component's returned elements, and the `setGoal` function should be called as a side effect to trigger new animations.

Learn more about how to use this hook in the [usage section](usage/react.md).

### useMotor
```lua
type ValueType = number | { [string]: number }
type GoalType = Otter.Goal<any> | { [string]: Otter.Goal<any> }

ReactOtter.useMotor<ValueType, GoalType>(
	initialValue: ValueType,
	onStep: (ValueType) -> ()
	onComplete: nil | (ValueType) -> ()
): setGoal: (GoalType) -> ()
```
A React hook that provides a slightly lower-level interface to an Otter motor. Use this hook in scenarios where a binding is not sufficient for your animation needs.

Learn more about how to use this hook in the [usage section](usage/react.md#usemotor).

!!! warning
	The `useMotor` hook is an escape hatch designed for handling uncommon use case. In general, you should prefer `useAnimatedBinding` instead.

### ease
Re-exports [`Otter.ease`](#otterease) for easier use within React components.

### spring
Re-exports [`Otter.spring`](#otterspring) for easier use within React components.

### instant
Re-exports [`Otter.instant`](#otterinstant) for easier use within React components.

## Otter

### Otter.createSingleMotor
```lua
Otter.createSingleMotor(initialValue: number): Otter.SingleMotor
```

Constructs a motor that controls a single value.

### Otter.createGroupMotor
```lua
Otter.createGroupMotor(initialValues: { string: number }): Otter.GroupMotor
```

Constructs a motor that controls a group of values.

### Otter.ease
```lua
Otter.ease(targetValue: number, config: Config?): Otter.Goal<EaseState>
```

Constructs a goal that uses easing options to transition to the target value. The `config` argument is an optional table of ease configuration data.

#### EaseOptions

The default ease configuration parameters.

```lua
type EaseOptions = {
	-- The duration of the animation, in seconds. Defaults to 1.
	duration: number?
	-- The easing style of the animation. Defaults to Enum.EasingStyle.Linear.
	easingStyle: Enum.EasingStyle?
}
```

### Otter.spring
```lua
Otter.spring(targetValue: number, config: Config?): Otter.Goal<SpringState>
```

Constructs a goal that uses spring physics to transition to the target value. The `config` argument is an optional table of spring configuration data. It can be one of the following:

#### SpringConfig

The default spring configuration parameters.

```lua
type SpringConfig = {
	-- The undamped frequency of the spring in cycles per second. Defaults to 1.
	frequency: number?
	-- The damping ratio of the spring. Defaults to 1.
	dampingRatio: number?
	-- The resting velocity limit for the spring. Defaults to 0.001.
	restingVelocityLimit: number?
	-- The resting position limit for the spring. Defaults to 0.01.
	restingPositionLimit: number?
}
```

#### FigmaSpringConfig

A set of parameters that matches the spring inputs from [design tools like Figma](https://help.figma.com/hc/en-us/articles/360051748654-Prototype-easing-and-spring-animations#Custom_spring_curves).

```lua
type SpringConfig = {
	-- Influences the number of “bounces” in the animation.
	stiffness: number,
	-- Influences the level of spring in the animation.
	damping: number,
	-- Influences the speed of the animation and height of the bounce.
	mass: number,
	 -- The resting velocity limit for the spring. Defaults to 0.001.
	restingVelocityLimit: number?
	 -- The resting position limit for the spring. Defaults to 0.01.
	restingPositionLimit: number?
}
```

The spring will be considered "resting" when both its position and velocity are under their resting limits. After that point, Otter stops simulating the spring and will fire the motor's `onComplete` handler.

Tweaking `restingVelocityLimit` and `restingPositionLimit` may be necessary if:

* `onComplete` fires too early, causing the spring visibly "teleport" to its goal
* `onComplete` fires too late, causing the spring pause very near to its goal for some time before triggering completion logic

### Otter.instant
```lua
Otter.instant(targetValue: number): Otter.Goal<State>
```

Constructs a goal that immediately reaches the target value.


### Motor API

#### setGoal
```lua
Motor<_, GoalType>:setGoal(goal: GoalType): ()
```

Sets the goal of a motor and, if the motor is stopped, starts it. For single motors, the `GoalType` be a single goal value:
```lua
singleMotor:setGoal(Otter.spring(1))
```

For group motors, the `GoalType` will be a map of goals to the values that the group motor controls:
```lua
groupMotor:setGoal({
	height = Otter.instant(100),
	transparency = Otter.spring(0),
})
```

#### onStep
```lua
Motor<ValueType, _>:onStep(
	callback: (value: ValueType) -> ()
): () -> ()
```

Subscribes to a Motor's step signal with the given callback. The signal will fire with the motor's new value(s) whenever the it updates.

A single motor will receive a `number` as the `ValueType` provided to the callback:
```lua
local subscription = singleMotor:onStep(function(value)
	print("Updated with " .. tostring(value))
end)
```

A group motor will receive a mapping of string keys to `number` values:
```lua
local subscription = groupMotor:onStep(function(values)
	print("Updated with:")
	for key, value in values do
		print("\t" .. key .. ": " .. tostring(value))
	end
end)
```

Returns a function that, when called, unsubscribes the callback.

#### onComplete
```lua
Motor<ValueType, _>:onComplete(
	callback: (value: ValueType) -> ()
) -> disconnectFunction
```

Connects a callback that will be called with the motor's current value(s) when it has reached all of its goals.

Returns a function that, when called, unsubscribes the callback.

#### start
```
Motor<_, _>:start(): ()
```

Starts the motor, allowing it to move. You shouldn't normally need to call this method; motors start themselves as needed.

#### step
```
Motor<_, _>:step(dt: number): ()
```

Manually steps the motor by a certain time step. Much like `start`, you shouldn't need to call this normally.

#### stop
```
Motor<_, _>:stop(): ()
```

Stops the motor, freezing it in time until `start` or `setGoal` is next called.

#### destroy
```
Motor<_, _>:destroy(): ()
```

Destroys the motor, rendering it unusable and cleaning up any connections.
