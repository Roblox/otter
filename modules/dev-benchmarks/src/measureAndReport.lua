--!strict
local function measureAndReport(fn: () -> (), stepCount: number)
	local start = os.clock()
	fn()
	local time = os.clock() - start
	print(string.format("%.3fms - %.3fµs", time * 1000, time * 1000000 / stepCount))
end

return measureAndReport
