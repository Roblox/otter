# Goals

**Goals** are what you use to tell [motors](../motors.md) what to move towards. There are two kinds of goals: [spring](./spring.md) and [instant](./instant.md) goals. Spring goals replicate the motion of a spring, and allow you to specify a frequency and a damping ratio. Instant goals immediately move the motor to a value, and are useful for resetting a motor's value.

Goals are given to a motor using the motor's `setGoal` method. For group motors, you can specify a different goal for each value.

## Spring goals

Spring goals use a model of a physical spring to animate towards a value over time. Spring goals animate faster for larger values automatically - moving over a small distance will visually move slower than moving over a large one. They also preserve velocity and will take time to decelerate. These two properties make your user interface feel more realistic and fluid.

Spring goals are created using the `Otter.spring` constructor. This constructor takes two arguments: the value to move towards and an optional table of parameters. This table has two values:

* `frequency`: A number that represents how quickly the spring responds to changes. Higher values move faster, lower values move slower. Defaults to 1.
* `dampingRatio`: A number that represents how dampened the spring is. Defaults to 1.

## Instant goals

Instant goals immediately move the motor to the goal. They're useful for resetting a value so that you can animate it again.

Instant goals are created using the `Otter.instant` constructor. This constructor takes one argument: the value to jump to.