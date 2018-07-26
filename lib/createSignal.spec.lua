return function()
	local createSignal = require(script.Parent.createSignal)

	local function createSpy(inner)
		local self = {
			callCount = 0,
			values = {},
			valuesLength = 0,
		}

		self.value = function(...)
			self.callCount = self.callCount + 1
			self.values = {...}
			self.valuesLength = select("#", ...)

			if inner ~= nil then
				return inner(...)
			end
		end

		self.assertCalledWith = function(_, ...)
			local len = select("#", ...)

			expect(self.valuesLength).to.equal(len)

			for i = 1, len do
				local expected = select(i, ...)
				expect(self.values[i]).to.equal(expected)
			end
		end

		setmetatable(self, {
			__index = function(_, key)
				error(("%q is not a valid member of spy"):format(key))
			end,
		})

		return self
	end

	it("should fire subscribers and disconnect them", function()
		local signal = createSignal()

		local spy = createSpy()
		local disconnect = signal:subscribe(spy.value)

		expect(spy.callCount).to.equal(0)

		local a = 1
		local b = {}
		local c = "hello"
		signal:fire(a, b, c)

		expect(spy.callCount).to.equal(1)
		spy:assertCalledWith(a, b, c)

		disconnect()

		signal:fire()

		expect(spy.callCount).to.equal(1)
	end)

	it("should handle multiple subscribers", function()
		local signal = createSignal()

		local spyA = createSpy()
		local spyB = createSpy()

		local disconnectA = signal:subscribe(spyA.value)
		local disconnectB = signal:subscribe(spyB.value)

		expect(spyA.callCount).to.equal(0)
		expect(spyB.callCount).to.equal(0)

		local a = {}
		local b = 67
		signal:fire(a, b)

		expect(spyA.callCount).to.equal(1)
		spyA:assertCalledWith(a, b)

		expect(spyB.callCount).to.equal(1)
		spyB:assertCalledWith(a, b)

		disconnectA()

		signal:fire(b, a)

		expect(spyA.callCount).to.equal(1)

		expect(spyB.callCount).to.equal(2)
		spyB:assertCalledWith(b, a)

		disconnectB()
	end)

	it("should stop firing a connection if disconnected mid-fire", function()
		local signal = createSignal()

		-- In this test, we'll connect two listeners that each try to disconnect
		-- the other. Because the order of listeners firing isn't defined, we
		-- have to be careful to handle either case.

		local disconnectA
		local disconnectB

		local spyA = createSpy(function()
			disconnectB()
		end)

		local spyB = createSpy(function()
			disconnectA()
		end)

		disconnectA = signal:subscribe(spyA.value)
		disconnectB = signal:subscribe(spyB.value)

		signal:fire()

		-- Exactly once listener should have been called.
		expect(spyA.callCount + spyB.callCount).to.equal(1)
	end)
end