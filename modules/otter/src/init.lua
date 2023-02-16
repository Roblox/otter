local createGroupMotor = require(script.createGroupMotor)
local createSingleMotor = require(script.createSingleMotor)
local spring = require(script.spring)
local instant = require(script.instant)
local types = require(script.types)

export type Goal<T> = types.Goal<T>
export type SingleMotor = types.SingleMotor
export type GroupMotor = types.GroupMotor

export type SpringOptions = spring.SpringOptions

return {
	createGroupMotor = createGroupMotor,
	createSingleMotor = createSingleMotor,
	spring = spring,
	instant = instant,
}
