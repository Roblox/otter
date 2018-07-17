return function()
	local Motion = require(script.Parent).Motion
	local Spring = require(script.Parent).Spring

	it("should have all expected APIs", function()
		expect(Motion).to.be.a("table")

		local template = {}
		function template:step(dt)
			return true
		end
		function template:getValue()
			return 1
		end
		function template:setGoal()
			return 1
		end

		local test = Motion.new({
			kind = template,
			callback = function() end,
			onComplete = function() end,
		})
		test:destroy()
	end)

	it("setGoal should pass correct value to kind", function()
		local template = {}
		local wasCalled = false
		function template:setGoal(number)
			expect(number).to.equal(5)
			wasCalled = true
		end
		local motion = Motion.new({
			kind = template,
			callback = function() end,
		})
		motion:setGoal(5)
		motion:destroy()
		expect(wasCalled).to.be.equal(true)
	end)

	it("should call onComplete if already completed", function()
		local template = {}
		function template:step(dt)
			return true
		end
		function template:getValue()
			return 1
		end

		local counter = 0
		local motion = Motion.new({
			kind = template,
			callback = function() end,
			onComplete = function()
				counter = counter + 1
			end,
		})
		motion:step(0)
		motion:destroy()
		expect(counter).to.be.equal(1)
	end)

	it("should be able to call onComplete multiple times", function()
		local template = {}
		function template:step(dt)
			return true
		end
		function template:getValue()
			return 1
		end
		function template:setGoal()
			return 1
		end

		local counter = 0
		local motion = Motion.new({
			kind = template,
			callback = function() end,
			onComplete = function()
				counter = counter + 1
			end,
		})
		motion:step(0.1)
		expect(counter).to.be.equal(1)
		motion:setGoal()
		expect(counter).to.be.equal(1)
		motion:step(0.1)
		expect(counter).to.be.equal(2)
		motion:destroy()
	end)

	it("should not call onComplete if not completed", function()
		local template = {}
		function template:step(dt)
			return false
		end
		function template:getValue()
			return 1
		end

		local failed = false

		local motion = Motion.new({
			kind = template,
			callback = function() end,
			onComplete = function()
				failed = true
			end,
		})
		motion:step(0)
		motion:destroy()
		expect(failed).to.be.equal(false)
	end)

	describe("should integrate with spring", function()
		it("can take a spring as a kind", function()
			Motion.new({
				kind = Spring.new({
					dampingRatio = 1,
					frequency = 0.5,
					position = 1,
				}),
				callback = function() end,
			})
		end)

		it("can step a spring to completion", function()
			local lastValue = 1
			local motion = Motion.new({
				kind = Spring.new({
					dampingRatio = 1,
					frequency = 0.5,
					position = 1,
				}),
				callback = function(value)
					expect(value >= lastValue).to.equal(true)
					lastValue = value
				end,
			})
			motion:setGoal(3)
			while not motion:step(0.5) do
			end
			motion:destroy()
		end)
	end)
end