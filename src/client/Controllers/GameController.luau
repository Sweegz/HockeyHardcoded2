local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Loaded = false
local Callbacks = {}

return {
	Start = function()
		task.spawn(function()
			while ReplicatedFirst:GetAttribute("ClientLoaded") ~= true do
				task.wait()
			end

			while ReplicatedFirst:GetAttribute("DataLoaded") ~= true do
				task.wait()
			end

			Loaded = true
			print("Loaded")
			for v5 = 1, #Callbacks do
				local v6 = Callbacks[v5]
				task.spawn(v6)
			end
			table.clear(Callbacks)
		end)
	end,
	OnGameLoaded = function(callback)
		if Loaded then
			return callback()
		else
			table.insert(Callbacks, callback)
			return
		end
	end,
}
