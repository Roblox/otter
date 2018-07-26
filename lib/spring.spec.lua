local positionLimit = 1e-5
local velocityLimit = 1e-7

return function()
	local spring = require(script.Parent.spring)

	it("should have all expected APIs", function()
		expect(spring).to.be.a("function")

		local s = spring(1, {
			dampingRatio = 0.1,
			frequency = 10,
		})

		expect(s).to.be.a("table")
		expect(s.step).to.be.a("function")

		-- handle when spring lacks option table
		local s = spring(1)
	end)

	it("should handle being still correctly", function()
		local s = spring(1, {
			dampingRatio = 0.1,
			frequency = 10,
		})

		local state = s:step({
			value = 1,
			velocity = 0,
			complete = false,
		}, 1)

		expect(state.value).to.equal(1)
		expect(state.velocity).to.equal(0)
		expect(state.complete).to.equal(true)
	end)

	it("should return not complete when in motion", function()
		local s = spring(100, {
			dampingRatio = 0.1,
			frequency = 10,
		})

		local state = s:step({
			value = 1,
			velocity = 0,
			complete = false,
		}, 1)

		expect(state.value > 1).to.equal(true)
		expect(math.abs(state.velocity) > 0).to.equal(true)
		expect(state.complete).to.equal(false)
	end)

	describe("should eventaully complete when", function()
		it("is critically damped", function()
			local s = spring(3, {
				dampingRatio = 1,
				frequency = 0.5,
			})

			local state = {
				value = 1,
				velocity = 0,
				complete = false,
			}

			while not state.complete do
				state = s:step(state, 0.5)
			end

			expect(state.complete).to.equal(true)
			expect(math.abs(state.value - 3) < positionLimit).to.equal(true)
			expect(math.abs(state.velocity) < velocityLimit).to.equal(true)
		end)

		it("is over damped", function()
			local s = spring(3, {
				dampingRatio = 10,
				frequency = 0.5,
			})

			local state = {
				value = 1,
				velocity = 0,
				complete = false,
			}

			while not state.complete do
				state = s:step(state, 0.5)
			end

			expect(state.complete).to.equal(true)
			expect(math.abs(state.value - 3) < positionLimit).to.equal(true)
			expect(math.abs(state.velocity) < velocityLimit).to.equal(true)
		end)

		it("is under damped", function()
			local s = spring(3, {
				dampingRatio = 0.1,
				frequency = 0.5,
			})

			local state = {
				value = 1,
				velocity = 0,
				complete = false,
			}

			while not state.complete do
				state = s:step(state, 0.5)
			end

			expect(state.complete).to.equal(true)
			expect(math.abs(state.value - 3) < positionLimit).to.equal(true)
			expect(math.abs(state.velocity) < velocityLimit).to.equal(true)
		end)

		it("changes goal mid motion", function()
			local s = spring(3, {
				dampingRatio = 0.1,
				frequency = 0.5,
			})

			local state = {
				value = 1,
				velocity = 0,
				complete = false,
			}

			state = s:step(state, 5)

			expect(state.complete).to.equal(false)

			s = spring(0, {
				dampingRatio = 0.1,
				frequency = 0.5,
			})

			while not state.complete do
				state = s:step(state, 0.5)
			end

			expect(state.complete).to.equal(true)
			expect(math.abs(state.value) < positionLimit).to.equal(true)
			print(tostring(state.velocity))
			expect(math.abs(state.velocity) < velocityLimit).to.equal(true)
		end)
	end)

	it("should remain complete when completed", function()
			local s = spring(3, {
				dampingRatio = 1,
				frequency = 0.5,
			})

			local state = {
				value = 1,
				velocity = 0,
				complete = false,
			}

			while not state.complete do
				state = s:step(state, 0.5)
			end
			state = s:step(state, 0.5)

			expect(state.complete).to.equal(true)
			expect(math.abs(state.value - 3) < positionLimit).to.equal(true)
			expect(math.abs(state.velocity) < velocityLimit).to.equal(true)
	end)
end