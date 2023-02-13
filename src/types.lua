--!strict
type Disconnector = () -> ()
type Callback<T> = (T) -> ()

-- Animation values need to be continuous and interpolatable; for now, that's
-- probably just numbers, but one could imagine something more sophisticated
export type AnimationValue = number

type Empty = {}
export type State = {
	value: AnimationValue,
	complete: boolean,
}

export type Goal<T = Empty> = {
	step: (state: State & T, dt: number) -> State & T,
}

export type SingleMotor = {
	start: (self: SingleMotor) -> (),
	stop: (self: SingleMotor) -> (),
	step: (self: SingleMotor, dt: number) -> (),
	setGoal: (self: SingleMotor, goal: Goal) -> (),
	onStep: (self: SingleMotor, callback: Callback<AnimationValue>) -> Disconnector,
	onComplete: (self: SingleMotor, callback: Callback<AnimationValue>) -> Disconnector,
	destroy: (self: SingleMotor) -> (),
}

export type GroupMotor = {
	start: (self: GroupMotor) -> (),
	stop: (self: GroupMotor) -> (),
	step: (self: GroupMotor, dt: number) -> (),
	setGoal: (self: GroupMotor, goal: { [string]: Goal }) -> (),
	onStep: (self: GroupMotor, callback: Callback<AnimationValue>) -> Disconnector,
	onComplete: (self: GroupMotor, callback: Callback<AnimationValue>) -> Disconnector,
	destroy: (self: GroupMotor) -> (),
}

return nil
