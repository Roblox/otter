# Otter Version History

## Unreleased

## 1.1.1
* Switch from applying updated properties on Heartbeat to applying them on RenderStepped.
* Include benchmarks for spring animations for scrolling and resizing using both RunService.Heartbeat and RunService.RenderStepped. ([#57](https://github.com/Roblox/otter-internal/pull/57))

## 1.1.0
* Add a `useMotor` hook that has a slightly lower-level interface to accommodate special cases around animating non-React Instances ([#51](https://github.com/Roblox/otter-internal/pull/51))

## 1.0.1
* Improve internal type interface and type strictness, expose public types, and fix inconsistency between single motor and group motor APIs. This is a **breaking change**! ([#45](https://github.com/Roblox/otter-internal/pull/45))
* Optionally accept Figma-style spring arguments instead of the default (`dampingRatio` and `frequency`) ([#44](https://github.com/Roblox/otter-internal/pull/44))
* Upgrade to jest 3 ([#43](https://github.com/Roblox/otter-internal/pull/43))

## 0.1.3
* Prevent `__onComplete` from being fired in `step` if an onStep callback stops the motor beforehand

## 0.1.2
* Added new configs to set the resting limit for the spring ([#36](https://github.com/Roblox/otter-internal/pull/36))
  * restingVelocityLimit - configures the resting velocity limit of the spring. Default: 0.001
  * restingPositionLimit - configures the resting position limit of the spring. Default: 0.01

## 0.1.1
* Allow for setting a new goal in onStep callback for groupMotor ([#27](https://github.com/Roblox/otter-internal/pull/27))
* Fix issue with using setGoal in onComplete callbacks ([#34](https://github.com/Roblox/otter-internal/pull/34))

## 0.1.0
* Initial implementation
