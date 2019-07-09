# Motors

Motors are the mechanism that Otter uses to animate values. Motors receive a [goal](./goals/index.md) and animate towards it. There are two kinds of motors: **single motors**, which animate a single value, and **group motors**, which animate multiple values in parallel.

## Creating motors

Motors are created using `createSingleMotor` and `createGroupMotor`, which create a single and group motor, respectively. These functions take one argument each: the initial value(s) that the motor uses. For single motors, this is one value. For group motors, this is a dictionary of each value that the motor will be animating.

!!! note
    When creating a group motor, all values must be specified at creation. You cannot add a value to a group motor after it is created.

```lua
local singleMotor = Otter.createSingleMotor(0)
local groupMotor = Otter.createGroupMotor({
	x = 0,
	y = 0,
})
```

## Using motors

### Assigning goals

Motors will animate when given goals to move towards. To supply a goal to a motor, use `setGoal`:

```lua
singleMotor:setGoal(Otter.spring(1))

groupMotor:setGoal({
	x = Otter.spring(300),
	y = Otter.spring(150),
})
```

This will start both `singleMotor` and `groupMotor` and make them move towards their position.

### Extracting values

In order to use the values that a motor is animating, call `onStep` with a callback. The callback will be called once per frame while the motor moves towards its goals. For single motors, the callback will be passed the current value; for group motors, it will be passed a dictionary of all values (even if a value has reached its goal).

```lua
singleMotor:onStep(function(transparency)
	-- do something with transparency
end)

groupMotor:onStep(function(values)
	local x = values.x
	local y = values.y

	-- position something somewhere
end)
```

## Demo: Following the mouse

This code, when run on the client, creates a frame that follows the mouse.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Otter = require(ReplicatedStorage.Otter)

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

local container = Instance.new("ScreenGui")
container.ResetOnSpawn = false
container.Parent = localPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(1, 1)
frame.Size = UDim2.new(0, 20, 0, 20)
frame.BorderSizePixel = 0
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.Parent = container

local positionMotor = Otter.createGroupMotor({
	x = 0,
	y = 0,
})

positionMotor:onStep(function(values)
	frame.Position = UDim2.new(0, values.x, 0, values.y)
end)

local function updateMotor()
	positionMotor:setGoal({
		x = Otter.spring(mouse.X),
		y = Otter.spring(mouse.Y),
	})
end

updateMotor()
mouse.Move:Connect(updateMotor)
```

## Manually running motors

Normally, motors automatically start when they are given a goal, and stop when they reach it. In some cases you may need to manually stop or start a motor, which you can do with the `start` and `stop` methods of the motor.

Stopping the motor while it is moving towards a goal will freeze it in time. It will retain its current velocity and goal, but will not move towards it, and any functions passed to `onStep` will not be called.

Starting the motor will resume the motor from this paused state. If the motor has already reached its goal, the motor will immediately stop again.