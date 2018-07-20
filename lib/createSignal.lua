local function addToSet(set, addValue)
	local new = {}

	for value in pairs(set) do
		new[value] = true
	end

	new[addValue] = true

	return new
end

local function removeFromSet(set, removeValue)
	local new = {}

	for value in pairs(set) do
		if value ~= removeValue then
			new[value] = true
		end
	end

	return new
end

local function createSignal()
	local subscribers = {}

	local function subscribe(subscriber)
		subscribers = addToSet(subscribers, subscriber)

		local function disconnect()
			subscribers = removeFromSet(subscribers, subscriber)
		end

		return disconnect
	end

	local function fire(...)
		for subscriber in pairs(subscribers) do
			subscriber(...)
		end
	end

	return {
		subscribe = subscribe,
		fire = fire,
	}
end

return createSignal