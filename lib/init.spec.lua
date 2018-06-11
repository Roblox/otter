return function()
	local Roto = require(script.Parent)

	it("should have all expected APIs", function()
		expect(Roto.Motion).to.be.a("table")
		expect(Roto.Spring).to.be.a("table")
	end)
end