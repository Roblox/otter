# Otter Version History

## Unreleased

## 0.1.3
* Prevent `__onComplete` from being fired in `step` if an onStep callback stops the motor beforehand

## 0.1.2
* Added new configs to set the resting limit for the spring ([#36](https://github.com/Roblox/otter/pull/36))
  * restingVelocityLimit - configures the resting velocity limit of the spring. Default: 0.001
  * restingPositionLimit - configures the resting position limit of the spring. Default: 0.01

## 0.1.1
* Allow for setting a new goal in onStep callback for groupMotor ([#27](https://github.com/Roblox/otter/pull/27))
* Fix issue with using setGoal in onComplete callbacks ([#34](https://github.com/Roblox/otter/pull/34))

## 0.1.0
* Initial implementation