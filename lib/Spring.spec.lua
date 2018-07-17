return function()
	local Spring = require(script.Parent).Spring

	it("should have all expected APIs", function()
		local spring = Spring.new({
			dampingRatio = 1,
			frequency = 0.5,
			position = 1,
		})
		expect(spring).to.be.a("table")
		expect(Spring.new).to.be.a("function")
		expect(spring.setGoal).to.be.a("function")
		expect(spring.getValue).to.be.a("function")
		expect(spring.step).to.be.a("function")
	end)

	it("should throw exceptions when passed bad args", function()
		expect(function()
			Spring.new()
		end).to.throw()
		expect(function()
			Spring.new({})
		end).to.throw()

		expect(function()
			Spring.new({
				dampingRatio = {},
				frequency = 0.5,
				position = 1,
			})
		end).to.throw()

		expect(function()
			Spring.new({
				dampingRatio = 1,
				frequency = {},
				position = 1,
			})
		end).to.throw()

		expect(function()
			Spring.new({
				dampingRatio = 1,
				frequency = 0.5,
				position = {},
			})
		end).to.throw()

		expect(function()
			Spring.new({
				dampingRatio = -1,
				frequency = 0.5,
				position = 1,
			})
		end).to.throw()

		Spring.new({
			dampingRatio = 1,
			frequency = 0.5,
			position = 1,
		})
	end)

	it("should remember its position", function()
		local spring = Spring.new({
			dampingRatio = 1,
			frequency = 0.5,
			position = 1,
		})
		expect(spring:getValue()).to.equal(1)
	end)

	it("should return complete when done", function()
		local spring = Spring.new({
			dampingRatio = 1,
			frequency = 0.5,
			position = 1,
		})
		expect(spring:step(0.5)).to.equal(true)
	end)

	it("should return not complete when in motion", function()
		local spring = Spring.new({
			dampingRatio = 1,
			frequency = 0.5,
			position = 1,
		})
		spring:setGoal(100)
		expect(spring:step(0.5)).to.equal(false)
	end)

	describe("should eventaully complete when", function()
		local positionLimit = 1e-5
		it("spring is critically damped", function()
			local spring = Spring.new({
				dampingRatio = 1,
				frequency = 0.5,
				position = 1,
				__restingPositionLimit = positionLimit,
			})
			spring:setGoal(3)

			while not spring:step(0.5) do
			end

			expect(math.abs(spring:getValue() - 3) < positionLimit).to.equal(true)
		end)

		it("spring is over damped", function()
			local spring = Spring.new({
				dampingRatio = 10,
				frequency = 0.5,
				position = 1,
				__restingPositionLimit = positionLimit,
			})
			spring:setGoal(3)

			while not spring:step(0.5) do
			end

			expect(math.abs(spring:getValue() - 3) < positionLimit).to.equal(true)
		end)

		it("spring is under damped", function()
			local spring = Spring.new({
				dampingRatio = 0.1,
				frequency = 0.5,
				position = 1,
				__restingPositionLimit = positionLimit,
			})
			spring:setGoal(3)

			while not spring:step(0.5) do
			end

			expect(math.abs(spring:getValue() - 3) < positionLimit).to.equal(true)
		end)

		it("spring changes goal mid motion", function()
			local spring = Spring.new({
				dampingRatio = 0.1,
				frequency = 0.5,
				position = 1,
				__restingPositionLimit = positionLimit,
			})
			spring:setGoal(3)
			spring:step(10)
			spring:setGoal(1)

			while not spring:step(0.5) do
			end

			expect(math.abs(spring:getValue() - 1) < positionLimit).to.equal(true)
		end)
	end)

	it("should be able to restart motion after completion", function()
		local positionLimit = 1e-5
		local spring = Spring.new({
			dampingRatio = 1,
			frequency = 0.5,
			position = 1,
			__restingPositionLimit = positionLimit,
		})
		spring:setGoal(3)

		while not spring:step(0.5) do
		end

		expect(math.abs(spring:getValue() - 3) < positionLimit).to.equal(true)
		spring:setGoal(1)

		while not spring:step(0.5) do
		end

		expect(math.abs(spring:getValue() - 1) < positionLimit).to.equal(true)
	end)
end