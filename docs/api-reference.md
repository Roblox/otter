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
Otter.spring(targetValue: number, springParams?)
```

Constructs a goal that uses spring physics to transition to the target value.

Valid spring parameters are:

* `frequency`: The undamped frequency of the spring in cycles per second.
* `dampingRatio`: The damping ratio of the spring.

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