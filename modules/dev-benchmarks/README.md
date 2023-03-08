# Otter Benchmarks

A collection of benchmarks for testing Otter performance, both in isolation and in the context of react usage.

## React Benchmarks

A set of benchmarks written around Roact components. Each benchmark renders a React component that:
* consists of a couple of buttons (intended to be simple but not completely trivial)
* animates its position from one corner of the "screen" to the other
* demonstrates idiomatic usage of Otter motors in practice
* uses a motor from `createSingleMotor` that simply increments a value (no spring computations)

### Legacy Roact

* `legacyRoact/classWithBinding`
* `legacyRoact/classWithState`

A pair of benchmarks that help establish a baseline against historical usage by rendering an animated component using the _legacy_ Roact implementations. They use idiomatic patterns with state and bindings and use a motor that steps incrementally towards a value (the stepping motor should help isolate the animation logic from spring calculations). These provide a baseline for comparison of the performance of bindings-driven approaches across React versions (and via the `useAnimatedBinding` hook) and provide a reference point for the performance properties of re-rendering using state.

**Note: Legacy Roact is _already known_ to be faster with small, synchronous workloads since it doesn't have as much scheduling overhead. Using Roact 17 with function components is still the only way to leverage the power and ergonomics of hooks and the benefits of asynchronous rendering.**

### Roact 17

* `react/classWithState`
* `react/functionWithState`
* `react/classWithBinding`
* `react/functionWithBinding`

These benchmarks measure practical uses of Otter to animate React components using configurations of class components vs function components and state vs bindings for tracking and responding to animation state. They do not use any new functionality from `ReactOtter`. They should provide a good baseline for the 0.1.4 release of Otter that's used in the Universal App.

## Spring Benchmarks

* `spring/spring`
* `spring/legacyWithSpring`

A set of benchmarks to measure the cost of spring calculations. Each of these uses a single motor with randomized spring goals and runs 10,000 steps of the spring. The `legacyWithSpring` component measures using springs in actual components and render the same minimal button container component as the React benchmarks.
