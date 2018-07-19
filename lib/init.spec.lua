return function()
	local Otter = require(script.Parent)

	it("should load successfully", function()
		expect(Otter).to.be.a("table")
	end)
end