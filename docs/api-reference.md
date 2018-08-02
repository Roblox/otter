## Methods

### Otter.createSingleMotor
```
Otter.createSingleMotor(initialValue: number)
```

Constructs a motor that controls a single value.

### Otter.createGroupMotor
```
Otter.createGroupMotor(initialValues: { string: number })
```

Constructs a motor that controls a group of values.

### Otter.spring
```
Otter.spring(targetValue: number, springParams?)
```

Constructs a goal that uses spring physics to transition to the target value.

Valid spring parameters are:

* `frequency`: The undamped frequency of the spring in cycles per second.
* `dampingRatio`: The damping ratio of the spring.

### Otter.instant
```
Otter.instant(targetValue: number)
```

Constructs a goal that immediately reaches the target value.