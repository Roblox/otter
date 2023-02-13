## Methods

### Otter.createSingleMotor
```
Otter.createSingleMotor(initialValue: number)
```

Constructs a motor that controls a single value.

---

### Otter.createGroupMotor
```
Otter.createGroupMotor(initialValues: { string: number })
```

Constructs a motor that controls a group of values.

---

### Otter.spring
```
Otter.spring(targetValue: number, springConfig?)
```

Constructs a goal that uses spring physics to transition to the target value. The `springConfig` argument is an optional table of spring configuration data. It can be one of the following:

**SpringConfig**

The default spring configuration parameters.

```lua
type SpringConfig = {
     -- The undamped frequency of the spring in cycles per second.
    frequency: number?
     -- The damping ratio of the spring.
    dampingRatio: number?
     -- The resting velocity limit for the spring. Defaults to 0.001.
    restingVelocityLimit: number?
     -- The resting position limit for the spring. Defaults to 0.01.
    restingPositionLimit: number?
}
```

**FigmaSpringConfig**

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

Tweaking `restingVelocityLimit` and `restingPositionLimit` may be necessary if `onComplete` fires too early, and the spring jumps to its goal, or if `onComplete` fires too late, and the spring sits at its goal for some time.

---

### Otter.instant
```
Otter.instant(targetValue: number)
```

Constructs a goal that immediately reaches the target value.

## Motors

### setGoal
```
setGoal(goal) -> void
```

Sets the goal of a motor and, if the motor is stopped, starts it.

---

### onStep
```
onStep(callback) -> disconnectFunction
```

Connects a callback that will be called with the motor's new value(s) whenever the motor updates. Returns a function that, when called, disconnects the callback from the motor.

---

### onComplete
```
onComplete(callback) -> disconnectFunction
```

Connects a callback that will be called with the motor's current value(s) when it has reached all of its goals. Returns a function that, when called, disconnects the callback from the motor.

---

### start
```
start() -> void
```

Starts the motor, allowing it to move. You shouldn't normally need to call this method; motors start themselves as needed.

---

### step
```
step(dt) -> void
```

Manually steps the motor by a certain time step. Much like `start`, you shouldn't need to call this normally.

---

### stop
```
stop() -> void
```

Stops the motor, freezing it in time.

---

### destroy
```
destroy() -> void
```

Destroys the motor, rendering it unusable.
